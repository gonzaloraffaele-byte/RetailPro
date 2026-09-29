USE Ventas_Tech_DB;
GO

-- =============================================
-- CONSULTA 1: RESUMEN EJECUTIVO MENSUAL
-- =============================================

SELECT
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;
GO

-- =============================================
-- CONSULTA 2: RANKING DE PRODUCTOS
-- =============================================

SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;
GO

-- =============================================
-- CONSULTA 3: CLIENTES RECURRENTES
-- =============================================

SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;
GO

-- =============================================
-- CONSULTA 4: MESES POR ENCIMA / DEBAJO DEL PROMEDIO
-- =============================================

WITH facturacion_mensual AS (
    SELECT
        MONTH(fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
),
promedio_mensual AS (
    SELECT
        AVG(total_facturado) AS promedio_general
    FROM facturacion_mensual
)

SELECT
    fm.mes,
    fm.total_facturado,
    pm.promedio_general,
    CASE
        WHEN fm.total_facturado > pm.promedio_general THEN 'Por encima'
        WHEN fm.total_facturado < pm.promedio_general THEN 'Por debajo'
        ELSE 'Igual al promedio'
    END AS comparacion_promedio
FROM facturacion_mensual fm
CROSS JOIN promedio_mensual pm
ORDER BY fm.mes;
GO

-- =============================================
-- HALLAZGOS DE NEGOCIO
-- =============================================

-- 1. El producto 1 generó $3.600 de una facturación total de $6.444,
--    representando aproximadamente el 55,9% del total.
--    Conviene priorizar su disponibilidad de stock por su alto peso en los ingresos.

-- 2. El producto 2 fue el de mayor volumen, con 13 unidades vendidas,
--    pero generó solo $364 de facturación.
--    Esto sugiere una oportunidad para revisar precio, promociones o ventas cruzadas.

-- 3. Los clientes 1 y 5 gastaron en conjunto $4.740,
--    aproximadamente el 73,6% de la facturación total.
--    Conviene trabajar acciones de fidelización para estos clientes y, al mismo tiempo,
--    reducir la dependencia comercial ampliando la participación de otros clientes.