-- 1.1 Tomas Vogt

DROP DATABASE IF EXISTS PEDIDOS;
CREATE DATABASE PEDIDOS 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE PEDIDOS;

CREATE TABLE Clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    apellido VARCHAR(100) NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    direccion VARCHAR(100) NOT NULL,
    mail VARCHAR(100) NOT NULL,
    CONSTRAINT uk_clientes_mail UNIQUE (mail)
);

CREATE TABLE Proveedores (
    id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
    nombre_proveedor VARCHAR(100) NOT NULL,
    direccion VARCHAR(100) NOT NULL,
    mail VARCHAR(100) NOT NULL,
    CONSTRAINT uk_proveedores_email UNIQUE (mail)
);

CREATE TABLE Vendedor (
    id_vendedor INT AUTO_INCREMENT PRIMARY KEY,
    apellido VARCHAR(100) NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    mail VARCHAR(100) NOT NULL,
    comision decimal(5,2) NOT NULL,
    CONSTRAINT uk_vendedor_email UNIQUE (mail),
    CONSTRAINT chk_vendedor_comision CHECK (comision between 0 and 100)
);

CREATE TABLE Productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(100) NOT NULL,
    precio_unitario decimal(10,2) NOT NULL,
    stock INT NOT NULL,
    stock_max INT NOT NULL,
    stock_min INT NOT NULL,
    id_proveedor INT NOT NULL,
    origen VARCHAR(100) NOT NULL,
    CONSTRAINT fk_productos_proveedores
        FOREIGN KEY (id_proveedor) REFERENCES Proveedores(id_proveedor) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_producto_origen CHECK(origen = 'Nacional' or origen = 'Importado'),
    CONSTRAINT chk_producto_precio CHECK(precio_unitario >= 0),
    CONSTRAINT chk_producto_stock CHECK(stock >= 0 AND stock_min >= 0 AND stock_max >= 0),
    CONSTRAINT chk_producto_stock_valores CHECK(stock_min < stock < stock_max)
);

CREATE TABLE Pedidos (
    numero_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_vendedor INT NOT NULL,
    fecha DATETIME NOT NULL,
    estado VARCHAR(100) NOT NULL,
    CONSTRAINT fk_pedidos_clientes 
        FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_pedidos_vendedores 
        FOREIGN KEY (id_vendedor) REFERENCES Vendedor(id_vendedor) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_pedidos_estado CHECK(estado IN('CONFIRMADO', 'ANULADO', 'PENDIENTE'))
)

CREATE TABLE detallePedidos (
    numero_pedido INT NOT NULL,
    renglon INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(12,2) NOT NULL,

    PRIMARY KEY(numero_pedido, renglon),
    CONSTRAINT fk_detalle_pedido FOREIGN KEY (numero_pedido) REFERENCES Pedidos(numero_pedido) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_detallePedido_productos FOREIGN KEY (id_producto) REFERENCES Productos(id_producto) ON DELETE RESTRICT ON UPDATE CASCADE
);