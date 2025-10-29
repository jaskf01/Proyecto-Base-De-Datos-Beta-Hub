# Medidas_Tendencia_Central_Juegos

## Resumen
Tabla que almacena las medidas de tendencia central (rango, media, mediana, moda) para las variables de interés del esquema `Analisis_Cuantitativo_Juegos`.

Propósito:
- Mantener valores resumen (descripcion estadística) para variables como Edad, Sesiones por semana y Duración de sesión, con el fin de alimentar reportes y vistas analíticas.

## Estructura
| Columna | Tipo | Nullable | Default | Descripción |
|---------|------|----------|----------|-------------|
| Variable | NVARCHAR(100) | NO | - | Nombre de la variable analizada (e.g., 'EDAD', 'SESIONES_POR_SEMANA') |
| Fecha_Reporte | DATE | NO | GETDATE() | Fecha de cálculo de las medidas |
| N | INT | SI | NULL | Tamaño muestral utilizado |
| Rango | DECIMAL(18,4) | SI | NULL | Diferencia entre valor máximo y mínimo |
| Media | DECIMAL(18,4) | SI | NULL | Promedio aritmético de los valores |
| Mediana | DECIMAL(18,4) | SI | NULL | Valor que divide el conjunto en dos partes iguales |
| Moda | DECIMAL(18,4) | SI | NULL | Valor más frecuente en el conjunto de datos |
| Fuente | NVARCHAR(100) | SI | NULL | Tabla origen de los datos analizados |

## Claves
- **Clave Primaria**: (`Variable`, `Fecha_Reporte`)
- **Claves Foráneas**: No aplica (tabla de análisis estadístico)

## Índices
1. **PK_Medidas_Tendencia_Central_Juegos** (clustered)
   - Columnas: (`Variable`, `Fecha_Reporte`)
   - Tipo: CLUSTERED
   - Unicidad: UNIQUE
   
2. **IX_Medidas_Tendencia_Fecha**
   - Columnas: (`Fecha_Reporte`) INCLUDE (`Media`, `Mediana`)
   - Tipo: NONCLUSTERED
   - Utilidad: Optimizar consultas de tendencias temporales y reportes históricos

## Objetos relacionados

### Tablas fuente
- `[dbo].[Tabla_De_Dimension_Jugador]` - Fuente para medidas de `Edad`
- `[dbo].[Tabla_de_Hechos_Comportamiento]` - Fuente para medidas de `Sesiones_por_Semana` y `Duracion_Sesion_Horas`

### Vistas
- `[Analisis_Cuantitativo_Juegos].[VW_MedidasTendenciaCentral_Dispersion]` - Vista consolidada de todas las medidas estadísticas
- `[Analisis_Cuantitativo_Juegos].[VW_TendenciasCentrales]` - Vista para análisis de tendencias temporales

### Procedimientos almacenados
- `[dbo].[sp_ActualizarMedidasTendenciaCentral]` - SP para actualizar las medidas
- `[dbo].[sp_ValidarMedidasTendenciaCentral]` - SP de validación pre-publicación

## Seguridad y clasificación

### Clasificación de datos
- **Nivel de sensibilidad**: BAJO
- **Tipo de datos**: Estadísticas agregadas
- **Retención**: 24 meses (mantener histórico para análisis de tendencias)

### Permisos requeridos
- SELECT: roles `data_analyst`, `bi_reader`
- INSERT/UPDATE: rol `etl_runner`
- DELETE: rol `db_owner` (operación restringida)

### Notas de seguridad
- No contiene datos personales identificables (PII)
- Los valores agregados no permiten identificación inversa
- Mantener registro de actualizaciones en tabla de auditoría

## DDL y ejemplos SQL

### DDL recomendado
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

### Notas de implementación
- Se usa escala de 4 decimales para mayor precisión en los cálculos
- `Variable` + `Fecha_Reporte` como clave primaria permite mantener histórico
- Los campos se permiten NULL para manejar casos donde no hay datos suficientes
- El campo `N` ayuda en la trazabilidad y validación de los cálculos

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

