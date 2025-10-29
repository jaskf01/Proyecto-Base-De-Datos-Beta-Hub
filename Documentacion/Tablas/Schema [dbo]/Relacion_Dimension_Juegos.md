# Relación entre dimensiones y tablas de hechos (Juegos)

## Estructura

**Entidades principales:**
- `Tabla_Madre`: datos fuente brutos (entrada ETL).
- `Tabla_de_Hechos_Comportamiento`: tabla de hechos que registra eventos por jugador/juego/tiempo.
- `Tabla_de_Dimension_Juego`: dimensión con atributos del juego (nombre, género, dificultad, plataforma).
- `Tabla_de_Dimension_Jugador`: dimensión del jugador (demografía, fecha_alta, segmento).
- `Clasificacion_Genero_Juegos`: catálogo de géneros para normalizar `Genero`.

**Diagrama lógico resumido:**

```
Tabla_Madre (origen)
   |
   |  (ETL: limpieza, normalización, mapeo de IDs)
   v
Tabla_de_Hechos_Comportamiento (Hecho)
   |--> Tabla_de_Dimension_Jugador (Dim)
   |--> Tabla_de_Dimension_Juego (Dim)
                          |
                          --> Clasificacion_Genero_Juegos (Catálogo)
```

**Notas:**
- Flujo típico: extraer de `Tabla_Madre`, normalizar/mapping, escribir en hechos y dimensiones.
- Usar valores `unknown` en dimensiones para referencias faltantes.

## Claves

**Tabla_de_Hechos_Comportamiento**
- **PK sugerida**: `ID_Hecho` (clave sustituta) o combinación (`ID_de_Jugador`, `ID_de_Juego`, `Fecha`, `Evento_ID`).
- **FKs**:
  - `ID_de_Jugador` → `Tabla_de_Dimension_Jugador.ID_de_Jugador`
  - `ID_de_Juego` → `Tabla_de_Dimension_Juego.ID_de_Juego`

**Tabla_de_Dimension_Juego**
- **PK**: `ID_de_Juego`
- **FK opcional**: `ID_Genero` → `Clasificacion_Genero_Juegos.ID_de_Juego`

**Tabla_de_Dimension_Jugador**
- **PK**: `ID_de_Jugador`

**Recomendación de integridad**: FKs con `ON DELETE/UPDATE = NO ACTION` o `SET NULL` para evitar pérdida de datos históricos.

## Índices

**Tabla_de_Hechos_Comportamiento**
- PK clustered en `ID_Hecho` o clave compuesta.
- `IX_Hechos_Jugador_Fecha` (`ID_de_Jugador`, `Fecha`)
- `IX_Hechos_Juego_Fecha` (`ID_de_Juego`, `Fecha`)

**Dimensiones**
- Índices sobre PKs (`ID_de_Juego`, `ID_de_Jugador`)
- Índices en columnas de filtros frecuentes (`Pais`, `Plataforma`, `Segmento`)

**Particionado/compresión**
- Particionar hechos por `Fecha`
- Comprimir particiones históricas

## Objetos relacionados

**Tablas**
- `dbo.Tabla_Madre`
- `dbo.Tabla_de_Hechos_Comportamiento`
- `dbo.Tabla_de_Dimension_Juego`
- `dbo.Tabla_de_Dimension_Jugador`
- `dbo.Clasificacion_Genero_Juegos`

**Vistas y procedimientos**
- `VW_Hechos_Por_Juego`
- `VW_Jugadores_Segmento`
- `sp_ActualizarTablasHechos`
- `sp_SincronizarDimensiones`

## Seguridad y clasificación

**Nivel de sensibilidad**: MEDIO  
**Restricciones**:
- Control de acceso por roles (`etl_runner`, `data_analyst`, `db_owner`)
- Enmascarar/anonimizar datos sensibles en vistas de reporting

**Permisos sugeridos**:
- `SELECT`: `data_analyst`, `bi_reader`
- `INSERT/UPDATE`: `etl_runner`
- `DDL`: `db_admin`

## Manejo de datos faltantes y referencias rotas

- Insertar filas `unknown` o `sin_categoria` en dimensiones
- Registrar errores en tabla de incidencias ETL

## Ejemplos de consultas

**1. Agregado diario de compras por juego y género**
```sql
SELECT
  h.Fecha,
  j.Nombre_Juego,
  g.Genero,
  SUM(h.Valor_Compras) AS ValorTotal
FROM dbo.Tabla_de_Hechos_Comportamiento h
JOIN dbo.Tabla_de_Dimension_Juego j ON h.ID_de_Juego = j.ID_de_Juego
LEFT JOIN dbo.Clasificacion_Genero_Juegos g ON j.ID_Genero = g.ID_de_Juego
WHERE h.Fecha BETWEEN '2025-01-01' AND '2025-01-31'
GROUP BY h.Fecha, j.Nombre_Juego, g.Genero
ORDER BY h.Fecha, ValorTotal DESC;
```

**2. Cohorte por fecha de alta del jugador y gasto acumulado**
```sql
SELECT
  DATEPART(YEAR, d.Fecha_Alta) AS AnoAlta,
  SUM(h.Valor_Compras) AS GastoTotal
FROM dbo.Tabla_de_Hechos_Comportamiento h
JOIN dbo.Tabla_de_Dimension_Jugador d ON h.ID_de_Jugador = d.ID_de_Jugador
GROUP BY DATEPART(YEAR, d.Fecha_Alta)
ORDER BY AnoAlta;
```

**3. Tasa de conversión por juego**
```sql
SELECT
  j.ID_de_Juego,
  j.Nombre_Juego,
  SUM(CASE WHEN h.Evento_Tipo = 'compra' THEN 1 ELSE 0 END) * 1.0 /
    NULLIF(SUM(CASE WHEN h.Evento_Tipo = 'visita' THEN 1 ELSE 0 END), 0) AS TasaConversion
FROM dbo.Tabla_de_Hechos_Comportamiento h
JOIN dbo.Tabla_de_Dimension_Juego j ON h.ID_de_Juego = j.ID_de_Juego
GROUP BY j.ID_de_Juego, j.Nombre_Juego
ORDER BY TasaConversion DESC;
```

## Consideraciones de rendimiento y escalabilidad

- Particionar hechos por `Fecha`
- Mantener estadísticas actualizadas
- Reorganizar o reconstruir índices periódicamente

## Próximos pasos

- Validar FKs en entorno de staging
- Generar scripts `ALTER TABLE` para aplicar claves e índices
