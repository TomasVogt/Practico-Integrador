USE PEDIDOS;

-- 1.4 Tomas Vogt
    
DROP USER IF EXISTS 'usuario_auditoria'@'localhost';
DROP USER IF EXISTS 'usuario_ventas1'@'localhost';
DROP USER IF EXISTS 'usuario_admin1'@'localhost';
DROP ROLE IF EXISTS 'rol_auditor';
DROP ROLE IF EXISTS 'rol_vendedor';
DROP ROLE IF EXISTS 'rol_admin';

-- 1)
CREATE ROLE 'rol_auditor';
GRANT SELECT ON PEDIDOS.* TO 'rol_auditor';

-- 2)
CREATE ROLE 'rol_vendedor';
GRANT SELECT, UPDATE ON Clientes TO 'rol_vendedor';
GRANT SELECT, UPDATE, INSERT ON Pedidos TO 'rol_vendedor';
GRANT SELECT, UPDATE, INSERT ON detallePedidos TO 'rol_vendedor';

-- 3)
CREATE ROLE 'rol_admin';
GRANT ALL PRIVILEGES ON PEDIDOS.* TO "rol_admin";

-- 4)
CREATE USER 'usuario_auditoria'@'localhost' IDENTIFIED BY '123456';
CREATE USER 'usuario_ventas1'@'localhost' IDENTIFIED BY '123456';
CREATE USER 'usuario_admin1'@'localhost' IDENTIFIED BY '123456';

GRANT 'rol_auditor' TO 'usuario_auditoria'@'localhost';
GRANT 'rol_vendedor' TO 'usuario_ventas1'@'localhost';
GRANT 'rol_admin' TO 'usuario_admin1'@'localhost';

-- Esta parte de setear los roles default no la conocia, por ende fue agregada por gemini al verificar mi trabajo practico

SET DEFAULT ROLE 'rol_auditor' TO 'usuario_auditoria'@'localhost';
SET DEFAULT ROLE 'rol_vendedor' TO 'usuario_ventas1'@'localhost';
SET DEFAULT ROLE 'rol_admin' TO 'usuario_admin1'@'localhost';

FLUSH PRIVILEGES;