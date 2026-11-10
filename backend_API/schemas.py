from pydantic import BaseModel, EmailStr
from typing import Optional

class LoginRequest(BaseModel):
    mail: str
    password: str

class UsuarioCrear(BaseModel):
    nom_usr: str
    mail: str
    password: str
    dir_usr: Optional[str] = None
    # tip_usu eliminado para no permitir seleccionar tipo de usuario al registrarse

class UsuarioActualizar(BaseModel):
    nom_usr: Optional[str] = None
    dir_usr: Optional[str] = None
    tip_usu: Optional[int] = None
    password: Optional[str] = None

class UsuarioRespuesta(BaseModel):
    id_usr: int
    nom_usr: str
    mail: str
    dir_usr: Optional[str] = None
    tip_usu: int

    class Config:
        from_attributes = True