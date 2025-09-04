===========CREACCION DE TRIGGERS=================
=================================================

--Actualización automática del stock en ventas
--Cada vez que se inserte un registro en la tabla `ventas_detalle`, el sistema debe **descontar automáticamente** la cantidad de productos vendidos del campo `stock` de la tabla `productos`.
-- Si el stock es insuficiente, el trigger debe evitar la operación y lanzar un error con `RAISE EXCEPTION`.

-- 1. Descontar stock automáticamente (Trigger en ventas_detalle)
--Actualización automática del stock en ventas
--Cada vez que se inserte un registro en la tabla `ventas_detalle`, el sistema debe **descontar automáticamente** la cantidad de productos vendidos del campo `stock` de la tabla `productos`.
-- Si el stock es insuficiente, el trigger debe evitar la operación y lanzar un error con `RAISE EXCEPTION`.

CREATE OR REPLACE FUNCTION descontar_stock()
RETURNS TRIGGER AS $$
DECLARE
  v_stock_actual INTEGER;
BEGIN
  SELECT stock INTO v_stock_actual FROM productos WHERE id = NEW.producto_id;

  IF v_stock_actual IS NULL THEN
    RAISE EXCEPTION 'Producto con ID % no existe.', NEW.producto_id;
  END IF;

  IF v_stock_actual < NEW.cantidad THEN
    RAISE EXCEPTION 'Stock insuficiente para producto ID %: disponible %, requerido %.', NEW.producto_id, v_stock_actual, NEW.cantidad;
  END IF;

  UPDATE productos
  SET stock = stock - NEW.cantidad
  WHERE id = NEW.producto_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_descontar_stock
BEFORE INSERT ON ventas_detalle
FOR EACH ROW
EXECUTE FUNCTION descontar_stock();

-- 2. Auditoría de ventas (auditoria_ventas)
--Registro de auditoría de ventas
--> Al insertar una nueva venta en la tabla `ventas`, se debe generar automáticamente un registro en la tabla `auditoria_ventas` indicando:
-- ID de la venta
-- Fecha y hora del registro
-- Usuario que realizó la transacción (usando `current_user`)

CREATE OR REPLACE FUNCTION registrar_auditoria_venta()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO auditoria_ventas (venta_id, usuario, registrado_en)
  VALUES (NEW.id, current_user, NOW());

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditoria_venta
AFTER INSERT ON ventas
FOR EACH ROW
EXECUTE FUNCTION registrar_auditoria_venta();

-- 3. Alerta por producto agotado (cuando stock = 0)
--Notificación de productos agotados
--> Cuando el stock de un producto llegue a **0** después de una actualización, se debe registrar en la tabla `alertas_stock` un mensaje indicando:
-- ID del producto
-- Nombre del producto
-- Fecha en la que se agotó

CREATE OR REPLACE FUNCTION generar_alerta_stock()
RETURNS TRIGGER AS $$
DECLARE
  v_nombre TEXT;
BEGIN
  IF NEW.stock = 0 AND OLD.stock > 0 THEN
    SELECT nombre INTO v_nombre FROM productos WHERE id = NEW.id;

    INSERT INTO alertas_stock (producto_id, nombre_producto, mensaje, generado_en)
    VALUES (NEW.id, v_nombre, 'Producto agotado', NOW());
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_alerta_stock_agotado
AFTER UPDATE OF stock ON productos
FOR EACH ROW
WHEN (NEW.stock = 0 AND OLD.stock > 0)
EXECUTE FUNCTION generar_alerta_stock();

-- 4. Validación de datos en clientes (correo no vacío ni repetido)
--Validación de datos en clientes
--> Antes de insertar un nuevo cliente en la tabla `clientes`, se debe validar que el campo `correo` no esté vacío y que no exista ya en la base de datos (unicidad).
-- Si la validación falla, se debe impedir la inserción y lanzar un mensaje de error.

CREATE OR REPLACE FUNCTION validar_cliente()
RETURNS TRIGGER AS $$
BEGIN
  IF TRIM(NEW.correo) = '' THEN
    RAISE EXCEPTION 'El campo correo no puede estar vacío.';
  END IF;

  IF EXISTS (SELECT 1 FROM clientes WHERE correo = NEW.correo) THEN
    RAISE EXCEPTION 'Ya existe un cliente con el correo %.', NEW.correo;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_cliente
BEFORE INSERT ON clientes
FOR EACH ROW
EXECUTE FUNCTION validar_cliente();

-- 5. Historial de cambios de precio (historial_precios)
--Historial de cambios de precio
--> Cada vez que se actualice el campo `precio` en la tabla `productos`, el trigger debe guardar el valor anterior y el nuevo en una tabla `historial_precios` con la fecha y hora de la modificación.

CREATE OR REPLACE FUNCTION registrar_cambio_precio()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.precio <> OLD.precio THEN
    INSERT INTO historial_precios (producto_id, precio_anterior, precio_nuevo, cambiado_en)
    VALUES (OLD.id, OLD.precio, NEW.precio, NOW());
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_historial_precio
AFTER UPDATE OF precio ON productos
FOR EACH ROW
EXECUTE FUNCTION registrar_cambio_precio();

-- 6. Bloquear eliminación de proveedor con productos activos
--Bloqueo de eliminación de proveedores con productos activos
--> Antes de eliminar un proveedor en la tabla `proveedores`, se debe verificar si existen productos asociados a dicho proveedor.
-- Si existen productos, se debe bloquear la eliminación y notificar con un error.

CREATE OR REPLACE FUNCTION bloquear_eliminacion_proveedor()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM productos WHERE proveedor_id = OLD.id) THEN
    RAISE EXCEPTION 'No se puede eliminar proveedor con productos asociados (ID %).', OLD.id;
  END IF;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_bloquear_proveedor
BEFORE DELETE ON proveedores
FOR EACH ROW
EXECUTE FUNCTION bloquear_eliminacion_proveedor();

-- 7. Validar que fecha de venta no sea futura
--Control de fechas en ventas
--> Antes de insertar un registro en la tabla `ventas`, el trigger debe validar que la fecha de la venta no sea mayor a la fecha actual (`NOW()`).
-- Si se detecta una fecha futura, la inserción debe ser cancelada.

CREATE OR REPLACE FUNCTION validar_fecha_venta()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.fecha > NOW() THEN
    RAISE EXCEPTION 'La fecha de la venta no puede ser futura.';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_fecha_venta
BEFORE INSERT ON ventas
FOR EACH ROW
EXECUTE FUNCTION validar_fecha_venta();

-- 8. Activar cliente inactivo si compra después de 6 meses
--Registro de clientes inactivos
--> Si un cliente no ha realizado compras en los últimos 6 meses y se intenta registrar una nueva venta a su nombre, el trigger debe actualizar su estado en la tabla `clientes` a **"activo"**.

CREATE OR REPLACE FUNCTION activar_cliente_si_inactivo()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE clientes
  SET estado = 'activo'
  WHERE id = NEW.cliente_id AND estado = 'inactivo';

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_activar_cliente
BEFORE INSERT ON ventas
FOR EACH ROW
EXECUTE FUNCTION activar_cliente_si_inactivo();
