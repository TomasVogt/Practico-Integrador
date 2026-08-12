USE PEDIDOS;

-- Tomas Vogt

-- Escenario A
START TRANSACTION;

INSERT INTO Pedidos (id_cliente, id_vendedor, fecha, estado)
VALUES (1, 1, NOW(), 'CONFIRMADO');

SET @id_nuevo_pedido = LAST_INSERT_ID();

INSERT INTO detallePedidos (numero_pedido, renglon, id_producto, cantidad, precio_unitario)
VALUES 
    (@id_nuevo_pedido, 1, 1, 2, 15000.00),
    (@id_nuevo_pedido, 2, 2, 1, 25000.00);

UPDATE Productos 
SET stock = stock - 2 
WHERE id_producto = 1;

UPDATE Productos 
SET stock = stock - 1 
WHERE id_producto = 2;

COMMIT;

-- Escenario B

START TRANSACTION;
INSERT INTO Pedidos(id_cliente, id_vendedor, fecha, estado) 
VALUES(99999, 1, CURDATE(), 'PENDIENTE');

ROLLBACK;

-- chequear 
SELECT * FROM Pedidos WHERE id_cliente = 99999;

-- Escenario C

START TRANSACTION;

UPDATE Productos 
SET precio_unitario = precio_unitario * 1.10 
WHERE id_producto = 1;

SAVEPOINT punto1;

UPDATE Productos 
SET stock = stock + 50 
WHERE id_producto = 2;

ROLLBACK TO SAVEPOINT punto1;

COMMIT;

-- chequear producto con id 1
SELECT id_producto, descripcion, precio_unitario 
FROM Productos 
WHERE id_producto = 1;

-- chequear producto con id 2
SELECT id_producto, descripcion, stock 
FROM Productos 
WHERE id_producto = 2;