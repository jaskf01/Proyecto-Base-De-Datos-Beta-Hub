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