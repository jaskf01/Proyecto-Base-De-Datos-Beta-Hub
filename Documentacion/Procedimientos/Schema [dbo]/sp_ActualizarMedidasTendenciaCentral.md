
# Procedimiento Almacenado: sp_ActualizarMedidasTendenciaCentral

## Parámetros
- `@FilasAfectadas INT OUTPUT`: Número de filas actualizadas por el procedimiento.

## Tablas involucradas
- `[dbo].[Tabla_De_Dimension_Jugador]`
- `[dbo].[Tabla_De_Hechos_Comportamiento]`
- `[Analisis_Cuantitativo_Juegos].[Medidas_Tendencia_Central_Juegos]`

## Validaciones
- Se asegura que la moda sea un único valor escalar mediante `TOP 1` y ordenamiento adicional.
- Se utiliza `PERCENTILE_CONT(0.5)` para calcular la mediana de forma precisa.

## Rendimiento
- Las subconsultas para moda, media y mediana pueden ser costosas en tablas grandes.
- Se recomienda tener índices en las columnas `Edad`, `Sesiones_por_Semana`, y `Duración_de_Sesión_en_Horas_en_Promedio`.

## Dependencias
- Requiere que las tablas de dimensión y hechos estén pobladas.
- Depende de la existencia de la tabla `[Analisis_Cuantitativo_Juegos].[Medidas_Tendencia_Central_Juegos]` con las variables: 'EDAD', 'SESIONES POR SEMANA', 'DURACIÓN DE SESIÓN HORAS'.

## Seguridad
- El procedimiento no accede a datos sensibles directamente.
- Se recomienda restringir su ejecución a roles como `etl_runner` o `db_admin`.

## Casos de uso
- Actualización periódica de medidas estadísticas para dashboards analíticos.
- Parte de un pipeline ETL para análisis descriptivo.

## Código SQL
```sql
CREATE PROCEDURE sp_ActualizarMedidasTendenciaCentral
    @FilasAfectadas INT OUTPUT
AS
BEGIN
    DECLARE @TotalFilasAfectadas INT = 0;
    DECLARE @ModaEdad DECIMAL(10, 2);
    DECLARE @ModaSesiones DECIMAL(10, 2);
    DECLARE @ModaDuracion DECIMAL(10, 2);

    SELECT @ModaEdad = (
        SELECT TOP 1 Edad 
        FROM [dbo].[Tabla_De_Dimension_Jugador] 
        GROUP BY Edad 
        ORDER BY COUNT(*) DESC, Edad ASC
    );

    SELECT @ModaSesiones = (
        SELECT TOP 1 Sesiones_por_Semana 
        FROM [dbo].[Tabla_De_Hechos_Comportamiento] 
        GROUP BY Sesiones_por_Semana 
        ORDER BY COUNT(*) DESC, Sesiones_por_Semana ASC
    );

    SELECT @ModaDuracion = (
        SELECT TOP 1 Duración_de_Sesión_en_Horas_en_Promedio 
        FROM [dbo].[Tabla_De_Hechos_Comportamiento]
        GROUP BY Duración_de_Sesión_en_Horas_en_Promedio 
        ORDER BY COUNT(*) DESC, Duración_de_Sesión_en_Horas_en_Promedio ASC
    );

    UPDATE [Analisis_Cuantitativo_Juegos].[Medidas_Tendencia_Central_Juegos]
    SET 
        RANGO = (SELECT MAX(Edad) - MIN(Edad) FROM [dbo].[Tabla_De_Dimension_Jugador]),
        MEDIA = (SELECT ROUND(AVG(Edad),2) FROM [dbo].[Tabla_De_Dimension_Jugador]),
        MEDIANA = (SELECT TOP 1 PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Edad ASC) OVER() FROM [dbo].[Tabla_De_Dimension_Jugador]),
        MODA = @ModaEdad 
    WHERE Variable = 'EDAD';

    SET @TotalFilasAfectadas = @TotalFilasAfectadas + @@ROWCOUNT;

    UPDATE [Analisis_Cuantitativo_Juegos].[Medidas_Tendencia_Central_Juegos]
    SET 
        RANGO = (SELECT MAX(Sesiones_por_Semana) - MIN(Sesiones_por_Semana) FROM [dbo].[Tabla_De_Hechos_Comportamiento]),
        MEDIA = (SELECT AVG(Sesiones_por_Semana) FROM [dbo].[Tabla_De_Hechos_Comportamiento]),
        MEDIANA = (SELECT TOP 1 PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Sesiones_por_Semana ASC) OVER() FROM [dbo].[Tabla_De_Hechos_Comportamiento]),
        MODA = @ModaSesiones 
    WHERE Variable = 'SESIONES POR SEMANA';

    SET @TotalFilasAfectadas = @TotalFilasAfectadas + @@ROWCOUNT;

    UPDATE [Analisis_Cuantitativo_Juegos].[Medidas_Tendencia_Central_Juegos]
    SET 
        RANGO = (SELECT MAX(Duración_de_Sesión_en_Horas_en_Promedio) - MIN(Duración_de_Sesión_en_Horas_en_Promedio) FROM [dbo].[Tabla_De_Hechos_Comportamiento]),
        MEDIA = (SELECT ROUND(AVG(Duración_de_Sesión_en_Horas_en_Promedio), 2) FROM [dbo].[Tabla_De_Hechos_Comportamiento]),
        MEDIANA = (SELECT TOP 1 PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Duración_de_Sesión_en_Horas_en_Promedio ASC) OVER() FROM [dbo].[Tabla_De_Hechos_Comportamiento]),
        MODA = @ModaDuracion 
    WHERE Variable = 'DURACIÓN DE SESIÓN HORAS';

    SET @TotalFilasAfectadas = @TotalFilasAfectadas + @@ROWCOUNT;

    SET @FilasAfectadas = @TotalFilasAfectadas;
    RETURN 0;
END
```

## Ejemplo de uso
```sql
DECLARE @RegistrosActualizados INT;
EXEC sp_ActualizarMedidasTendenciaCentral
    @FilasAfectadas = @RegistrosActualizados OUTPUT;
SELECT 'Procedimiento Finalizado' AS Estado, @RegistrosActualizados AS Total_De_Filas_Actualizadas;
```
