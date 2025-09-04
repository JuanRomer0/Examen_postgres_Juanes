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

