CREATE DATABASE Comportamiento_Online_Jugadores;

-- Ahora deberíamos importar todas las tablas.

-- Manipulación de datos:
-- Nos aseguramos de usar la base de datos correcta.
USE Comportamiento_Online_Jugadores;
--------------------------------------------------- BEGIN CODE --------------------------------------------------
-- ANTES DE SUBIR DATOS TIENES QUE CREAR UNA TABLA VACÍA CON LA ESTRUCTURA CORRECTA.
-- Ejemplo de creación de tabla:
CREATE TABLE Tabla_De_Dimension_Jugador(
    [ID de Jugador] INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    [Género] NVARCHAR(50) COLLATE Modern_Spanish_CI_AS,
    [Edad] INT,
    [Ubicación] NVARCHAR(50) COLLATE Modern_Spanish_CI_AS,
);
GO
-- COMANDOS PARA VERIFICACIÓN O ELIMINACIÓN DE TABLAS.
DROP TABLE Tabla_De_Dimension_Jugador;
GO
SELECT * FROM [dbo].[Tabla_De_Dimension_Jugador];
GO
---------------------------------------------------- END CODE ----------------------------------------------------


---------------------------------------------------- BEGIN CODE --------------------------------------------------
-- Si es que nos hemos cargado ya los datos en SQL server management studio, procedemos a cargarlos en códigos TSQL.
-- Cargamos los datos de la tabla Dimensión_Juegos.
BULK INSERT [dbo].[Tabla_De_Hechos_Comportamiento_Jugadores]
FROM 'C:\Users\Usuario\Desktop\Hechos_Comportamiento_Jugadores.csv(LA DIRECCIÓN DEBE SER LA CORRECTA)'
WITH (
  FIRSTROW = 2,              -- Si no hay cabecera quita FIRSTROW o pon FIRSTROW = 1.
  FIELDTERMINATOR = ';',
  ROWTERMINATOR = '\n',
  CODEPAGE = '65001',
  TABLOCK
);
GO

BULK INSERT [Comportamiento_Online_Jugadores].[dbo].[Tabla_De_Dimension_Jugador]
FROM 'c:\Users\offic\Downloads\Tabla_De_Dimension_Jugador.csv'
WITH (
  FIRSTROW = 1,                  -- Si no hay cabecera quita FIRSTROW o pon FIRSTROW = 1.
  FIELDTERMINATOR = ';',
  ROWTERMINATOR = '0x0d0a',
  CODEPAGE = '65001',
  TABLOCK
);
GO

BULK INSERT [Comportamiento_Online_Jugadores].[dbo].[Tabla_De_Dimension_Jugador]
FROM 'c:\Users\offic\Downloads\Tabla_De_Dimension_Jugador.csv'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '0x0a',
    FIRSTROW = 2,
    CODEPAGE = '65001',
    TABLOCK
);
GO

-- POR SI COMETEMOS ALGÚN ERROR INSERTANDO, PODEMOS TRUNCAR LA TABLA Y VOLVER A INTENTARLO.
-- EJEMPLO:
TRUNCATE TABLE [Comportamiento_Online_Jugadores].[dbo].[Tabla_De_Dimension_Jugador];
/* Repetimos el procedimiento con las demás tablas.
---------- FIN DE CARGA ----------*/
---------------------------------------------------- END CODE ----------------------------------------------------


---------------------------------------------------- BEGIN CODE --------------------------------------------------
-- Se creó la tabla Clasificacion_Genero_Juegos donde se otorgaba un identificador único a cada categoría
-- de juego
/* Observamos que carecemos de una clasificación de los géneros de juegos con los que estamos trabajanado.
    Procedemos a crear una tabla nueva para almacenar esta información. */
CREATE TABLE [dbo].[Clasificacion_Genero_Juegos] (
    ID_de_Juego INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    Género NVARCHAR(50) NOT NULL UNIQUE,
);
GO
-- En caso de cometer algún error:
DROP TABLE [dbo].[Clasificacion_Genero_Juegos];
GO
-- INSERTAMOS LOS GÉNEROS DE JUEGOS USADOS EN NUESTRA BASE DE DATOS.
INSERT INTO [dbo].[Clasificacion_Genero_Juegos] (Género)
VALUES
       ('Estrategia'),
       ('Deportes'),
       ('Acción'),
       ('Juego de Roles'),
       ('Simulación')
