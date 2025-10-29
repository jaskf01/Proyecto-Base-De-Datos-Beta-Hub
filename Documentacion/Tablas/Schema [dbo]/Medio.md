# Medio

## Resumen
Etiqueta/categoría que indica un nivel intermedio de dificultad en un juego o actividad. Se usa en `Dificultad_de_Juego` en `Tabla_Madre` y en atributos de `Tabla_de_Dimension_Juego` para clasificar experiencias.

## Estructura
- No es obligatoriamente una tabla, pero si se normaliza se sugiere la estructura de catálogo mínima:

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

Campos relevantes cuando se registra en tablas fuente:
- `Dificultad_de_Juego` (VARCHAR) — valor normalizado (`Medio`).
- `ID_Dificultad` (INT) — FK opcional hacia `Catalogo_Dificultad`.

## Claves
- Si existe `Catalogo_Dificultad`: **PK** = `ID_Dificultad`.
- En tablas fuente, `ID_Dificultad` actuaría como FK hacia `Catalogo_Dificultad`.

## Índices
- Índice único en `Catalogo_Dificultad.Nombre` para búsquedas y mapeos rápidos.
- En tablas de hechos o dimensiones: índice nonclustered sobre `Dificultad_de_Juego` o `ID_Dificultad` para acelerar filtros y agregaciones.

## Objetos relacionados
- Tablas:
	- `dbo.Tabla_Madre` (columna `Dificultad_de_Juego` / `ID_Dificultad`)
	- `dbo.Tabla_de_Dimension_Juego` (atributo `Dificultad`)

- Vistas / Procedimientos:
	- `VW_DistribucionDificultad` — vista con conteos y porcentajes por dificultad
	- `sp_ActualizarCatalogoDificultad` — SP para sincronizar valores desde staging

## Seguridad y clasificación
- **Nivel de sensibilidad**: BAJO — categoría no sensible.
- **Retención**: Permanente como metadato.
- **Permisos**:
	- SELECT: roles `data_analyst`, `bi_reader`
	- INSERT/UPDATE: `etl_runner`, `data_steward`
	- DELETE: DENIED (usar `Estado` para inactivar)

## Criterios sugeridos para asignación
- Tiempo promedio por sesión: 0.5 - 2 horas (ajustable según género de juego).
- Mecánicas: requieren cierta familiaridad con controles/estrategia.
- Progresión: curva de aprendizaje moderada.

## Mapeo y normalización (ETL)
- Normalizar variantes antes de insertar: convertir ('med','medio','medium') a `Medio`.

Ejemplo ETL (SQL):

```sql
UPDATE staging
SET Dificultad_Nombre = 'Medio'
WHERE LOWER(Dificultad_Nombre) IN ('med','medio','medium','m');
```

## Ejemplos de consultas de uso

1) Conteo de sesiones por dificultad

```sql
SELECT Dificultad_de_Juego, COUNT(*) AS Cantidad
FROM dbo.Tabla_Madre
GROUP BY Dificultad_de_Juego;
```

2) Promedio de duración de sesión para `Medio`:

```sql
SELECT AVG(Duracion_Sesion_Horas) AS PromedioHoras
FROM dbo.Tabla_Madre
WHERE Dificultad_de_Juego = 'Medio';
```

## Calidad de datos y recomendaciones
- Forzar valores válidos con tabla de dominio o constraint CHECK (ej.: `CHECK (Dificultad_de_Juego IN ('Facil','Medio','Dificil'))`).
- Registrar en staging los valores desconocidos para revisión manual.

---


