
# Tabla_de_Hechos_Comportamiento (Schema: dbo)

## Estructura
Tabla de hechos que registra eventos y métricas de comportamiento de jugadores. Se utiliza para análisis temporales, agregaciones por jugador/juego y para alimentar cubos o modelos analíticos.

Propósito principal:
- Almacenar medidas (duración, eventos, compras) y dimensiones de enlace (jugador, juego, tiempo) en forma denormalizada para consultas analíticas.

## Claves
- `ID_Hecho` (BIGINT, PK IDENTITY) — Identificador único de la fila en la tabla de hechos.
- `ID_de_Jugador` (INT, FK → Tabla_de_Dimension_Jugador.ID_de_Jugador)
- `ID_de_Juego` (INT, FK → Tabla_de_Dimension_Juego.ID_de_Juego)

## Índices
- Índice compuesto (`ID_de_Jugador`, `Fecha`) para consultas por jugador en periodos.
- Índice en `ID_de_Juego` para agregaciones por juego.
- Índice en `Fecha` para particionado y consultas temporales.

## Objetos relacionados
- `dbo.Tabla_de_Dimension_Jugador`
- `dbo.Tabla_de_Dimension_Juego`
- `dbo.Tabla_Madre`

## Seguridad y clasificación
- No contiene PII directamente; usar `ID_de_Jugador` como referencia.
- Política de retención: definir duración de almacenamiento detallado.
- Control de acceso por roles (`etl_runner`, `data_analyst`, `db_owner`).

## Columnas propuestas
- `ID_Hecho` (BIGINT, PK IDENTITY)
- `ID_de_Jugador` (INT, FK)
- `ID_de_Juego` (INT, FK)
- `Fecha` (DATE)
- `Fecha_Hora` (DATETIME)
- `Evento_Tipo` (VARCHAR(100))
- `Duracion_Sesion_Horas` (DECIMAL(5,2))
- `Sesiones_En_Periodo` (INT)
- `Cantidad_Compras` (INT)
- `Valor_Compras` (DECIMAL(12,2))
- `Logros_Desbloqueados` (INT)
- `Nivel_de_Enganche` (DECIMAL(5,4))
- `Fuente` (VARCHAR(100))
- `Batch_ID` (VARCHAR(50))

## Consultas de ejemplo

```sql
-- Total de valor de compras por día y por juego
SELECT Fecha, d.Nombre_Juego AS Juego, SUM(Valor_Compras) AS ValorTotal
FROM dbo.Tabla_de_Hechos_Comportamiento h
JOIN dbo.Tabla_de_Dimension_Juego d ON h.ID_de_Juego = d.ID_de_Juego
WHERE Fecha BETWEEN '2025-01-01' AND '2025-01-31'
GROUP BY Fecha, d.Nombre_Juego
ORDER BY Fecha, ValorTotal DESC;
```

```sql
-- Promedio de duración de sesión por jugador (últimos 30 días)
SELECT ID_de_Jugador, AVG(Duracion_Sesion_Horas) AS PromedioHoras
FROM dbo.Tabla_de_Hechos_Comportamiento
WHERE Fecha >= DATEADD(DAY, -30, CAST(GETDATE() AS DATE))
GROUP BY ID_de_Jugador
HAVING COUNT(*) >= 3
ORDER BY PromedioHoras DESC;
```

```sql
-- Top 10 jugadores por valor de compras acumulado
SELECT TOP 10 ID_de_Jugador, SUM(Valor_Compras) AS TotalCompras
FROM dbo.Tabla_de_Hechos_Comportamiento
GROUP BY ID_de_Jugador
ORDER BY TotalCompras DESC;
```

## Validaciones y calidad de datos
- Validar duplicados por (`ID_de_Jugador`, `Fecha_Hora`, `Evento_Tipo`).
- Comprobar rangos válidos para `Duracion_Sesion_Horas` y `Valor_Compras`.
- Normalizar `Evento_Tipo` contra tabla de dominios.

## Rendimiento y mantenimiento
- Particionar por `Fecha` si el volumen es alto.
- Documentar frecuencia de carga y volumen esperado.
- Aplicar compresión si hay muchas columnas y registros.

## Próximos pasos
- Validar contra DDL real y pipeline ETL.
- Generar `CREATE TABLE` sugerido si se requiere.
