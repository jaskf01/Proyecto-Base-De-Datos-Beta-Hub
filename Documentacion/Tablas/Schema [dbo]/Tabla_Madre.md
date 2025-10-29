
# Tabla_Madre (Schema: dbo)

## Estructura

**Propósito principal:**
- Centralizar eventos y atributos de jugadores antes de limpieza y normalización.

**Suposiciones:**
- Tipos y claves sugeridas basadas en convenciones del proyecto.

## Claves
- `ID_Registro` (PK sugerida)
- `ID_de_Jugador` (clave natural o surrogate)

## Índices
- `ID_de_Jugador` — para joins
- `Fecha_Registro` — para filtros temporales
- `Genero_Juego`, `Edad` — para agregaciones

## Objetos relacionados
- `Clasificacion_Genero_Juegos` — FK sugerida desde `Genero_Juego`
- `Tabla_de_Dimension_Jugador` — relación por `ID_de_Jugador`

## Seguridad y clasificación
- Evitar almacenar PII en texto plano
- Enmascarar/cifrar si es necesario
- Documentar políticas de retención

## Columnas propuestas

- `ID_de_Jugador` (INT, PK)
- `ID_Registro` (INT, PK AUTO_INCREMENT)
- `Genero` (VARCHAR(50))
- `Edad` (INT)
- `Ubicacion_Pais` (VARCHAR(100))
- `Genero_Juego` (VARCHAR(100))
- `Dificultad_de_Juego` (VARCHAR(50))
- `Sesiones_por_Semana` (TINYINT)
- `Duracion_Sesion_Horas` (DECIMAL(4,2))
- `Nivel_de_Jugador` (INT)
- `Logros_Desbloqueados` (INT)
- `Nivel_de_Enganche` (DECIMAL(3,2))
- `Compra_en_Juego` (BIT)
- `Fecha_Registro` (DATETIME)

## Consultas de ejemplo

```sql
-- Registros por rango de edad
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

```sql
-- Promedio de duración de sesión por género de juego
SELECT
  Genero_Juego,
  AVG(Duracion_Sesion_Horas) AS PromedioHoras
FROM dbo.Tabla_Madre
GROUP BY Genero_Juego
ORDER BY PromedioHoras DESC;
```

```sql
-- Jugadores que hicieron compra y tienen alto engagement
SELECT TOP 100 ID_de_Jugador, Nivel_de_Enganche, Compra_en_Juego
FROM dbo.Tabla_Madre
WHERE Compra_en_Juego = 1
ORDER BY Nivel_de_Enganche DESC;
```

## Buenas prácticas ETL
- Mantener como fuente inmutable
- Registrar `Fecha_Registro` y `Fuente`
- Normalizar campos categóricos
- Definir valores por defecto para nulos

## Volumen y mantenimiento
- Carga diaria sugerida
- Particionar por `Fecha_Registro` si crece mucho

## Próximos pasos
- Validar tipos contra DDL real
- Vincular desde `TABLAS.md` y `DICCIONARIO_DATOS.md`
- Generar script `CREATE TABLE` si se requiere
