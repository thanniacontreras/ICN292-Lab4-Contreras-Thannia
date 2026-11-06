-- =============================================================
-- 1. BASE DE DATOS
-- =============================================================

DROP DATABASE IF EXISTS austzal;

CREATE DATABASE austzal
DEFAULT CHARACTER SET utf8mb4;

USE austzal;


-- =============================================================
-- 2. CREACION TABLAS
-- =============================================================

CREATE TABLE autores (
    id_autor INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(80) NOT NULL,
    pais VARCHAR(60),
    genero ENUM(
        'Cómic',
        'Ensayo',
        'Infantil',
        'Novela',
        'Poesía'
    ) NOT NULL,

    CONSTRAINT pk_autores
        PRIMARY KEY (id_autor)
) ENGINE = InnoDB;


CREATE TABLE colecciones (
    id_coleccion INT UNSIGNED NOT NULL AUTO_INCREMENT,
    titulo VARCHAR(120) NOT NULL,
    fecha_publicacion DATE NOT NULL,

    CONSTRAINT pk_colecciones
        PRIMARY KEY (id_coleccion),

    CONSTRAINT uq_colecciones_titulo
        UNIQUE (titulo)
) ENGINE = InnoDB;


CREATE TABLE libros (
    id_libro INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_autor INT UNSIGNED NOT NULL,
    id_coleccion INT UNSIGNED DEFAULT NULL,
    titulo VARCHAR(120) NOT NULL,
    paginas SMALLINT UNSIGNED,
    ejemplares_vendidos INT UNSIGNED,
    anio YEAR,

    CONSTRAINT pk_libros
        PRIMARY KEY (id_libro),

    CONSTRAINT uq_libros_titulo
        UNIQUE (titulo),

    CONSTRAINT fk_libros_autores
        FOREIGN KEY (id_autor)
        REFERENCES autores (id_autor),

    CONSTRAINT fk_libros_colecciones
        FOREIGN KEY (id_coleccion)
        REFERENCES colecciones (id_coleccion)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE = InnoDB;


CREATE TABLE pagos (
    id_pago INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_autor INT UNSIGNED NOT NULL,
    fecha_pago DATE NOT NULL,
    monto DECIMAL(12,2) NOT NULL,

    CONSTRAINT pk_pagos
        PRIMARY KEY (id_pago),

    CONSTRAINT fk_pagos_autores
        FOREIGN KEY (id_autor)
        REFERENCES autores (id_autor)
) ENGINE = InnoDB;


-- =============================================================
-- 3. CARGA AUTORES
-- =============================================================

INSERT INTO autores (
    nombre,
    pais,
    genero
)

SELECT
    'Elena Pizarro',
    'Chile',
    'Novela'

UNION ALL

SELECT
    'Harold Finch',
    'Inglaterra',
    'Ensayo'

UNION ALL

SELECT
    'Rodrigo Bahamonde',
    'Chile',
    'Poesía'

UNION ALL

SELECT
    'Valentina Correa',
    'Argentina',
    'Infantil'

UNION ALL

SELECT
    'Nora Keller',
    'Estados Unidos',
    'Novela'

UNION ALL

SELECT
    'Kenji Arakawa',
    NULL,
    'Cómic';


-- =============================================================
-- 4. CARGA DE LIBROS
-- =============================================================

-- Los libros se relacionan con los autores mediante el nombre.
-- De esta forma no es necesario escribir directamente los IDs.

INSERT INTO libros (
    id_autor,
    titulo,
    paginas,
    ejemplares_vendidos,
    anio
)

SELECT
    a.id_autor,
    datos.titulo,
    datos.paginas,
    datos.ventas,
    datos.anio

FROM autores AS a

INNER JOIN (

    SELECT
        'Elena Pizarro' AS autor,
        'Cielo de Enero' AS titulo,
        210 AS paginas,
        1500 AS ventas,
        2024 AS anio

    UNION ALL

    SELECT
        'Elena Pizarro',
        'Marea Baja',
        185,
        800,
        2023

    UNION ALL

    SELECT
        'Elena Pizarro',
        'El Norte',
        200,
        2200,
        2024

    UNION ALL

    SELECT
        'Harold Finch',
        'Estrellas que Caen',
        240,
        3000,
        2022

    UNION ALL

    SELECT
        'Harold Finch',
        'Máquinas',
        215,
        450,
        2024

    UNION ALL

    SELECT
        'Rodrigo Bahamonde',
        'Luz Artificial',
        300,
        1200,
        2024

    UNION ALL

    SELECT
        'Rodrigo Bahamonde',
        'Ruido Blanco',
        280,
        600,
        2023

    UNION ALL

    SELECT
        'Valentina Correa',
        'El Barrio de Lila',
        190,
        5000,
        2024

    UNION ALL

    SELECT
        'Valentina Correa',
        'Antes del Amanecer',
        205,
        2700,
        2024

    UNION ALL

    SELECT
        'Valentina Correa',
        'La Calle 8',
        175,
        900,
        2023

    UNION ALL

    SELECT
        'Nora Keller',
        'Flor de Hierro',
        195,
        4100,
        2024

    UNION ALL

    SELECT
        'Nora Keller',
        'Hora Dorada',
        220,
        1800,
        2022

) AS datos
    ON datos.autor = a.nombre;


-- =============================================================
-- COMPROBAR LA CARGA DE LOS DATOS
-- =============================================================

SELECT *
FROM autores;

SELECT *
FROM libros;

SELECT
    COUNT(*) AS cantidad_autores
FROM autores;

SELECT
    COUNT(*) AS cantidad_libros
FROM libros;


-- =============================================================
-- C1
-- =============================================================

SELECT
    a.nombre,
    a.genero
FROM autores AS a
WHERE COALESCE(
    a.pais,
    'SIN PAIS'
) <> 'Chile'
ORDER BY
    a.nombre ASC;

-- =============================================================
-- C2
-- =============================================================

SELECT
    l.titulo,
    l.paginas
FROM libros AS l
WHERE l.paginas >= 190
  AND l.paginas <= 220
ORDER BY
    l.paginas ASC,
    l.titulo ASC;


-- =============================================================
-- C3
-- =============================================================

SELECT
    COUNT(l.id_libro)
        AS numero_libros,
    SUM(l.ejemplares_vendidos)
        AS total_ejemplares_vendidos,
    ROUND(
        AVG(l.paginas),
        4
    ) AS promedio_paginas,
    MIN(l.anio)
        AS anio_mas_antiguo,
    MAX(l.ejemplares_vendidos)
        AS mayor_venta_libro
FROM libros AS l;


-- =============================================================
-- C4
-- =============================================================

SELECT
    a.genero
FROM autores AS a
GROUP BY
    a.genero
ORDER BY
    CAST(a.genero AS CHAR)
    COLLATE utf8mb4_spanish_ci;

-- =============================================================
-- C5
-- =============================================================

SELECT
    a.nombre,
    SUM(
        CASE
            WHEN l.anio = 2024
            THEN 1
            ELSE 0
        END
    ) AS libros_publicados_2024
FROM autores AS a
INNER JOIN libros AS l
    ON l.id_autor = a.id_autor
GROUP BY
    a.id_autor,
    a.nombre
HAVING SUM(
    CASE
        WHEN l.anio = 2024
        THEN 1
        ELSE 0
    END
) >= 2
ORDER BY
    a.nombre ASC;


-- =============================================================
-- C6
-- =============================================================

SELECT
    l.titulo,
    l.ejemplares_vendidos
FROM libros AS l
WHERE l.anio = 2024
  AND l.ejemplares_vendidos > 2000
ORDER BY
    l.ejemplares_vendidos DESC,
    l.titulo ASC
LIMIT 3;


-- =============================================================
-- C7
-- =============================================================
-- PASO 1
INSERT INTO libros (
    id_autor,
    titulo,
    paginas,
    ejemplares_vendidos,
    anio
)
SELECT
    id_autor,
    'Papel Hojado',
    260,
    50,
    2024
FROM autores
WHERE nombre = 'Rodrigo Bahamonde';


-- PASO 2

SET @libro_temporal := LAST_INSERT_ID();


-- PASO 3
SELECT *
FROM libros
WHERE id_libro = @libro_temporal;

-- PASO 4

DELETE FROM libros
WHERE id_libro = @libro_temporal;


-- PASO 5

SELECT *
FROM libros
WHERE id_libro = @libro_temporal;

-- =============================================================
-- C8
-- =============================================================

-- PASO 1

SELECT
    titulo,
    ejemplares_vendidos
FROM libros
WHERE titulo = 'Cielo de Enero';


-- PASO 2

UPDATE libros
SET ejemplares_vendidos =
    ejemplares_vendidos + 100
WHERE titulo = 'Cielo de Enero';


-- PASO 3

SELECT
    titulo,
    ejemplares_vendidos
FROM libros
WHERE titulo = 'Cielo de Enero';



-- =============================================================
-- C9
-- =============================================================

-- PASO 1

INSERT INTO colecciones (
    titulo,
    fecha_publicacion
)
VALUES
    (
        'Narrativas Australes',
        '2024-03-15'
    ),
    (
        'Horizontes y Descubrimientos',
        '2024-08-20'
    );


-- PASO 2

UPDATE libros AS l
INNER JOIN colecciones AS c
    ON c.titulo = 'Narrativas Australes'
SET
    l.id_coleccion = c.id_coleccion
WHERE l.titulo IN (
    'Cielo de Enero',
    'Marea Baja',
    'El Norte',
    'Estrellas que Caen',
    'Máquinas',
    'Luz Artificial'
);


-- PASO 3

UPDATE libros AS l
INNER JOIN colecciones AS c
    ON c.titulo = 'Horizontes y Descubrimientos'
SET
    l.id_coleccion = c.id_coleccion
WHERE l.titulo IN (
    'Ruido Blanco',
    'El Barrio de Lila',
    'Antes del Amanecer',
    'La Calle 8',
    'Flor de Hierro',
    'Hora Dorada'
);


-- PASO 4

SELECT
    l.titulo
        AS titulo_libro,
    c.titulo
        AS titulo_coleccion,
    DATE_FORMAT(
        c.fecha_publicacion,
        '%d-%m-%Y'
    ) AS fecha_publicacion
FROM libros AS l
INNER JOIN colecciones AS c
    ON c.id_coleccion = l.id_coleccion
ORDER BY
    c.titulo ASC,
    l.titulo ASC;

-- =============================================================
-- C10
-- =============================================================

INSERT INTO pagos (
    id_autor,
    fecha_pago,
    monto
)
SELECT
    a.id_autor,
    datos_pago.fecha_pago,
    datos_pago.monto
FROM autores AS a
INNER JOIN (
    SELECT
        'Elena Pizarro' AS autor,
        DATE('2026-09-05') AS fecha_pago,
        1250000.00 AS monto
    UNION ALL
    SELECT
        'Elena Pizarro',
        DATE('2026-10-05'),
        875000.00
    UNION ALL
    SELECT
        'Valentina Correa',
        DATE('2026-10-15'),
        2100000.00
) AS datos_pago
    ON datos_pago.autor = a.nombre;


-- =============================================================
-- C11
-- =============================================================

SELECT
    a.nombre
        AS autor,
    DATE_FORMAT(
        p.fecha_pago,
        '%d-%m-%Y'
    ) AS fecha_pago,
    p.monto
FROM pagos AS p
INNER JOIN autores AS a
    ON a.id_autor = p.id_autor
ORDER BY
    p.fecha_pago ASC,
    a.nombre ASC;


-- =============================================================
-- C12
-- =============================================================

SELECT
    a.nombre
        AS autor,
    SUM(p.monto)
        AS total_pagado
FROM pagos AS p
INNER JOIN autores AS a
    ON a.id_autor = p.id_autor
GROUP BY
    a.id_autor,
    a.nombre
ORDER BY
    total_pagado DESC,
    a.nombre ASC;

