# Descripción de Procedimientos Almacenados

## sp_ActualizarTablasFrecuencia
Actualiza las tablas de frecuencia para las diferentes variables de análisis.
```sql
---------------------------------------------------- BEGIN CODE --------------------------------------------------
/* Crearemos un procedimiento almacenado para actualizar las tablas de frecuencia. */
CREATE PROCEDURE sp_ActualizarTablasFrecuencia
    @FilasAfectadas INT OUTPUT,
    @TablaTipo VARCHAR(50)
AS
BEGIN
    -- Variable para llevar el conteo total de filas actualizadas
    DECLARE @TotalFilasAfectadas INT = 0;

    -- ************************************************************
    -- 1. Variables de Cálculo Global
    -- ************************************************************
    DECLARE @FrecuenciaAbsoluta INT;
    -- Usamos DECIMAL para la división y CAST para evitar la división entera (INT/INT)
    DECLARE @TotalRegistros DECIMAL(10, 2); 
    DECLARE @FrecuenciaAnteriorAcumulada INT;


    IF @TablaTipo = 'Edad'
    BEGIN
        -- 1.1: Calcular el Total de Registros UNA SOLA VEZ (Eficiencia)
        SELECT @TotalRegistros = COUNT(ID_de_Jugador)
        FROM [dbo].[Tabla_De_Dimension_Jugador];

        -- 1.2: Variables para el Bucle de Intervalos
        DECLARE @IntervaloActualEdad INT = 2; -- Comenzamos desde el Intervalo 2
        DECLARE @LimiteInferiorEdad DECIMAL(10, 3) = 15.000;
        DECLARE @AmplitudEdad DECIMAL(10, 3) = 2.125;
        DECLARE @MaxIntervaloEdad INT = 16; -- 2 (original) + 14 nuevos intervalos = 16

        -- ************************************************************
        -- 2. BUCLE PARA ACTUALIZAR LOS 16 INTERVALOS (2 al 176)
        -- ************************************************************
        WHILE @IntervaloActualEdad <= @MaxIntervaloEdad
        BEGIN
            -- 2.1 Calcular los límites del intervalo actual
            DECLARE @LimiteSuperiorEdad DECIMAL(10, 3) = @LimiteInferiorEdad + @AmplitudEdad;

            -- 2.2 Calcular la Frecuencia Absoluta para el rango actual
            SELECT @FrecuenciaAbsoluta = COUNT(*)
            FROM [dbo].[Tabla_De_Dimension_Jugador]
            -- Rango: [LimiteInferior, LimiteSuperior)
            WHERE Edad >= @LimiteInferiorEdad AND Edad < @LimiteSuperiorEdad;
            
            -- 2.3 Obtener la Frecuencia Acumulada del intervalo anterior
            -- ISNULL garantiza que si el intervalo anterior no existe (ej. el Intervalo 1), se use 0
            SELECT @FrecuenciaAnteriorAcumulada = ISNULL(Frecuencia_Acumulada, 0)
            FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_Edad]
            WHERE Intervalo = @IntervaloActualEdad - 1; 

            -- 2.4 Actualizar la Fila correspondiente al Intervalo Actual
            UPDATE [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_Edad]
            SET 
                Frecuencia = @FrecuenciaAbsoluta,
                Frecuencia_Acumulada = @FrecuenciaAbsoluta + @FrecuenciaAnteriorAcumulada,
                
                -- Se utiliza CAST para forzar la división decimal
                Frecuencia_Relativa = (CAST(@FrecuenciaAbsoluta AS DECIMAL(10, 4)) / @TotalRegistros),

                -- Frecuencia Relativa Acumulada
                Frecuencia_Relativa_Acumulada = (CAST((@FrecuenciaAbsoluta + @FrecuenciaAnteriorAcumulada) AS DECIMAL(10, 4)) / @TotalRegistros),

                -- Frecuencia Porcentual (Relativa * 100)
                Frecuencia_Porcentual = (CAST(@FrecuenciaAbsoluta AS DECIMAL(10, 4)) / @TotalRegistros) * 100,

                -- Frecuencia Porcentual Acumulada
                Frecuencia_Porcentual_Acumulada = (CAST((@FrecuenciaAbsoluta + @FrecuenciaAnteriorAcumulada) AS DECIMAL(10, 4)) / @TotalRegistros) * 100
            WHERE 
                Intervalo = @IntervaloActualEdad; 
            
            SET @TotalFilasAfectadas = @TotalFilasAfectadas + @@ROWCOUNT;

            -- 2.5 Avanzar al siguiente intervalo
            SET @LimiteInferiorEdad = @LimiteSuperiorEdad;
            SET @IntervaloActualEdad = @IntervaloActualEdad + 1;
        END; -- Fin del WHILE

        SET @LimiteSuperiorEdad = 49.000;
        SET @LimiteInferiorEdad = 46.875;
        SET @IntervaloActualEdad = 17; -- El último intervalo es 17
        
        SELECT @FrecuenciaAbsoluta = COUNT(*)
            FROM [dbo].[Tabla_De_Dimension_Jugador]
            -- Rango: [LimiteInferior, LimiteSuperior)
            WHERE Edad >= @LimiteInferiorEdad AND Edad <= @LimiteSuperiorEdad;

            SELECT @FrecuenciaAnteriorAcumulada = ISNULL(Frecuencia_Acumulada, 0)
            FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_Edad]
            WHERE Intervalo = @IntervaloActualEdad - 1;
            -- 2.6 Actualizar la última Fila (Intervalo 17)
        UPDATE [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_Edad]
        SET
            Frecuencia = @FrecuenciaAbsoluta,
            Frecuencia_Acumulada = @FrecuenciaAbsoluta + @FrecuenciaAnteriorAcumulada,
            Frecuencia_Relativa = (CAST(@FrecuenciaAbsoluta AS DECIMAL(10, 4)) / @TotalRegistros),
            Frecuencia_Relativa_Acumulada = (CAST((@FrecuenciaAbsoluta + @FrecuenciaAnteriorAcumulada) AS DECIMAL(10, 4)) / @TotalRegistros),
            Frecuencia_Porcentual = (CAST(@FrecuenciaAbsoluta AS DECIMAL(10, 4)) / @TotalRegistros) * 100,
            Frecuencia_Porcentual_Acumulada = (CAST((@FrecuenciaAbsoluta + @FrecuenciaAnteriorAcumulada) AS DECIMAL(10, 4)) / @TotalRegistros) * 100
        WHERE
            Intervalo = @IntervaloActualEdad;
        SET @TotalFilasAfectadas = @TotalFilasAfectadas + @@ROWCOUNT;
    END -- Fin de IF @TablaTipo = 'Edad'
    
    ELSE IF @TablaTipo = 'SesionesPorSemana'
    BEGIN
        -- 1.1: Calcular el Total de Registros UNA SOLA VEZ (Eficiencia)
        SELECT @TotalRegistros = COUNT(ID_de_Jugador)
        FROM [dbo].[Tabla_De_Hechos_Comportamiento];

        -- 1.2: Variables para el Bucle de Intervalos
        DECLARE @IntervaloActualSesionesPorSemana INT = 3; -- Comenzamos desde el Intervalo 3
        DECLARE @LimiteInferiorSesionesPorSemana DECIMAL(10, 3) = 1.000;
        DECLARE @AmplitudSesionesPorSemana DECIMAL(10, 3) = 1.000;
        DECLARE @MaxIntervaloSesionesPorSemana INT = 11; -- 3 (original) + 9 nuevos intervalos = 11

        -- ************************************************************
        -- 2. BUCLE PARA ACTUALIZAR LOS 9 INTERVALOS (3 al 11)
        -- ************************************************************
        WHILE @IntervaloActualSesionesPorSemana <= @MaxIntervaloSesionesPorSemana
        BEGIN
            -- 2.1 Calcular los límites del intervalo actual
            DECLARE @LimiteSuperiorSesionesPorSemana DECIMAL(10, 3) = @LimiteInferiorSesionesPorSemana + @AmplitudSesionesPorSemana;

            -- 2.2 Calcular la Frecuencia Absoluta para el rango actual
            SELECT @FrecuenciaAbsoluta = COUNT(*)
            FROM [dbo].[Tabla_De_Hechos_Comportamiento]
            -- Rango: [LimiteInferior, LimiteSuperior)
            WHERE Sesiones_Por_Semana >= @LimiteInferiorSesionesPorSemana AND Sesiones_Por_Semana < @LimiteSuperiorSesionesPorSemana;
            
            -- 2.3 Obtener la Frecuencia Acumulada del intervalo anterior
            -- ISNULL garantiza que si el intervalo anterior no existe (ej. el Intervalo 2), se use 0
            SELECT @FrecuenciaAnteriorAcumulada = ISNULL(Frecuencia_Acumulada, 0)
            FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_SesionesPorSemana]
            WHERE Intervalo = @IntervaloActualSesionesPorSemana - 1;

            -- 2.4 Actualizar la Fila correspondiente al Intervalo Actual
            UPDATE [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_SesionesPorSemana]
            SET 
                Frecuencia = @FrecuenciaAbsoluta,
                Frecuencia_Acumulada = @FrecuenciaAbsoluta + @FrecuenciaAnteriorAcumulada,
                
                -- Se utiliza CAST para forzar la división decimal
                Frecuencia_Relativa = (CAST(@FrecuenciaAbsoluta AS DECIMAL(10, 4)) / @TotalRegistros),

                -- Frecuencia Relativa Acumulada
                Frecuencia_Relativa_Acumulada = (CAST((@FrecuenciaAbsoluta + @FrecuenciaAnteriorAcumulada) AS DECIMAL(10, 4)) / @TotalRegistros),

                -- Frecuencia Porcentual (Relativa * 100)
                Frecuencia_Porcentual = (CAST(@FrecuenciaAbsoluta AS DECIMAL(10, 4)) / @TotalRegistros) * 100,

                -- Frecuencia Porcentual Acumulada
                Frecuencia_Porcentual_Acumulada = (CAST((@FrecuenciaAbsoluta + @FrecuenciaAnteriorAcumulada) AS DECIMAL(10, 4)) / @TotalRegistros) * 100
            WHERE 
                Intervalo = @IntervaloActualSesionesPorSemana; 
            
            SET @TotalFilasAfectadas = @TotalFilasAfectadas + @@ROWCOUNT;

            -- 2.5 Avanzar al siguiente intervalo
            SET @LimiteInferiorSesionesPorSemana = @LimiteSuperiorSesionesPorSemana;
            SET @IntervaloActualSesionesPorSemana = @IntervaloActualSesionesPorSemana + 1;
        END; -- Fin del WHILE
        
        SET @LimiteSuperiorSesionesPorSemana = 10.000;
        SET @LimiteInferiorSesionesPorSemana = 9.000;
        SET @IntervaloActualSesionesPorSemana = 11; -- El último intervalo es 11
        
        SELECT @FrecuenciaAbsoluta = COUNT(*)
            FROM [dbo].[Tabla_De_Hechos_Comportamiento]
            -- Rango: [LimiteInferior, LimiteSuperior)
            WHERE Sesiones_Por_Semana >= @LimiteInferiorSesionesPorSemana AND Sesiones_Por_Semana <= @LimiteSuperiorSesionesPorSemana;

            SELECT @FrecuenciaAnteriorAcumulada = ISNULL(Frecuencia_Acumulada, 0)
            FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_SesionesPorSemana]
            WHERE Intervalo = @IntervaloActualSesionesPorSemana - 1;
            -- 2.6 Actualizar la última Fila (Intervalo 11)
        UPDATE [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_SesionesPorSemana]
        SET
            Frecuencia = @FrecuenciaAbsoluta,
            Frecuencia_Acumulada = @FrecuenciaAbsoluta + @FrecuenciaAnteriorAcumulada,
            Frecuencia_Relativa = (CAST(@FrecuenciaAbsoluta AS DECIMAL(10, 4)) / @TotalRegistros),
            Frecuencia_Relativa_Acumulada = (CAST((@FrecuenciaAbsoluta + @FrecuenciaAnteriorAcumulada) AS DECIMAL(10, 4)) / @TotalRegistros),
            Frecuencia_Porcentual = (CAST(@FrecuenciaAbsoluta AS DECIMAL(10, 4)) / @TotalRegistros) * 100,
            Frecuencia_Porcentual_Acumulada = (CAST((@FrecuenciaAbsoluta + @FrecuenciaAnteriorAcumulada) AS DECIMAL(10, 4)) / @TotalRegistros) * 100
        WHERE
            Intervalo = @IntervaloActualSesionesPorSemana;

        SET @TotalFilasAfectadas = @TotalFilasAfectadas + @@ROWCOUNT;

    END -- Fin de IF @TablaTipo = 'SesionesPorSemana'
    
    ELSE IF @TablaTipo = 'DuracionSesionHoras'
    BEGIN
        -- 1.1: Calcular el Total de Registros UNA SOLA VEZ (Eficiencia)
        SELECT @TotalRegistros = COUNT(ID_de_Jugador)
        FROM [dbo].[Tabla_De_Hechos_Comportamiento];

        -- 1.2: Variables para el Bucle de Intervalos
        DECLARE @IntervaloActualDuracionSesionHoras INT = 2; -- Comenzamos desde el Intervalo 2
        DECLARE @LimiteInferiorDuracionSesionHoras DECIMAL(10, 3) = 0.000;
        DECLARE @AmplitudDuracionSesionHoras DECIMAL(10, 3) = 0.500;
        DECLARE @MaxIntervaloDuracionSesionHoras INT = 16; -- 2 (original) + 14 nuevos intervalos = 16

        -- ************************************************************
        -- 2. BUCLE PARA ACTUALIZAR LOS 16 INTERVALOS (2 al 16)
        -- ************************************************************
        WHILE @IntervaloActualDuracionSesionHoras <= @MaxIntervaloDuracionSesionHoras
        BEGIN
            -- 2.1 Calcular los límites del intervalo actual
            DECLARE @LimiteSuperiorDuracionSesionHoras DECIMAL(10, 3) = @LimiteInferiorDuracionSesionHoras + @AmplitudDuracionSesionHoras;

            -- 2.2 Calcular la Frecuencia Absoluta para el rango actual
            SELECT @FrecuenciaAbsoluta = COUNT(*)
            FROM [dbo].[Tabla_De_Hechos_Comportamiento]
            -- Rango: [LimiteInferior, LimiteSuperior)
            WHERE Duración_de_Sesión_en_Horas_en_Promedio >= @LimiteInferiorDuracionSesionHoras
            AND Duración_de_Sesión_en_Horas_en_Promedio < @LimiteSuperiorDuracionSesionHoras;
            
            -- 2.3 Obtener la Frecuencia Acumulada del intervalo anterior
            -- ISNULL garantiza que si el intervalo anterior no existe (ej. el Intervalo 1), se use 0
            SELECT @FrecuenciaAnteriorAcumulada = ISNULL(Frecuencia_Acumulada, 0)
            FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_DuracionSesionHoras]
            WHERE Intervalo = @IntervaloActualDuracionSesionHoras - 1; 

            -- 2.4 Actualizar la Fila correspondiente al Intervalo Actual
            UPDATE [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_DuracionSesionHoras]
            SET 
                Frecuencia = @FrecuenciaAbsoluta,
                Frecuencia_Acumulada = @FrecuenciaAbsoluta + @FrecuenciaAnteriorAcumulada,
                
                -- Se utiliza CAST para forzar la división decimal
                Frecuencia_Relativa = (CAST(@FrecuenciaAbsoluta AS DECIMAL(10, 4)) / @TotalRegistros),

                -- Frecuencia Relativa Acumulada
                Frecuencia_Relativa_Acumulada = (CAST((@FrecuenciaAbsoluta + @FrecuenciaAnteriorAcumulada) AS DECIMAL(10, 4)) / @TotalRegistros),

                -- Frecuencia Porcentual (Relativa * 100)
                Frecuencia_Porcentual = (CAST(@FrecuenciaAbsoluta AS DECIMAL(10, 4)) / @TotalRegistros) * 100,

                -- Frecuencia Porcentual Acumulada
                Frecuencia_Porcentual_Acumulada = (CAST((@FrecuenciaAbsoluta + @FrecuenciaAnteriorAcumulada) AS DECIMAL(10, 4)) / @TotalRegistros) * 100
            WHERE 
                Intervalo = @IntervaloActualDuracionSesionHoras; 
            
            SET @TotalFilasAfectadas = @TotalFilasAfectadas + @@ROWCOUNT;

            -- 2.5 Avanzar al siguiente intervalo
            SET @LimiteInferiorDuracionSesionHoras = @LimiteSuperiorDuracionSesionHoras;
            SET @IntervaloActualDuracionSesionHoras = @IntervaloActualDuracionSesionHoras + 1;
        END; -- Fin del WHILE
        
        SET @LimiteSuperiorDuracionSesionHoras = 8.000;
        SET @LimiteInferiorDuracionSesionHoras = 7.500;
        SET @IntervaloActualDuracionSesionHoras = 17; -- El último intervalo es 17
        
        SELECT @FrecuenciaAbsoluta = COUNT(*)
            FROM [dbo].[Tabla_De_Hechos_Comportamiento]
            -- Rango: [LimiteInferior, LimiteSuperior)
            WHERE Duración_de_Sesión_en_Horas_en_Promedio >= @LimiteInferiorDuracionSesionHoras 
            AND Duración_de_Sesión_en_Horas_en_Promedio <= @LimiteSuperiorDuracionSesionHoras;

            SELECT @FrecuenciaAnteriorAcumulada = ISNULL(Frecuencia_Acumulada, 0)
            FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_DuracionSesionHoras]
            WHERE Intervalo = @IntervaloActualDuracionSesionHoras - 1;
            -- 2.6 Actualizar la última Fila (Intervalo 17)
        UPDATE [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_DuracionSesionHoras]
        SET
            Frecuencia = @FrecuenciaAbsoluta,
            Frecuencia_Acumulada = @FrecuenciaAbsoluta + @FrecuenciaAnteriorAcumulada,
            Frecuencia_Relativa = (CAST(@FrecuenciaAbsoluta AS DECIMAL(10, 4)) / @TotalRegistros),
            Frecuencia_Relativa_Acumulada = (CAST((@FrecuenciaAbsoluta + @FrecuenciaAnteriorAcumulada) AS DECIMAL(10, 4)) / @TotalRegistros),
            Frecuencia_Porcentual = (CAST(@FrecuenciaAbsoluta AS DECIMAL(10, 4)) / @TotalRegistros) * 100,
            Frecuencia_Porcentual_Acumulada = (CAST((@FrecuenciaAbsoluta + @FrecuenciaAnteriorAcumulada) AS DECIMAL(10, 4)) / @TotalRegistros) * 100
        WHERE
            Intervalo = @IntervaloActualDuracionSesionHoras;

        SET @TotalFilasAfectadas = @TotalFilasAfectadas + @@ROWCOUNT;

    END -- Fin de IF @TablaTipo = 'DuracionSesionHoras'
    
    ELSE
    BEGIN
        RAISERROR('El tipo de tabla ingresado (%s) no es válido. Debe ser "Edad", "SesionesPorSemana" o "DuracionSesionHoras".', 16, 1, @TablaTipo);
        RETURN -1;
    END;

    SET @FilasAfectadas = @TotalFilasAfectadas;
    RETURN 0;
END -- Fin de PROCEDURE sp_ActualizarTablasFrecuencia
GO

/* Llamamos al procedimiento almacenado para actualizar las tablas de frecuencia. */

---------------------------------- UPDATE EDAD ---------------------------------
-- 1. Declarar una variable para capturar el valor que devuelve el procedimiento
-- Debe ser del mismo tipo de dato que el parámetro de salida (@FilasAfectadas INT OUTPUT).
DECLARE @RegistrosActualizados INT;

-- 2. Ejecutar el procedimiento
-- Usar EXEC o EXECUTE. Se pasa la variable declarada (@RegistrosActualizados)
-- y se ADJUNTA la palabra clave OUTPUT para recibir el valor.
EXECUTE sp_ActualizarTablasFrecuencia
    @FilasAfectadas = @RegistrosActualizados OUTPUT,
    @TablaTipo = 'Edad'; -- Cambiar a 'SesionesPorSemana' o 'DuracionSesionHoras' según la tabla a actualizar

-- 3. Mostrar el resultado
-- Se consulta la variable para ver cuántas filas se actualizaron en total.
-- Idealmente, el valor debería ser 3 (una fila por cada UPDATE).
SELECT 
    'Procedimiento Finalizado' AS Estado,
    @RegistrosActualizados AS Total_De_Filas_Actualizadas;
GO
-------------------------------- UPDATE SESIONES POR SEMANA ---------------------------------
-- 1. Declarar una variable para capturar el valor que devuelve el procedimiento
-- Debe ser del mismo tipo de dato que el parámetro de salida (@FilasAfectadas INT OUTPUT).
DECLARE @RegistrosActualizados INT;

-- 2. Ejecutar el procedimiento
-- Usar EXEC o EXECUTE. Se pasa la variable declarada (@RegistrosActualizados)
-- y se ADJUNTA la palabra clave OUTPUT para recibir el valor.
EXECUTE sp_ActualizarTablasFrecuencia
    @FilasAfectadas = @RegistrosActualizados OUTPUT,
    @TablaTipo = 'SesionesPorSemana'; -- Cambiar a 'SesionesPorSemana' o 'DuracionSesionHoras' según la tabla a actualizar

-- 3. Mostrar el resultado
-- Se consulta la variable para ver cuántas filas se actualizaron en total.
-- Idealmente, el valor debería ser 3 (una fila por cada UPDATE).
SELECT 
    'Procedimiento Finalizado' AS Estado,
    @RegistrosActualizados AS Total_De_Filas_Actualizadas;
GO
------------------------------ UPDATE DURACIÓN DE SESIÓN HORAS --------------------------------
-- 1. Declarar una variable para capturar el valor que devuelve el procedimiento
-- Debe ser del mismo tipo de dato que el parámetro de salida (@FilasAfectadas INT OUTPUT).
DECLARE @RegistrosActualizados INT;

-- 2. Ejecutar el procedimiento
-- Usar EXEC o EXECUTE. Se pasa la variable declarada (@RegistrosActualizados)
-- y se ADJUNTA la palabra clave OUTPUT para recibir el valor.
EXECUTE sp_ActualizarTablasFrecuencia
    @FilasAfectadas = @RegistrosActualizados OUTPUT,
    @TablaTipo = 'DuracionSesionHoras'; -- Cambiar a 'SesionesPorSemana' o 'DuracionSesionHoras' según la tabla a actualizar

-- 3. Mostrar el resultado
-- Se consulta la variable para ver cuántas filas se actualizaron en total.
-- Idealmente, el valor debería ser 3 (una fila por cada UPDATE).
SELECT 
    'Procedimiento Finalizado' AS Estado,
    @RegistrosActualizados AS Total_De_Filas_Actualizadas;
GO

/* Comprobamos que las tablas de frecuencia se actualizaron correctamente */
SELECT * FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_Edad];
SELECT * FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_SesionesPorSemana];  
SELECT * FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_DuracionSesionHoras];
---------------------------------------------------- END CODE ----------------------------------------------------
```

### Parámetros
- @FilasAfectadas INT OUTPUT: Número de filas actualizadas
- @TablaTipo VARCHAR(50): Tipo de tabla a actualizar ('Edad', 'SesionesPorSemana', 'DuracionSesionHoras')

### Cálculos Realizados
- Frecuencia Absoluta
- Frecuencia Acumulada
- Frecuencia Relativa
- Frecuencia Relativa Acumulada
- Frecuencia Porcentual
- Frecuencia Porcentual Acumulada

### Ejemplo de Uso
```sql
DECLARE @RegistrosActualizados INT;
EXEC sp_ActualizarTablasFrecuencia
    @FilasAfectadas = @RegistrosActualizados OUTPUT,
    @TablaTipo = 'Edad';
```