;
GO
SELECT * FROM [dbo].[Clasificacion_Genero_Juegos] ORDER BY ID_de_Juego;
GO
-- ESTRATEGIA, DEPORTES, ACCION, JUEGO DE ROLES, SIMULACION.
---------------------------------------------------- END CODE ----------------------------------------------------


---------------------------------------------------- BEGIN CODE --------------------------------------------------
-- Se crea la tabla Rleacion_Dimension_Juegos como ayuda para poder visualizar los datos en un join antes de crear
-- una FK para la tabla Tabla_De_Dimension_Juego.
/* Observamos que la tabla de dimensión juego no tiene una columna que identifique de manera única cada juego.
   Por lo que usaremos la tabla Clasificacion_Genero_Juegos para agregar una columna ID_de_Juego a la tabla de dimensión juego.
   Para ello utilizaremos una Tabla que relacione ambas tablas (esto para poder ser añadida después como Foreign Key). */
SELECT 
    CGJ.ID_de_Juego, 
    TDJ.Género_de_Juego,    
    TDJ.Dificultdad_de_Juego
INTO [dbo].[Relacion_Dimension_Juegos]
FROM [dbo].[Tabla_De_Dimension_Juego] TDJ
LEFT JOIN [dbo].[Clasificacion_Genero_Juegos] CGJ
    ON TDJ.Género_de_Juego = CGJ.Género;
GO

SELECT * FROM [dbo].[Relacion_Dimension_Juegos];
GO
---------------------------------------------------- END CODE ----------------------------------------------------

---------------------------------------------------- BEGIN CODE --------------------------------------------------
-- Se crea la FK
/* Notamos que la tabla de dimensión juego le falta una Foreign Key de la tabla clasificacion_genero_juegos.
    Procedimiento para agregar la FK:
    Para ello empezamos modificando la tabla de dimensión juego. */
ALTER TABLE [dbo].[Tabla_De_Dimension_Juego]
ADD ID_de_Genero_Juego INT NULL;
GO
-- Por si cometemos algún error:
ALTER TABLE [dbo].[Tabla_De_Dimension_Juego]
DROP COLUMN ID_de_Genero_Juego;
GO
/* Ahora procedemos a actualizar la tabla de hechos comportamiento jugador con la información de la tabla de dimensión juego. */
UPDATE [dbo].[Tabla_De_Dimension_Juego]
SET ID_de_Genero_Juego = CGJ.ID_de_Juego
FROM [dbo].[Tabla_De_Dimension_Juego] TDJ
INNER JOIN [dbo].[Clasificacion_Genero_Juegos] CGJ
    ON TDJ.Género_de_Juego = CGJ.Género;
GO
-- Comprobamos que el código sea correcto antes de actualizar la tabla de dimension juego.
SELECT 
    *
FROM [dbo].[Tabla_De_Dimension_Juego] TDJ
INNER JOIN [dbo].[Clasificacion_Genero_Juegos] CGJ
    ON TDJ.Género_de_Juego = CGJ.Género
    ORDER BY ID_de_Jugador;
GO
-- Actualizamos y vemos el resultado.
SELECT * FROM [dbo].[Tabla_De_Dimension_Juego];
GO
/* Finalmente procedemos a agregar la Foreign Key. */
ALTER TABLE [dbo].[Tabla_De_Dimension_Juego]
ADD CONSTRAINT FK_Clasificacion_Genero_Juegos_Tabla_De_Dimension_Juego
FOREIGN KEY (ID_de_Genero_Juego)
REFERENCES [dbo].[Clasificacion_Genero_Juegos](ID_de_Juego);
GO
SELECT * FROM [dbo].[Tabla_De_Dimension_Juego];
GO
---------------------------------------------------- END CODE ----------------------------------------------------


-- CREACION SCHEMA ANALISIS CUANTITATIVO JUEGOS
---------------------------------------------------- BEGIN CODE --------------------------------------------------
/* Es evidente la necesidad de crear tablas para análisis continuos. 
    Por lo que crearemos un nuevo esquema en el que almacenar estas tablas con campos calculados.
    Idealmente utilizaremos vistas para este propósito. */
