# Medidas_Dispersion_Juegos

## Resumen
Tabla destinada a almacenar medidas de dispersión para las variables de interés del análisis cuantitativo: varianza y desviación estándar. Estas medidas describen la dispersión o variabilidad de las distribuciones y se usan en reportes, control de calidad y como insumo para inferencia estadística.

Variables típicas: `Edad`, `Sesiones_por_Semana`, `Duracion_Sesion_Horas` (nombres de columna reales según el DDL).

## Observaciones sobre el SQL original
- El script original crea la tabla y acto seguido la borra con `DROP TABLE` — esto elimina los datos inmediatamente después de crearla. En entornos productivos no debe incluirse el `DROP TABLE` salvo en scripts de testing.  
- Los nombres de columnas en el script contienen acentos (`DESVIACIÓN_ESTÁNDAR`) y nombres con espacios; es preferible usar identificadores sin acentos ni espacios o, si se mantienen, utilizar corchetes consistentemente.  
- La tabla original define `VARIANZA` y `DESVIACIÓN_ESTÁNDAR` como NOT NULL; si el cálculo se ejecuta sobre tablas vacías o con muchos NULLs, los inserts podrían fallar. Recomiendo permitir NULLs y registrar `N` (tamaño muestral) para trazabilidad.
- El script usa funciones de población `VARP` y `STDEVP`. Asegúrate de escoger entre medidas poblacionales (VARP/STDEVP) y muestrales (VAR/ STDEV) según la interpretación; ambas apreciaciones se incluyen en los ejemplos.

## DDL recomendado
Versión mejorada que incluye metadatos y evita caracteres problemáticos:

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

Motivaciones:
- Incluir `Fecha_Reporte` y `N` permite mantener histórico y detectar cambios de población entre ejecuciones.  
- Guardar tanto la varianza/desviación poblacional como la muestral facilita comparaciones y uso correcto en análisis posteriores.

## SQL recomendado para calcular medidas (ejemplos)
Nota: ajustar nombres de tabla/columna a los reales en tu base.

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

2) Insertar el resultado en la tabla de medidas:

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

3) Para variables en la tabla de hechos (p.ej. `Sesiones_por_Semana` o `Duracion_Sesion_Horas`), sustituir la tabla/columna en el select anterior.

## Notas sobre funciones y definiciones
- VARP / STDEVP: varianza y desviación estándar poblacionales (división por N).  
- VAR / STDEV: varianza y desviación estándar muestrales (división por N-1).  
- Elegir la versión adecuada según el contexto: si se considera que tienes la población completa, usar poblacional; si son muestras, usar muestral.

## Validaciones y QA
- Comprobar `N` antes de insertar (evitar división por cero).  
- Verificar que los resultados no sean NULL; si la fuente está vacía, registrar un mensaje en logs y no insertar.  
- Comparar con ejecuciones previas (control de cambios grandes y outliers) antes de publicar en reporting.

## Procedimiento de refresco sugerido
1. Ejecutar calc en staging y guardar resultados en tabla temporal.  
2. Validar (N creciente/estable, no hay cambios drásticos sin justificante).  
3. Insertar una nueva fila en `Medidas_Dispersion_Juegos` con `Fecha_Reporte` y `Fuente`.  
4. (Opcional) Mantener vista `VW_MedidasDispersion_Juegos` que muestre la última fecha por variable.

## Buenas prácticas
- Evitar `DROP TABLE` en scripts de despliegue; emplear migraciones versionadas.  
- Redondear para presentación en reporting, pero almacenar valores con mayor precisión en la tabla.  
- Documentar la versión del pipeline y transformaciones aplicadas antes del cálculo (filtros, truncamientos, top-coding).


