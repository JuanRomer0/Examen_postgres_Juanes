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