CREATE SCHEMA Analisis_Cuantitativo_Juegos;
GO
---------------------------------------------------- END CODE ----------------------------------------------------

---------------------------------------------------- BEGIN CODE --------------------------------------------------
-- Creamos las tablas dentro del esquema Analisis_Cuantitativo_Juegos.

/* Ahora crearemos tablas de frecuencia con campos calculados y que podamos actualizar cada vez que necesitemos. */
CREATE TABLE [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_SesionesPorSemana] (
    Intervalo INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
    Límite_Inferior DECIMAL(6,3) NULL,
    Límite_Superior DECIMAL(6,3) NULL,
    Marca_Clase DECIMAL (6,3) NULL, 
    Frecuencia INT NOT NULL,
    Frecuencia_Acumulada INT NULL,
    Frecuencia_Relativa DECIMAL(6,3) NULL,
    Frecuencia_Relativa_Acumulada DECIMAL(6,3) NULL,
    Frecuencia_Porcentual DECIMAL(6,3) NULL,
    Frecuencia_Porcentual_Acumulada DECIMAL(6,3) NULL,
);
GO

CREATE TABLE [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_Edad] (
    Intervalo INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
    Límite_Inferior DECIMAL(6,3) NULL,
    Clases_Inferior INT NULL,
    Clases_Superior INT NULL,
    Límite_Superior DECIMAL(6,3) NULL,
    Marca_Clase DECIMAL (6,3) NULL, 
    Frecuencia INT NOT NULL,
    Frecuencia_Acumulada INT NULL,
    Frecuencia_Relativa DECIMAL(6,3) NULL,
    Frecuencia_Relativa_Acumulada DECIMAL(6,3) NULL,
    Frecuencia_Porcentual DECIMAL(6,3) NULL,
    Frecuencia_Porcentual_Acumulada DECIMAL(6,3) NULL,
);
GO

CREATE TABLE [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_DuracionSesionHoras](
    Intervalo INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
    Límite_Inferior DECIMAL(6,3) NULL,
    Límite_Superior DECIMAL(6,3) NULL,
    Marca_Clase DECIMAL (6,3) NULL, 
    Frecuencia INT NOT NULL,
    Frecuencia_Acumulada INT NULL,
    Frecuencia_Relativa DECIMAL(6,3) NULL,
    Frecuencia_Relativa_Acumulada DECIMAL(6,3) NULL,
    Frecuencia_Porcentual DECIMAL(6,3) NULL,
    Frecuencia_Porcentual_Acumulada DECIMAL(6,3) NULL,
);
GO

/* Crearemos una tabla para almacenar las medidas de tendencia central de las variables de interés. */
CREATE TABLE [Analisis_Cuantitativo_Juegos].[Medidas_Tendencia_Central_Juegos] (
    Variable NVARCHAR(50) NOT NULL,
    RANGO DECIMAL(18,2) NOT NULL,
    MEDIA DECIMAL(18,2) NOT NULL,
    MEDIANA DECIMAL(18,2) NOT NULL,
    MODA DECIMAL(18,2) NOT NULL
);
GO
DROP TABLE [Analisis_Cuantitativo_Juegos].[Medidas_Tendencia_Central_Juegos];
GO

/* Crearemos una tabla para almacenar las medidas de dispersión de las variables de interés. */
CREATE TABLE [Analisis_Cuantitativo_Juegos].[Medidas_Dispersion_Juegos] (
    Variable NVARCHAR(50) NOT NULL,
    VARIANZA DECIMAL(18,2) NOT NULL,
    DESVIACIÓN_ESTÁNDAR DECIMAL(18,2) NOT NULL,
);
GO
---------------------------------------------------- END CODE ----------------------------------------------------

---------------------------------------------------- BEGIN CODE --------------------------------------------------
-- INSERTAMOS LOS VALORES CORRESPONDIENTES ANTES DE CREAR PROCEDIMIENTOS ALMACENADOS QUE OPTIMIZEN LOS DATOS.

