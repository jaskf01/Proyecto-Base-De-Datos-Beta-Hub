# Tabla_Frecuencia_DuracionSesionHoras

## Resumen
Tabla que almacena la distribución de frecuencias de la duración de las sesiones de juego en horas. Esta tabla permite analizar patrones de tiempo de juego y es fundamental para entender el comportamiento de los usuarios.

Propósito:
- Agrupar las duraciones de sesión en intervalos significativos
- Calcular frecuencias absolutas y relativas para análisis estadístico
- Servir como base para visualizaciones de distribución y reportes de engagement

## Estructura
| Columna | Tipo | Nullable | Default | Descripción |
|---------|------|----------|----------|-------------|
| ID_Rango | INT | NO | - | Identificador único del rango de duración |
| Limite_Inferior | DECIMAL(5,2) | NO | - | Valor mínimo del intervalo en horas |
| Limite_Superior | DECIMAL(5,2) | NO | - | Valor máximo del intervalo en horas |
| Frecuencia_Absoluta | INT | NO | 0 | Cantidad de sesiones en este rango |
| Frecuencia_Relativa | DECIMAL(5,4) | NO | 0 | Proporción sobre el total (entre 0 y 1) |
| Frecuencia_Acumulada | INT | NO | 0 | Suma acumulada de frecuencias hasta este rango |
| Porcentaje_Acumulado | DECIMAL(5,4) | NO | 0 | Porcentaje acumulado hasta este rango |
| Fecha_Actualizacion | DATETIME | NO | GETDATE() | Timestamp de último cálculo |

## Claves
- **Clave Primaria**: `ID_Rango`
- **Claves Foráneas**: No aplica (tabla de análisis estadístico)

## Índices
1. **PK_Tabla_Frecuencia_DuracionSesionHoras** (clustered)
   - Columnas: (`ID_Rango`)
   - Tipo: CLUSTERED
   - Unicidad: UNIQUE

2. **IX_Frecuencia_Limites**
   - Columnas: (`Limite_Inferior`, `Limite_Superior`)
   - Tipo: NONCLUSTERED
   - Utilidad: Búsquedas por rangos de duración

3. **IX_Frecuencia_Actualizacion**
   - Columnas: (`Fecha_Actualizacion`) INCLUDE (`Frecuencia_Absoluta`, `Frecuencia_Acumulada`)
   - Tipo: NONCLUSTERED
   - Utilidad: Análisis temporal y validación de datos

## Objetos relacionados

### Tablas fuente
- `[dbo].[Tabla_de_Hechos_Comportamiento]` - Fuente de datos de duración de sesiones

### Vistas
- `[Analisis_Cuantitativo_Juegos].[VW_TablaFrecuenciaDuracionSesionHoras]` - Vista para reporting
- `[Analisis_Cuantitativo_Juegos].[VW_DistribucionSesiones]` - Vista consolidada de patrones de juego

### Procedimientos almacenados
- `[dbo].[sp_ActualizarTablasFrecuencia]` - SP para actualizar todas las tablas de frecuencia
- `[dbo].[sp_CalcularFrecuenciasDuracion]` - SP específico para duración de sesiones

## Seguridad y clasificación

### Clasificación de datos
- **Nivel de sensibilidad**: BAJO
- **Tipo de datos**: Estadísticas agregadas de comportamiento
- **Retención**: 12 meses (rotación anual de datos históricos)

### Permisos requeridos
- SELECT: roles `data_analyst`, `bi_reader`, `marketing_analyst`
- INSERT/UPDATE: rol `etl_runner`
- TRUNCATE/DELETE: rol `db_owner` (operación restringida)

### Notas de seguridad
- No contiene datos personales identificables (PII)
- Los rangos y agregaciones protegen la privacidad individual
- Mantener auditoría de actualizaciones masivas

