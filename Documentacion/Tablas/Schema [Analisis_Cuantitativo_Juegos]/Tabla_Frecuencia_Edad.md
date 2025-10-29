# Tabla_Frecuencia_Edad

## Resumen
Tabla de frecuencias para la variable "Edad". Guarda clases (intervalos), marcas de clase y medidas derivadas (frecuencia absoluta, acumulada, relativa y porcentual). Está diseñada para poder recalcularse periódicamente según el pipeline ETL.

## Estructura
| Columna | Tipo | Nullable | Default | Descripción |
|---------|------|----------|----------|-------------|
| Intervalo | INT | NO | IDENTITY(1,1) | Identificador secuencial de la clase |
| Limite_Inferior | DECIMAL(6,3) | SI | NULL | Límite inferior del intervalo |
| Clases_Inferior | INT | SI | NULL | Índice entero de la clase inferior |
| Clases_Superior | INT | SI | NULL | Índice entero de la clase superior |
| Limite_Superior | DECIMAL(6,3) | SI | NULL | Límite superior del intervalo |
| Marca_Clase | DECIMAL(6,3) | SI | NULL | Punto medio del intervalo |
| Frecuencia | INT | NO | - | Número de observaciones en la clase |
| Frecuencia_Acumulada | INT | SI | NULL | Suma acumulada de frecuencias |
| Frecuencia_Relativa | DECIMAL(6,6) | SI | NULL | Frecuencia / Total (0 a 1) |
| Frecuencia_Relativa_Acumulada | DECIMAL(6,6) | SI | NULL | Suma acumulada de frecuencias relativas |
| Frecuencia_Porcentual | DECIMAL(6,3) | SI | NULL | Frecuencia relativa * 100 |
| Frecuencia_Porcentual_Acumulada | DECIMAL(6,3) | SI | NULL | Acumulado porcentual |

## Claves
- **Clave Primaria**: `Intervalo` (INT IDENTITY)
- **Claves Foráneas**: No aplica (tabla de análisis estadístico)

## Índices
1. **PK_Tabla_Frecuencia_Edad** (clustered)
   - Columnas: (`Intervalo`)
   - Tipo: CLUSTERED
   - Unicidad: UNIQUE

2. **IX_Frecuencia_Edad_Marca**
   - Columnas: (`Marca_Clase`)
   - Tipo: NONCLUSTERED
   - Utilidad: Búsquedas y joins por valor de clase

3. **IX_Frecuencia_Edad_Limites**
   - Columnas: (`Limite_Inferior`, `Limite_Superior`)
   - Tipo: NONCLUSTERED
   - Utilidad: Búsquedas por rangos de edad

## Objetos relacionados

### Tablas fuente
- `[dbo].[Tabla_Madre]` - Fuente de datos de edad de los jugadores
- `[dbo].[Tabla_de_Dimension_Jugador]` - Dimensión con atributos de jugador

### Vistas
- `[Analisis_Cuantitativo_Juegos].[VW_TablaFrecuenciaEdad]` - Vista para reporting
- `[Analisis_Cuantitativo_Juegos].[VW_DistribucionEdades]` - Vista de análisis demográfico

### Procedimientos almacenados
- `[dbo].[sp_ActualizarTablasFrecuencia]` - SP para actualizar todas las tablas de frecuencia
- `[dbo].[sp_CalcularFrecuenciasEdad]` - SP específico para distribución de edades

## Seguridad y clasificación

### Clasificación de datos
- **Nivel de sensibilidad**: BAJO-MEDIO
- **Tipo de datos**: Estadísticas agregadas demográficas
- **Retención**: 24 meses (rotación bianual de datos históricos)

### Permisos requeridos
- SELECT: roles `data_analyst`, `bi_reader`, `marketing_analyst`
- INSERT/UPDATE: rol `etl_runner`
- TRUNCATE/DELETE: rol `db_owner` (operación restringida)

### Notas de seguridad
- Aunque contiene datos demográficos, están agregados sin identificadores
- Mantener intervalos suficientemente amplios para evitar identificación
- Aplicar redondeo en reporting para grupos pequeños
- Registrar en auditoría las actualizaciones masivas

## DDL y notas de implementación

```sql
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
    Frecuencia_Porcentual_Acumulada DECIMAL(6,3) NULL,
    CONSTRAINT CHK_Limites_Validos CHECK (Limite_Superior > Limite_Inferior),
    CONSTRAINT CHK_Frecuencias_Positivas CHECK (Frecuencia >= 0),
    CONSTRAINT CHK_Porcentajes_Validos CHECK (Frecuencia_Porcentual BETWEEN 0 AND 100)
);

CREATE NONCLUSTERED INDEX IX_Frecuencia_Edad_Marca ON [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_Edad](Marca_Clase);
CREATE NONCLUSTERED INDEX IX_Frecuencia_Edad_Limites ON [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_Edad](Limite_Inferior, Limite_Superior);
```

### Notas de implementación
- Se usan 3 decimales para mejor precisión en límites y marcas de clase
- Los campos de frecuencia relativa usan 6 decimales para cálculos exactos
- Se incluyen constraints para validar integridad de datos
- Los índices optimizan consultas comunes de reporting

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

