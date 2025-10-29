# Tabla_Frecuencia_SesionesPorSemana

## Resumen
Tabla de frecuencias para la variable "Sesiones por semana". Almacena la distribución del número de sesiones de juego por semana de los usuarios, permitiendo analizar patrones de engagement y actividad.

## Estructura
| Columna | Tipo | Nullable | Default | Descripción |
|---------|------|----------|----------|-------------|
| Intervalo | INT | NO | IDENTITY(1,1) | Identificador secuencial de la clase |
| Limite_Inferior | DECIMAL(6,3) | SI | NULL | Límite inferior del intervalo |
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
1. **PK_Tabla_Frecuencia_SesionesPorSemana** (clustered)
   - Columnas: (`Intervalo`)
   - Tipo: CLUSTERED
   - Unicidad: UNIQUE

2. **IX_Frecuencia_Sesiones_Marca**
   - Columnas: (`Marca_Clase`) INCLUDE (`Frecuencia`, `Frecuencia_Acumulada`)
   - Tipo: NONCLUSTERED
   - Utilidad: Optimizar consultas de distribución y percentiles

3. **IX_Frecuencia_Sesiones_Fecha**
   - Columnas: (`Frecuencia_Relativa`) INCLUDE (`Frecuencia_Porcentual`)
   - Tipo: NONCLUSTERED
   - Utilidad: Análisis de distribución y reportes

## Objetos relacionados

### Tablas fuente
- `[dbo].[Tabla_Madre]` - Fuente principal de datos de sesiones
- `[dbo].[Tabla_de_Hechos_Comportamiento]` - Hechos detallados de comportamiento

### Vistas
- `[Analisis_Cuantitativo_Juegos].[VW_TablaFrecuenciaSesiones]` - Vista para reporting
- `[Analisis_Cuantitativo_Juegos].[VW_EngagementSemanal]` - Vista de análisis de actividad
- `[Analisis_Cuantitativo_Juegos].[VW_PatronesJuego]` - Vista consolidada de comportamiento

### Procedimientos almacenados
- `[dbo].[sp_ActualizarTablasFrecuencia]` - SP para actualizar todas las tablas de frecuencia
- `[dbo].[sp_CalcularFrecuenciasSesiones]` - SP específico para sesiones semanales

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
- Los datos agregados protegen la privacidad individual
- Mantener registro de actualizaciones masivas en tabla de auditoría
- Considerar enmascaramiento de datos para ambientes no productivos

## DDL y notas de implementación

```sql
CREATE TABLE [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_SesionesPorSemana] (
    Intervalo INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    Limite_Inferior DECIMAL(6,3) NULL,
    Limite_Superior DECIMAL(6,3) NULL,
    Marca_Clase DECIMAL(6,3) NULL,
    Frecuencia INT NOT NULL,
    Frecuencia_Acumulada INT NULL,
    Frecuencia_Relativa DECIMAL(6,6) NULL,
    Frecuencia_Relativa_Acumulada DECIMAL(6,6) NULL,
    Frecuencia_Porcentual DECIMAL(6,3) NULL,
    Frecuencia_Porcentual_Acumulada DECIMAL(6,3) NULL,
    CONSTRAINT CHK_Limites_Sesiones CHECK (Limite_Superior > Limite_Inferior),
    CONSTRAINT CHK_Frecuencias_Sesiones_Positivas CHECK (Frecuencia >= 0),
    CONSTRAINT CHK_Porcentajes_Sesiones_Validos CHECK (Frecuencia_Porcentual BETWEEN 0 AND 100)
);

CREATE NONCLUSTERED INDEX IX_Frecuencia_Sesiones_Marca 
ON [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_SesionesPorSemana](Marca_Clase)
INCLUDE (Frecuencia, Frecuencia_Acumulada);

CREATE NONCLUSTERED INDEX IX_Frecuencia_Sesiones_Fecha 
ON [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_SesionesPorSemana](Frecuencia_Relativa)
INCLUDE (Frecuencia_Porcentual);
```

### Notas de implementación
- Se utiliza precisión de 3 decimales para valores de sesiones
- Frecuencias relativas con 6 decimales para cálculos precisos
- Constraints garantizan integridad de datos y valores válidos
- Índices optimizan consultas frecuentes de reporting

Notas sobre la corrección:
- El DDL original incluía una coma final antes del paréntesis de cierre; esto produce error de sintaxis en la mayoría de SGBD. La versión anterior la elimina.
- Se recomienda evitar caracteres acentuados en nombres de columnas (por ejemplo `Límite_Inferior`) para compatibilidad. En la versión corregida usé nombres sin acentos (`Limite_Inferior`). Si prefieres conservar acentos, encerrar los identificadores entre corchetes siempre.
- Ajusté la precisión de `Frecuencia_Relativa` a DECIMAL(6,6) para permitir valores entre 0 y 1 con 6 decimales; puedes modificar la precisión según necesidades.