/* Insertaremos los valores que tienen por predeterminado debido a la naturaleza de estas tablas y después
    procederemos a actualizar los campos calculados con un procedimiento almacenado. */
INSERT INTO [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_SesionesPorSemana](
    Límite_Inferior,
    Límite_Superior,
    Marca_Clase,
    Frecuencia,
    Frecuencia_Acumulada,
    Frecuencia_Relativa,
    Frecuencia_Relativa_Acumulada,
    Frecuencia_Porcentual,
    Frecuencia_Porcentual_Acumulada,
)
VALUES 
        (NULL,0,0,0,0,0,0,0,0),
        (0,1,0.5,0,0,0,0,0,0),
        (1,2,1.5,0,0,0,0,0,0),
        (2,3,2.5,0,0,0,0,0,0),
        (3,4,3.5,0,0,0,0,0,0),
        (4,5,4.5,0,0,0,0,0,0),
        (5,6,5.5,0,0,0,0,0,0),
        (6,7,6.5,0,0,0,0,0,0),
        (7,8,7.5,0,0,0,0,0,0),
        (8,9,8.5,0,0,0,0,0,0),
        (9,10,9.5,0,0,0,0,0,0),
        (11,NULL,0,0,0,0,0,0,0
        );
GO

-- Comprobamos insercción
SELECT * FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_SesionesPorSemana];
GO

/* Insertaremos los valores que tienen por predeterminado debido a la naturaleza de estas tablas y después
    procederemos a actualizar los campos calculados con un procedimiento almacenado. */
INSERT INTO [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_Edad](
    Límite_Inferior,
    Clases_Inferior,
    Clases_Superior,
    Límite_Superior,
    Marca_Clase,
    Frecuencia,
    Frecuencia_Acumulada,
    Frecuencia_Relativa,
    Frecuencia_Relativa_Acumulada,
    Frecuencia_Porcentual,
    Frecuencia_Porcentual_Acumulada,
)
VALUES 
        (NULL, NULL, NULL, 15, 13.5,0,0,0,0,0,0),
        (15,15,17,17.125,16,0,0,0,0,0,0),
        (17.125,18,19,19.250,18.5,0,0,0,0,0,0),
        (19.250,20,21,21.375,20.5,0,0,0,0,0,0),
        (21.375,22,23,23.500,22.5,0,0,0,0,0,0),
        (23.500,24,25,25.625,24.5,0,0,0,0,0,0),
        (25.625,26,27,27.750,26.5,0,0,0,0,0,0),
        (27.750,28,29,29.875,28.5,0,0,0,0,0,0),
        (29.875,30,31,32,30.5,0,0,0,0,0,0),
        (32,32,34,34.125,33,0,0,0,0,0,0),
        (34.125,35,36,36.250,35.5,0,0,0,0,0,0),
        (36.250,37,38,38.375,37.5,0,0,0,0,0,0),
        (38.375,39,40,40.500,39.5,0,0,0,0,0,0),
        (40.500,41,42,42.625,41.5,0,0,0,0,0,0),
        (42.625,43,44,44.750,43.5,0,0,0,0,0,0),
        (44.750,45,46,46.875,45.5,0,0,0,0,0,0),
        (46.875,47,49,49,48,0,0,0,0,0,0),
        (49,NULL,NULL,NULL,0,0,0,0,0,0,0
        );
GO

-- Comprobamos insercción
SELECT * FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_Edad];
GO

/* Insertaremos los valores que tienen por predeterminado debido a la naturaleza de estas tablas y después
    procederemos a actualizar los campos calculados con un procedimiento almacenado. */
