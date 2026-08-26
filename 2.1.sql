-- 2.1 Tomas Vogt

USE PEDIDOS;

DROP FUNCTION IF EXISTS fn_calcular_total_pedido;
DROP FUNCTION IF EXISTS fn_validar_stock_disponible;

-- 1)

DELIMITER //

CREATE FUNCTION fn_calcular_total_pedido(p_numero_pedido INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(12,2);

    SELECT COALESCE(SUM(dp.cantidad * dp.precio_unitario), 0.00)
    INTO v_total
    FROM detallePedidos dp
    WHERE dp.numero_pedido = p_numero_pedido;

    RETURN v_total;
END//

-- Ejemplo de uso: 
-- select numero_pedido, fn_calcular_total_pedido(numero_pedido) from detalle_pedidos;

-- 2)

CREATE FUNCTION fn_validar_stock_disponible(p_idproducto INT, p_cantidad INT)
RETURNS TINYINT(1)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_stock INT;
    DECLARE v_resultado TINYINT(1) DEFAULT 0;

    SELECT stock
    INTO v_stock
    FROM Productos
    WHERE id_producto = p_idproducto;

    IF v_stock IS NOT NULL AND v_stock >= p_cantidad THEN
        SET v_resultado = 1;
    ELSE
        SET v_resultado = 0;
    END IF;

    RETURN v_resultado;
END//

DELIMITER ;