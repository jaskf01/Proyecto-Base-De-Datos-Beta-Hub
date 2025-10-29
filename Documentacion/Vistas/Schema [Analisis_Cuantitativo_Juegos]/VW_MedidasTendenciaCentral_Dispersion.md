# Descripción de Vistas

## VW_MedidasTendenciaCentral_Dispersion
Esta vista combina las medidas de tendencia central y dispersión para facilitar un análisis estadístico completo de las variables cuantitativas registradas en el proyecto.


```sql
/* Después de la creación de todas las tablas necesarias en nuestra base de datos, como habíamos mencionado en un principio,
    Nos tendremos que ayudar de vistas a las que usuarios tengan acceso para hacer un reporte simulado de lo que sería
    el proyecto, por lo que procederemoos a crearlas */
CREATE VIEW [Analisis_Cuantitativo_Juegos].[VW_MedidasTendenciaCentral_Dispersion]
AS
    SELECT 
        MTCJ.Variable,
        MTCJ.RANGO,
        MTCJ.MEDIA,
        MTCJ.MEDIANA,
        MTCJ.MODA,
        MDJ.DESVIACIÓN_ESTÁNDAR,
        MDJ.VARIANZA
    FROM [Analisis_Cuantitativo_Juegos].[Medidas_Tendencia_Central_Juegos] MTCJ
    LEFT JOIN [Analisis_Cuantitativo_Juegos].[Medidas_Dispersion_Juegos] MDJ 
    ON MTCJ.Variable = MDJ.Variable;
GO
```

###  Columnas
| Columna               | Descripción                                                  |
|------------------------|--------------------------------------------------------------|
| `Variable`             | Nombre de la variable analizada                              |
| `RANGO`                | Diferencia entre el valor máximo y mínimo                    |
| `MEDIA`                | Promedio aritmético de los datos                             |
| `MEDIANA`              | Valor central de la distribución                             |
| `MODA`                 | Valor más frecuente                                          |
| `DESVIACIÓN_ESTÁNDAR` | Medida de dispersión respecto a la media                     |
| `VARIANZA`             | Medida de variabilidad de los datos                          |

### Tablas Origen
- `[Analisis_Cuantitativo_Juegos].[Medidas_Tendencia_Central_Juegos]`
- `[Analisis_Cuantitativo_Juegos].[Medidas_Dispersion_Juegos]`

### Transformaciones Aplicadas
- Unión `LEFT JOIN` entre ambas tablas por la columna `Variable`.
- Selección de columnas clave para análisis estadístico descriptivo.

### Uso Recomendado
Consulta para obtener un resumen estadístico completo de cada variable:
```sql
SELECT * FROM [Analisis_Cuantitativo_Juegos].[VW_MedidasTendenciaCentral_Dispersion];
```
Ideal para reportes, dashboards y análisis exploratorio de datos.

### Rendimiento
- La vista está optimizada para lectura, ya que no realiza cálculos complejos en tiempo real.
- Se recomienda mantener índices sobre la columna `Variable` en ambas tablas base para mejorar el rendimiento del `JOIN`.

### Seguridad
- Otorgar permisos de solo lectura (`SELECT`) a los usuarios finales.
- Limitar el acceso directo a las tablas base para preservar la integridad de los datos.
