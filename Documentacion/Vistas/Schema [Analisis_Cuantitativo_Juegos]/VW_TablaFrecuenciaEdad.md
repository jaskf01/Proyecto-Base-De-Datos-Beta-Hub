# Descripción de Vistas

## VW_TablaFrecuenciaEdad
Esta vista muestra la distribución de frecuencias de las edades de los jugadores, permitiendo observar cómo se agrupan los datos en intervalos definidos.


```sql
/* Después de la creación de todas las tablas necesarias en nuestra base de datos, como habíamos mencionado en un principio,
    Nos tendremos que ayudar de vistas a las que usuarios tengan acceso para hacer un reporte simulado de lo que sería
    el proyecto, por lo que procederemoos a crearlas */
-- Creamos nuestra segunda Vista
CREATE VIEW [Analisis_Cuantitativo_Juegos].[VW_TablaFrecuenciaEdad]
AS
    SELECT
        Intervalo AS I,
        Clases_Inferior AS '>=',
        Clases_Superior AS '<',
        Frecuencia,
        Frecuencia_Acumulada,
        Frecuencia_Porcentual,
        Frecuencia_Porcentual_Acumulada
    FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_Edad];
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
- `[Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_Edad]`: Contiene los datos agrupados por intervalos de edad.

### Transformaciones Aplicadas
- Renombramiento de columnas para facilitar la interpretación.
- Selección directa de todos los intervalos disponibles en la tabla base.

### Uso Recomendado
Consulta para obtener la distribución de edades de los jugadores:
```sql
SELECT * FROM [Analisis_Cuantitativo_Juegos].[VW_TablaFrecuenciaEdad];
```
Útil para análisis demográfico, segmentación de usuarios y visualización de histogramas.

### Rendimiento
- La vista es liviana y rápida, ya que no realiza cálculos adicionales.
- Se recomienda indexar la columna `Intervalo` en la tabla base si se realizan consultas frecuentes.

### Seguridad
- Otorgar permisos de solo lectura (`SELECT`) a los usuarios finales.
- Mantener la tabla base protegida para evitar modificaciones no autorizadas.
