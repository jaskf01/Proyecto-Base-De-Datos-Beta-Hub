# Tabla_de_Hechos_Comportamiento (Schema: dbo)

## Resumen
Tabla de hechos que registra eventos y métricas de comportamiento de jugadores. Se utiliza para análisis temporales, agregaciones por jugador/juego y para alimentar cubos o modelos analíticos.

Propósito principal:
- Almacenar medidas (duración, eventos, compras) y dimensiones de enlace (jugador, juego, tiempo) en forma denormalizada para consultas analíticas.

## Suposiciones
- El DDL original no se encuentra en este archivo; las columnas y tipos siguientes son propuestas basadas en la convención del proyecto y en la `Tabla_Madre`.
- Marcaré como `FK` las columnas que normalmente referencian dimensiones (ajustar si el DDL real es distinto).

## Estructura de columnas (documentación propuesta)

- `ID_Hecho` (BIGINT, PK IDENTITY) — Identificador único de la fila en la tabla de hechos.

- `ID_de_Jugador` (INT, FK -> Tabla_de_Dimension_Jugador.ID_de_Jugador) — Identificador del jugador.

- `ID_de_Juego` (INT, FK -> Tabla_de_Dimension_Juego.ID_de_Juego) — Identificador del juego o género.

- `Fecha` (DATE) — Fecha del evento o agregación.

- `Fecha_Hora` (DATETIME) — Marca temporal completa (opcional si se requiere granularidad horaria).

- `Evento_Tipo` (VARCHAR(100)) — Tipo de evento (inicio_sesion, fin_sesion, compra, logro_desbloqueado, etc.).

- `Duracion_Sesion_Horas` (DECIMAL(5,2)) — Duración de la sesión asociada al registro (si aplica).

- `Sesiones_En_Periodo` (INT) — Número de sesiones en el periodo (por ejemplo, día/semana) si la tabla almacena agregados.

- `Cantidad_Compras` (INT) — Número de transacciones en el periodo.

- `Valor_Compras` (DECIMAL(12,2)) — Valor monetario total de compras en la moneda del sistema.

- `Logros_Desbloqueados` (INT) — Cantidad de logros desbloqueados en el evento/periodo.

- `Nivel_de_Enganche` (DECIMAL(5,4)) — Métrica de engagement normalizada (0-1), calculada por el pipeline.

- `Fuente` (VARCHAR(100)) — Origen del dato (ingesta, API, ETL, etc.) para trazabilidad.

- `Batch_ID` (VARCHAR(50)) — Identificador del lote de carga (útil para re-procesos y auditoría).

## Claves, índices y particionado sugerido

- Clave primaria recomendada: `ID_Hecho`.
- Índices recomendados:
	- Index compuesto (`ID_de_Jugador`, `Fecha`) para consultas por jugador en periodos.
	- Index en `ID_de_Juego` para agregaciones por juego.
	- Index en `Fecha` para particionado y consultas temporales.
- Particionado recomendado: particionar por rango en `Fecha` (por ejemplo, por mes) si el volumen es grande.

## Consideraciones ETL/Modelado
- Modelo estrella: esta tabla actúa como hecho central y se une a dimensiones de jugador, juego y tiempo.
- Cargar desde la `Tabla_Madre` durante el proceso ETL: transformar/normalizar las categorías y mapear IDs de dimensiones.
- Mantener `Batch_ID` y `Fuente` para soporte de replay y auditoría.

## Consultas de ejemplo

1) Total de valor de compras por día y por juego

```sql
SELECT Fecha, d.Nombre_Juego AS Juego, SUM(Valor_Compras) AS ValorTotal
FROM dbo.Tabla_de_Hechos_Comportamiento h
JOIN dbo.Tabla_de_Dimension_Juego d ON h.ID_de_Juego = d.ID_de_Juego
WHERE Fecha BETWEEN '2025-01-01' AND '2025-01-31'
GROUP BY Fecha, d.Nombre_Juego
ORDER BY Fecha, ValorTotal DESC;
```

2) Promedio de duración de sesión por jugador (últimos 30 días)

```sql
SELECT ID_de_Jugador, AVG(Duracion_Sesion_Horas) AS PromedioHoras
FROM dbo.Tabla_de_Hechos_Comportamiento
WHERE Fecha >= DATEADD(DAY, -30, CAST(GETDATE() AS DATE))
GROUP BY ID_de_Jugador
HAVING COUNT(*) >= 3 -- por ejemplo, filtrar jugadores con al menos 3 sesiones
ORDER BY PromedioHoras DESC;
```

3) Top 10 jugadores por valor de compras acumulado

```sql
SELECT TOP 10 ID_de_Jugador, SUM(Valor_Compras) AS TotalCompras
FROM dbo.Tabla_de_Hechos_Comportamiento
GROUP BY ID_de_Jugador
ORDER BY TotalCompras DESC;
```

## Calidad de datos y validaciones recomendadas
- Validar duplicados por combinación (`ID_de_Jugador`, `Fecha_Hora`, `Evento_Tipo`) si se espera unicidad de eventos.
- Comprobar rangos válidos para `Duracion_Sesion_Horas` y `Valor_Compras`.
- Normalizar `Evento_Tipo` contra una tabla de dominios para evitar inconsistencias.

## Privacidad, retención y gobernanza
- No almacenar PII en esta tabla; utilizar `ID_de_Jugador` referencial en lugar de datos personales.
- Política de retención: definir cuánto tiempo se mantiene la granularidad completa; aplicar agregaciones y archivar/compactar datos históricos.

## Volumen y performance
- Documentar frecuencia de cargas y volumen esperado (filas/día). Si el tamaño supera decenas de millones de filas por mes, activar particionado y compresión.

## Notas finales y próximos pasos
- Validar este documento contra el DDL real y el pipeline ETL.
- Puedo generar un `CREATE TABLE` sugerido (incluyendo índices y particionado) o buscar en el repositorio el DDL real y adaptar la documentación.

---



