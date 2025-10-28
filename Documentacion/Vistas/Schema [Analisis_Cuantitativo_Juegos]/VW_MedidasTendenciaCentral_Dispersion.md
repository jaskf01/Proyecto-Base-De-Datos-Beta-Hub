# Descripción de Vistas

## VW_MedidasTendenciaCentral_Dispersion
Esta vista combina las medidas de tendencia central y dispersión para facilitar el análisis estadístico completo.

```sql
---------------------------------------------------- BEGIN CODE --------------------------------------------------
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
---------------------------------------------------- END CODE ----------------------------------------------------
```

### Columnas
- Variable: Nombre de la variable analizada
- RANGO: Diferencia entre el valor máximo y mínimo
- MEDIA: Promedio aritmético
- MEDIANA: Valor central
- MODA: Valor más frecuente
- DESVIACIÓN_ESTÁNDAR: Medida de dispersión respecto a la media
- VARIANZA: Medida de variabilidad de los datos

### Uso
```sql
SELECT * FROM [Analisis_Cuantitativo_Juegos].[VW_MedidasTendenciaCentral_Dispersion];
```
