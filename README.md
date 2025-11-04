# Proyecto-Base-De-Datos-Beta-Hub
Proyecto Base de Datos del curso BetaHub del período agosto-noviembre 2025. Con un enfoque en el impacto de los videojuegos hacia el bienestar psicológico, este proyecto ha sido creado, generando conciencia y formas útiles de replicarlo con datos reales.


## INSTRUCCIONES.MD
# Nombre de la Base de Datos: Comportamiento Online

## Objetivo
Importar datos desde un archivo CSV a una base de datos SQL Server y realizar consultas analíticas sobre el comportamiento de los jugadores.

## Pasos Generales
1. Crear base de datos en SQL Server:
```sql

# Crear base da datos
CREATE DATABASE ComportamientoOnline;
GO
# Seleccionar base de datos
USE ComportamientoOnline;
GO

# Crear columnas para almacenar los datos de la tabla
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

# Insertar datos de la tabla
BULK INSERT ComportamientoOnlineDatos
FROM 'C:\Datos\DataSet_Comportamiento_Online.csv'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '0x0a',
    FIRSTROW = 2,
    CODEPAGE = '65001',
    TABLOCK
);
# Mostrar los datos de la  tabla
SELECT * FROM ComportamientoOnlineDatos;   */


## Uso de GitHub Copilot
Escribe comentarios en SQL o Markdown para pedir sugerencias.
-- Consulta que muestre los jugadores con mayor nivel de enganche.










## CONSULTAS.SQL
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







# Bitácora del Proyecto: Comportamiento Online

---

## Fecha de inicio:
09 de octubre de 2025

**Tema:** Análisis del Comportamiento Online de Jugadores
---

## Descripción General del Proyecto

El objetivo de este proyecto es **construir una base de datos en SQL Server** a partir de un **dataset en formato CSV**, el cual contiene información sobre el comportamiento de jugadores en línea.  
La base permitirá **realizar análisis y consultas** sobre distintos factores: edad, género, frecuencia de juego, tipo de juego, duración de sesiones y nivel de enganche.

El trabajo se desarrolla íntegramente en **Visual Studio Code**, **SQL Server Management Studio (SSMS)** y **GitHub Copilot** para asistencia de código y documentación.

---

## Etapa 1: Creación de la Base de Datos
**Acción realizada:**  
Se creó la base de datos llamada `ComportamientoOnline` en SQL Server.
**Script :**
```sql
--crear base da datos
CREATE DATABASE ComportamientoOnline;
GO
--seleccionar base de datos
USE ComportamientoOnline;
GO
```
**Resultado:**  
Base de datos creada con éxito y seleccionada para uso.



## Etapa 2: Reconstrucción desde Texto Plano (DDL)
**Acción realizada:**  
Creación de la tabla principal a partir de la estructura del archivo CSV, definiendo tipos de datos adecuados para cada columna.
```sql
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
```
**Resultado:**  
Tabla creada correctamente con todas las columnas y sus tipos de datos definidos.



## Etapa 3: Importación desde CSV
**Acción realizada:**  
La importación del dataset desde el archivo C:\Datos\DataSet_Comportamiento_Online.csv.
```sql
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
```
**Resultado:**  
Base de datos importada correctamente con todas sus columnas y filas.

## Etapa 4: Creación de procedimientos, vistas y triggers

**Acción realizada:**  
Se agregaron procedimientos almacenados para actualizar medidas estadísticas, un trigger para sincronizar la **Tabla_Madre** con tablas normalizadas (dimensión y hechos), y vistas para consulta y reporte.

### 1) Procedimientos
- `sp_ActualizarMedidasDispersion (@FilasAfectadas INT OUTPUT)`  
  Actualiza `VARIANZA` y `DESVIACIÓN_ESTÁNDAR` en `[Analisis_Cuantitativo_Juegos].[Medidas_Dispersion_Juegos]` a partir de:
  - `[dbo].[Tabla_De_Dimension_Jugador]` (Edad)
  - `[dbo].[Tabla_De_Hechos_Comportamiento]` (Sesiones_por_Semana, Duración_de_Sesión_en_Horas_en_Promedio)

- `sp_ActualizarMedidasTendenciaCentral (@FilasAfectadas INT OUTPUT)`  
  Actualiza `RANGO`, `MEDIA`, `MEDIANA`, `MODA` en `[Analisis_Cuantitativo_Juegos].[Medidas_Tendencia_Central_Juegos]`.  
  La **moda** se calcula de forma segura (TOP 1 por mayor frecuencia, desempate ascendente).

- `sp_ActualizarTablasFrecuencia (@FilasAfectadas INT OUTPUT, @TablaTipo VARCHAR(50))`  
  Recalcula las tablas de frecuencia según `@TablaTipo` ∈ {`Edad`, `SesionesPorSemana`, `DuracionSesionHoras`}, actualizando:  
  `Frecuencia`, `Frecuencia_Acumulada`, `Frecuencia_Relativa`, `Frecuencia_Relativa_Acumulada`, `Frecuencia_Porcentual`, `Frecuencia_Porcentual_Acumulada`.

### 2) Trigger
- `TRG_SincronizarHijasDesdeMadre` (AFTER INSERT, UPDATE en `[dbo].[Tabla_Madre]`)  
  - **Prohíbe** cambios en `ID_de_Jugador` (clave).  
  - Sincroniza:
    - `[dbo].[Tabla_De_Dimension_Jugador]` (MERGE)
    - `[dbo].[Tabla_De_Dimension_Juego]` (MERGE)
    - `[dbo].[Tabla_De_Hechos_Comportamiento]` (INSERT y UPDATE por join en `ID_de_Jugador`)

> Nota: Si la tabla de hechos no tiene PK, un UPDATE podría afectar varias filas por jugador; el script conserva el comportamiento que describiste.

### 3) Vistas (para reporteo)
- `[Analisis_Cuantitativo_Juegos].[VW_MedidasTendenciaCentral_Dispersion]`  
  Une tendencia central + dispersión por variable.

- `[Analisis_Cuantitativo_Juegos].[VW_TablaFrecuenciaDuracionSesionHoras]`  
  Intervalos seleccionados: 2,4,6,8,10,12,14,16,17.

- `[Analisis_Cuantitativo_Juegos].[VW_TablaFrecuenciaEdad]`  
  Todas las filas de la tabla de frecuencia de Edad.

- `[Analisis_Cuantitativo_Juegos].[VW_TablaFrecuenciaSesionesPorSemana]`  
  Todas las filas de la tabla de frecuencia de Sesiones por semana.

**Resultado esperado:**  
Quedan disponibles SPs para recalcular métricas, un trigger de sincronización de tablas normalizadas y vistas para consulta y dashboards.

**Ejecución rápida (ejemplos):**
```sql
-- Dispersión
DECLARE @n INT; EXEC dbo.sp_ActualizarMedidasDispersion @FilasAfectadas=@n OUTPUT; SELECT @n AS filas_dispersion;

