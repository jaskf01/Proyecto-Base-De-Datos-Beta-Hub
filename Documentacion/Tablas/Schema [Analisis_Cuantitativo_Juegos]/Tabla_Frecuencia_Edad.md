# Tabla_Frecuencia_Edad

## Resumen
Tabla de frecuencias para la variable "Edad". Guarda clases (intervalos), marcas de clase y medidas derivadas (frecuencia absoluta, acumulada, relativa y porcentual). Está diseñada para poder recalcularse periódicamente según el pipeline ETL.

Esta ficha incluye:
- DDL corregido y recomendaciones de nombrado
- Descripción de columnas (incluyendo `Clases_Inferior` / `Clases_Superior`)
- Procedimiento para poblar la tabla (discreta y agrupada)
- Ejemplos SQL para cálculo de relativos y acumulados
- Validaciones, usos y buenas prácticas

## DDL (origen + correcciones)
DDL extraído de `Scripts/.../Tabla_Frecuencia_Edad.sql` (se aplican correcciones para sintaxis y compatibilidad):

```sql
-- Versión corregida y recomendada
CREATE TABLE [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_Edad] (
		Intervalo INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
		Limite_Inferior DECIMAL(6,3) NULL,
		Clases_Inferior INT NULL,
		Clases_Superior INT NULL,
		Limite_Superior DECIMAL(6,3) NULL,
		Marca_Clase DECIMAL(6,3) NULL,
		Frecuencia INT NOT NULL,
		Frecuencia_Acumulada INT NULL,
		Frecuencia_Relativa DECIMAL(6,6) NULL,
		Frecuencia_Relativa_Acumulada DECIMAL(6,6) NULL,
		Frecuencia_Porcentual DECIMAL(6,3) NULL,
		Frecuencia_Porcentual_Acumulada DECIMAL(6,3) NULL
);
GO
```

Notas:
- Se eliminaron comas finales que generan error de sintaxis.
- Se recomienda evitar acentos en nombres de columnas (he usado `Limite_Inferior` en lugar de `Límite_Inferior`). Si deseas mantener acentos, usa siempre identificadores entre corchetes.
- `Clases_Inferior` y `Clases_Superior` permiten almacenar los índices enteros de la clase si usas numeración discreta (p.ej. clase 1..n).

## Descripción de columnas
- `Intervalo` (INT, PK): id secuencial de la clase.
- `Limite_Inferior` (DECIMAL): límite inferior del intervalo (según convención inclusive/exclusive).
- `Clases_Inferior` (INT): índice entero de la clase inferior (opcional; útil cuando se numeran clases).
- `Clases_Superior` (INT): índice entero de la clase superior (opcional).
- `Limite_Superior` (DECIMAL): límite superior del intervalo.
- `Marca_Clase` (DECIMAL): punto medio o valor representativo de la clase.
- `Frecuencia` (INT): número de observaciones en la clase.
- `Frecuencia_Acumulada` (INT): suma acumulada de `Frecuencia` hasta la clase actual.
- `Frecuencia_Relativa` (DECIMAL): `Frecuencia / Total` (valor entre 0 y 1).
- `Frecuencia_Relativa_Acumulada` (DECIMAL): suma acumulada de las frecuencias relativas.
- `Frecuencia_Porcentual` (DECIMAL): `Frecuencia_Relativa * 100`.
- `Frecuencia_Porcentual_Acumulada` (DECIMAL): acumulado porcentual.

## Procedimiento recomendado para poblar la tabla
1) Definir origen de datos: por ejemplo `dbo.Tabla_Madre.Edad`.
2) Decidir la estrategia: variable discreta (edad exacta en años) o agrupada (rango de edades con ancho k).
3) Re-generativo (recomendado para reproducibilidad): TRUNCATE + INSERT.

Ejemplo: TRUNCATE

```sql
TRUNCATE TABLE [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_Edad];
```

