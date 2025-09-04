# 🏪 Gestión de Inventario para una Tienda de Tecnología




📌 Contexto del Problema
La tienda TechZone es un negocio dedicado a la venta de productos tecnológicos, desde laptops y teléfonos hasta accesorios y componentes electrónicos. Con el crecimiento del comercio digital y la alta demanda de dispositivos electrónicos, la empresa ha notado la necesidad de mejorar la gestión de su inventario y ventas. Hasta ahora, han llevado el control de productos y transacciones en hojas de cálculo, lo que ha generado problemas como:

🔹 Errores en el control de stock: No saben con certeza qué productos están por agotarse, lo que ha llevado a problemas de desabastecimiento o acumulación innecesaria de productos en bodega.

🔹 Dificultades en el seguimiento de ventas: No cuentan con un sistema eficiente para analizar qué productos se venden más, en qué períodos del año hay mayor demanda o quiénes son sus clientes más frecuentes.

🔹 Gestión manual de proveedores: Los pedidos a proveedores se han realizado sin un historial claro de compras y ventas, dificultando la negociación de mejores precios y la planificación del abastecimiento.

🔹 Falta de automatización en el registro de compras: Cada vez que un cliente realiza una compra, los empleados deben registrar manualmente los productos vendidos y actualizar el inventario, lo que consume tiempo y es propenso a errores.

Para solucionar estos problemas, TechZone ha decidido implementar una base de datos en PostgreSQL que le permita gestionar de manera eficiente su inventario, las ventas, los clientes y los proveedores.





📋 Especificaciones del Sistema
La empresa necesita un sistema que registre todos los productos disponibles en la tienda, clasificándolos por categoría y manteniendo un seguimiento de la cantidad en stock. Cada producto tiene un proveedor asignado, por lo que también es fundamental llevar un registro de los proveedores y los productos que suministran.

Cuando un cliente realiza una compra, el sistema debe registrar la venta y actualizar automáticamente el inventario, asegurando que no se vendan productos que ya están agotados. Además, la tienda quiere identificar qué productos se venden más, qué clientes compran con mayor frecuencia y cuánto se ha generado en ventas en un período determinado.



El nuevo sistema deberá cumplir con las siguientes funcionalidades:

	1️⃣ Registro de Productos: Cada producto debe incluir su nombre, categoría, precio, stock disponible y proveedor.

	2️⃣ Registro de Clientes: Se debe almacenar la información de cada cliente, incluyendo nombre, correo electrónico y número de teléfono.

	3️⃣ Registro de Ventas: Cada venta debe incluir qué productos fueron vendidos, en qué cantidad y a qué cliente.

	4️⃣ Registro de Proveedores: La tienda obtiene productos de diferentes proveedores, por lo que es necesario almacenar información sobre cada uno.

	5️⃣ Consultas avanzadas: Se requiere la capacidad de analizar datos clave como productos más vendidos, ingresos por proveedor y clientes más frecuentes.

	6️⃣ Procedimiento almacenado con transacciones: Para asegurar que no se vendan productos sin stock, el sistema debe validar la disponibilidad de inventario antes de completar una venta.




# Resultado esperado

📌 Entregables del Examen
Los estudiantes deben entregar un repositorio en GitHub, con su hash del último commit, con los siguientes archivos:

## 📄 1. Modelo E-R (modelo_er.png o modelo_er.jpg)
Un diagrama Entidad-Relación (E-R) con entidades, relaciones y cardinalidades bien definidas.
El modelo debe estar normalizado hasta la 3FN para evitar redundancias.
![1 Modelo E-R](https://github.com/user-attachments/assets/2007b381-570a-458e-b846-f5490ebdfd3f)


## 📄 2. Estructura de la Base de Datos (db.sql)
Archivo SQL con la creación de todas las tablas.
Uso de claves primarias y foráneas para asegurar integridad referencial.
Aplicación de restricciones (NOT NULL, CHECK, UNIQUE).

```sql

===========SCRIPT DE CREACION DE LA BASE DE DATOS Y TABLAS============
================================DML===================================

CREATE DATABASE IF NOT EXIST examen_juanes;
USE examen_juanes;

CREATE TABLE IF NOT EXISTS productos (
  id SERIAL PRIMARY KEY,
  nombre TEXT NOT NULL,
  categoria TEXT NOT NULL,
  precio NUMERIC(12,2) NOT NULL CHECK (precio >= 0),
  stock INTEGER NOT NULL CHECK (stock >= 0),
  proveedor_id INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS clientes (
  id SERIAL PRIMARY KEY,
  nombre TEXT NOT NULL,
  correo TEXT NOT NULL UNIQUE,
  telefono TEXT,
  estado TEXT NOT NULL DEFAULT 'activo' CHECK (estado IN ('activo','inactivo'))
);

CREATE TABLE IF NOT EXISTS proveedores (
  id SERIAL PRIMARY KEY,
  nombre TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS ventas (
  id SERIAL PRIMARY KEY,
  cliente_id INTEGER NOT NULL REFERENCES clientes(id),
  fecha TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ventas_detalle (
  id SERIAL PRIMARY KEY,
  venta_id INTEGER NOT NULL REFERENCES ventas(id) ON DELETE CASCADE,
  producto_id INTEGER NOT NULL REFERENCES productos(id),
  cantidad INTEGER NOT NULL CHECK (cantidad > 0),
  precio_unitario NUMERIC(12,2) NOT NULL CHECK (precio_unitario >= 0)
);

-- Tablas de apoyo
CREATE TABLE IF NOT EXISTS historial_precios (
  id BIGSERIAL PRIMARY KEY,
  producto_id INTEGER NOT NULL REFERENCES productos(id),
  precio_anterior NUMERIC(12,2) NOT NULL,
  precio_nuevo NUMERIC(12,2) NOT NULL,
  cambiado_en TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS auditoria_ventas (
  id BIGSERIAL PRIMARY KEY,
  venta_id INTEGER NOT NULL REFERENCES ventas(id) ON DELETE CASCADE,
  usuario TEXT NOT NULL,
  registrado_en TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS alertas_stock (
  id BIGSERIAL PRIMARY KEY,
  producto_id INTEGER NOT NULL REFERENCES productos(id),
  nombre_producto TEXT NOT NULL,
  mensaje TEXT NOT NULL,
  generado_en TIMESTAMP NOT NULL DEFAULT NOW()
);
```


## 📄 3. Inserción de Datos (insert.sql)
Cada entidad debe contener al menos 15 registros.
Datos representativos y realistas.

```sql
===========SCRIPT PARA INSERTAR DATOS DE PRUEBA EN LA DB==============
================================DDL===================================

INSERT INTO proveedores (nombre) VALUES
('Proveedor Global S.A.'),
('Importadora del Norte'),
('Tech Supplies Inc.'),
('Distribuciones López'),
('Comercial Eléctrica Martínez');


INSERT INTO productos (nombre, categoria, precio, stock, proveedor_id) VALUES
('Laptop HP 15"', 'Electrónica', 750.00, 20, 1),
('Mouse Inalámbrico Logitech', 'Electrónica', 25.50, 100, 2),
('Teclado Mecánico Redragon', 'Electrónica', 55.00, 50, 2),
('Monitor Samsung 24"', 'Electrónica', 130.00, 30, 1),
('Disco Duro Externo 1TB', 'Almacenamiento', 70.00, 45, 3),
('Memoria USB 64GB', 'Almacenamiento', 15.99, 150, 3),
('Router TP-Link', 'Redes', 45.00, 35, 4),
('Cable HDMI 2m', 'Accesorios', 10.00, 200, 5),
('Smartphone Samsung A24', 'Telefonía', 220.00, 25, 1),
('Impresora Epson EcoTank', 'Impresoras', 180.00, 12, 4),
('Toner HP 85A', 'Consumibles', 65.00, 60, 2),
('Tablet Lenovo 10"', 'Electrónica', 150.00, 18, 1),
('Webcam Full HD', 'Accesorios', 35.00, 40, 5),
('Micrófono USB', 'Accesorios', 28.00, 55, 5),
('Auriculares Bluetooth', 'Accesorios', 60.00, 70, 3);


INSERT INTO clientes (nombre, correo, telefono, estado) VALUES
('María González', 'maria.gonzalez@example.com', '123456789', 'activo'),
('Carlos Pérez', 'carlos.perez@example.com', '987654321', 'activo'),
('Ana Torres', 'ana.torres@example.com', '1122334455', 'inactivo'),
('Luis Fernández', 'luis.fernandez@example.com', '6677889900', 'activo'),
('Carmen Ramírez', 'carmen.ramirez@example.com', '5566778899', 'activo'),
('José Castillo', 'jose.castillo@example.com', '4433221100', 'activo'),
('Lucía Méndez', 'lucia.mendez@example.com', NULL, 'inactivo'),
('Miguel Díaz', 'miguel.diaz@example.com', '123123123', 'activo'),
('Paula Rivas', 'paula.rivas@example.com', '321321321', 'activo'),
('Andrés Salinas', 'andres.salinas@example.com', NULL, 'activo');


INSERT INTO ventas (cliente_id, fecha) VALUES
(1, '2025-09-04 09:15:00'),
(2, '2025-09-04 09:20:00'),
(4, '2025-09-04 09:30:00'),
(5, '2025-09-04 09:40:00'),
(6, '2025-09-04 09:45:00'),
(8, '2025-09-04 10:00:00'),
(9, '2025-09-04 10:05:00'),
(10, '2025-09-04 10:10:00'),
(1, '2025-09-04 10:15:00'),
(3, '2025-09-04 10:25:00');


INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario) VALUES
(1, 1, 1, 750.00),
(1, 2, 2, 25.50),
(2, 4, 1, 130.00),
(3, 3, 1, 55.00),
(4, 5, 1, 70.00),
(4, 6, 3, 15.99),
(5, 7, 1, 45.00),
(6, 9, 1, 220.00),
(7, 10, 1, 180.00),
(7, 11, 2, 65.00),
(8, 12, 1, 150.00),
(9, 14, 1, 28.00),
(9, 15, 2, 60.00),
(10, 13, 1, 35.00),
(10, 8, 1, 10.00);


INSERT INTO historial_precios (producto_id, precio_anterior, precio_nuevo, cambiado_en) VALUES
(1, 700.00, 750.00, '2025-09-03 15:00:00'),
(3, 50.00, 55.00, '2025-09-02 10:30:00'),
(5, 65.00, 70.00, '2025-09-01 14:45:00'),
(9, 210.00, 220.00, '2025-08-30 12:00:00'),
(14, 25.00, 28.00, '2025-09-03 16:20:00');


INSERT INTO auditoria_ventas (venta_id, usuario, registrado_en) VALUES
(1, 'admin', '2025-09-04 09:15:10'),
(2, 'admin', '2025-09-04 09:20:05'),
(3, 'vendedor1', '2025-09-04 09:30:10'),
(4, 'vendedor1', '2025-09-04 09:40:10'),
(5, 'vendedor2', '2025-09-04 09:45:30'),
(6, 'admin', '2025-09-04 10:00:10'),
(7, 'admin', '2025-09-04 10:05:15'),
(8, 'vendedor2', '2025-09-04 10:10:10'),
(9, 'vendedor1', '2025-09-04 10:15:20'),
(10, 'admin', '2025-09-04 10:25:00');


INSERT INTO alertas_stock (producto_id, nombre_producto, mensaje, generado_en) VALUES
(10, 'Impresora Epson EcoTank', 'Stock bajo: quedan menos de 15 unidades', '2025-09-04 08:00:00'),
(1, 'Laptop HP 15"', 'Stock bajo: quedan menos de 25 unidades', '2025-09-04 08:30:00'),
(9, 'Smartphone Samsung A24', 'Stock crítico: menos de 10 unidades', '2025-09-04 09:00:00');

```

## 📄 4. Consultas SQL (queries.sql)
Incluir 6 consultas avanzadas:

### 1️⃣ Listar los productos con stock menor a 5 unidades.
```sql
SELECT id, nombre, categoria, precio, stock, proveedor_id
FROM productos
WHERE stock < 5;
--no hay productos que tengan un stock menor a 5--
```
### 2️⃣ Calcular ventas totales de un mes específico.
```sql
SELECT SUM (vd.cantidad * vd.precio_unitario) AS total_ventas
FROM ventas v
JOIN ventas_detalle vd ON v.id = vd.venta_id
WHERE EXTRACT(YEAR FROM v.fecha) = 2025 AND EXTRACT(MONTH FROM v.fecha) = 09;
```
### 3️⃣ Obtener el cliente con más compras realizadas.
```sql
SELECT c.id, c.nombre COUNT(v.id) AS total_compras
FROM clientes c
JOIN ventas v ON c.id = v.cliente_id
GROUP BY c.id
ORDER BY total_compras DESC
LIMIT 1;

SELECT c.id, c.nombre, SUM(vd.cantidad * vd.precio_unitario) AS total_gastado
FROM clientes c
JOIN ventas v ON c.id = v.cliente_id
JOIN ventas_detalle vd ON v.id = vd.venta_id
GROUP BY c.id
ORDER BY total_gastado DESC
LIMIT 1;
```
### 4️⃣ Listar los productos más vendidos.
```sql
SELECT p.id, p.nombre, SUM(vd.cantidad) AS total_vendido
FROM productos p
JOIN ventas_detalle vd ON p.id = vd.producto_id
GROUP BY p.id
ORDER BY total_vendido DESC
LIMIT 5;
```
### 5️⃣ Consultar ventas realizadas en un rango de fechas.
```sql
SELECT v.id, v.fecha, c.nombre AS cliente, SUM(vd.cantidad * vd.precio_unitario) AS total_venta
FROM ventas v
JOIN clientes c ON v.cliente_id = c.id
JOIN ventas_detalle vd ON v.id = vd.venta_id
WHERE v.fecha BETWEEN '2025-09-03 09:15:10' AND '2025-10-06 10:25:00'
GROUP BY v.id, v.fecha, c.nombre
ORDER BY v.fecha;
```
### 6️⃣ Identificar clientes que no han comprado en los últimos 6 meses.
```sql
SELECT c.id, c.nombre, c.correo
FROM clientes c
WHERE c.id NOT IN (
  SELECT DISTINCT v.cliente_id
  FROM ventas v
  WHERE v.fecha >= (CURRENT_DATE - INTERVAL '6 months')
);
```


## 📄 5. Procedimiento Almacenado (procedure.sql)
Un procedimiento almacenado para registrar una venta.
Implementación de transacciones (COMMIT y ROLLBACK) para:
Validar que el cliente exista.
Verificar que el stock sea suficiente antes de procesar la venta.
Si no hay stock suficiente, se hace un ROLLBACK para cancelar la venta.
Si hay stock, se realiza un COMMIT para confirmar la transacción.

```sql

===========PROCEDIMIENTO ALMACENADO PARA GESTIONAR VENTAS CON TRANSACCIONES=================
============================================================================================

-- Un procedimiento almacenado para registrar una venta.
-- Validar que el cliente exista.
-- Verificar que el stock sea suficiente antes de procesar la venta.
-- Si no hay stock suficiente, Notificar por medio de un mensaje en consola usando RAISE.
-- Si hay stock, se realiza el registro de la venta.


CREATE OR REPLACE PROCEDURE registrar_venta(
  p_cliente_id INTEGER,
  p_productos JSON
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_venta_id INTEGER;
  v_producto JSON;
  v_producto_id INTEGER;
  v_cantidad INTEGER;
  v_precio_unitario NUMERIC(12,2);
  v_stock_actual INTEGER;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM clientes WHERE id = p_cliente_id) THEN
    RAISE EXCEPTION 'El cliente con ID % no existe.', p_cliente_id;
  END IF;

  FOR v_producto IN SELECT * FROM json_array_elements(p_productos)
  LOOP
    v_producto_id := (v_producto ->> 'producto_id')::INTEGER;
    v_cantidad := (v_producto ->> 'cantidad')::INTEGER;

    SELECT stock INTO v_stock_actual
    FROM productos
    WHERE id = v_producto_id;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'El producto con ID % no existe.', v_producto_id;
    END IF;

    IF v_stock_actual < v_cantidad THEN
      RAISE EXCEPTION 'Stock insuficiente para el producto ID %: disponible %, requerido %.', v_producto_id, v_stock_actual, v_cantidad;
    END IF;
  END LOOP;

  INSERT INTO ventas (cliente_id)
  VALUES (p_cliente_id)
  RETURNING id INTO v_venta_id;

  FOR v_producto IN SELECT * FROM json_array_elements(p_productos)
  LOOP
    v_producto_id := (v_producto ->> 'producto_id')::INTEGER;
    v_cantidad := (v_producto ->> 'cantidad')::INTEGER;
    v_precio_unitario := (v_producto ->> 'precio_unitario')::NUMERIC;

    INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario)
    VALUES (v_venta_id, v_producto_id, v_cantidad, v_precio_unitario);

    UPDATE productos
    SET stock = stock - v_cantidad
    WHERE id = v_producto_id;
  END LOOP;

  RAISE NOTICE 'Venta registrada exitosamente con ID: %', v_venta_id;

END;
$$;

CALL registrar_venta(
  1,
  '[
    {"producto_id": 1, "cantidad": 2, "precio_unitario": 15.50},
    {"producto_id": 2, "cantidad": 1, "precio_unitario": 8.75}
  ]'
);
```
📂 Estructura del Repositorio
📌 modelo_er.png → Imagen del modelo Entidad-Relación.

📌 db.sql → Script de creación de la base de datos y tablas.

📌 insert.sql → Script para insertar datos de prueba en la base de datos.

📌 queries.sql → Conjunto de consultas avanzadas para análisis de datos.

📌 procedure.sql → Procedimiento almacenado para gestionar ventas con transacciones.

📌 README.md → Documentación del proyecto y guía de uso.
