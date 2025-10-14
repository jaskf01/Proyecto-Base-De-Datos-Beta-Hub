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