Ejemplo A — variable discreta (edad en años)

```sql
INSERT INTO [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_Edad]
		(Limite_Inferior, Limite_Superior, Marca_Clase, Clases_Inferior, Clases_Superior, Frecuencia)
SELECT
	CAST(Edad AS DECIMAL(6,3)) - 0.5 AS Limite_Inferior,
	CAST(Edad AS DECIMAL(6,3)) + 0.5 AS Limite_Superior,
	CAST(Edad AS DECIMAL(6,3)) AS Marca_Clase,
	Edad AS Clases_Inferior,
	Edad AS Clases_Superior,
	COUNT(*) AS Frecuencia
FROM dbo.Tabla_Madre m
WHERE Edad IS NOT NULL
GROUP BY Edad
ORDER BY Marca_Clase;
```

Ejemplo B — variable agrupada (intervalos de ancho k)

```sql
DECLARE @k INT = 5; -- ancho de clase (ej. 5 años)

;WITH bins AS (
	SELECT DISTINCT FLOOR(Edad / @k) AS bin_index
	FROM dbo.Tabla_Madre
	WHERE Edad IS NOT NULL
)
INSERT INTO [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_Edad]
SELECT
	CAST(bin_index*@k AS DECIMAL(6,3)) AS Limite_Inferior,
	CAST((bin_index*@k) + (@k - 1) AS DECIMAL(6,3)) AS Limite_Superior,
	CAST((bin_index*@k) + (@k/2.0) AS DECIMAL(6,3)) AS Marca_Clase,
	bin_index*@k AS Clases_Inferior,
	(bin_index*@k) + (@k - 1) AS Clases_Superior,
	COUNT(m.Edad) AS Frecuencia
FROM dbo.Tabla_Madre m
JOIN bins b ON FLOOR(m.Edad / @k) = b.bin_index
GROUP BY bin_index
ORDER BY bin_index;
```

## Calcular relativos, porcentuales y acumulados

```sql
DECLARE @Total INT = (SELECT COUNT(*) FROM dbo.Tabla_Madre WHERE Edad IS NOT NULL);

UPDATE t
SET
	Frecuencia_Relativa = CAST(Frecuencia AS DECIMAL(10,6)) / NULLIF(@Total,0),
	Frecuencia_Porcentual = (CAST(Frecuencia AS DECIMAL(10,6)) / NULLIF(@Total,0)) * 100
FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_Edad] t;

WITH ordered AS (
	SELECT *,
		SUM(Frecuencia) OVER (ORDER BY Marca_Clase ROWS UNBOUNDED PRECEDING) AS running_freq,
		SUM(Frecuencia_Relativa) OVER (ORDER BY Marca_Clase ROWS UNBOUNDED PRECEDING) AS running_rel
	FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_Edad]
)
UPDATE t
SET Frecuencia_Acumulada = o.running_freq,
		Frecuencia_Relativa_Acumulada = o.running_rel,
		Frecuencia_Porcentual_Acumulada = o.running_rel * 100
FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_Edad] t
JOIN ordered o ON t.Intervalo = o.Intervalo;
```

## Validaciones y QA
- `SUM(Frecuencia)` debe ser igual a `@Total`.
- `Frecuencia_Relativa_Acumulada` debe terminar en 1.0 (o cercano por redondeo).
- Revisar clases vacías; decidir si mantener filas con frecuencia 0 o eliminarlas según necesidad de reporting.

## Uso y consumo
- Alimenta vistas y reportes de distribución por edad, histogramas, cálculos de percentiles y medidas de tendencia/dispersion.
- Si se requiere, crear vistas agregadas para exponer solo columnas necesarias al reporting.

## Performance y mantenimiento
- Para tablas pequeñas no es necesario indexar; si se hacen joins frecuentes por `Marca_Clase`, crear índice nonclustered.
- Si la tabla se regenera enteramente, TRUNCATE + INSERT es más eficiente que UPDATE.

