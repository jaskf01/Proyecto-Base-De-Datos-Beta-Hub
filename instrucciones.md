# Nombre de la Base de Datos: Comportamiento Online

## Objetivo
Importar datos desde un archivo CSV a una base de datos SQL Server y realizar consultas analíticas sobre el comportamiento de los jugadores.

## Pasos Generales
1. Crear base de datos en SQL Server:
```sql

--crear base da datos
CREATE DATABASE ComportamientoOnline;
GO
--seleccionar base de datos
USE ComportamientoOnline;
GO

--crear columnas para almacenar los datos de la tabla
CREATE TABLE ComportamientoOnlineDatos (
    [ID de Jugador] INT,
    [Género] NVARCHAR(50),
    [Edad] INT,
    [Ubicación] NVARCHAR(100),
    [Género de Juego] NVARCHAR(100),
    [Dificultdad de Juego] NVARCHAR(50),
    [Sesiones por Semana] INT,
    [Duración de Sesión en Horas en Promedio] DECIMAL(5,2),
    [Duración de Sesión en Minutos en Promedio] DECIMAL(6,2),
    [Nivel de Jugador] INT,
    [Logros Desbloqueados] INT,
    [Nivel de Enganche] NVARCHAR(50),
    [Compra en Juego] NVARCHAR(10)
);
GO

--insertar datos de la tabla
BULK INSERT ComportamientoOnlineDatos
FROM 'C:\Datos\DataSet_Comportamiento_Online.csv'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '0x0a',
    FIRSTROW = 2,
    CODEPAGE = '65001',
    TABLOCK
);
--mostrar los datos de la  tabla
SELECT * FROM ComportamientoOnlineDatos;


## Uso de GitHub Copilot
Escribe comentarios en SQL o Markdown para pedir sugerencias.
-- Consulta que muestre los jugadores con mayor nivel de enganche.


