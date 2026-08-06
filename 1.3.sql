-- 1.3 Tomas Vogt

USE PEDIDOS;

CREATE VIEW vw_clientes_activos as  
SELECT DISTINCT 
    c.id_cliente,
    c.nombres,
    c.apellido,
    c.mail,
    p.fecha
FROM Clientes c
INNER JOIN Pedidos p on p.id_cliente = c.id_cliente;

-- Ejemplo de uso

SELECT idcliente, apellido, nombres, mail 
FROM vw_clientes_activos 
WHERE fecha BETWEEN '2025-01-01' AND CURDATE();

CREATE VIEW vw_rendimiento_vendedores as
SELECT 
    v.id_vendedor,
    v.apellido,
    v.nombres,
    v.mail,
    v.comision,
    COUNT(p.numero_pedido) as totl_pedidos
FROM Vendedor v
LEFT JOIN Pedidos p on p.id_vendedor = v.id_vendedor
GROUP BY v.id_vendedor, v.apellido, v.nombres, v.mail, v.comision
ORDER BY total_pedidos DESC;
