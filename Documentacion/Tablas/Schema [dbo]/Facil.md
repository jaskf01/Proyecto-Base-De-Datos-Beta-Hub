# Facil

## Resumen
Etiqueta usada en el proyecto para indicar que un juego o una actividad tiene un nivel de dificultad bajo. Se aplica en `Dificultad_de_Juego` en `Tabla_Madre` y en atributos de `Tabla_de_Dimension_Juego`.

## Estructura
- No siempre se modela como tabla; se puede implementar como catálogo mínimo:

```sql
CREATE TABLE dbo.Catalogo_Dificultad (
	ID_Dificultad INT IDENTITY(1,1) PRIMARY KEY,
	Nombre VARCHAR(50) NOT NULL UNIQUE, -- 'Facil','Medio','Dificil'
	Codigo INT NULL,
	Descripcion VARCHAR(250) NULL,
	Fecha_Creacion DATETIME NOT NULL DEFAULT GETDATE(),
	Estado BIT NOT NULL DEFAULT 1
);
```

Campos cuando se usa texto en las tablas de datos:
- `Dificultad_de_Juego` (VARCHAR) — valor normalizado (`Facil`).
- `ID_Dificultad` (INT) — FK opcional hacia `Catalogo_Dificultad`.

## Claves
- Si existe `Catalogo_Dificultad`: **PK** = `ID_Dificultad`.
- Si sólo se mantiene el string en `Tabla_Madre`, no aplica clave adicional en esa columna.

## Índices
- En `Catalogo_Dificultad`: índice único en `Nombre`.
- En `Tabla_Madre` o `Tabla_de_Dimension_Juego`: índice nonclustered sobre `Dificultad_de_Juego` o `ID_Dificultad` para mejorar filtros y agregaciones.

## Objetos relacionados
- Tablas:
	- `dbo.Tabla_Madre` (columna `Dificultad_de_Juego` / `ID_Dificultad`)
	- `dbo.Tabla_de_Dimension_Juego` (atributo `Dificultad`)

- Vistas / SPs:
	- `VW_DistribucionDificultad` — vista con conteos y porcentajes por dificultad.
	- `sp_ActualizarCatalogoDificultad` — SP para sincronizar valores desde staging.

## Seguridad y clasificación
- **Nivel de sensibilidad**: BAJO — etiqueta categórica sin PII.
- **Retención**: Permanente como metadato del juego.
- **Permisos**:
	- SELECT: roles `data_analyst`, `bi_reader`
	- INSERT/UPDATE: `etl_runner`, `data_steward` (controlado)
	- DELETE: DENIED (usar `Estado` para inactivar)

## Criterios sugeridos para asignación
- Tiempo promedio por sesión: esperado < 0.5 horas.
- Mecánicas: tutoriales integrados, controles simples.
- Progresión: rápido sentido de logro, baja fricción.

## Mapeo y normalización (ETL)
- Normalizar variantes antes de insertar: convertir 'facil','fácil','easy' a `Facil`.

Ejemplo ETL (SQL) para normalizar en staging:

```sql
UPDATE staging
SET Dificultad_Nombre = 'Facil'
WHERE LOWER(Dificultad_Nombre) IN ('facil','fácil','easy','e');
```

## Ejemplos de consultas de uso

1) Conteo de registros etiquetados como `Facil`:

```sql
SELECT COUNT(*) AS CantidadFacil
FROM dbo.Tabla_Madre
WHERE Dificultad_de_Juego = 'Facil';
```

2) Retención (ejemplo simplificado) para juegos `Facil`:

```sql
SELECT d.Fecha_Alta, COUNT(DISTINCT h.ID_de_Jugador) AS Usuarios_Activos_Dia7
FROM dbo.Tabla_de_Hechos_Comportamiento h
JOIN dbo.Tabla_de_Dimension_Jugador d ON h.ID_de_Jugador = d.ID_de_Jugador
JOIN dbo.Tabla_de_Dimension_Juego j ON h.ID_de_Juego = j.ID_de_Juego
WHERE j.Dificultad_de_Juego = 'Facil'
	AND h.Fecha = DATEADD(DAY, 7, d.Fecha_Alta)
GROUP BY d.Fecha_Alta;
```

## Calidad de datos y recomendaciones
- Aplicar constraint o FK a `Catalogo_Dificultad` para asegurar valores válidos.
- Registrar en staging los valores desconocidos o no mapeados para revisión manual.

---


