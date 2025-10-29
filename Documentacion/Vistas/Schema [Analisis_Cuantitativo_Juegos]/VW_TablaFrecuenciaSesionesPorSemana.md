# Descripción de Vistas

## VW_TablaFrecuenciaSesionesPorSemana
Esta vista muestra la distribución de frecuencias del número de sesiones por semana realizadas por los jugadores, permitiendo observar patrones de actividad semanal.


```sql
/* Después de la creación de todas las tablas necesarias en nuestra base de datos, como habíamos mencionado en un principio,
    Nos tendremos que ayudar de vistas a las que usuarios tengan acceso para hacer un reporte simulado de lo que sería
    el proyecto, por lo que procederemoos a crearlas */
-- Creamos nuestra tercera Vista
CREATE VIEW [Analisis_Cuantitativo_Juegos].[VW_TablaFrecuenciaSesionesPorSemana]
AS
    SELECT
        Intervalo AS I,
        Límite_Inferior AS '>=',
        Límite_Superior AS '<',
        Frecuencia,
        Frecuencia_Acumulada,
        Frecuencia_Porcentual,
        Frecuencia_Porcentual_Acumulada
    FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_SesionesPorSemana];
GO
```

### Columnas
| Columna                          | Descripción                                      |
|----------------------------------|--------------------------------------------------|
| `I`                              | Número de intervalo                              |
| `>=`                             | Límite inferior del intervalo                    |
| `<`                              | Límite superior del intervalo                    |
| `Frecuencia`                     | Cantidad de observaciones                        |
| `Frecuencia_Acumulada`          | Suma acumulada de frecuencias                    |
| `Frecuencia_Porcentual`         | Porcentaje respecto al total                     |
| `Frecuencia_Porcentual_Acumulada` | Porcentaje acumulado respecto al total         |

### Tabla Origen
- `[Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_SesionesPorSemana]`: Contiene los datos agrupados por número de sesiones semanales.

### Transformaciones Aplicadas
- Renombramiento de columnas para facilitar la lectura.
- Selección directa de todos los intervalos disponibles en la tabla base.

### Uso Recomendado
Consulta para obtener la distribución de sesiones semanales:
```sql
SELECT * FROM [Analisis_Cuantitativo_Juegos].[VW_TablaFrecuenciaSesionesPorSemana];
```
Ideal para análisis de comportamiento de uso, segmentación de jugadores y visualización de histogramas.

### Rendimiento
- Vista optimizada para lectura rápida.
- Se recomienda indexar la columna `Intervalo` en la tabla base si se prevé alto volumen de consultas.

### Seguridad
- Otorgar permisos de solo lectura (`SELECT`) a los usuarios finales.
- Limitar el acceso directo a la tabla base para preservar la integridad de los datos.