INSERT INTO [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_DuracionSesionHoras](
    Límite_Inferior,
    Límite_Superior,
    Marca_Clase,
    Frecuencia,
    Frecuencia_Acumulada,
    Frecuencia_Relativa,
    Frecuencia_Relativa_Acumulada,
    Frecuencia_Porcentual,
    Frecuencia_Porcentual_Acumulada,
)
VALUES
        (NULL,0,0,0,0,0,0,0,0),
        (0,0.5,0.25,0,0,0,0,0,0),
        (0.5,1,0.75,0,0,0,0,0,0),
        (1,1.5,1.25,0,0,0,0,0,0),
        (1.5,2,1.75,0,0,0,0,0,0),
        (2,2.5,2.25,0,0,0,0,0,0),
        (2.5,3,2.75,0,0,0,0,0,0),
        (3,3.5,3.25,0,0,0,0,0,0),
        (3.5,4,3.75,0,0,0,0,0,0),
        (4,4.5,4.25,0,0,0,0,0,0),
        (4.5,5,4.75,0,0,0,0,0,0),
        (5,5.5,5.25,0,0,0,0,0,0),
        (5.5,6,5.75,0,0,0,0,0,0),
        (6,6.5,6.25,0,0,0,0,0,0),
        (6.5,7,6.75,0,0,0,0,0,0),
        (7,7.5,7.25,0,0,0,0,0,0),
        (7.5,8,7.75,0,0,0,0,0,0),
        (8,NULL,0,0,0,0,0,0,0
        );
GO

-- Comprobamos insercción
SELECT * FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_DuracionSesionHoras];
GO

/* Añadimos los campos calculados para cada columna en la tabla de medidas de tendencia central. */
INSERT INTO [Analisis_Cuantitativo_Juegos].[Medidas_Tendencia_Central_Juegos] (Variable, RANGO, MEDIA, MEDIANA, MODA)
VALUES
        ('EDAD', 
        (SELECT MAX(Edad) - MIN(Edad) FROM [dbo].[Tabla_De_Dimension_Jugador]), 
        (SELECT ROUND(AVG(Edad),2) FROM [dbo].[Tabla_De_Dimension_Jugador]), 
        (SELECT TOP 1 PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Edad ASC) OVER() FROM [dbo].[Tabla_De_Dimension_Jugador]), 
        (SELECT TOP 1 WITH TIES Edad FROM [dbo].[Tabla_De_Dimension_Jugador] GROUP BY Edad ORDER BY COUNT(*) DESC)),
        ('SESIONES POR SEMANA',
        (SELECT MAX(Sesiones_por_Semana) - MIN(Sesiones_por_Semana) FROM [dbo].[Tabla_De_Hechos_Comportamiento]), 
        (SELECT AVG(Sesiones_por_Semana) FROM [dbo].[Tabla_De_Hechos_Comportamiento]), 
        (SELECT TOP 1 PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Sesiones_por_Semana ASC) OVER() FROM [dbo].[Tabla_De_Hechos_Comportamiento]), 
        (SELECT TOP 1 WITH TIES Sesiones_por_Semana FROM [dbo].[Tabla_De_Hechos_Comportamiento] GROUP BY Sesiones_por_Semana ORDER BY COUNT(*) DESC)),
        ('DURACIÓN DE SESIÓN HORAS',
        (SELECT MAX(Duración_de_Sesión_en_Horas_en_Promedio) - MIN(Duración_de_Sesión_en_Horas_en_Promedio) FROM [dbo].[Tabla_De_Hechos_Comportamiento]), 
        (SELECT ROUND(AVG(Duración_de_Sesión_en_Horas_en_Promedio),2) FROM [dbo].[Tabla_De_Hechos_Comportamiento]), 
        (SELECT TOP 1 PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Duración_de_Sesión_en_Horas_en_Promedio ASC) OVER() FROM [dbo].[Tabla_De_Hechos_Comportamiento]), 
        (SELECT TOP 1 WITH TIES Duración_de_Sesión_en_Horas_en_Promedio FROM [dbo].[Tabla_De_Hechos_Comportamiento] GROUP BY Duración_de_Sesión_en_Horas_en_Promedio ORDER BY COUNT(*) DESC));
GO
-- Comprobamos Insercción
SELECT * FROM [Analisis_Cuantitativo_Juegos].[Medidas_Tendencia_Central_Juegos];
GO

