CREATE DATABASE IF NOT EXISTS bd_aplicacion_movil
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE bd_aplicacion_movil;

CREATE TABLE usuario (
    id_usr INT AUTO_INCREMENT PRIMARY KEY,
    nom_usr VARCHAR(100) NOT NULL,
    mail VARCHAR(150) NOT NULL UNIQUE,
    pass VARCHAR(255) NOT NULL,
    dir_usr VARCHAR(200),
    tip_usu INT NOT NULL DEFAULT 1
);

CREATE TABLE blog (
    id_blog INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    `desc` TEXT,
    img VARCHAR(500),
    tags VARCHAR(255)
);

CREATE TABLE comentarios (
    id_com INT AUTO_INCREMENT PRIMARY KEY,
    comentario TEXT NOT NULL,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estatus INT NOT NULL DEFAULT 1,
    usr_id INT NOT NULL,
    blog_id INT NOT NULL,

    CONSTRAINT fk_comentario_usuario
        FOREIGN KEY (usr_id)
        REFERENCES usuario(id_usr),

    CONSTRAINT fk_comentario_blog
        FOREIGN KEY (blog_id)
        REFERENCES blog(id_blog)
);
INSERT INTO usuario
    (nom_usr, mail, pass, dir_usr, tip_usu)
VALUES
    ('Adriana Contreras', 'adriana@ejemplo.com',
     'HASH_DE_PRUEBA', 'Querétaro', 1),
    ('Carlos Pérez', 'carlos@ejemplo.com',
     'HASH_DE_PRUEBA', 'Querétaro', 2);

INSERT INTO blog (titulo, `desc`, img, tags)
VALUES
    (
      'Construyendo aplicaciones con Flutter',
      'Una introducción al desarrollo móvil con Dart.',
      'https://picsum.photos/800/400?random=1',
      'Flutter,Dart'
    ),
    (
      'Introducción a la inteligencia artificial',
      'Conceptos fundamentales de inteligencia artificial.',
      'https://picsum.photos/800/400?random=2',
      'IA,tecnología'
    );

INSERT INTO comentarios
    (comentario, estatus, usr_id, blog_id)
VALUES
    ('Muy útil la explicación de Flutter.', 1, 1, 1),
    ('Me gustaría ver más ejemplos.', 1, 2, 1),
    ('Buen artículo de introducción.', 1, 1, 2);