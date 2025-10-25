# Descripción de Procedimientos Almacenados

## sp_ActualizarMedidasTendenciaCentral
Actualiza las medidas de tendencia central (media, mediana, moda) para las variables de análisis.
```sql
---------------------------------------------------- BEGIN CODE --------------------------------------------------
/* Para saber siempre las medidas de tendencia central actualizadas, crearemos un procedimiento almacenado. */
CREATE PROCEDURE sp_ActualizarMedidasTendenciaCentral
    @FilasAfectadas INT OUTPUT
AS
BEGIN
    -- Variable para acumular el conteo de filas afectadas por las tres sentencias UPDATE
    DECLARE @TotalFilasAfectadas INT = 0;
    
    -- Variables para asegurar que el cálculo de la MODA siempre devuelva UN ÚNICO VALOR ESCALAR
    DECLARE @ModaEdad DECIMAL(10, 2);
    DECLARE @ModaSesiones DECIMAL(10, 2);
    DECLARE @ModaDuracion DECIMAL(10, 2);


    -- ************************************************************
    -- PASO 1: CALCULAR Y ASIGNAR LAS MODAS DE FORMA SEGURA
    -- Se utiliza una subconsulta externa para aislar el TOP 1 y forzar la unicidad.
    -- ************************************************************

    -- 1.1 Moda para 'EDAD' 
    SELECT @ModaEdad = (
        SELECT TOP 1 Edad 
        FROM [dbo].[Tabla_De_Dimension_Jugador] 
        GROUP BY Edad 
        ORDER BY COUNT(*) DESC, Edad ASC
    );

    -- 1.2 Moda para 'SESIONES POR SEMANA' 
    SELECT @ModaSesiones = (
        SELECT TOP 1 Sesiones_por_Semana 
        FROM [dbo].[Tabla_De_Hechos_Comportamiento] 
        GROUP BY Sesiones_por_Semana 
        ORDER BY COUNT(*) DESC, Sesiones_por_Semana ASC
    );

    -- 1.3 Moda para 'DURACIÓN DE SESIÓN HORAS' 
    SELECT @ModaDuracion = (
        SELECT TOP 1 Duración_de_Sesión_en_Horas_en_Promedio 
        FROM [dbo].[Tabla_De_Hechos_Comportamiento]
        GROUP BY Duración_de_Sesión_en_Horas_en_Promedio 
        ORDER BY COUNT(*) DESC, Duración_de_Sesión_en_Horas_en_Promedio ASC
    );


    -- ************************************************************
    -- PASO 2: ACTUALIZACIÓN DE MEDIDAS (Usando las variables de Moda)
    -- ************************************************************

    -- 2.1 Actualización para la variable 'EDAD'
    UPDATE [Analisis_Cuantitativo_Juegos].[Medidas_Tendencia_Central_Juegos]
    SET 
        RANGO = (SELECT MAX(Edad) - MIN(Edad) FROM [dbo].[Tabla_De_Dimension_Jugador]),
        MEDIA = (SELECT ROUND(AVG(Edad),2) FROM [dbo].[Tabla_De_Dimension_Jugador]),
        MEDIANA = (SELECT TOP 1 PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Edad ASC) OVER() FROM [dbo].[Tabla_De_Dimension_Jugador]), -- <<<< SOLUCIÓN 512
        MODA = @ModaEdad 
    WHERE
        Variable = 'EDAD';

    SET @TotalFilasAfectadas = @TotalFilasAfectadas + @@ROWCOUNT;


    -- 2.2 Actualización para la variable 'SESIONES POR SEMANA'
    UPDATE [Analisis_Cuantitativo_Juegos].[Medidas_Tendencia_Central_Juegos]
    SET 
        RANGO = (SELECT MAX(Sesiones_por_Semana) - MIN(Sesiones_por_Semana) FROM [dbo].[Tabla_De_Hechos_Comportamiento]),
        MEDIA = (SELECT AVG(Sesiones_por_Semana) FROM [dbo].[Tabla_De_Hechos_Comportamiento]),
        MEDIANA = (SELECT TOP 1 PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Sesiones_por_Semana ASC) OVER() FROM [dbo].[Tabla_De_Hechos_Comportamiento]), -- <<<< SOLUCIÓN 512
        MODA = @ModaSesiones 
    WHERE 
        Variable = 'SESIONES POR SEMANA';

    SET @TotalFilasAfectadas = @TotalFilasAfectadas + @@ROWCOUNT;


    -- 2.3 Actualización para la variable 'DURACIÓN DE SESIÓN HORAS'
    UPDATE [Analisis_Cuantitativo_Juegos].[Medidas_Tendencia_Central_Juegos]
    SET 
        RANGO = (SELECT MAX(Duración_de_Sesión_en_Horas_en_Promedio) - MIN(Duración_de_Sesión_en_Horas_en_Promedio) FROM [dbo].[Tabla_De_Hechos_Comportamiento]),
        MEDIA = (SELECT ROUND(AVG(Duración_de_Sesión_en_Horas_en_Promedio), 2) FROM [dbo].[Tabla_De_Hechos_Comportamiento]),
        MEDIANA = (SELECT TOP 1 PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Duración_de_Sesión_en_Horas_en_Promedio ASC) OVER() FROM [dbo].[Tabla_De_Hechos_Comportamiento]), -- <<<< SOLUCIÓN 512
        MODA = @ModaDuracion 
    WHERE 
        Variable = 'DURACIÓN DE SESIÓN HORAS';

    SET @TotalFilasAfectadas = @TotalFilasAfectadas + @@ROWCOUNT;
    
    -- ************************************************************
    -- 3. Finalización y Retorno
    -- ************************************************************

    SET @FilasAfectadas = @TotalFilasAfectadas;

    RETURN 0;
END
GO

/* Ejecutamos el procedimiento almacenado. */
-- 1. Declarar una variable para capturar el valor que devuelve el procedimiento
-- Debe ser del mismo tipo de dato que el parámetro de salida (@FilasAfectadas INT OUTPUT).
DECLARE @RegistrosActualizados INT;

-- 2. Ejecutar el procedimiento
-- Usar EXEC o EXECUTE. Se pasa la variable declarada (@RegistrosActualizados)
-- y se ADJUNTA la palabra clave OUTPUT para recibir el valor.
EXEC sp_ActualizarMedidasTendenciaCentral
    @FilasAfectadas = @RegistrosActualizados OUTPUT;

-- 3. Mostrar el resultado
-- Se consulta la variable para ver cuántas filas se actualizaron en total.
-- Idealmente, el valor debería ser 3 (una fila por cada UPDATE).
SELECT 
    'Procedimiento Finalizado' AS Estado,
    @RegistrosActualizados AS Total_De_Filas_Actualizadas_En_Tabla_Medidas;
GO
/* Comprobamos que las medidas de tendencia central se actualizaron correctamente */
SELECT * FROM [Analisis_Cuantitativo_Juegos].[Medidas_Tendencia_Central_Juegos];
GO
---------------------------------------------------- END CODE ----------------------------------------------------
```

### Parámetros
- @FilasAfectadas INT OUTPUT: Número de filas actualizadas

### Cálculos Realizados
- RANGO: Diferencia entre valor máximo y mínimo
- MEDIA: Promedio aritmético
- MEDIANA: Percentil 50
- MODA: Valor más frecuente

### Ejemplo de Uso
```sql
DECLARE @RegistrosActualizados INT;
EXEC sp_ActualizarMedidasTendenciaCentral
    @FilasAfectadas = @RegistrosActualizados OUTPUT;
```