/* Añadimos los campos calculados para cada columna en la tabla de medidas de dispersión. */
INSERT INTO [Analisis_Cuantitativo_Juegos].[Medidas_Dispersion_Juegos] (Variable, VARIANZA, DESVIACIÓN_ESTÁNDAR)
VALUES
        ('EDAD', 
        (SELECT VARP(Edad) FROM [dbo].[Tabla_De_Dimension_Jugador]), 
        (SELECT STDEVP(Edad) FROM [dbo].[Tabla_De_Dimension_Jugador])),
        ('SESIONES POR SEMANA',
        (SELECT VARP(Sesiones_por_Semana) FROM [dbo].[Tabla_De_Hechos_Comportamiento]), 
        (SELECT STDEVP(Sesiones_por_Semana) FROM [dbo].[Tabla_De_Hechos_Comportamiento])),
        ('DURACIÓN DE SESIÓN HORAS',
        (SELECT VARP(Duración_de_Sesión_en_Horas_en_Promedio) FROM [dbo].[Tabla_De_Hechos_Comportamiento]), 
        (SELECT STDEVP(Duración_de_Sesión_en_Horas_en_Promedio) FROM [dbo].[Tabla_De_Hechos_Comportamiento]));
GO
-- Comprobamos Insercción
SELECT * FROM [Analisis_Cuantitativo_Juegos].[Medidas_Dispersion_Juegos];
GO
---------------------------------------------------- END CODE ----------------------------------------------------

---------------------------------------------------- BEGIN CODE --------------------------------------------------
--Pasamos a la creación de procedimientos almacenados para optimizar los datos.

## Crearemos un procedimiento almacenado para actualizar las tablas de frecuencia. */
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

## Para saber siempre las medidas de tendencia central actualizadas, crearemos un procedimiento almacenado. */
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


## Crearemos un procedimiento almacenado para actualizar las medidas de dispersión. */
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

---------------------------------------------------- BEGIN CODE --------------------------------------------------
-- PROCEDEMOS A LA OPRTIMIZACIÓN DE CONSULTAS CON VISTAS.

/* Después de la creación de todas las tablas necesarias en nuestra base de datos, como habíamos mencionado en un principio,
    Nos tendremos que ayudar de vistas a las que usuarios tengan acceso para hacer un reporte simulado de lo que sería
    el proyecto, por lo que procederemoos a crearlas */
-- Creamos nuestra tercera Vista
CREATE VIEW [Analisis_Cuantitativo_Juegos].[VW_TablaFrecuenciaSesionesPorSemana]
AS
    SELECT
        Intervalo AS I,
        Límite_Inferior AS '>=',
        Límite_Superior AS '<',
        Frecuencia,
        Frecuencia_Acumulada,
        Frecuencia_Porcentual,
        Frecuencia_Porcentual_Acumulada
    FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_SesionesPorSemana];
GO

SELECT * FROM [Analisis_Cuantitativo_Juegos].[VW_TablaFrecuenciaSesionesPorSemana];
GO


/* Después de la creación de todas las tablas necesarias en nuestra base de datos, como habíamos mencionado en un principio,
    Nos tendremos que ayudar de vistas a las que usuarios tengan acceso para hacer un reporte simulado de lo que sería
    el proyecto, por lo que procederemoos a crearlas */
-- Creamos nuestra segunda Vista
CREATE VIEW [Analisis_Cuantitativo_Juegos].[VW_TablaFrecuenciaEdad]
AS
    SELECT
        Intervalo AS I,
        Clases_Inferior AS '>=',
        Clases_Superior AS '<',
        Frecuencia,
        Frecuencia_Acumulada,
        Frecuencia_Porcentual,
        Frecuencia_Porcentual_Acumulada
    FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_Edad];
GO

SELECT * FROM [Analisis_Cuantitativo_Juegos].[VW_TablaFrecuenciaEdad];
GO


/* Después de la creación de todas las tablas necesarias en nuestra base de datos, como habíamos mencionado en un principio,
    Nos tendremos que ayudar de vistas a las que usuarios tengan acceso para hacer un reporte simulado de lo que sería
    el proyecto, por lo que procederemoos a crearlas */
