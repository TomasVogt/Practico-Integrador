-- 2.4 Tomas Vogt

USE PEDIDOS;

DROP PROCEDURE IF EXISTS sp_procesar_reajuste_stock_critico;
DROP TABLE IF EXISTS Ordenes_Compra_Sugeridas;


CREATE TABLE Ordenes_Compra_Sugeridas (
    id_orden INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    descripcion VARCHAR(100) NOT NULL,
    stock_actual INT NOT NULL,
    stock_min INT NOT NULL,
    stock_max INT NOT NULL,
    cantidad_reponer INT NOT NULL,
    fecha_generacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

-- =============================================
-- sp_procesar_reajuste_stock_critico
-- Recorre con un cursor explícito todos los productos en Stock Crítico
-- (stock < stock_min), calcula la cantidad necesaria para reponer hasta
-- el stock_max, e inserta el detalle en Ordenes_Compra_Sugeridas.
-- =============================================

CREATE PROCEDURE sp_procesar_reajuste_stock_critico()
BEGIN
    DECLARE fin_cursor INT DEFAULT 0;
    DECLARE v_id_producto INT;
    DECLARE v_descripcion VARCHAR(100);
    DECLARE v_stock INT;
    DECLARE v_stock_min INT;
    DECLARE v_stock_max INT;
    DECLARE v_cantidad_reponer INT;

    DECLARE cur_stock_critico CURSOR FOR
        SELECT id_producto, descripcion, stock, stock_min, stock_max
        FROM Productos
        WHERE stock < stock_min;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin_cursor = 1;

    OPEN cur_stock_critico;

    read_loop: LOOP
        FETCH cur_stock_critico INTO v_id_producto, v_descripcion, v_stock, v_stock_min, v_stock_max;

        IF fin_cursor = 1 THEN
            LEAVE read_loop;
        END IF;

        SET v_cantidad_reponer = v_stock_max - v_stock;

        INSERT INTO Ordenes_Compra_Sugeridas
            (id_producto, descripcion, stock_actual, stock_min, stock_max, cantidad_reponer)
        VALUES
            (v_id_producto, v_descripcion, v_stock, v_stock_min, v_stock_max, v_cantidad_reponer);
    END LOOP;

    CLOSE cur_stock_critico;
END//

DELIMITER ;