## DDL y notas de implementación
```sql
CREATE TABLE [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_DuracionSesionHoras] (
    ID_Rango INT NOT NULL,
    Limite_Inferior DECIMAL(5,2) NOT NULL,
    Limite_Superior DECIMAL(5,2) NOT NULL,
    Frecuencia_Absoluta INT NOT NULL DEFAULT 0,
    Frecuencia_Relativa DECIMAL(5,4) NOT NULL DEFAULT 0,
    Frecuencia_Acumulada INT NOT NULL DEFAULT 0,
    Porcentaje_Acumulado DECIMAL(5,4) NOT NULL DEFAULT 0,
    Fecha_Actualizacion DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_Tabla_Frecuencia_DuracionSesionHoras PRIMARY KEY CLUSTERED (ID_Rango),
    CONSTRAINT CHK_Limites_Validos CHECK (Limite_Superior > Limite_Inferior),
    CONSTRAINT CHK_Frecuencias_Positivas CHECK (Frecuencia_Absoluta >= 0),
    CONSTRAINT CHK_Porcentajes_Validos CHECK (Frecuencia_Relativa BETWEEN 0 AND 1)
);
```

### Notas de implementación
- Los rangos de duración sugeridos son de 0.5 horas para mejor interpretabilidad
- Mantener consistencia en el cálculo de frecuencias acumuladas
- Validar que la suma de frecuencias relativas sea 1 (100%)

## Resumen
Tabla de frecuencias para la variable "Duración de sesión (horas)". Guarda clases (intervalos), marcas de clase y las medidas derivadas necesarias para análisis descriptivo (frecuencia absoluta, acumulada, relativa y porcentual). Está pensada para poder recalcularse periódicamente desde la fuente (p.ej. `dbo.Tabla_Madre` o `Tabla_de_Hechos_Comportamiento`).

Esta ficha incluye:
- DDL corregido y recomendaciones de nombrado
- Descripción de columnas
- Procedimiento ETL recomendado para poblar/actualizar la tabla (incluyendo binning en 0.5 h)
- Ejemplos SQL para cálculo de relativos y acumulados
- Validaciones, uso en reporting y buenas prácticas

## DDL (origen + correcciones)
DDL extraído de `Scripts/.../Tabla_Frecuencia_DuracionSesionHoras.sql` con correcciones de sintaxis y compatibilidad:

```sql
-- Versión corregida y recomendada
CREATE TABLE [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_DuracionSesionHoras] (
		Intervalo INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
		Limite_Inferior DECIMAL(6,3) NULL,
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
- El DDL original contenía una coma final antes del paréntesis de cierre; la versión corregida la elimina para evitar error de sintaxis.
- Recomiendo usar nombres sin acentos (`Limite_Inferior`) para compatibilidad con herramientas y distintos SGBD. Si prefieres acentos, mantén los identificadores entre corchetes.
- Se ajustó la precisión de `Frecuencia_Relativa` a DECIMAL(6,6) para representar valores entre 0 y 1 con suficiente resolución.

## Descripción de columnas
- `Intervalo` (INT, PK): identificador secuencial de la clase.
- `Limite_Inferior` (DECIMAL): límite inferior del intervalo (horas).
- `Limite_Superior` (DECIMAL): límite superior del intervalo (horas).
- `Marca_Clase` (DECIMAL): punto medio o valor representativo del intervalo (horas).
- `Frecuencia` (INT): número de sesiones cuya duración cae en el intervalo.
- `Frecuencia_Acumulada` (INT): suma acumulada de la frecuencia hasta la clase actual.
- `Frecuencia_Relativa` (DECIMAL): `Frecuencia / Total_Observaciones` (0..1).
- `Frecuencia_Relativa_Acumulada` (DECIMAL): suma acumulada de las frecuencias relativas.
- `Frecuencia_Porcentual` (DECIMAL): `Frecuencia_Relativa * 100`.
- `Frecuencia_Porcentual_Acumulada` (DECIMAL): acumulado porcentual.

## Procedimiento recomendado para poblar/actualizar
1) Definir origen de los datos: p.ej. `Tabla_de_Hechos_Comportamiento.Duracion_Sesion_Horas` o `Tabla_Madre.Duracion_Sesion_Horas`.
2) Elegir estrategia de binning. Recomendación para duración: ancho de clase = 0.5 horas (30 minutos) para capturar granularidad útil.
3) Re-generativo (recomendado): TRUNCATE + INSERT para reproducibilidad.

Ejemplo: TRUNCATE

```sql
TRUNCATE TABLE [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_DuracionSesionHoras];
```

Ejemplo A — bins de 0.5 horas (recomendado)

```sql
DECLARE @k DECIMAL(6,3) = 0.5; -- ancho de clase en horas

