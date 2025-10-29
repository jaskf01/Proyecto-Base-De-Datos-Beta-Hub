
# Procedimiento Almacenado: sp_ActualizarMedidasDispersion

## Parámetros
- `@FilasAfectadas INT OUTPUT`: Número total de filas actualizadas por el procedimiento.

## Tablas involucradas
- `[Analisis_Cuantitativo_Juegos].[Medidas_Dispersion_Juegos]`: Tabla destino donde se actualizan las medidas.
- `[dbo].[Tabla_De_Dimension_Jugador]`: Fuente para la variable `Edad`.
- `[dbo].[Tabla_De_Hechos_Comportamiento]`: Fuente para `Sesiones_por_Semana` y `Duración_de_Sesión_en_Horas_en_Promedio`.

## Validaciones
- Se espera que la tabla `Medidas_Dispersion_Juegos` contenga una fila por variable (`EDAD`, `SESIONES POR SEMANA`, `DURACIÓN DE SESIÓN HORAS`).
- Se recomienda validar que las columnas de origen no contengan valores nulos extremos antes de calcular varianza y desviación estándar.

## Rendimiento
- Las subconsultas usan funciones agregadas (`VARP`, `STDEVP`) sobre tablas posiblemente grandes.
- Se recomienda tener índices en las columnas utilizadas (`Edad`, `Sesiones_por_Semana`, `Duración_de_Sesión_en_Horas_en_Promedio`) para mejorar el rendimiento.

## Dependencias
- Depende de la existencia y estructura de las tablas:
  - `Medidas_Dispersion_Juegos`
  - `Tabla_De_Dimension_Jugador`
  - `Tabla_De_Hechos_Comportamiento`

## Seguridad
- El procedimiento no modifica datos sensibles directamente.
- Se recomienda restringir su ejecución a roles como `etl_runner` o `data_engineer`.

## Casos de uso
- Actualización periódica (diaria/semanal) de métricas estadísticas para dashboards o modelos analíticos.
- Parte de un pipeline ETL para mantener actualizadas las medidas de dispersión.

## Código SQL
```sql
CREATE PROCEDURE sp_ActualizarMedidasDispersion
    @FilasAfectadas INT OUTPUT
AS
BEGIN
    DECLARE @TotalFilasAfectadas INT = 0;

    UPDATE [Analisis_Cuantitativo_Juegos].[Medidas_Dispersion_Juegos]
    SET 
        VARIANZA = (SELECT VARP(Edad) FROM [dbo].[Tabla_De_Dimension_Jugador]),
        DESVIACIÓN_ESTÁNDAR = (SELECT STDEVP(Edad) FROM [dbo].[Tabla_De_Dimension_Jugador])
    WHERE Variable = 'EDAD';
    SET @TotalFilasAfectadas += @@ROWCOUNT;

    UPDATE [Analisis_Cuantitativo_Juegos].[Medidas_Dispersion_Juegos]
    SET 
        VARIANZA = (SELECT VARP(Sesiones_por_Semana) FROM [dbo].[Tabla_De_Hechos_Comportamiento]),
        DESVIACIÓN_ESTÁNDAR = (SELECT STDEVP(Sesiones_por_Semana) FROM [dbo].[Tabla_De_Hechos_Comportamiento])
    WHERE Variable = 'SESIONES POR SEMANA';
    SET @TotalFilasAfectadas += @@ROWCOUNT;

    UPDATE [Analisis_Cuantitativo_Juegos].[Medidas_Dispersion_Juegos]
    SET 
        VARIANZA = (SELECT VARP(Duración_de_Sesión_en_Horas_en_Promedio) FROM [dbo].[Tabla_De_Hechos_Comportamiento]),
        DESVIACIÓN_ESTÁNDAR = (SELECT STDEVP(Duración_de_Sesión_en_Horas_en_Promedio) FROM [dbo].[Tabla_De_Hechos_Comportamiento])
    WHERE Variable = 'DURACIÓN DE SESIÓN HORAS';
    SET @TotalFilasAfectadas += @@ROWCOUNT;

    SET @FilasAfectadas = @TotalFilasAfectadas;
    RETURN 0;
END
```