-- Creamos nuestra cuarta Vista
CREATE VIEW [Analisis_Cuantitativo_Juegos].[VW_TablaFrecuenciaDuracionSesionHoras]
AS
    SELECT
        Intervalo AS I,
        Límite_Inferior AS '>=',
        Límite_Superior AS '<',
        Frecuencia,
        Frecuencia_Acumulada,
        Frecuencia_Porcentual,
        Frecuencia_Porcentual_Acumulada
    FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_DuracionSesionHoras]
    WHERE Intervalo = '2' OR Intervalo ='4' OR Intervalo = '6' OR Intervalo = '8' OR Intervalo = '10' OR Intervalo = '12' OR Intervalo = '14' OR
    Intervalo = '16' OR Intervalo = '17';
GO

SELECT * FROM [Analisis_Cuantitativo_Juegos].[VW_TablaFrecuenciaDuracionSesionHoras];
GO

/* Después de la creación de todas las tablas necesarias en nuestra base de datos, como habíamos mencionado en un principio,
    Nos tendremos que ayudar de vistas a las que usuarios tengan acceso para hacer un reporte simulado de lo que sería
    el proyecto, por lo que procederemoos a crearlas */

CREATE VIEW [Analisis_Cuantitativo_Juegos].[VW_MedidasTendenciaCentral_Dispersion]
AS
    SELECT 
        MTCJ.Variable,
        MTCJ.RANGO,
        MTCJ.MEDIA,
        MTCJ.MEDIANA,
        MTCJ.MODA,
        MDJ.DESVIACIÓN_ESTÁNDAR,
        MDJ.VARIANZA
    FROM [Analisis_Cuantitativo_Juegos].[Medidas_Tendencia_Central_Juegos] MTCJ
    LEFT JOIN [Analisis_Cuantitativo_Juegos].[Medidas_Dispersion_Juegos] MDJ 
    ON MTCJ.Variable = MDJ.Variable;
GO

SELECT * FROM [Analisis_Cuantitativo_Juegos].[VW_MedidasTendenciaCentral_Dispersion];
GO
---------------------------------------------------- END CODE ----------------------------------------------------

---------------------------------------------------- BEGIN CODE --------------------------------------------------
-- Ahora procederemos a la creación de un trigger para actualizar todas las tablas hijas cada vez 
-- que se ingresen nuevos datos a la tabla madre.

/* Trigger para SINCRONIZAR los cambios de la Tabla_Madre hacia las tres tablas normalizadas (Dimensiones y Hechos).
    Se dispara DESPUÉS de cualquier INSERT o UPDATE. */