;WITH bins AS (
	SELECT DISTINCT FLOOR(Duracion_Sesion_Horas / @k) * @k AS bin_start
	FROM dbo.Tabla_Madre
	WHERE Duracion_Sesion_Horas IS NOT NULL
)
INSERT INTO [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_DuracionSesionHoras]
(Limite_Inferior, Limite_Superior, Marca_Clase, Frecuencia)
SELECT
	bin_start AS Limite_Inferior,
	bin_start + @k AS Limite_Superior,
	bin_start + (@k/2.0) AS Marca_Clase,
	COUNT(*) AS Frecuencia
FROM dbo.Tabla_Madre m
JOIN bins b ON FLOOR(m.Duracion_Sesion_Horas / @k) * @k = b.bin_start
GROUP BY bin_start
ORDER BY bin_start;
```

Ejemplo B — tratar como variable continua con tope (ej. agrupar >8h en último bin)

```sql
-- Considerar top-coding para valores extremos
DECLARE @k DECIMAL(6,3) = 0.5; -- ancho de clase
DECLARE @maxBin DECIMAL(6,3) = 8.0; -- agrupar todo >8h en el último bin

;WITH b AS (
	SELECT CASE WHEN Duracion_Sesion_Horas >= @maxBin THEN @maxBin ELSE FLOOR(Duracion_Sesion_Horas / @k) * @k END AS bin_start
	FROM dbo.Tabla_Madre
	WHERE Duracion_Sesion_Horas IS NOT NULL
)
SELECT
	bin_start AS Limite_Inferior,
	CASE WHEN bin_start = @maxBin THEN NULL ELSE bin_start + @k END AS Limite_Superior,
	CASE WHEN bin_start = @maxBin THEN bin_start + (@k/2.0) ELSE bin_start + (@k/2.0) END AS Marca_Clase,
	COUNT(*) AS Frecuencia
FROM dbo.Tabla_Madre m
JOIN (SELECT DISTINCT bin_start FROM b) bins ON 1=1
WHERE (CASE WHEN m.Duracion_Sesion_Horas >= @maxBin THEN @maxBin ELSE FLOOR(m.Duracion_Sesion_Horas / @k) * @k END) = bins.bin_start
GROUP BY bin_start
ORDER BY bin_start;
```

## Calcular relativos, porcentuales y acumulados

```sql
DECLARE @Total INT = (SELECT COUNT(*) FROM dbo.Tabla_Madre WHERE Duracion_Sesion_Horas IS NOT NULL);

UPDATE t
SET
	Frecuencia_Relativa = CAST(Frecuencia AS DECIMAL(10,6)) / NULLIF(@Total,0),
	Frecuencia_Porcentual = (CAST(Frecuencia AS DECIMAL(10,6)) / NULLIF(@Total,0)) * 100
FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_DuracionSesionHoras] t;

WITH ordered AS (
	SELECT *,
		SUM(Frecuencia) OVER (ORDER BY Marca_Clase ROWS UNBOUNDED PRECEDING) AS running_freq,
		SUM(Frecuencia_Relativa) OVER (ORDER BY Marca_Clase ROWS UNBOUNDED PRECEDING) AS running_rel
	FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_DuracionSesionHoras]
)
UPDATE t
SET Frecuencia_Acumulada = o.running_freq,
		Frecuencia_Relativa_Acumulada = o.running_rel,
		Frecuencia_Porcentual_Acumulada = o.running_rel * 100
FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_DuracionSesionHoras] t
JOIN ordered o ON t.Intervalo = o.Intervalo;
```

## Validaciones y QA
- `SUM(Frecuencia)` debe ser igual a `@Total`.
- `Frecuencia_Relativa_Acumulada` debe terminar en ~1.0 (redondeo posible).
- Comprobar filas con `Frecuencia = 0` y decidir si mantenerlas para reporting.

## Uso en reporting
- Alimenta histogramas, tablas de frecuencia y cálculos de percentiles/medidas de dispersión (media, mediana, desvío estándar).
- Para dashboards, crear vistas que agreguen o filtren rangos (p.ej. 0-0.5h, 0.5-1h, 1-2h, >2h) según la necesidad del producto.

## Índices y performance
- Tabla de frecuencia normalmente pequeña; no requiere índices salvo casos de joins frecuentes por `Marca_Clase`.
- Si se regenera frecuentemente, TRUNCATE + INSERT es más eficiente que UPDATE incremental.

