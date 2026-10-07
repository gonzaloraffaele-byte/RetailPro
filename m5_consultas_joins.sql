USE Ventas_Tech_DB;
GO

-- =========================================================
-- PRE-ENTREGA 5 - CONSULTAS CON JOINS PARA RETAILPRO
-- Archivo: m5_consultas_joins.sql
-- Objetivo: cruzar las tablas del proyecto para enriquecer
-- el análisis comercial y preparar la información para Power BI.
-- =========================================================


-- =========================================================
-- CONSULTA 1: VISTA BASE DEL PROYECTO - INNER JOIN
-- Propósito: enriquecer cada venta con información
-- del cliente, producto y categoría.
-- =========================================================

SELECT
    v.fecha_venta,
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.email,
    c.ciudad,
    p.id_producto,
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    v.cantidad,
    v.precio_unitario,
    CAST(v.cantidad * v.precio_unitario AS DECIMAL(10,2)) AS total_venta
FROM ventas AS v
INNER JOIN clientes AS c
    ON v.id_cliente = c.id_cliente
INNER JOIN productos AS p
    ON v.id_producto = p.id_producto
INNER JOIN categorias AS cat
    ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta, v.id_venta;
GO

-- Hallazgo:
-- La consulta devuelve las 10 ventas registradas enriquecidas
-- con información de cliente, ciudad, producto y categoría.
-- Esta vista puede utilizarse como fuente principal para Power BI.


-- =========================================================
-- CONSULTA 2: CLIENTES SIN VENTAS - LEFT JOIN
-- Propósito: identificar clientes registrados
-- que todavía no realizaron ninguna compra.
-- =========================================================

SELECT
    c.nombre AS nombre_cliente,
    c.email,
    c.fecha_registro
FROM clientes AS c
LEFT JOIN ventas AS v
    ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;
GO

-- Hallazgo:
-- Con los datos actuales no existen clientes registrados sin ventas,
-- ya que todos los clientes tienen al menos una compra asociada.


-- =========================================================
-- CONSULTA 3: PRODUCTOS SIN VENTAS - LEFT JOIN
-- Propósito: identificar productos del catálogo
-- que todavía no registraron ninguna venta.
-- =========================================================

SELECT
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos AS p
LEFT JOIN ventas AS v
    ON p.id_producto = v.id_producto
INNER JOIN categorias AS cat
    ON p.id_categoria = cat.id_categoria
WHERE v.id_venta IS NULL;
GO

-- Hallazgo:
-- Con los datos actuales no existen productos sin ventas,
-- ya que todos los productos tienen al menos una venta registrada.


-- =========================================================
-- CONSULTA 4: CONSOLIDADO POR CANAL / ORIGEN - UNION ALL
-- Propósito: dividir las ventas en dos períodos,
-- crear una columna canal como valor literal
-- y consolidar la facturación mediante UNION ALL.
-- =========================================================

WITH ventas_por_canal AS (

    SELECT
        fecha_venta,
        CAST(cantidad * precio_unitario AS DECIMAL(10,2)) AS total,
        'Periodo inicial' AS canal
    FROM ventas
    WHERE fecha_venta BETWEEN '2024-03-05' AND '2024-03-10'

    UNION ALL

    SELECT
        fecha_venta,
        CAST(cantidad * precio_unitario AS DECIMAL(10,2)) AS total,
        'Periodo final' AS canal
    FROM ventas
    WHERE fecha_venta BETWEEN '2024-03-11' AND '2024-03-15'
)

SELECT
    canal,
    SUM(total) AS total_facturado
FROM ventas_por_canal
GROUP BY canal
ORDER BY total_facturado DESC;
GO

-- Hallazgo:
-- El período inicial generó $3.620 de facturación,
-- mientras que el período final generó $2.824.
-- El período inicial concentró la mayor facturación.