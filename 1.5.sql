-- Tomas Vogt

USE PEDIDOS;

EXPLAIN ANALYZE
SELECT p.descripcion, SUM(dp.cantidad) AS total_vendido
FROM Productos p
JOIN detallePedidos dp ON p.id_producto = dp.id_producto
JOIN Pedidos pe ON dp.numero_pedido = pe.numero_pedido
WHERE pe.fecha BETWEEN '2024-01-01' AND '2026-06-30' -- modificado a 2026 por la fecha de datos durante el poblado 
AND p.origen = 'Importado'
GROUP BY p.descripcion
ORDER BY total_vendido DESC;


/* 
Resultado: 
-> Sort: total_vendido DESC  (actual time=4.23..4.25 rows=48 loops=1)
    -> Table scan on <temporary>  (actual time=4.12..4.15 rows=48 loops=1)
        -> Aggregate using temporary table  (actual time=4.12..4.12 rows=48 loops=1)
            -> Nested loop inner join  (cost=50 rows=6.31) (actual time=0.104..3.3 rows=255 loops=1)
                -> Nested loop inner join  (cost=30.1 rows=56.8) (actual time=0.0878..1.51 rows=285 loops=1)
                    -> Filter: (p.origen = 'Importado')  (cost=10.2 rows=10) (actual time=0.0414..0.198 rows=50 loops=1)
                        -> Table scan on p  (cost=10.2 rows=100) (actual time=0.0367..0.141 rows=100 loops=1)
                    -> Index lookup on dp using fk_detallePedido_productos (id_producto = p.id_producto)  (cost=1.48 rows=5.68) (actual time=0.0185..0.0247 rows=5.7 loops=50)
                -> Filter: (pe.fecha between '2024-01-01' and '2026-06-30')  (cost=0.25 rows=0.111) (actual time=0.00548..0.00576 rows=0.895 loops=285)
                    -> Single-row index lookup on pe using PRIMARY (numero_pedido = dp.numero_pedido)  (cost=0.25 rows=1) (actual time=0.0032..0.00331 rows=1 loops=285)

Tipos de Acceso y Métodos de Lectura

    1) Table scan on p (Full Table Scan en Productos):

        Método: Recorrido completo de la tabla Productos.

        Detalle: Lee las 100 filas de la tabla para evaluar el filtro p.origen = 'Importado'. Esto ocurre porque no existe un índice en la columna origen.

    2) Index lookup on dp using fk_detallePedido_productos:

        Método: Búsqueda por índice (ref).

        Detalle: Utiliza la clave foránea para encontrar los renglones correspondientes en Detalle_Pedidos para los 50 productos importados encontrados.

    3) Single-row index lookup on pe using PRIMARY:

        Método: Búsqueda por Clave Primaria (eq_ref).

        Detalle: Accede fila por fila a la tabla Pedidos usando numero_pedido.

    4) Filter: (pe.fecha between ...):

        Método: Evaluación posterior (Filter).

        Detalle: Realiza las 285 búsquedas a la tabla Pedidos y después evalúa si la fecha está en el rango deseado.


Operaciones Costosas e Ineficiencias

    1) Uso de Tabla Temporal (Aggregate using temporary table): Para poder agrupar los datos por p.descripcion 
    (GROUP BY), MySQL tiene que volcar los resultados en memoria/disco en una tabla temporal.

    2) Operación de Ordenamiento (Sort: total_vendido DESC / Filesort): Una vez agrupados los datos, 
    realiza un escaneo de la tabla temporal para ordenarlos de mayor a menor.


Diagnóstico de los Cuellos de Botella

    1) Falta de índice en Productos.origen: Obliga al motor a leer todos los productos 
    existentes mediante un Table Scan para filtrar los importados.

    2) Falta de índice en Pedidos.fecha: Obliga a hacer el JOIN hacia la tabla Pedidos 285 veces por clave 
    primaria para recién ahí descartar los pedidos fuera del rango de fechas. Si existiera un índice por fecha,
    MySQL podría comenzar filtrando los pedidos en el rango o reducir drásticamente las lecturas.
*/  

-- Indices
-- Índice compuesto en Productos (Filtro + JOIN)
CREATE INDEX idx_productos_origen_id ON Productos(origen, id_producto);

-- Índice compuesto en Pedidos (Filtro por fecha + Clave primaria)
CREATE INDEX idx_pedidos_fecha_numero ON Pedidos(fecha, numero_pedido);

EXPLAIN ANALYZE
SELECT p.descripcion, SUM(dp.cantidad) AS total_vendido
FROM Productos p
JOIN detallePedidos dp ON p.id_producto = dp.id_producto
JOIN Pedidos pe ON dp.numero_pedido = pe.numero_pedido
WHERE pe.fecha BETWEEN '2024-01-01' AND '2026-06-30' -- modificado a 2026 por la fecha de datos durante el poblado 
AND p.origen = 'Importado'
GROUP BY p.descripcion
ORDER BY total_vendido DESC;

/*

-> Sort: total_vendido DESC  (actual time=4.03..4.04 rows=48 loops=1)
    -> Table scan on <temporary>  (actual time=3.92..3.93 rows=48 loops=1)
        -> Aggregate using temporary table  (actual time=3.91..3.91 rows=48 loops=1)
            -> Nested loop inner join  (cost=205 rows=257) (actual time=0.0902..3.15 rows=255 loops=1)
                -> Nested loop inner join  (cost=105 rows=284) (actual time=0.0755..1.48 rows=285 loops=1)
                    -> Index lookup on p using idx_productos_origen_id (origen = 'Importado')  (cost=5.75 rows=50) (actual time=0.0392..0.208 rows=50 loops=1)
                    -> Index lookup on dp using fk_detallePedido_productos (id_producto = p.id_producto)  (cost=1.43 rows=5.68) (actual time=0.0183..0.0241 rows=5.7 loops=50)
                -> Filter: (pe.fecha between '2024-01-01' and '2026-06-30')  (cost=0.25 rows=0.904) (actual time=0.00492..0.00542 rows=0.895 loops=285)
                    -> Single-row index lookup on pe using PRIMARY (numero_pedido = dp.numero_pedido)  (cost=0.25 rows=1) (actual time=0.00291..0.00301 rows=1 loops=285)


Conclusión:
    La creación del índice compuesto idx_productos_origen_id (origen, idproductos) resolvió con 
    éxito el cuello de botella más grave de la consulta: el Full Table Scan sobre la tabla Productos.

    Al contar con un índice indexado por la columna de filtro (origen), el optimizador de MySQL redujo a la mitad 
    las filas leídas en la primera etapa del pipeline de procesamiento, 
    disminuyendo la carga de I/O en disco/memoria y garantizando un plan de ejecución mucho más escalable 
    a medida que la tabla de productos crezca.
*/

