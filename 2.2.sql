-- 2.2 Tomas Vogt
USE PEDIDOS;

DROP PROCEDURE IF EXISTS sp_registrar_pedido_completo;
DROP PROCEDURE IF EXISTS sp_actualizar_precios_por_origen;

-- 1)

DELIMITER //

CREATE PROCEDURE sp_registrar_pedido_completo(
    IN p_idcliente INT,
    IN p_idvendedor INT,
    IN p_idproducto INT,
    IN p_cantidad INT
)
BEGIN
    DECLARE v_existe_cliente INT DEFAULT 0;
    DECLARE v_existe_vendedor INT DEFAULT 0;
    DECLARE v_stock_ok TINYINT(1);
    DECLARE v_precio_actual DECIMAL(10,2);
    DECLARE v_nuevo_pedido INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_existe_cliente
    FROM Clientes
    WHERE id_cliente = p_idcliente;

    IF v_existe_cliente = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: El cliente especificado no existe';
    END IF;

    SELECT COUNT(*) INTO v_existe_vendedor
    FROM Vendedor
    WHERE id_vendedor = p_idvendedor;

    IF v_existe_vendedor = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: El vendedor especificado no existe';
    END IF;

    SET v_stock_ok = fn_validar_stock_disponible(p_idproducto, p_cantidad);

    IF v_stock_ok = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: Stock insuficiente para procesar la operación';
    END IF;

    INSERT INTO Pedidos (id_cliente, id_vendedor, fecha, estado)
    VALUES (p_idcliente, p_idvendedor, NOW(), 'CONFIRMADO');

    SET v_nuevo_pedido = LAST_INSERT_ID();

    SELECT precio_unitario INTO v_precio_actual
    FROM Productos
    WHERE id_producto = p_idproducto;

    INSERT INTO detallePedidos (numero_pedido, renglon, id_producto, cantidad, precio_unitario)
    VALUES (v_nuevo_pedido, 1, p_idproducto, p_cantidad, v_precio_actual);

    UPDATE Productos
    SET stock = stock - p_cantidad
    WHERE id_producto = p_idproducto;

    COMMIT;
END//


-- 2)

CREATE PROCEDURE sp_actualizar_precios_por_origen(
    IN p_origen VARCHAR(20),
    IN p_porcentaje_incremento DECIMAL(5,2)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_porcentaje_incremento <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: El porcentaje de incremento debe ser mayor a cero';
    END IF;

    START TRANSACTION;

    UPDATE Productos
    SET precio_unitario = ROUND(precio_unitario * (1 + p_porcentaje_incremento / 100), 2)
    WHERE origen = p_origen;

    COMMIT;
END//

DELIMITER ;
