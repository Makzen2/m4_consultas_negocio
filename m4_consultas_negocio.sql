
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

-- M4 CONSULTAS--

-- Consulta 1

SELECT SUM(cantidad * precio_unitario) as [total facturado], 
COUNT(id_venta) as [total pedidos],
SUM(cantidad * precio_unitario) / COUNT(id_venta) as [ticket promedio],
month(fecha_venta) as [mes]
FROM ventas
group by month(fecha_venta);

-- Consulta 2
SELECT TOP 5 
    id_producto,
    SUM(cantidad) AS [unidades vendidas],
    SUM(cantidad * precio_unitario) AS [total facturado]
FROM ventas
GROUP BY id_producto
ORDER BY [total facturado] DESC;

-- Consulta 3
SELECT 
    id_cliente, 
    COUNT(id_venta) AS [cantidad pedidos], 
    SUM(cantidad * precio_unitario) AS [total gastado]
FROM ventas
GROUP BY id_cliente
HAVING COUNT(id_venta) > 1;

-- Consulta 4
WITH ventas_mensuales AS (
    SELECT 
        MONTH(fecha_venta) AS mes, 
        SUM(cantidad * precio_unitario) AS [total facturado]
    FROM ventas
    GROUP BY MONTH(fecha_venta)
)
SELECT 
    [mes],
    [total facturado],
    CASE 
        WHEN [total facturado] > AVG([total facturado]) OVER () THEN 'Por encima'
        ELSE 'Por debajo'
    END AS [rendimiento]
FROM ventas_mensuales;

--Hallazgos---
-- El Producto que mas se vendio este mes fue el mouse inalambrico con un total de 13 unidades--
-- Todos los clientes compraron mas de 1 vez--
--el ticket promedio es 222.206896