-- Tendencia central
DECLARE @m INT; EXEC dbo.sp_ActualizarMedidasTendenciaCentral @FilasAfectadas=@m OUTPUT; SELECT @m AS filas_tend_central;

-- Frecuencia (elige una)
DECLARE @k INT; EXEC dbo.sp_ActualizarTablasFrecuencia @FilasAfectadas=@k OUTPUT, @TablaTipo='Edad';                 SELECT @k AS filas_freq;
DECLARE @k INT; EXEC dbo.sp_ActualizarTablasFrecuencia @FilasAfectadas=@k OUTPUT, @TablaTipo='SesionesPorSemana';  SELECT @k AS filas_freq;
DECLARE @k INT; EXEC dbo.sp_ActualizarTablasFrecuencia @FilasAfectadas=@k OUTPUT, @TablaTipo='DuracionSesionHoras';SELECT @k AS filas_freq;

-- Vistas
SELECT TOP 10 * FROM [Analisis_Cuantitativo_Juegos].[VW_MedidasTendenciaCentral_Dispersion];
SELECT TOP 10 * FROM [Analisis_Cuantitativo_Juegos].[VW_TablaFrecuenciaEdad];
SELECT TOP 10 * FROM [Analisis_Cuantitativo_Juegos].[VW_TablaFrecuenciaSesionesPorSemana];
SELECT TOP 10 * FROM [Analisis_Cuantitativo_Juegos].[VW_TablaFrecuenciaDuracionSesionHoras];

## Etapa 5: Consultas
```sql
--mostrar los datos de la  tabla
SELECT * FROM ComportamientoOnlineDatos;

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
```

## Uso de GitHub Copilot
-Sugerencia de tipos de datos en el DDL.
-Comentarios automáticos en el código SQL.
-Formato de Markdown y títulos de la bitácora.
**Beneficios Observados:**  
Copilot ayudó a acelerar la escritura de scripts, reducir errores sintácticos y mantener una documentación clara y organizada.
