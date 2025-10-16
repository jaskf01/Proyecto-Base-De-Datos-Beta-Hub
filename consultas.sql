--Clase dia Jueves 09/10/2025

USE ComportamientoOnline
GO
-- Ver los primeros registros
SELECT TOP 10 * FROM ComportamientoOnlineDatos;

-- Contar cuántos registros existen
SELECT COUNT(*) AS TotalRegistros FROM ComportamientoOnlineDatos;

-- Promedio de edad por género
SELECT [Género], AVG([Edad]) AS PromedioEdad
FROM ComportamientoOnlineDatos
GROUP BY [Género];

-- Contar usuarios por país
SELECT [Ubicación], COUNT(*) AS TotalUsuarios
FROM ComportamientoOnlineDatos
GROUP BY [Ubicación]
ORDER BY TotalUsuarios DESC;

-- Filtrar usuarios mayores de 30 años
SELECT * FROM ComportamientoOnlineDatos
WHERE [Edad] > 30;

-- Usuarios que han hecho una compra
SELECT * FROM ComportamientoOnlineDatos
WHERE [Compra en Juego] > 0;



--Clase dia Martes 14/10/2025
--FUNCIONES ESCALARES
-- Genero de los jugadores en mayuscula
SELECT 
    [ID de Jugador],
    UPPER([Género]) AS GeneroEnMayuscula
FROM ComportamientoOnlineDatos;

--Cuantos caracteres tiene el genero de juego
SELECT 
    [Género de Juego],
    LEN([Género de Juego]) AS LargoDelTexto
FROM ComportamientoOnlineDatos;

-- Redondear la duración de sesión en horas a un decimal
SELECT 
    [ID de Jugador],
    ROUND([Duración de Sesión en Horas en Promedio], 1) AS DuracionRedondeada
FROM ComportamientoOnlineDatos;

--FUNCIONES DE AGREGACION
-- Promedio de edad de los jugadores
SELECT 
    AVG([Edad]) AS PromedioEdad
FROM ComportamientoOnlineDatos;

-- Edad máxima y mínima de los jugadores
SELECT 
    MAX([Edad]) AS EdadMaxima,
    MIN([Edad]) AS EdadMinima       
FROM ComportamientoOnlineDatos;
-- Nivel máximo de jugador
SELECT 
    MAX([Nivel de Jugador]) AS NivelMaximo
FROM ComportamientoOnlineDatos;

-- Suma total de compras en juego
SELECT 
    SUM([Compra en Juego]) AS TotalComprasEnJuego
FROM ComportamientoOnlineDatos;

-- Promedio de duración de sesión en horas por nivel de enganche mayor a 3 horas
SELECT 
    [Nivel de Enganche],
    AVG([Duración de Sesión en Horas en Promedio]) AS PromedioHoras
FROM ComportamientoOnlineDatos
GROUP BY [Nivel de Enganche]
HAVING AVG([Duración de Sesión en Horas en Promedio]) > 3;


--Clase dia Jueves 16/10/2025
-- Tabla complementaria 
CREATE TABLE GeneroJuegoInfo (
    [Género de Juego] NVARCHAR(100) PRIMARY KEY,
    [Tipo] NVARCHAR(50),
    [Popularidad] INT
);

INSERT INTO GeneroJuegoInfo VALUES
('Acción', 'Competitivo', 90),
('Aventura', 'Narrativo', 80),
('Estrategia', 'Mental', 75),
('Deportes', 'Realista', 85);

-- INNER JOIN para combinar tablas
SELECT                            -- Selecciona columnas específicas
    d.[ID de Jugador],            -- Columna de la tabla principal- d
    d.[Género de Juego],          -- Columna de la tabla principal -d
    g.[Tipo]                     -- Columna de la tabla relacionada  -g
FROM ComportamientoOnlineDatos AS d           -- Alias para la tabla principal
INNER JOIN GeneroJuegoInfo AS g               -- Alias para la tabla relacionada
    ON d.[Género de Juego] = g.[Género de Juego];   -- Condición de unión

-- LEFT JOIN para incluir todos los jugadores
--TODOS LOS JUGADORES / REGISTROS DE LA TABLA IZQUIERDA Y NO IMPORTA SI HAY O NO COINCIDENCIA EN LA TABLA DERECHA
SELECT
    d.[ID de Jugador],
    d.[Género de Juego],
    g.[Tipo],
    g.[Popularidad]
FROM ComportamientoOnlineDatos AS d
LEFT JOIN GeneroJuegoInfo AS g
    ON d.[Género de Juego] = g.[Género de Juego];   

-- Subconsultas
-- Jugadores mayores al promedio de edad
SELECT 
    [ID de Jugador],
    [Edad],
    [Ubicación]
FROM ComportamientoOnlineDatos
WHERE [Edad] > (
    SELECT AVG([Edad]) FROM ComportamientoOnlineDatos
);
-- Jugadores que han hecho compras superiores al promedio
SELECT 
    [ID de Jugador],
    [Compra en Juego]   
FROM ComportamientoOnlineDatos
WHERE [Compra en Juego] > (
    SELECT AVG([Compra en Juego]) FROM ComportamientoOnlineDatos
);

-- VISTAs
--jugadores menrores a 16 años
CREATE VIEW JugadoresMenores16 AS
SELECT 
    [ID de Jugador],
    [Edad],
    [Nivel de Jugador]
FROM ComportamientoOnlineDatos
WHERE [Edad] < 16;

-- Consultar la vista
SELECT * FROM JugadoresMenores16;

--ista juafores con nivel menor a 5
CREATE VIEW JugadoresNivel1 AS
SELECT
    [ID de Jugador],
    [Nivel de Jugador],
    [Duración de Sesión en Horas en Promedio]
FROM ComportamientoOnlineDatos
WHERE [Nivel de Jugador] = 1;

-- Consultar la vista
SELECT * FROM JugadoresNivel1;

--Jugadores con nivel igual a 3 y solo los primeros 20
CREATE VIEW JugadoresNivel3 AS
SELECT TOP 20
    [ID de Jugador],
    [Nivel de Jugador],
    [Duración de Sesión en Horas en Promedio]   
FROM ComportamientoOnlineDatos
WHERE [Nivel de Jugador] = 3;

-- Consultar la vista
SELECT * FROM JugadoresNivel3;