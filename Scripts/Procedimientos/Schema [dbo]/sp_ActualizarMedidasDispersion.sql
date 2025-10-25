---------------------------------------------------- BEGIN CODE --------------------------------------------------
/* Crearemos un procedimiento almacenado para actualizar las medidas de dispersión. */
CREATE PROCEDURE sp_ActualizarMedidasDispersion
    @FilasAfectadas INT OUTPUT
AS
BEGIN
    DECLARE @TotalFilasAfectadas INT = 0;
    -- 1. Actualización para la variable 'EDAD'
    UPDATE [Analisis_Cuantitativo_Juegos].[Medidas_Dispersion_Juegos]
    SET 
        VARIANZA = (SELECT VARP(Edad) FROM [dbo].[Tabla_De_Dimension_Jugador]),
        DESVIACIÓN_ESTÁNDAR = (SELECT STDEVP(Edad) FROM [dbo].[Tabla_De_Dimension_Jugador])
    WHERE
        Variable = 'EDAD';
    
    SET @TotalFilasAfectadas = @TotalFilasAfectadas + @@ROWCOUNT;

    -- 2. Actualización para la variable 'SESIONES POR SEMANA'
    UPDATE [Analisis_Cuantitativo_Juegos].[Medidas_Dispersion_Juegos]
    SET 
        VARIANZA = (SELECT VARP(Sesiones_por_Semana) FROM [dbo].[Tabla_De_Hechos_Comportamiento]),
        DESVIACIÓN_ESTÁNDAR = (SELECT STDEVP(Sesiones_por_Semana) FROM [dbo].[Tabla_De_Hechos_Comportamiento])
    WHERE
        Variable = 'SESIONES POR SEMANA';
    
    SET @TotalFilasAfectadas = @TotalFilasAfectadas + @@ROWCOUNT;
    -- 1. Actualización para la variable 'DURACIÓN DE SESIÓN HORAS'
    UPDATE [Analisis_Cuantitativo_Juegos].[Medidas_Dispersion_Juegos]
    SET 
        VARIANZA = (SELECT VARP(Duración_de_Sesión_en_Horas_en_Promedio) FROM [dbo].[Tabla_De_Hechos_Comportamiento]),
        DESVIACIÓN_ESTÁNDAR = (SELECT STDEVP(Duración_de_Sesión_en_Horas_en_Promedio) FROM [dbo].[Tabla_De_Hechos_Comportamiento])
    WHERE
        Variable = 'DURACIÓN DE SESIÓN HORAS';

    SET @TotalFilasAfectadas = @TotalFilasAfectadas + @@ROWCOUNT;

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
EXEC sp_ActualizarMedidasDispersion
    @FilasAfectadas = @RegistrosActualizados OUTPUT;

-- 3. Mostrar el resultado
-- Se consulta la variable para ver cuántas filas se actualizaron en total.
-- Idealmente, el valor debería ser 3 (una fila por cada UPDATE).
SELECT 
    'Procedimiento Finalizado' AS Estado,
    @RegistrosActualizados AS Total_De_Filas_Actualizadas_En_Tabla_Medidas;
GO

/* Comprobamos que las medidas de dispersión se actualizaron correctamente */
SELECT * FROM [Analisis_Cuantitativo_Juegos].[Medidas_Dispersion_Juegos];
GO
---------------------------------------------------- END CODE ----------------------------------------------------