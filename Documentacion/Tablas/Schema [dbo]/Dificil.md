# Dificil

## Resumen
Etiqueta usada en el proyecto para indicar que un juego o una actividad dentro del juego tiene un nivel de dificultad alto. Se aplica en campos como `Dificultad_de_Juego` en `Tabla_Madre` y en metadatos en `Tabla_de_Dimension_Juego`.

## Estructura
- No es una tabla por sí misma (es una etiqueta/categoría). Si se implementa como catálogo, la estructura mínima sugerida sería:

```sql
CREATE TABLE dbo.Catalogo_Dificultad (
	ID_Dificultad INT IDENTITY(1,1) PRIMARY KEY,
	Nombre VARCHAR(50) NOT NULL UNIQUE, -- 'Facil','Medio','Dificil'
	Codigo INT NULL, -- opcional: 1,2,3
	Descripcion VARCHAR(250) NULL,
	Fecha_Creacion DATETIME NOT NULL DEFAULT GETDATE(),
	Estado BIT NOT NULL DEFAULT 1
);
```

Campos relevantes cuando la etiqueta se almacena en `Tabla_Madre` o `Tabla_de_Dimension_Juego`:
- `Dificultad_de_Juego` (VARCHAR) — valor textual normalizado ('Dificil').
- `ID_Dificultad` (INT) — FK opcional hacia `Catalogo_Dificultad`.

## Claves
- Si existe `Catalogo_Dificultad`: **PK** = `ID_Dificultad`.
- Si se mantiene solo como texto en `Tabla_Madre`: no aplica clave adicional.

## Índices
- En `Catalogo_Dificultad`: índice único sobre `Nombre` (para búsquedas y mapeos rápidos).
- En `Tabla_Madre` o `Tabla_de_Dimension_Juego`: índice nonclustered sobre `Dificultad_de_Juego` o sobre `ID_Dificultad` si se usan FKs, útil para agregaciones y filtros.

## Objetos relacionados
- Tablas:
	- `dbo.Tabla_Madre` (columna `Dificultad_de_Juego` o `ID_Dificultad`)
	- `dbo.Tabla_de_Dimension_Juego` (atributo `Dificultad` / `ID_Dificultad`)

- Vistas / SPs:
	- `VW_DistribucionDificultad` — vista con conteos y porcentajes por dificultad
	- `sp_ActualizarCatalogoDificultad` — procedimiento para sincronizar y normalizar valores desde staging

## Seguridad y clasificación
- **Nivel de sensibilidad**: BAJO — etiqueta categórica sin PII.
- **Retención**: Permanente como metadato del juego.
- **Permisos**:
	- SELECT: `data_analyst`, `bi_reader`
	- INSERT/UPDATE: `etl_runner`, `data_steward` (controlado)
	- DELETE: DENIED (usar `Estado` para inactivar)

## Criterios sugeridos para asignación
- Tiempo promedio por sesión: generalmente > 2 horas (ajustar por género de juego).
- Mecánicas: alta complejidad, curva de aprendizaje pronunciada.
- Progresión: mayor número de intentos antes de completar objetivos.

## Mapeo y normalización (ETL)
- Normalizar variantes antes de insertar: convertir 'difícil', 'dificil', 'hard', 'h' a `Dificil`.

Ejemplo de actualización en staging:

```sql
UPDATE staging
SET Dificultad_Nombre = 'Dificil'
WHERE LOWER(Dificultad_Nombre) IN ('difícil','dificil','hard','h');
```

## Ejemplos de consultas de uso

1) Conteo y porcentaje de registros `Dificil`:

```sql
SELECT
	COUNT(*) AS CantidadDificil,
	100.0 * COUNT(*) / NULLIF((SELECT COUNT(*) FROM dbo.Tabla_Madre),0) AS Porcentaje
FROM dbo.Tabla_Madre
WHERE Dificultad_de_Juego = 'Dificil';
```

2) Promedio de duración de sesión para `Dificil`:

```sql
SELECT AVG(Duracion_Sesion_Horas) AS PromedioHoras
FROM dbo.Tabla_Madre
WHERE Dificultad_de_Juego = 'Dificil';
```

3) Monetización por dificultad (Facil/Medio/Dificil):

```sql
SELECT j.Dificultad_de_Juego, SUM(h.Valor_Compras) AS ValorTotal, COUNT(DISTINCT h.ID_de_Jugador) AS Jugadores
FROM dbo.Tabla_de_Hechos_Comportamiento h
JOIN dbo.Tabla_de_Dimension_Juego j ON h.ID_de_Juego = j.ID_de_Juego
GROUP BY j.Dificultad_de_Juego
ORDER BY ValorTotal DESC;
```

## Calidad de datos y recomendaciones
- Forzar valores válidos mediante `Catalogo_Dificultad` o `CHECK` constraint:

```sql
ALTER TABLE dbo.Tabla_Madre
ADD CONSTRAINT CHK_Dificultad_Valores CHECK (Dificultad_de_Juego IN ('Facil','Medio','Dificil'));
```

- Registrar y revisar en staging los valores no mapeados para evitar pérdida de información.
- Mantener consistencia entre `Tabla_Madre` y `Tabla_de_Dimension_Juego`.

## Privacidad y gobernanza
- La etiqueta `Dificil` no contiene PII, pero segmentaciones pueden combinarse con datos de usuario — aplicar controles de acceso y auditoría apropiados.

## Notas finales
- Usar `Estado` para desactivar categorías en lugar de borrarlas. Mantener un proceso de revisión para cambios en el catálogo de dificultad.


