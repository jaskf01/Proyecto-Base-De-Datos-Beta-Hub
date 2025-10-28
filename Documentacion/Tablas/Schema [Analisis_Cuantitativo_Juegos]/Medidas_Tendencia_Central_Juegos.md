# Medidas_Tendencia_Central_Juegos

## Resumen
Tabla que almacena las medidas de tendencia central (rango, media, mediana, moda) para las variables de interés del esquema `Analisis_Cuantitativo_Juegos`.

Propósito:
- Mantener valores resumen (descripcion estadística) para variables como Edad, Sesiones por semana y Duración de sesión, con el fin de alimentar reportes y vistas analíticas.

## Observaciones sobre el SQL original
- El script original crea la tabla y a continuación la elimina con un `DROP TABLE` — esto borraría la tabla y los datos. En producción debe eliminarse el `DROP TABLE` o usarse en un contexto de testing controlado.
- Algunos identificadores y columnas en los SELECT contienen acentos y nombres distintos (`Duración_de_Sesión_en_Horas_en_Promedio`) — aconsejo normalizar nombres y usar los nombres exactos del DDL de las tablas fuente.
- El uso de `PERCENTILE_CONT(...) WITHIN GROUP (...) OVER()` debe revisarse: la forma correcta en T-SQL es usar PERCENTILE_CONT(...) WITHIN GROUP (ORDER BY columna) OVER() sin TOP 1, o calcular la mediana con funciones analíticas/CTE adecuadas. La sintaxis usada en el INSERT puede generar errores.
- Recomiendo almacenar metadata adicional: `Fecha_Reporte`, `Fuente` y `N` (tamaño muestral) para trazabilidad.

## DDL recomendado (mejoras)
Se sugiere una versión persistente y extendida de la tabla con metadatos:

```sql
CREATE TABLE [Analisis_Cuantitativo_Juegos].[Medidas_Tendencia_Central_Juegos] (
	Variable NVARCHAR(100) NOT NULL,
	Fecha_Reporte DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
	N INT NULL, -- tamaño muestral utilizado
	Rango DECIMAL(18,4) NULL,
	Media DECIMAL(18,4) NULL,
	Mediana DECIMAL(18,4) NULL,
	Moda DECIMAL(18,4) NULL,
	Fuente NVARCHAR(100) NULL,
	PRIMARY KEY (Variable, Fecha_Reporte)
);
```

Notas:
- `Variable` + `Fecha_Reporte` como clave primaria permite mantener un histórico (refresh diario o por batch).
- Aumenté la escala de decimales a 4 cifras para mayor precisión.

## SQL recomendado para calcular e insertar medidas (ejemplo)
Usar scripts separados por variable o un procedimiento almacenado. Ejemplo para `Edad` (ajusta nombres de tabla/columna según tu DDL real):

```sql
-- Ejemplo: calcular medidas para EDAD
DECLARE @N INT = (SELECT COUNT(Edad) FROM dbo.Tabla_De_Dimension_Jugador WHERE Edad IS NOT NULL);
DECLARE @Rango DECIMAL(18,4) = (SELECT MAX(Edad) - MIN(Edad) FROM dbo.Tabla_De_Dimension_Jugador WHERE Edad IS NOT NULL);
DECLARE @Media DECIMAL(18,4) = (SELECT AVG(CAST(Edad AS DECIMAL(18,4))) FROM dbo.Tabla_De_Dimension_Jugador WHERE Edad IS NOT NULL);
DECLARE @Mediana DECIMAL(18,4) = (
	SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Edad) OVER() FROM dbo.Tabla_De_Dimension_Jugador WHERE Edad IS NOT NULL
);
DECLARE @Moda DECIMAL(18,4) = (
	SELECT TOP 1 WITH TIES CAST(Edad AS DECIMAL(18,4))
	FROM dbo.Tabla_De_Dimension_Jugador
	WHERE Edad IS NOT NULL
	GROUP BY Edad
	ORDER BY COUNT(*) DESC
);

INSERT INTO [Analisis_Cuantitativo_Juegos].[Medidas_Tendencia_Central_Juegos]
	(Variable, Fecha_Reporte, N, Rango, Media, Mediana, Moda, Fuente)
VALUES
	('EDAD', CAST(GETDATE() AS DATE), @N, @Rango, @Media, @Mediana, @Moda, 'Tabla_De_Dimension_Jugador');
```

Para las variables que provienen de la tabla de hechos (por ejemplo `Sesiones_por_Semana` o `Duracion_Sesion_Horas`), reemplaza la fuente y la columna en las consultas anteriores.

## Alternativa: insert por UNION (más compacto)
Si prefieres calcular e insertar en una sola operación:

```sql
INSERT INTO [Analisis_Cuantitativo_Juegos].[Medidas_Tendencia_Central_Juegos]
	(Variable, Fecha_Reporte, N, Rango, Media, Mediana, Moda, Fuente)
SELECT 'EDAD', CAST(GETDATE() AS DATE),
	COUNT(Edad),
	MAX(Edad)-MIN(Edad),
	AVG(CAST(Edad AS DECIMAL(18,4))),
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Edad) OVER(),
	(SELECT TOP 1 WITH TIES CAST(Edad AS DECIMAL(18,4)) FROM dbo.Tabla_De_Dimension_Jugador WHERE Edad IS NOT NULL GROUP BY Edad ORDER BY COUNT(*) DESC),
	'Tabla_De_Dimension_Jugador'
FROM dbo.Tabla_De_Dimension_Jugador
WHERE Edad IS NOT NULL;
```

Observación: en T-SQL la expresión `PERCENTILE_CONT(...) WITHIN GROUP (...) OVER()` devuelve la mediana sobre el conjunto; comprueba compatibilidad de la versión de SQL Server que uses.

## Calidad de datos y validaciones
- Comprobar valores nulos antes de calcular (evitar dividir por cero o insertar filas con N=0).
- Registrar el `N` y la `Fuente` en la tabla para detectar cambios de población entre ejecuciones.
- Redondear o truncar según política de presentación, pero mantener mayor precisión en la tabla de origen.

## Procedimiento de refresco sugerido
1. Ejecutar en staging: calcular medidas y almacenar en tabla temporal.
2. Validar (comparar con medidas anteriores, revisar outliers).
3. Insertar en `Medidas_Tendencia_Central_Juegos` con `Fecha_Reporte`.
4. (Opcional) Generar vista `VW_MedidasTendenciaCentral_Juegos` que muestre la última fila por variable.

## Buenas prácticas y recomendaciones
- Evitar DROP TABLE en scripts de producción; si quieres recrear la tabla usar `CREATE TABLE IF NOT EXISTS` o migraciones versionadas.
- Añadir un campo `Batch_ID` si los cálculos se ejecutan varias veces por día.
- Documentar claramente el origen de cada variable (tabla y transformación previa).

