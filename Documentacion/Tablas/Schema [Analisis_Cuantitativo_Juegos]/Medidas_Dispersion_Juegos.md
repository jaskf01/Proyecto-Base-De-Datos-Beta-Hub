# Medidas_Dispersion_Juegos

## Resumen
Tabla destinada a almacenar medidas de dispersión para las variables de interés del análisis cuantitativo: varianza y desviación estándar. Estas medidas describen la dispersión o variabilidad de las distribuciones y se usan en reportes, control de calidad y como insumo para inferencia estadística.

Variables típicas: `Edad`, `Sesiones_por_Semana`, `Duracion_Sesion_Horas` (nombres de columna reales según el DDL).

## Estructura
| Columna | Tipo | Nullable | Default | Descripción |
|---------|------|----------|----------|-------------|
| Variable | NVARCHAR(100) | NO | - | Nombre de la variable analizada (e.g., 'EDAD', 'SESIONES_POR_SEMANA') |
| Fecha_Reporte | DATE | NO | GETDATE() | Fecha de cálculo de las medidas |
| N | INT | SI | NULL | Tamaño muestral usado en los cálculos |
| Var_Poblacional | DECIMAL(18,6) | SI | NULL | Varianza poblacional (VARP) |
| Var_Muestral | DECIMAL(18,6) | SI | NULL | Varianza muestral (VAR) |
| SD_Poblacional | DECIMAL(18,6) | SI | NULL | Desviación estándar poblacional (STDEVP) |
| SD_Muestral | DECIMAL(18,6) | SI | NULL | Desviación estándar muestral (STDEV) |
| Fuente | NVARCHAR(100) | SI | NULL | Tabla origen de los datos analizados |

## Claves
- **Clave Primaria**: (`Variable`, `Fecha_Reporte`)
- **Claves Foráneas**: No aplica (tabla de análisis)

## Índices
1. **PK_Medidas_Dispersion_Juegos** (clustered)
   - Columnas: (`Variable`, `Fecha_Reporte`)
   - Tipo: CLUSTERED
   - Unicidad: UNIQUE
   
2. **IX_Medidas_Dispersion_Fecha**
   - Columnas: (`Fecha_Reporte`) INCLUDE (`Var_Poblacional`, `SD_Poblacional`)
   - Tipo: NONCLUSTERED
   - Utilidad: Optimizar consultas de tendencias temporales

## Objetos relacionados

### Tablas fuente
- `[dbo].[Tabla_De_Dimension_Jugador]` - Fuente para medidas de `Edad`
- `[dbo].[Tabla_de_Hechos_Comportamiento]` - Fuente para medidas de `Sesiones_por_Semana` y `Duracion_Sesion_Horas`

### Vistas
- `[Analisis_Cuantitativo_Juegos].[VW_MedidasTendenciaCentral_Dispersion]` - Vista consolidada de medidas
- `[Analisis_Cuantitativo_Juegos].[VW_EvolucionDispersion]` - Vista de tendencias temporales

### Procedimientos almacenados
- `[dbo].[sp_ActualizarMedidasDispersion]` - SP para actualizar las medidas
- `[dbo].[sp_ValidarMedidasDispersion]` - SP de validación pre-publicación

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
CREATE TABLE [Analisis_Cuantitativo_Juegos].[Medidas_Dispersion_Juegos] (
    Variable NVARCHAR(100) NOT NULL,
    Fecha_Reporte DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    N INT NULL, -- tamaño muestral
    Var_Poblacional DECIMAL(18,6) NULL,
    Var_Muestral DECIMAL(18,6) NULL,
    SD_Poblacional DECIMAL(18,6) NULL,
    SD_Muestral DECIMAL(18,6) NULL,
    Fuente NVARCHAR(100) NULL,
    PRIMARY KEY (Variable, Fecha_Reporte)
);
```

### Ejemplos de uso

1) Ejemplo robusto para `Edad` (tabla: `dbo.Tabla_De_Dimension_Jugador`, columna `Edad`):

```sql
-- Calcular medidas para EDAD (poblacional y muestral)
DECLARE @N INT = (SELECT COUNT(Edad) FROM dbo.Tabla_De_Dimension_Jugador WHERE Edad IS NOT NULL);

SELECT
    @N AS N,
    CAST(VARP(CAST(Edad AS FLOAT)) AS DECIMAL(18,6)) AS Var_Poblacional,
    CAST(VAR(CAST(Edad AS FLOAT)) AS DECIMAL(18,6)) AS Var_Muestral,
    CAST(STDEVP(CAST(Edad AS FLOAT)) AS DECIMAL(18,6)) AS SD_Poblacional,
    CAST(STDEV(CAST(Edad AS FLOAT)) AS DECIMAL(18,6)) AS SD_Muestral
FROM dbo.Tabla_De_Dimension_Jugador
WHERE Edad IS NOT NULL;
```

2) Insertar el resultado:

```sql
INSERT INTO [Analisis_Cuantitativo_Juegos].[Medidas_Dispersion_Juegos]
    (Variable, Fecha_Reporte, N, Var_Poblacional, Var_Muestral, SD_Poblacional, SD_Muestral, Fuente)
SELECT
    'EDAD', CAST(GETDATE() AS DATE),
    COUNT(Edad),
    VARP(CAST(Edad AS FLOAT)),
    VAR(CAST(Edad AS FLOAT)),
    STDEVP(CAST(Edad AS FLOAT)),
    STDEV(CAST(Edad AS FLOAT)),
    'Tabla_De_Dimension_Jugador'
FROM dbo.Tabla_De_Dimension_Jugador
WHERE Edad IS NOT NULL;
```

## Notas sobre funciones y definiciones
- VARP / STDEVP: varianza y desviación estándar poblacionales (división por N)
- VAR / STDEV: varianza y desviación estándar muestrales (división por N-1)
- Elegir la versión adecuada según el contexto: si se considera que tienes la población completa, usar poblacional; si son muestras, usar muestral

## Validaciones y QA
- Comprobar `N` antes de insertar (evitar división por cero)
- Verificar que los resultados no sean NULL; si la fuente está vacía, registrar un mensaje en logs y no insertar
- Comparar con ejecuciones previas (control de cambios grandes y outliers) antes de publicar en reporting

## Procedimiento de refresco sugerido
1. Ejecutar calc en staging y guardar resultados en tabla temporal
2. Validar (N creciente/estable, no hay cambios drásticos sin justificante)
3. Insertar una nueva fila en `Medidas_Dispersion_Juegos` con `Fecha_Reporte` y `Fuente`
4. (Opcional) Mantener vista `VW_MedidasDispersion_Juegos` que muestre la última fecha por variable

## Buenas prácticas
- Evitar `DROP TABLE` en scripts de despliegue; emplear migraciones versionadas
- Redondear para presentación en reporting, pero almacenar valores con mayor precisión en la tabla
- Documentar la versión del pipeline y transformaciones aplicadas antes del cálculo (filtros, truncamientos, top-coding)

