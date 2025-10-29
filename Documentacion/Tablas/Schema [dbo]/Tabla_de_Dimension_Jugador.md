# Tabla_de_Dimension_Jugador (Schema: dbo)

## Resumen
Tabla de dimensión que almacena atributos descriptivos del jugador. Se utiliza para enriquecer los hechos de comportamiento y para los análisis segmentados (por edad, país, nivel, segmento, etc.).

Propósito:
- Mantener los atributos estables o lentamente cambiantes del jugador para unirse a las tablas de hechos.

## Suposiciones
- El archivo original estaba vacío; aquí se proponen columnas y tipos basados en convenciones del proyecto y en la `Tabla_Madre`.
- Ajustar tipos y nombres si existe un DDL real distinto en el repositorio.

## Columnas propuestas

- `ID_de_Jugador` (INT, PK) — Identificador único del jugador.
  - Recomendación: usar surrogate key (INT IDENTITY) si no hay un identificador natural estable.

- `Jugador_UUID` (UNIQUEIDENTIFIER, NULLABLE) — UUID opcional si existe identificación distribuida.

- `Nombre` (VARCHAR(200), NULLABLE) — Nombre del jugador (si se almacena; considerar privacidad).

- `Email_Hash` (VARCHAR(128), NULLABLE) — Hash del email para identificación sin exponer PII (p.ej. SHA-256).

- `Fecha_Nacimiento` (DATE, NULLABLE) — Fecha de nacimiento.

- `Edad` (INT, NULLABLE) — Edad calculada (documentar cómo y cuándo se actualiza).

- `Genero` (VARCHAR(50), NULLABLE) — Género reportado.

- `Pais` (VARCHAR(100), NULLABLE) — País de residencia.

- `Ciudad` (VARCHAR(100), NULLABLE) — Ciudad (opcional).

- `Nivel` (INT, NULLABLE) — Nivel actual del jugador en el juego.

- `Segmento` (VARCHAR(50), NULLABLE) — Segmentación analítica (p.ej., 'Casual','Core','Hardcore').

- `Estado_Cuenta` (VARCHAR(50)) — Estado (activo, inactivo, baneado, eliminado).

- `Plataforma` (VARCHAR(50)) — Plataforma principal (PC, iOS, Android, Consola).

- `Fecha_Alta` (DATETIME) — Fecha de creación del jugador en el sistema.

- `Fecha_Ultima_Actualizacion` (DATETIME) — Última actualización de la dimensión (para SCD tracking).

- `Fuente` (VARCHAR(100)) — Origen del registro (API, import, sync, etc.).

## Claves e índices sugeridos

- Clave primaria: `ID_de_Jugador`.
- Índices recomendados:
  - Índice único en `Email_Hash` si se usa para identificar usuarios (evita duplicados).
  - Índice en `Segmento` y `Nivel` para consultas rápidas de segmentación.
  - Índice en `Pais` para análisis geográfico.

## Manejo de cambios (SCD)
- Tipo recomendado: SCD tipo 2 para atributos críticos que cambian (por ejemplo, `Segmento`, `Pais`, `Nivel`) si necesitas mantener el histórico.
  - Alternativa: SCD tipo 1 (sobrescribir) para atributos no críticos.
- Si se implementa SCD2, agregar columnas: `Fecha_Vigencia_Inicio`, `Fecha_Vigencia_Fin`, `Is_Current`.

## Calidad de datos y validaciones
- Validar unicidad de identificadores externos antes de insertar.
- Normalizar valores categóricos (`Genero`, `Pais`, `Plataforma`) mediante tablas de dominio.
- Validar rango de `Edad` y coherencia con `Fecha_Nacimiento`.

## Consultas de ejemplo

1) Contar jugadores por país y segmento

```sql
SELECT Pais, Segmento, COUNT(*) AS Cantidad
FROM dbo.Tabla_de_Dimension_Jugador
WHERE Estado_Cuenta = 'activo'
GROUP BY Pais, Segmento
ORDER BY Cantidad DESC;
```

2) Listado de jugadores con alto nivel en plataforma móvil

```sql
SELECT ID_de_Jugador, Nombre, Nivel, Plataforma
FROM dbo.Tabla_de_Dimension_Jugador
WHERE Plataforma IN ('iOS','Android') AND Nivel >= 30
ORDER BY Nivel DESC;
```

3) Detectar posibles duplicados por hash de email

```sql
SELECT Email_Hash, COUNT(*) AS Repeticiones
FROM dbo.Tabla_de_Dimension_Jugador
WHERE Email_Hash IS NOT NULL
GROUP BY Email_Hash
HAVING COUNT(*) > 1;
```

## Privacidad y seguridad
- Evitar almacenar emails en texto claro; usar `Email_Hash` o tokenización.
- Proteger acceso a la tabla con roles y políticas de row-level security si aplica.
- Registrar cambios sensibles y rotar hashes/sal si la política lo requiere.

## Mantenimiento y volumen
- Registrar frecuencia de actualización (p.ej., diaria) y estimación del número de filas.
- Si la tabla crece mucho, considerar compresión y particionado por `Fecha_Alta` (menos común en dimensiones, pero posible si archivas versiones SCD2).

## Enlaces y siguientes pasos
- Enlazar desde `TABLAS.md` y `DICCIONARIO_DATOS.md` a este archivo.
- Validar contra DDL real y el pipeline de ingestión. Puedo generar un DDL sugerido o buscar el DDL real en `Scripts/DDL Tablas`.

---
