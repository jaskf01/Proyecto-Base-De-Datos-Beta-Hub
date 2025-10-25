# Dificil

## Resumen
`Dificil` es la etiqueta usada en el proyecto para indicar que un juego o una actividad dentro del juego tiene un nivel de dificultad alto. Se aplica en campos como `Dificultad_de_Juego` en `Tabla_Madre` y en metadatos de la dimensión de juego.

## Significado operativo
- Señala contenido que exige experiencia, estrategia avanzada o alto dominio de las mecánicas del juego.
- Se utiliza para segmentar usuarios avanzados, analizar retención a largo plazo y estudiar monetización en jugadores experimentados.

## Criterios sugeridos para asignación
- Tiempo promedio por sesión: generalmente > 2 horas (dependiendo del tipo de juego).
- Mecánicas: alta complejidad, curva de aprendizaje pronunciada, retos que requieren práctica y habilidad.
- Progresión: mayor número de fracasos/ensayos antes de completar objetivos, recompensas más altas.

## Mapeo y valores posibles
- Valor textual: `Dificil` (usar exactamente esta cadena en las columnas y documentación para consistencia).
- Código alternativo (opcional): `3` (si el catálogo de dificultad usa códigos numéricos: 1=Facil, 2=Medio, 3=Dificil).

## Uso en ETL y normalización
- Normalizar variantes antes de insertar: convertir 'difícil', 'dificil', 'hard', 'h' a `Dificil`.
- Ejemplo de actualización en staging:

```sql
UPDATE staging
SET Dificultad_Nombre = 'Dificil'
WHERE LOWER(Dificultad_Nombre) IN ('difícil','dificil','hard','h');
```

## Consultas de ejemplo

1) Conteo y porcentaje de registros `Dificil`

```sql
SELECT
	COUNT(*) AS CantidadDificil,
	100.0 * COUNT(*) / NULLIF((SELECT COUNT(*) FROM dbo.Tabla_Madre),0) AS Porcentaje
FROM dbo.Tabla_Madre
WHERE Dificultad_de_Juego = 'Dificil';
```

2) Promedio de duración de sesión para `Dificil`

```sql
SELECT AVG(Duracion_Sesion_Horas) AS PromedioHoras
FROM dbo.Tabla_Madre
WHERE Dificultad_de_Juego = 'Dificil';
```

3) Comparar monetización entre dificultades (Facil/Medio/Dificil)

```sql
SELECT j.Dificultad_de_Juego, SUM(h.Valor_Compras) AS ValorTotal, COUNT(DISTINCT h.ID_de_Jugador) AS Jugadores
FROM dbo.Tabla_de_Hechos_Comportamiento h
JOIN dbo.Tabla_de_Dimension_Juego j ON h.ID_de_Juego = j.ID_de_Juego
GROUP BY j.Dificultad_de_Juego
ORDER BY ValorTotal DESC;
```

## Calidad de datos y recomendaciones
- Forzar valores válidos mediante tabla de dominio (`Catalogo_Dificultad`) o CHECK constraint (por ejemplo: `CHECK (Dificultad_de_Juego IN ('Facil','Medio','Dificil'))`).
- Registrar y revisar en staging los valores no mapeados para evitar pérdida de información.
- Mantener consistencia entre `Tabla_Madre` y `Tabla_de_Dimension_Juego` (si ambas contienen el campo de dificultad).

## Privacidad y gobernanza
- La etiqueta `Dificil` no contiene PII; sin embargo, segmentaciones basadas en dificultad pueden combinarse con datos de usuarios — aplicar controles de acceso apropiados.


