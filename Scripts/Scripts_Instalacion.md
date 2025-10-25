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

-- CREACION SCHEMA ANALISIS CUANTITATIVO JUEGOS ESO IRIA EN SCRIPT INSTALACION CREO
---------------------------------------------------- BEGIN CODE --------------------------------------------------
/* Es evidente la necesidad de crear tablas para análisis continuos. 
    Por lo que crearemos un nuevo esquema en el que almacenar estas tablas con campos calculados.
    Idealmente utilizaremos vistas para este propósito. */
CREATE SCHEMA Analisis_Cuantitativo_Juegos;
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