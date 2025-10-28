# Clasificación de Género de Juegos

## Resumen
Ficha del catálogo `Clasificacion_Genero_Juegos` que contiene los géneros usados para clasificar juegos en el proyecto. Esta tabla actúa como referencia (tabla de dominio) para normalizar el campo `Genero_Juego` en la `Tabla_Madre` y en `Tabla_de_Dimension_Juego`.

Propósito:
- Mantener una lista canónica de géneros para asegurar consistencia entre ETL, análisis y reporting.

## Estructura sugerida
- `ID_de_Juego` (INT, PK) — Identificador único del género.
- `Genero` (VARCHAR(100), NOT NULL, UNIQUE) — Nombre legible del género (p.ej. "Estrategia", "Deportes").
- `Descripcion` (VARCHAR(500), NULLABLE) — Descripción breve del género y ejemplos si aplica.
- `Fecha_Creacion` (DATETIME, NOT NULL) — Fecha de creación del registro en el catálogo.
- `Fuente` (VARCHAR(100), NULLABLE) — Origen del dato (manual, sync_catalogo, API).


## Valores iniciales recomendados
Se recomiendan los siguientes géneros como punto de partida; ajustar según el catálogo del producto:

1. Estrategia
2. Deportes
3. Acción
4. Juego de Roles
5. Simulación
6. Puzzle
7. Aventura
8. Carreras
9. Indie
10. Casual

## Integridad y uso en ETL
- FK sugerida: `Tabla_de_Dimension_Juego.ID_Genero` -> `Clasificacion_Genero_Juegos.ID_de_Juego`.
- Durante la ingesta (ETL): mapear variantes libres de `Genero_Juego` a `ID_de_Juego`. Si no existe correspondencia, insertar en staging para revisión o asignar al ID reservado `UNKNOWN`.
- Política recomendada: no permitir borrados en el catálogo; en su lugar, marcar `Estado` (activo/inactivo) si se requiere desactivación.

## Scripts y constraints (sugeridos)
Ejemplo de DDL sugerido (ajustar sintaxis al SGBD):

```sql
CREATE TABLE dbo.Clasificacion_Genero_Juegos (
	ID_de_Juego INT IDENTITY(1,1) PRIMARY KEY,
	Genero VARCHAR(100) NOT NULL UNIQUE,
	Descripcion VARCHAR(500) NULL,
	Fecha_Creacion DATETIME NOT NULL DEFAULT GETDATE(),
	Fuente VARCHAR(100) NULL
);

-- Inserción de valores iniciales (ejemplo)
INSERT INTO dbo.Clasificacion_Genero_Juegos (Genero) VALUES
('Estrategia'), ('Deportes'), ('Acción'), ('Juego de Roles'), ('Simulación');
```

## Buenas prácticas
- Mantener el catálogo en control de versiones y documentar cambios (añadir nuevo género, renombrar, desactivar).
- Usar este catálogo como fuente de verdad en los pipelines ETL para evitar inconsistencias lingüísticas.
- Proveer un proceso de revisión para nuevos géneros (propiedad, clasificación, ejemplos de pertenencia).

## Ejemplos de mapeo en ETL

```sql
-- Ejemplo: mapear texto libre a ID de catálogo
SELECT g.ID_de_Juego
FROM dbo.Clasificacion_Genero_Juegos g
WHERE LOWER(g.Genero) = LOWER(@GeneroEntrada);

-- Si no existe, enviar a tabla_staging para revisión manual
```

## Control de calidad y monitoreo
- Registrar casos no mapeados y frecuencias para priorizar ampliaciones del catálogo.
- Implementar tests de integración en el pipeline ETL que aseguren que todos los `Genero_Juego` en `Tabla_Madre` tienen correspondencia o están marcados para revisión.

---

