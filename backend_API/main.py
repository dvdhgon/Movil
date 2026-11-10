import shutil
import uuid
from contextlib import asynccontextmanager
from pathlib import Path

from database import Base, SessionLocal, engine, obtener_sesion
from fastapi import Depends, FastAPI, File, Form, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from models import Blog, Usuario
from pwdlib import PasswordHash
from schemas import (
    LoginRequest,
    UsuarioActualizar,
    UsuarioCrear,
    UsuarioRespuesta,
)
from sqlalchemy import select
from sqlalchemy.orm import Session

password_hash = PasswordHash.recommended()


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Crear automáticamente las tablas en la base de datos si no existen
    Base.metadata.create_all(bind=engine)
    yield


app = FastAPI(
    title="API de aplicación móvil",
    lifespan=lifespan,
)

# Directorio de almacenamiento de imágenes
UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(exist_ok=True)
app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

# Configuración CORS para comunicación con Flutter y Web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def inicio():
    return {"mensaje": "API funcionando correctamente"}


# ==========================================
# AUTENTICACIÓN / LOGIN
# ==========================================
@app.post("/login", response_model=UsuarioRespuesta)
def iniciar_sesion(
    datos: LoginRequest,
    db: Session = Depends(obtener_sesion),
):
    correo = datos.mail.strip().lower()
    usuario = db.scalar(select(Usuario).where(Usuario.mail == correo))

    if usuario is None:
        raise HTTPException(
            status_code=401,
            detail="Correo o contraseña incorrectos",
        )

    clave_guardada = getattr(usuario, "pass_hash", getattr(usuario, "pass_usr", ""))

    es_valida = False
    try:
        es_valida = password_hash.verify(datos.password, clave_guardada)
    except Exception:
        es_valida = datos.password == clave_guardada

    if not es_valida:
        raise HTTPException(
            status_code=401,
            detail="Correo o contraseña incorrectos",
        )

    return usuario


# ==========================================
# REGISTRO Y GESTIÓN DE USUARIOS
# ==========================================
@app.post("/usuarios", response_model=UsuarioRespuesta)
def crear_usuario(
    usuario_in: UsuarioCrear,
    db: Session = Depends(obtener_sesion),
):
    correo = usuario_in.mail.strip().lower()
    existente = db.scalar(select(Usuario).where(Usuario.mail == correo))
    if existente:
        raise HTTPException(status_code=400, detail="El correo ya está registrado")

    # Todo registro nuevo se asigna automáticamente como Usuario Normal (tip_usu = 2)
    nuevo_usuario = Usuario(
        nom_usr=usuario_in.nom_usr,
        mail=correo,
        pass_hash=password_hash.hash(usuario_in.password),
        dir_usr=usuario_in.dir_usr,
        tip_usu=2,  # 2: Usuario normal
    )
    db.add(nuevo_usuario)
    db.commit()
    db.refresh(nuevo_usuario)
    return nuevo_usuario


@app.get("/usuarios", response_model=list[UsuarioRespuesta])
def listar_usuarios(db: Session = Depends(obtener_sesion)):
    return db.scalars(select(Usuario)).all()


@app.get("/usuarios/{id_usuario}", response_model=UsuarioRespuesta)
def obtener_usuario(id_usuario: int, db: Session = Depends(obtener_sesion)):
    usuario = db.get(Usuario, id_usuario)
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return usuario


@app.put("/usuarios/{id_usuario}", response_model=UsuarioRespuesta)
def actualizar_usuario(
    id_usuario: int,
    usuario_in: UsuarioActualizar,
    db: Session = Depends(obtener_sesion),
):
    usuario = db.get(Usuario, id_usuario)
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    if usuario_in.nom_usr is not None:
        usuario.nom_usr = usuario_in.nom_usr
    if usuario_in.dir_usr is not None:
        usuario.dir_usr = usuario_in.dir_usr
    if usuario_in.tip_usu is not None:
        usuario.tip_usu = usuario_in.tip_usu
    if usuario_in.password is not None and usuario_in.password.strip():
        usuario.pass_hash = password_hash.hash(usuario_in.password)

    db.commit()
    db.refresh(usuario)
    return usuario


@app.delete("/usuarios/{id_usuario}")
def eliminar_usuario(id_usuario: int, db: Session = Depends(obtener_sesion)):
    usuario = db.get(Usuario, id_usuario)
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    db.delete(usuario)
    db.commit()
    return {"mensaje": "Usuario eliminado correctamente"}


# ==========================================
# PUBLICACIONES / BLOGS
# ==========================================
@app.get("/blogs")
def listar_blogs(db: Session = Depends(obtener_sesion)):
    return db.scalars(select(Blog)).all()


# ==========================================
# PUBLICACIONES / BLOGS
# ==========================================
@app.get("/blogs")
def listar_blogs(db: Session = Depends(obtener_sesion)):
    return db.scalars(select(Blog)).all()

@app.post("/blogs")
async def crear_blog(
    titulo: str = Form(...),
    contenido: str = Form(None),
    descripcion: str = Form(None),
    id_usr: int = Form(None),
    usr_id: int = Form(None),
    id_autor: int = Form(None),  # <-- AÑADIDO PARA EVITAR ERROR 500
    imagen: UploadFile = File(None),
    img: UploadFile = File(None),
    db: Session = Depends(obtener_sesion),
):
    # Si Flutter manda contenido vacío, evitamos el error de NULL
    texto_final = contenido or descripcion or "Sin contenido"
    
    # Buscamos el ID en cualquiera de los formatos que mande Flutter
    usuario_id_final = id_autor or id_usr or usr_id or 1
    archivo_imagen = imagen or img

    ruta_imagen = ""
    if archivo_imagen and archivo_imagen.filename:
        extension = Path(archivo_imagen.filename).suffix
        nombre_archivo = f"{uuid.uuid4()}{extension}"
        destino = UPLOAD_DIR / nombre_archivo
        with open(destino, "wb") as buffer:
            shutil.copyfileobj(archivo_imagen.file, buffer)
        ruta_imagen = f"/uploads/{nombre_archivo}"

    nuevo_blog = Blog()
    nuevo_blog.titulo = titulo

    if hasattr(nuevo_blog, 'contenido'):
        nuevo_blog.contenido = texto_final
    if hasattr(nuevo_blog, 'descripcion'):
        nuevo_blog.descripcion = texto_final
        
    # <-- FIX CLAVE: Asignamos correctamente el autor a la tabla MySQL -->
    if hasattr(nuevo_blog, 'id_autor'):
        nuevo_blog.id_autor = usuario_id_final
    elif hasattr(nuevo_blog, 'id_usr'):
        nuevo_blog.id_usr = usuario_id_final
    elif hasattr(nuevo_blog, 'usr_id'):
        nuevo_blog.usr_id = usuario_id_final

    if hasattr(nuevo_blog, 'imagen'):
        nuevo_blog.imagen = ruta_imagen
    if hasattr(nuevo_blog, 'img'):
        nuevo_blog.img = ruta_imagen

    db.add(nuevo_blog)
    db.commit()
    db.refresh(nuevo_blog)
    return nuevo_blog