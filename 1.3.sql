-- 1.3 Tomas Vogt

USE PEDIDOS;

CREATE OR REPLACE VIEW vw_clientes_activos as  
SELECT DISTINCT 
    c.id_cliente,
    c.nombres,
    c.apellido,
    c.mail,
    p.fecha
FROM Clientes c
INNER JOIN Pedidos p on p.id_cliente = c.id_cliente;

-- Ejemplo de uso con lo que se pide en la consgina

SELECT id_cliente, apellido, nombres, mail, fecha
FROM vw_clientes_activos 
WHERE fecha BETWEEN '2025-01-01' AND CURDATE();

CREATE OR REPLACE VIEW vw_rendimiento_vendedores AS
SELECT 
    v.id_vendedor,
    v.apellido,
    v.nombres,
    v.mail,
    v.comision,
    COUNT(p.numero_pedido) as total_pedidos
FROM Vendedor v
LEFT JOIN Pedidos p on p.id_vendedor = v.id_vendedor
GROUP BY v.id_vendedor, v.apellido, v.nombres, v.mail, v.comision
ORDER BY total_pedidos DESC;

CREATE OR REPLACE VIEW vw_pedidos_alto_valor AS 
SELECT
    p.numero_pedido,
    p.id_cliente,
    p.id_vendedor,
    p.fecha,
    p.estado,
    SUM(precio_unitario) as importe_total
FROM Pedidos p
INNER JOIN detallePedidos dp on dp.numero_pedido = p.numero_pedido
GROUP BY p.numero_pedido, p.id_cliente ,p.id_vendedor ,p.fecha ,p.estado
HAVING importe_total > 500000;

CREATE OR REPLACE VIEW vw_productos_vendidos_periodo AS 
SELECT 
    pr.id_producto,
    pr.descripcion,
    pr.stock,
    pr.origen,
    pe.fecha,
    SUM(dp.cantidad) as cantidad_vendida
FROM Productos pr
INNER JOIN detallePedidos dp on pr.id_producto = dp.id_producto
INNER JOIN Pedidos pe on pe.numero_pedido = dp.numero_pedido
GROUP BY  pr.id_producto, pr.descripcion, pr.stock, pr.origen, pe.fecha;

CREATE OR REPLACE VIEW vw_clientes_sin_pedidos AS
SELECT 
    c.id_cliente,
    CONCAT(c.nombres, " ", c.apellido) as nombre_cliente,
    c.direccion,
    c.mail
FROM Clientes c
WHERE c.id_cliente NOT IN(
        SELECT p2.id_cliente
        FROM Pedidos p2
        WHERE p2.estado IN("CONFIRMADO", "PENDIENTE")
);

CREATE OR REPLACE VIEW vw_clientes_ocacionales AS 
SELECT 
    c.id_cliente,
    CONCAT(c.nombres, " ", c.apellido) as nombre_cliente,
    c.direccion,
    c.mail,
    COUNT(p.numero_pedido) as cantidad_total_pedidos
FROM Clientes c
INNER JOIN Pedidos p on p.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombres, c.apellido, c.direccion, c.mail
HAVING cantidad_total_pedidos < 2;
