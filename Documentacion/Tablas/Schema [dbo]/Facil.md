# Fácil

## Resumen
`Fácil` es una etiqueta utilizada en el proyecto para indicar que un juego o una actividad dentro del juego tiene un nivel de dificultad bajo. Se emplea en campos como `Dificultad_de_Juego` en `Tabla_Madre` y en dimensiones relacionadas con la experiencia del jugador.

## Significado operativo
- Indica contenido introductorio o con curva de aprendizaje baja: accesible para nuevos jugadores.
- Se usa para segmentar experiencias, soportar pruebas A/B y analizar retención/métricas iniciales.

## Criterios sugeridos para asignación
- Tiempo promedio esperado por sesión: < 0.5 horas.
- Mecánicas: tutoriales integrados, controles simples, baja exigencia estratégica.
- Progresión: rápido sentido de logro, pocos puntos de fricción.

## Mapeo y valores posibles
- Valor textual: `Facil` (usar exactamente esta cadena para consistencia).
- Código alternativo (opcional): `1` (si el catálogo de dificultad usa códigos numéricos: 1=Facil, 2=Medio, 3=Dificil).

## Uso en ETL y normalización
- Normalizar variantes antes de insertar en la dimensión: convertir variantes ('facil','fácil','easy') a `Facil`.
- Ejemplo ETL (SQL) para normalizar en staging:

```sql
UPDATE staging
SET Dificultad_Nombre = 'Facil'
WHERE LOWER(Dificultad_Nombre) IN ('facil','fácil','easy','e');
```

## Consultas de ejemplo

1) Conteo de registros etiquetados como `Facil`

```sql
SELECT COUNT(*) AS CantidadFacil
FROM dbo.Tabla_Madre
WHERE Dificultad_de_Juego = 'Facil';
```

2) Retención (ejemplo simple) para juegos `Facil` — comparación entre cohortes

```sql
-- Cohorte por fecha de alta y retención a 7 días (ejemplo simplificado)
SELECT d.Fecha_Alta, COUNT(DISTINCT h.ID_de_Jugador) AS Usuarios_Activos_Dia7
FROM dbo.Tabla_de_Hechos_Comportamiento h
JOIN dbo.Tabla_de_Dimension_Jugador d ON h.ID_de_Jugador = d.ID_de_Jugador
JOIN dbo.Tabla_de_Dimension_Juego j ON h.ID_de_Juego = j.ID_de_Juego
WHERE j.Dificultad_de_Juego = 'Facil'
	AND h.Fecha = DATEADD(DAY, 7, d.Fecha_Alta)
GROUP BY d.Fecha_Alta;
```

## Calidad de datos y recomendaciones
- Aplicar constraint o tabla de dominio para forzar valores válidos (e.g., CHECK o FK a `Catalogo_Dificultad`).
- Registrar en staging los valores desconocidos o no mapeados para revisión manual.


