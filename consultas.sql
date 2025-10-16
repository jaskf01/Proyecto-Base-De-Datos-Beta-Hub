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
