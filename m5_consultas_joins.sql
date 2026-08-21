USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'Ventas_Tech_DB')
BEGIN
    ALTER DATABASE Ventas_Tech_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Ventas_Tech_DB;
END
GO

CREATE DATABASE Ventas_Tech_DB;
GO

USE Ventas_Tech_DB;
GO

DROP TABLE IF EXISTS ventas;
    DROP TABLE IF EXISTS productos; 
    DROP TABLE IF EXISTS categorias;
    DROP TABLE IF EXISTS clientes;
    go

CREATE TABLE categorias(
    id_categoria INT IDENTITY(1,1) PRIMARY KEY,
    nombre_categoria VARCHAR(50) NOT NULL,
    descripcion VARCHAR(200) 
);

CREATE TABLE clientes(
    id_clientes INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    ciudad VARCHAR(50),
    fecha_registro DATE NOT NULL
);

CREATE TABLE productos(
    id_producto INT IDENTITY(1,1) PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    id_categoria INT,
    precio DECIMAL (10,2) NOT NULL,
    stock INT DEFAULT 0,
    activo TINYINT DEFAULT 1,
    CONSTRAINT FK_productos_categorias FOREIGN KEY(id_categoria) REFERENCES categorias(id_categoria)
); 

CREATE TABLE ventas(
    id_venta INT IDENTITY(1,1) PRIMARY KEY,
    id_cliente INT,
    id_producto INT,
    cantidad INT NOT NULL, 
    precio_unitario DECIMAL(10,2) NOT NULL,
    fecha_venta DATE NOT NULL,
    CONSTRAINT FK_ventas_clientes FOREIGN KEY (id_cliente) REFERENCES clientes(id_clientes),
    CONSTRAINT FK_ventas_productos FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);
GO

INSERT INTO categorias (nombre_categoria, descripcion) VALUES 
('Computación', 'Laptops, PCs y monitores'),
('Accesorios', 'Periféricos y complementos'),
('Audio', 'Auriculares y parlantes'),
('Almacenamiento', 'Discos y memorias');

INSERT INTO clientes (nombre, email, ciudad, fecha_registro) VALUES 
('María López',   'maria@mail.com',   'Buenos Aires', '2024-01-05'),
('Carlos Ruiz',   'carlos@mail.com',  'Córdoba',      '2024-01-10'),
('Ana Gómez',     'ana@mail.com',     'Rosario',      '2024-02-01'),
('Pedro Sanz',    'pedro@mail.com',   'Mendoza',      '2024-02-15'),
('Laura Torres',  'laura@mail.com',   'Tucumán',      '2024-03-01');

INSERT INTO productos (nombre_producto, id_categoria, precio, stock, activo) VALUES 
('Laptop Pro 15',       1, 1200.00, 15, 1),
('Mouse Inalámbrico',   2,   28.00, 80, 1),
('Monitor 4K 27"',      1,  450.00, 12, 1),
('Auriculares BT Pro',  3,  120.00, 35, 1),
('SSD Externo 1TB',     4,  130.00, 18, 1),
('Teclado Mecánico',    2,   95.00, 40, 1);

INSERT INTO ventas (id_cliente, id_producto, cantidad, precio_unitario, fecha_venta) VALUES 
(1, 1, 2, 1200.00, '2024-03-05'),
(2, 2, 5,   28.00, '2024-03-06'),
(3, 3, 1,  450.00, '2024-03-07'),
(1, 4, 2,  120.00, '2024-03-08'),
(4, 5, 3,  130.00, '2024-03-10'),
(2, 6, 4,   95.00, '2024-03-11'),
(5, 1, 1, 1200.00, '2024-03-12'),
(3, 2, 8,   28.00, '2024-03-13'),
(4, 4, 1,  120.00, '2024-03-14'),
(5, 3, 2,  450.00, '2024-03-15');
GO

SELECT * FROM categorias;
SELECT * FROM clientes;
SELECT * FROM productos;
SELECT * FROM ventas;

--M5 consultas-- 
--ventas, clientes, productos y territorios-- 

--Consulta 1-- 

SELECT v.fecha_venta, c.nombre as [nombre del cliente], categorias.descripcion as segmento, c.ciudad as región, p.nombre_producto as [nombre del producto],
categorias.nombre_categoria as categoria, v.cantidad, v.precio_unitario, (cantidad * precio_unitario) as [total de venta], '' AS canal 
FROM ventas v 
INNER JOIN clientes c
     ON c.id_clientes = v.id_cliente
INNER JOIN productos p
     ON p.id_producto = v.id_producto
INNER JOIN categorias 
     ON categorias.id_categoria = p.id_categoria;

--Consulta 2-- 
SELECT c.nombre, c.email, c.fecha_registro 
FROM clientes c
LEFT JOIN ventas v 
     ON c.id_clientes = v.id_cliente
     WHERE v.id_cliente IS NULL;

--Consulta 3-- 
SELECT p.nombre_producto, categorias.nombre_categoria as [categoria],v.precio_unitario as precio
FROM productos p
LEFT JOIN ventas v
    ON p.id_producto = v.id_producto
INNER JOIN categorias
    ON p.id_categoria = categorias.id_categoria
    WHERE v.id_producto IS NULL;

--Consulta 4--
WITH total_por_canal AS (
    SELECT 
        'Online' AS canal,
        (cantidad * precio_unitario) AS total_venta
    FROM ventas
    UNION ALL
    SELECT 
        'Presencial' AS canal,
       (cantidad * precio_unitario) AS total_venta
    FROM ventas)
SELECT 
    canal,
    SUM(total_venta) AS total_general
FROM total_por_canal
GROUP BY canal;