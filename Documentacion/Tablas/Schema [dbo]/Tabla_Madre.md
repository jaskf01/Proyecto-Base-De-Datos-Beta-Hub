# Tabla_Madre (Schema: dbo)

## Resumen
Tabla fuente que contiene los registros de comportamiento de jugadores en bruto. Se usa como tabla madre desde la cual se derivan dimensiones y tablas analíticas (frecuencias y medidas estadísticas).

Propósito principal:
- Centralizar eventos y atributos de jugadores antes de limpieza y normalización.

## Suposiciones (si faltan detalles en el DDL)
- Base: asumí tipos comunes para cada columna; ajustar si el DDL real difiere.
- Las columnas marcadas como `PK`/`FK` son sugeridas según convenciones del repositorio.

## Estructura de columnas (documentación sugerida)

- `ID_de_Jugador` (INT, PK) — Identificador único del jugador.
	- Notas: clave primaria natural o surrogate. Si usan GUID, cambiar a UNIQUEIDENTIFIER.

- `ID_Registro` (INT, PK AUTO_INCREMENT) — Identificador de fila (opcional, recomendado para tracking de cambios).

- `Genero` (VARCHAR(50)) — Género reportado del jugador.
	- Valores esperados: 'Masculino','Femenino','No especificado', etc.

- `Edad` (INT) — Edad del jugador en años.
	- Validaciones: valores razonables 0–120; para análisis se filtran extremos.

- `Ubicacion_Pais` (VARCHAR(100)) — País del jugador.

- `Genero_Juego` (VARCHAR(100)) — Género de juego preferido o jugado.
	- FK sugerida a `Clasificacion_Genero_Juegos(ID_de_Juego)` si existe catálogo.

- `Dificultad_de_Juego` (VARCHAR(50)) — Etiqueta de dificultad (Facil/Medio/Dificil) o número.

- `Sesiones_por_Semana` (TINYINT) — Número promedio de sesiones por semana.

- `Duracion_Sesion_Horas` (DECIMAL(4,2)) — Duración promedio de sesión en horas.

- `Nivel_de_Jugador` (INT) — Nivel o progreso alcanzado.

- `Logros_Desbloqueados` (INT) — Conteo de logros desbloqueados.

- `Nivel_de_Enganche` (DECIMAL(3,2)) — Métrica compuesta de engagement (0-1 o 0-100).

- `Compra_en_Juego` (BIT) — Indicador si realizó compras en el juego (0/1).

- `Fecha_Registro` (DATETIME) — Fecha y hora en que se registró el evento/registro.

## Claves, índices y relaciones sugeridas
- Clave primaria recomendada: `ID_Registro` (INT IDENTITY) o combinación (`ID_de_Jugador`,`Fecha_Registro`) según el modelo.
- Índices recomendados:
	- Index en `ID_de_Jugador` para joins con dimensiones.
	- Index en `Fecha_Registro` para filtros temporales.
	- Index en `Genero_Juego`, `Edad` si se hacen agregaciones frecuentes.
- Relaciones:
	- `Genero_Juego` → `Clasificacion_Genero_Juegos(ID_de_Juego)` (FK opcional)
	- Relaciones con `Tabla_de_Dimension_Jugador` a través de `ID_de_Jugador`.

## Buenas prácticas y consideraciones ETL
- Mantener la `Tabla_Madre` como fuente inmutable idealmente: insertar registros nuevos y usar tablas de staging para transformaciones.
- Registrar `Fecha_Registro` y `Fuente` (si aplica) para trazabilidad.
- Normalizar campos categóricos: mapear `Genero_Juego` y `Dificultad_de_Juego` a tablas de dimensión.
- Manejo de nulos: definir valores por defecto (por ejemplo, `Compra_en_Juego = 0`).

## Consultas de ejemplo

1) Registros por rango de edad

```sql
SELECT
	CASE
		WHEN Edad BETWEEN 0 AND 17 THEN '0-17'
		WHEN Edad BETWEEN 18 AND 24 THEN '18-24'
		WHEN Edad BETWEEN 25 AND 34 THEN '25-34'
		WHEN Edad BETWEEN 35 AND 44 THEN '35-44'
		ELSE '45+'
	END AS RangoEdad,
	COUNT(*) AS Cantidad
FROM dbo.Tabla_Madre
GROUP BY
	CASE
		WHEN Edad BETWEEN 0 AND 17 THEN '0-17'
		WHEN Edad BETWEEN 18 AND 24 THEN '18-24'
		WHEN Edad BETWEEN 25 AND 34 THEN '25-34'
		WHEN Edad BETWEEN 35 AND 44 THEN '35-44'
		ELSE '45+'
	END
ORDER BY Cantidad DESC;
```

2) Promedio de duración de sesión por género de juego

```sql
SELECT
	Genero_Juego,
	AVG(Duracion_Sesion_Horas) AS PromedioHoras
FROM dbo.Tabla_Madre
GROUP BY Genero_Juego
ORDER BY PromedioHoras DESC;
```

3) Jugadores que hicieron compra y tienen alto engagement

```sql
SELECT TOP 100 ID_de_Jugador, Nivel_de_Enganche, Compra_en_Juego
FROM dbo.Tabla_Madre
WHERE Compra_en_Juego = 1
ORDER BY Nivel_de_Enganche DESC;
```

## Consideraciones de privacidad y seguridad
- Evitar almacenar datos sensibles (identificadores personales, PII) en texto plano.
- Si se requiere, enmascarar o cifrar columnas sensibles y documentar políticas de retención.

## Volumen y mantenimiento
- Indicar frecuencia de carga (p.ej., diaria) y tamaño aproximado (número de filas) si está disponible.
- Estrategia de particionado: por `Fecha_Registro` si la tabla crece mucho.

## Notas finales y próximos pasos
- Validar tipos de datos contra el DDL real y ajustar este documento.
- Vincular esta documentación desde `TABLAS.md` y desde `DICCIONARIO_DATOS.md`.
- Si quieres, puedo generar un script DDL sugerido (CREATE TABLE) basado en estas suposiciones.

---


