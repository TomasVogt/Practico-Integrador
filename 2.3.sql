USE PEDIDOS;

CREATE TABLE log_anulaciones (
id_log INT AUTO_INCREMENT PRIMARY KEY,
numero_pedido INT NOT NULL,
fecha_anulacion DATETIME NOT NULL,
usuario VARCHAR(100) NOT NULL,
motivo VARCHAR(255) DEFAULT 'Anulación requerida por el cliente'
);

DROP TRIGGER IF EXISTS trg_audit_anulacion_pedido;
DROP PROCEDURE IF EXISTS sp_anular_pedido;


DELIMITER //

CREATE TRIGGER trg_audit_anulacion_pedido
AFTER UPDATE ON Pedidos
FOR EACH ROW
BEGIN
    IF OLD.estado <> 'ANULADO' AND NEW.estado = 'ANULADO' THEN
        INSERT INTO log_anulaciones(numero_pedido, fecha_anulacion, usuario)
        VALUES(NEW.numero_pedido, NOW(), CURRENT_USER());
    END IF;
END //


DELIMITER //
CREATE PROCEDURE sp_anular_pedido(
    IN p_numero_pedido INT
)
BEGIN
    DECLARE v_estado VARCHAR(100);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT estado INTO v_estado
    FROM Pedidos
    WHERE numero_pedido = p_numero_pedido;

    IF v_estado IS NULL THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El pedido especificado no existe';
    END IF;

    IF v_estado = 'Anulado' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El pedido ya ha sido anulado';
    END IF;

    UPDATE Pedidos
    SET estado = 'ANULADO'
    WHERE numero_pedido = p_numero_pedido;

    UPDATE Productos p
    INNER JOIN detallePedidos dp on dp.id_producto = p.id_producto
    SET p.stock = p.stock + dp.cantidad
    WHERE dp.numero_pedido = p_numero_pedido;

    COMMIT;
END //
DELIMITER ;