## Descripción de columnas
- `Intervalo` (INT, PK): identificador secuencial de la clase.
- `Limite_Inferior` (DECIMAL): límite inferior del intervalo (inclusive según convención).
- `Limite_Superior` (DECIMAL): límite superior del intervalo (exclusive o inclusive según convención de clases).
- `Marca_Clase` (DECIMAL): punto medio del intervalo o valor representativo de la clase.
- `Frecuencia` (INT): número de observaciones que caen en la clase.
- `Frecuencia_Acumulada` (INT): suma acumulada de la frecuencia desde la primera clase hasta la clase actual.
- `Frecuencia_Relativa` (DECIMAL): `Frecuencia / Total_Observaciones` (valor entre 0 y 1).
- `Frecuencia_Relativa_Acumulada` (DECIMAL): suma acumulada de las frecuencias relativas.
- `Frecuencia_Porcentual` (DECIMAL): `Frecuencia_Relativa * 100`.
- `Frecuencia_Porcentual_Acumulada` (DECIMAL): acumulado porcentual.

## Procedimiento recomendado para poblar/actualizar
1) Definir el origen de los datos (p. ej. `dbo.Tabla_Madre.Sesiones_por_Semana` o `Tabla_de_Hechos_Comportamiento.Sesiones_por_Semana`).
2) Decidir el tipo de variable: discreta (enteros 0,1,2...) o agrupada (intervalos de ancho k). Para sesiones por semana suele ser razonable tratarlas como discretas (0..n) o con intervalos unitarios.
3) Truncar/archivar la tabla de frecuencias antes de recalcular (si el proceso es re-generativo):

```sql
TRUNCATE TABLE [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_SesionesPorSemana];
```

4) Ejemplo A — variable discreta (conteo por valor entero)

```sql
INSERT INTO [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_SesionesPorSemana]
		(Limite_Inferior, Limite_Superior, Marca_Clase, Frecuencia)
SELECT
		CAST(Sesiones_por_Semana AS DECIMAL(6,3)) - 0.5 AS Limite_Inferior,
		CAST(Sesiones_por_Semana AS DECIMAL(6,3)) + 0.5 AS Limite_Superior,
		CAST(Sesiones_por_Semana AS DECIMAL(6,3)) AS Marca_Clase,
		COUNT(*) AS Frecuencia
FROM dbo.Tabla_Madre m
WHERE Sesiones_por_Semana IS NOT NULL
GROUP BY Sesiones_por_Semana
ORDER BY Marca_Clase;
```

5) Ejemplo B — variable agrupada (intervalos de ancho k)

```sql
-- Parámetro: ancho de clase k (ej. 1 ó 2)
DECLARE @k DECIMAL(6,3) = 1.0;

;WITH bins AS (
	SELECT
		FLOOR(Sesiones_por_Semana / @k) * @k AS bin_start
	FROM dbo.Tabla_Madre
	WHERE Sesiones_por_Semana IS NOT NULL
)
SELECT
	bin_start AS Limite_Inferior,
	bin_start + @k AS Limite_Superior,
	bin_start + (@k/2.0) AS Marca_Clase,
	COUNT(*) AS Frecuencia
FROM dbo.Tabla_Madre m
JOIN bins b ON FLOOR(m.Sesiones_por_Semana / @k) * @k = b.bin_start
GROUP BY bin_start
ORDER BY bin_start;
```

6) Calcular totales y frecuencias relativas / acumuladas

```sql
-- Total de observaciones
DECLARE @Total INT = (SELECT COUNT(*) FROM dbo.Tabla_Madre WHERE Sesiones_por_Semana IS NOT NULL);

-- Calcular frecuencias relativas y porcentuales
UPDATE t
SET
	Frecuencia_Relativa = CAST(Frecuencia AS DECIMAL(10,6)) / NULLIF(@Total,0),
	Frecuencia_Porcentual = (CAST(Frecuencia AS DECIMAL(10,6)) / NULLIF(@Total,0)) * 100
FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_SesionesPorSemana] t;

-- Calcular acumulados (ejemplo usando variable de ventana si el SGBD lo permite)
WITH ordered AS (
	SELECT *,
		SUM(Frecuencia) OVER (ORDER BY Marca_Clase ROWS UNBOUNDED PRECEDING) AS running_freq,
		SUM(Frecuencia_Relativa) OVER (ORDER BY Marca_Clase ROWS UNBOUNDED PRECEDING) AS running_rel
	FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_SesionesPorSemana]
)
UPDATE t
SET Frecuencia_Acumulada = o.running_freq,
		Frecuencia_Relativa_Acumulada = o.running_rel,
		Frecuencia_Porcentual_Acumulada = o.running_rel * 100
FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_SesionesPorSemana] t
JOIN ordered o ON t.Intervalo = o.Intervalo;
```

7) Validaciones post-proceso
- `SUM(Frecuencia)` debe ser igual a `@Total`.
- `Frecuencia_Relativa_Acumulada` debe terminar en 1.0 (o muy cercano por redondeo).

## Uso y consumo
- Esta tabla alimenta vistas y reportes de distribución de sesiones por semana (histogramas, tablas de frecuencia, cálculos de percentiles y medidas de dispersión).
- Crear una vista que exponga únicamente las columnas necesarias para reporting si quieres ocultar las columnas intermedias.

## Índices y performance
- Para tablas de frecuencia pequeñas no es necesario indexar. Si planeas realizar joins frecuentes por `Marca_Clase`, considera un índice nonclustered en `Marca_Clase`.
- Si la tabla se regenera completamente con frecuencia, TRUNCATE + INSERT suele ser más eficiente que UPDATE incremental.
