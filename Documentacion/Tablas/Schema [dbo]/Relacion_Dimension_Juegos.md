# Relación entre dimensiones y tablas de hechos (Juegos)

## Resumen
Documento que describe las relaciones entre las tablas relacionadas con juegos en el esquema `dbo` y cómo se conectan con las tablas de hechos analíticas. Incluye cardinalidades, claves foráneas sugeridas, recomendaciones de integridad y consultas de ejemplo.

## Objetos principales involucrados
- `Tabla_Madre` (fuente en bruto)
- `Tabla_de_Hechos_Comportamiento` (tabla de hechos)
- `Tabla_de_Dimension_Juego` (dimensión juego)
- `Tabla_de_Dimension_Jugador` (dimensión jugador)
- `Clasificacion_Genero_Juegos` (catálogo de géneros)

## Diagrama lógico (ASCII)

Tabla_Madre (origen)
		|
		|  (ETL: limpieza, normalización, mapeo de IDs)
		v
Tabla_de_Hechos_Comportamiento (Hecho) ------------------- Tabla_de_Dimension_Jugador (Dim)
								 |                                          ^
								 |                                          |
								 |---> Tabla_de_Dimension_Juego (Dim) --------+
								 |
								 +---> Clasificacion_Genero_Juegos (Catálogo)

Explicación rápida:
- Los registros en `Tabla_Madre` se procesan y transforman para poblar `Tabla_de_Hechos_Comportamiento`.
- `Tabla_de_Hechos_Comportamiento` referencia a las dimensiones `Tabla_de_Dimension_Jugador` y `Tabla_de_Dimension_Juego` mediante `ID_de_Jugador` y `ID_de_Juego`.
- `Tabla_de_Dimension_Juego` puede a su vez referenciar el catálogo `Clasificacion_Genero_Juegos` para normalizar géneros.

## Cardinalidades y claves foráneas sugeridas
- `Tabla_de_Dimension_Jugador` 1 --- * `Tabla_de_Hechos_Comportamiento`
	- FK sugerida en hechos: `FK_Hechos_Jugador (Tabla_de_Hechos_Comportamiento.ID_de_Jugador -> Tabla_de_Dimension_Jugador.ID_de_Jugador)`

- `Tabla_de_Dimension_Juego` 1 --- * `Tabla_de_Hechos_Comportamiento`
	- FK sugerida en hechos: `FK_Hechos_Juego (Tabla_de_Hechos_Comportamiento.ID_de_Juego -> Tabla_de_Dimension_Juego.ID_de_Juego)`

- `Clasificacion_Genero_Juegos` 1 --- * `Tabla_de_Dimension_Juego`
	- FK sugerida: `FK_Juego_Genero (Tabla_de_Dimension_Juego.ID_Genero -> Clasificacion_Genero_Juegos.ID_de_Juego)`

## Reglas de integridad y acciones recomendadas
- En la mayoría de los modelos analíticos (data warehouse) se recomienda mantener las dimensiones como la fuente de verdad y usar FKs con NO ACTION o NO CASCADE para evitar borrados accidentales de dimensiones.
- Para los pipelines ETL:
	- Validar existencia de dimensión antes de insertar hechos; si falta, crear una fila `unknown` o enrutar a tabla de staging para revisión.
	- Versionado / SCD: si usas SCD tipo 2 en dimensiones, los hechos deben apuntar a la versión `Is_Current = 1` (o a la surrogate key actual) para consistencia histórica.

## Índices recomendados para joins frecuentes
- Indice en `Tabla_de_Hechos_Comportamiento(ID_de_Jugador, Fecha)` para consultas por jugador en periodos.
- Indice en `Tabla_de_Hechos_Comportamiento(ID_de_Juego, Fecha)` para agregaciones por juego.
- Índices en dimensiones sobre las columnas PK y en columnas usadas en filtros (`Pais`, `Segmento`, `Plataforma`).

## Ejemplos de consultas (joins comunes)

1) Agregado diario de compras por juego y género

```sql
SELECT
	h.Fecha,
	j.Nombre_Juego,
	g.Genero AS Genero,
	SUM(h.Valor_Compras) AS ValorTotal
FROM dbo.Tabla_de_Hechos_Comportamiento h
JOIN dbo.Tabla_de_Dimension_Juego j ON h.ID_de_Juego = j.ID_de_Juego
LEFT JOIN dbo.Clasificacion_Genero_Juegos g ON j.ID_Genero = g.ID_de_Juego
WHERE h.Fecha BETWEEN '2025-01-01' AND '2025-01-31'
GROUP BY h.Fecha, j.Nombre_Juego, g.Genero
ORDER BY h.Fecha, ValorTotal DESC;
```

2) Cohorte por fecha de alta del jugador y gasto acumulado

```sql
SELECT
	DATEPART(YEAR, d.Fecha_Alta) AS AnoAlta,
	SUM(h.Valor_Compras) AS GastoTotal
FROM dbo.Tabla_de_Hechos_Comportamiento h
JOIN dbo.Tabla_de_Dimension_Jugador d ON h.ID_de_Jugador = d.ID_de_Jugador
GROUP BY DATEPART(YEAR, d.Fecha_Alta)
ORDER BY AnoAlta;
```

3) Tasa de conversión por juego (ejemplo simple)

```sql
-- Asume que Evento_Tipo = 'visita' y 'compra'
SELECT
	j.ID_de_Juego,
	j.Nombre_Juego,
	SUM(CASE WHEN h.Evento_Tipo = 'compra' THEN 1 ELSE 0 END) * 1.0 /
		NULLIF(SUM(CASE WHEN h.Evento_Tipo = 'visita' THEN 1 ELSE 0 END),0) AS TasaConversion
FROM dbo.Tabla_de_Hechos_Comportamiento h
JOIN dbo.Tabla_de_Dimension_Juego j ON h.ID_de_Juego = j.ID_de_Juego
GROUP BY j.ID_de_Juego, j.Nombre_Juego
ORDER BY TasaConversion DESC;
```

## Manejo de datos faltantes y referencias rotas
- Insertar filas `unknown`/`sin_categoria` en dimensiones con IDs reservados para usar como fallback cuando la referencia no exista.
- Mantener logs de errores en la ingesta para identificar y corregir referencias rotas.

## Consideraciones de rendimiento y escalabilidad
- Si la tabla de hechos crece mucho, particionar por `Fecha` y comprimir particiones antiguas.
- Mantener estadísticas actualizadas y planear mantenimiento de índices (rebuild/reorganize) según la carga.

## Notas finales y próximos pasos
- Validar y aplicar las FKs sugeridas en un entorno de staging antes de producción.
- Si quieres, puedo generar scripts `ALTER TABLE ... ADD CONSTRAINT` para añadir las FKs e índices sugeridos (elige entorno y política de ON DELETE/ON UPDATE: NO ACTION, SET NULL o CASCADE).

---

