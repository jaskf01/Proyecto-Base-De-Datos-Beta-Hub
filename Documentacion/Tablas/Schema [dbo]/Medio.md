# Medio

## Resumen
`Medio` es una etiqueta/categoría utilizada en el proyecto para clasificar el nivel de dificultad de un juego o de una actividad dentro del juego. Se emplea en campos como `Dificultad_de_Juego` en `Tabla_Madre` y en dimensiones relacionadas con la experiencia de juego.

## Significado operativo
- Indica un nivel intermedio de complejidad o reto: no es ni fácil (introductorio) ni difícil (avanzado).
- En la práctica se usa para:
	- Definir expectativas de contenido (duración, mecánicas, curva de aprendizaje).
	- Segmentar usuarios para análisis de retención y monetización.

## Criterios sugeridos para asignación
- Tiempo promedio esperado por sesión: 0.5 - 2 horas.
- Dificultad en mecánicas: requiere cierta familiaridad con controles/estrategia pero no conocimientos avanzados.
- Progresión: curva moderada de aprendizaje con desafíos incrementales.

## Mapeo y valores posibles
- Valor textual: `Medio` (usar exactamente esta cadena para consistencia).
- Código alternativo (opcional): `2` (si el catálogo de dificultad usa códigos numéricos: 1=Facil, 2=Medio, 3=Dificil).

## Uso en ETL y normalización
- Normalizar valores antes de insertar en la dimensión: convertir variantes ('med','medio','Medium') a `Medio`.
- Si se usan códigos, mantener ambas columnas (`Dificultad_Codigo`, `Dificultad_Nombre`) o mapear al catálogo de dificultades.

Ejemplo de mapeo en SQL (ETL simple):

```sql
-- Mapea variantes al valor normalizado 'Medio'
UPDATE staging
SET Dificultad_Nombre = 'Medio'
WHERE LOWER(Dificultad_Nombre) IN ('med','medio','medium','m');
```

## Consultas de ejemplo

1) Conteo de sesiones por dificultad

```sql
SELECT Dificultad_de_Juego, COUNT(*) AS Cantidad
FROM dbo.Tabla_Madre
GROUP BY Dificultad_de_Juego;
```

2) Promedio de duración de sesión para la dificultad `Medio`

```sql
SELECT AVG(Duracion_Sesion_Horas) AS PromedioHoras
FROM dbo.Tabla_Madre
WHERE Dificultad_de_Juego = 'Medio';
```

## Calidad de datos y recomendaciones
- Forzar valores válidos con una tabla de dominio o constraint CHECK (p. ej. CHECK (Dificultad_de_Juego IN ('Facil','Medio','Dificil'))).
- Registrar en staging los valores desconocidos para revisión manual.

