===========CONJUNTO DE CONSULTAS AVANZADAS PARA ANALISIS DE DATOS================
=================================================================================

--1️⃣ Listar los productos con stock menor a 5 unidades.

SELECT id, nombre, categoria, precio, stock, proveedor_id
FROM productos
WHERE stock < 5;
--no hay productos que tengan un stock menor a 5-- 

--2️⃣ Calcular ventas totales de un mes específico.

SELECT SUM (vd.cantidad * vd.precio_unitario) AS total_ventas
FROM ventas v
JOIN ventas_detalle vd ON v.id = vd.venta_id
WHERE EXTRACT(YEAR FROM v.fecha) = 2025 AND EXTRACT(MONTH FROM v.fecha) = 09;


--3️⃣ Obtener el cliente con más compras realizadas.

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


--4️⃣ Listar los 5 productos más vendidos.

SELECT p.id, p.nombre, SUM(vd.cantidad) AS total_vendido
FROM productos p
JOIN ventas_detalle vd ON p.id = vd.producto_id
GROUP BY p.id
ORDER BY total_vendido DESC
LIMIT 5;


--5️⃣ Consultar ventas realizadas en un rango de fechas de tres Días y un Mes.

SELECT v.id, v.fecha, c.nombre AS cliente, SUM(vd.cantidad * vd.precio_unitario) AS total_venta
FROM ventas v
JOIN clientes c ON v.cliente_id = c.id
JOIN ventas_detalle vd ON v.id = vd.venta_id
WHERE v.fecha BETWEEN '2025-09-03 09:15:10' AND '2025-10-06 10:25:00'
GROUP BY v.id, v.fecha, c.nombre
ORDER BY v.fecha;


--6️⃣ Identificar clientes que no han comprado en los últimos 6 meses.

SELECT c.id, c.nombre, c.correo
FROM clientes c
WHERE c.id NOT IN (
  SELECT DISTINCT v.cliente_id
  FROM ventas v
  WHERE v.fecha >= (CURRENT_DATE - INTERVAL '6 months')
);