CREATE TRIGGER TRG_SincronizarHijasDesdeMadre
ON [dbo].[Tabla_Madre]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el ID_de_Jugador fue actualizado, ya que es la clave.
    -- Si el ID_de_Jugador fue modificado, la lógica de UPDATE no funcionaría correctamente.
    IF UPDATE(ID_de_Jugador)
    BEGIN
        RAISERROR('La columna ID_de_Jugador no debe ser modificada en la Tabla_Madre. No se ejecutará la sincronización.', 16, 1);
        RETURN;
    END

    -- 1. SINCRONIZACIÓN DE LA TABLA DIMENSIÓN JUGADOR (ID, Género, Edad, Ubicación)
    
    -- Usamos MERGE para manejar las inserciones y actualizaciones en un solo paso
    MERGE Tabla_De_Dimension_Jugador AS Target
    USING INSERTED AS Source
    ON (Target.ID_de_Jugador = Source.ID_de_Jugador)
    
    -- Cuando hay coincidencia (fila existe, es UPDATE)
    WHEN MATCHED THEN
        UPDATE SET 
            Target.Género = Source.Género,
            Target.Edad = Source.Edad,
            Target.Ubicación = Source.Ubicación
    
    -- Cuando NO hay coincidencia (fila no existe, es INSERT)
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (ID_de_Jugador, Género, Edad, Ubicación)
        VALUES (Source.ID_de_Jugador, Source.Género, Source.Edad, Source.Ubicación);


    -- 2. SINCRONIZACIÓN DE LA TABLA DIMENSIÓN JUEGO (ID, Género_de_Juego, Dificultad_de_Juego)
    
    MERGE Tabla_De_Dimension_Juego AS Target
    USING INSERTED AS Source
    ON (Target.ID_de_Jugador = Source.ID_de_Jugador)
    
    -- Cuando hay coincidencia (fila existe, es UPDATE)
    WHEN MATCHED THEN
        UPDATE SET 
            Target.Género_de_Juego = Source.Género_de_Juego,
            Target.Dificultad_de_Juego = Source.Dificultad_de_Juego
            -- Nota: ID_de_Genero_Juego (FK) no está en la tabla madre, no se actualiza
    
    -- Cuando NO hay coincidencia (fila no existe, es INSERT)
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (ID_de_Jugador, Género_de_Juego, Dificultad_de_Juego)
        VALUES (Source.ID_de_Jugador, Source.Género_de_Juego, Source.Dificultad_de_Juego);


    /* 3. SINCRONIZACIÓN DE LA TABLA DE HECHOS COMPORTAMIENTO
        (Nota: Esta tabla NO tiene PK por lo que no puede usar MERGE para UPDATE)
        Si es un INSERT, insertamos. Si es UPDATE, actualizamos TODAS las columnas excepto ID_de_Jugador. */

    -- Lógica para INSERT (sólo si es una nueva fila en INSERTED que no existía antes)
    IF EXISTS (SELECT 1 FROM INSERTED EXCEPT SELECT 1 FROM DELETED) -- Esto indica un INSERT completo
    BEGIN
        INSERT INTO Tabla_De_Hechos_Comportamiento (
            ID_de_Jugador, Sesiones_por_Semana, Duración_de_Sesión_en_Horas_en_Promedio, 
            Duración_de_Sesión_en_Minutos_en_Promedio, Nivel_de_Jugador, Logros_Desbloqueados, 
            Nivel_de_Enganche, Compra_en_Juego
        )
        SELECT 
            ID_de_Jugador, Sesiones_por_Semana, Duración_de_Sesión_en_Horas_en_Promedio, 
            Duración_de_Sesión_en_Minutos_en_Promedio, Nivel_de_Jugador, Logros_Desbloqueados, 
            Nivel_de_Enganche, Compra_en_Juego
        FROM INSERTED;
    END

    /* Lógica para UPDATE
        Este es el escenario más complejo, ya que la tabla de hechos no tiene PK.
        Sin una clave única, no podemos saber cuál fila específica actualizar.
        Lo más seguro y común en un modelo de hechos es INSERTAR una nueva fila para reflejar el estado actual. */
    IF EXISTS (SELECT 1 FROM INSERTED INTERSECT SELECT 1 FROM DELETED) -- Esto indica un UPDATE
    BEGIN
        -- Usamos UPDATE JOIN para actualizar la tabla de hechos con los nuevos valores de INSERTED
        UPDATE T
        SET 
            T.Sesiones_por_Semana = I.Sesiones_por_Semana,
            T.Duración_de_Sesión_en_Horas_en_Promedio = I.Duración_de_Sesión_en_Horas_en_Promedio,
            T.Duración_de_Sesión_en_Minutos_en_Promedio = I.Duración_de_Sesión_en_Minutos_en_Promedio,
            T.Nivel_de_Jugador = I.Nivel_de_Jugador,
            T.Logros_Desbloqueados = I.Logros_Desbloqueados,
            T.Nivel_de_Enganche = I.Nivel_de_Enganche,
            T.Compra_en_Juego = I.Compra_en_Juego
        FROM 
            Tabla_De_Hechos_Comportamiento AS T
        INNER JOIN 
            INSERTED AS I ON T.ID_de_Jugador = I.ID_de_Jugador;
        -- ADVERTENCIA: Esta actualización afectará potencialmente MÚLTIPLES filas de T si un jugador tiene más de un registro de hechos.
    END

END
GO
---------------------------------------------------- END CODE ----------------------------------------------------


---------------------------------------------------- BEGIN CODE --------------------------------------------------
/* Visualizar todas nuestras tablas creadas e importadas hasta el momento.(Este código nos ayuda con la organización de la documentación) */
SELECT * FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_CATALOG = 'Comportamiento_Online_Jugadores';
GO
/* Visualizar todas las columnas de una tabla específica. */
SELECT * FROM [dbo].[Tabla_Madre];
GO
/* Visualizar el esquema de una tabla específica. */
SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Tabla_Madre');
GO
---------------------------------------------------- END CODE ----------------------------------------------------