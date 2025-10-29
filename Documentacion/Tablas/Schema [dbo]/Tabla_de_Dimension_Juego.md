# Tabla_de_Dimension_Juego (Schema: dbo)

## Resumen
Dimensión que contiene atributos descriptivos de los juegos (o tipos de juego) usados en el análisis. Se une a la tabla de hechos para agregar contexto a las métricas de comportamiento.

Propósito:
- Proveer metadatos sobre cada juego: nombre, género, categoría, modelo de monetización y atributos que permiten segmentar analíticamente.

## Suposiciones
- Archivo original vacío; las columnas y tipos siguientes son propuestas basadas en convenciones del proyecto y en la presencia de `Clasificacion_Genero_Juegos`.
- Ajustar tipos y nombres si existe un DDL real diferente en el repositorio.

## Columnas propuestas

- `ID_de_Juego` (INT, PK) — Identificador único del juego.
- `Nombre_Juego` (VARCHAR(200)) — Nombre legible del juego.
- `ID_Genero` (INT, FK -> Clasificacion_Genero_Juegos.ID_de_Juego) — FK al catálogo de géneros.
- `Genero_Nombre` (VARCHAR(100)) — Nombre del género (duplicado para rapidez si se prefiere denormalizar).
- `Categoria` (VARCHAR(100)) — Categoría o subgénero (p. ej. estrategia, simulación, acción).
- `Plataforma` (VARCHAR(50)) — Plataforma principal (PC, iOS, Android, Consola).
- `Desarrollador` (VARCHAR(200), NULLABLE) — Empresa/desarrollador.
- `Editor` (VARCHAR(200), NULLABLE) — Editor/publicador.
- `Fecha_Lanzamiento` (DATE, NULLABLE) — Fecha de lanzamiento.
- `Edad_Recomendada` (VARCHAR(50), NULLABLE) — Clasificación por edad (p.ej. PEGI, ESRB).
- `Monetizacion_Tipo` (VARCHAR(50)) — Modelo de monetización (Free-to-play, Paga, Freemium, Subscripción).
- `Precio` (DECIMAL(10,2), NULLABLE) — Precio si aplica.
- `Estado_Juego` (VARCHAR(50)) — Estado (activo, retirado, en_desarrollo).
- `Tags` (VARCHAR(500), NULLABLE) — Etiquetas separadas por comas (para búsqueda/filtro rápido).
- `Fecha_Creacion` (DATETIME) — Fecha de creación del registro en la dimensión.
- `Fecha_Actualizacion` (DATETIME) — Última modificación del registro.
- `Fuente` (VARCHAR(100)) — Origen del dato (manual, API, sync_catalogo).

## Claves e índices sugeridos

- Clave primaria: `ID_de_Juego`.
- Índices recomendados:
  - Índice en `ID_Genero` para joins y agregaciones por género.
  - Índice en `Nombre_Juego` para búsquedas rápidas (puede ser índice con full-text si el SGBD lo soporta).
  - Índice en `Plataforma` y `Monetizacion_Tipo` para segmentación.

## Manejo de cambios
- Dimensión relativamente estática; SCD tipo 1 suele ser suficiente (sobrescribir atributos). Si necesitas histórico por cambios de metadatos importantes (p. ej., cambio de editor), considerar SCD tipo 2 con columnas de vigencia.

## Calidad de datos y validaciones
- Validar unicidad de `Nombre_Juego` por plataforma si requiere coherencia.
- Normalizar `Monetizacion_Tipo` y `Categoria` frente a tablas de dominio.

## Consultas de ejemplo

1) Juegos por género y plataforma

```sql
SELECT g.Genero_Nombre, j.Plataforma, COUNT(*) AS CantidadJuegos
FROM dbo.Tabla_de_Dimension_Juego j
JOIN dbo.Clasificacion_Genero_Juegos g ON j.ID_Genero = g.ID_de_Juego
GROUP BY g.Genero_Nombre, j.Plataforma
ORDER BY CantidadJuegos DESC;
```

2) Top 10 juegos con mayor valor promedio por sesión (requiere unión con tabla de hechos)

```sql
SELECT TOP 10 j.ID_de_Juego, j.Nombre_Juego, SUM(h.Valor_Compras)/NULLIF(COUNT(h.ID_Hecho),0) AS ValorPromedioPorRegistro
FROM dbo.Tabla_de_Dimension_Juego j
JOIN dbo.Tabla_de_Hechos_Comportamiento h ON j.ID_de_Juego = h.ID_de_Juego
GROUP BY j.ID_de_Juego, j.Nombre_Juego
ORDER BY ValorPromedioPorRegistro DESC;
```

3) Juegos activos con monetización freemium

```sql
SELECT ID_de_Juego, Nombre_Juego, Plataforma, Monetizacion_Tipo
FROM dbo.Tabla_de_Dimension_Juego
WHERE Estado_Juego = 'activo' AND Monetizacion_Tipo = 'Freemium';
```

## Privacidad y gobernanza
- Normalmente no contiene PII; si se enriquece con metadatos que provienen de usuarios (reseñas, contactos), aplicar controles de acceso.
- Mantener registro de la `Fuente` y `Fecha_Actualizacion` para trazabilidad.

## Volumen y mantenimiento
- Dimensión de tamaño moderado (número de juegos). No suele requerir particionado; considerar compresión si contiene muchas columnas y metadatos.

## Enlaces y siguientes pasos
- Enlazar desde `TABLAS.md` y `DICCIONARIO_DATOS.md` a este archivo.
- Validar contra DDL real en `Scripts/DDL Tablas`. Puedo generar un `CREATE TABLE` sugerido o sincronizar con el DDL real si lo prefieres.
