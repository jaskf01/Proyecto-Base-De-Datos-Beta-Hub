# Descripción de Vistas

## VW_TablaFrecuenciaDuracionSesionHoras
Esta vista muestra la distribución de frecuencias de la duración de las sesiones en horas, filtrando únicamente ciertos intervalos específicos.


```sql
/* Después de la creación de todas las tablas necesarias en nuestra base de datos, como habíamos mencionado en un principio,
Nos tendremos que ayudar de vistas a las que usuarios tengan acceso para hacer un reporte simulado de lo que sería el proyecto,
por lo que procederemoos a crearlas */

-- Creamos nuestra cuarta Vista
CREATE VIEW [Analisis_Cuantitativo_Juegos].[VW_TablaFrecuenciaDuracionSesionHoras] AS
SELECT
    Intervalo AS I,
    Límite_Inferior AS '>=',
    Límite_Superior AS '<',
    Frecuencia,
    Frecuencia_Acumulada,
    Frecuencia_Porcentual,
    Frecuencia_Porcentual_Acumulada
FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_DuracionSesionHoras]
WHERE Intervalo IN ('2', '4', '6', '8', '10', '12', '14', '16', '17');
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

### Tablas Origen
- `[Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_DuracionSesionHoras]`: Tabla base que contiene los datos de distribución de duración de sesiones.

### Transformaciones Aplicadas
- Renombramiento de columnas para facilitar la lectura.
- Filtro aplicado sobre los intervalos específicos: `'2', '4', '6', '8', '10', '12', '14', '16', '17'`.

### Uso Recomendado
Consulta directa para reportes estadísticos sobre duración de sesiones:
```sql
SELECT * FROM [Analisis_Cuantitativo_Juegos].[VW_TablaFrecuenciaDuracionSesionHoras];
```
Ideal para dashboards, análisis descriptivo y generación de gráficos de distribución.

### Rendimiento
- La vista está optimizada para lectura rápida al filtrar solo los intervalos relevantes.
- Recomendado indexar la columna `Intervalo` en la tabla base si se prevé alto volumen de consultas.

### Seguridad
- Se recomienda otorgar permisos de solo lectura (`SELECT`) a los usuarios que accedan a esta vista.
- Evitar exponer la tabla base directamente para mantener encapsulamiento y control de acceso.
