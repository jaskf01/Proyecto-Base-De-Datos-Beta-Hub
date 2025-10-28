# Descripción de Vistas

## VW_TablaFrecuenciaEdad
Muestra la distribución de frecuencias de las edades de los jugadores.
```sql
---------------------------------------------------- BEGIN CODE --------------------------------------------------
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
---------------------------------------------------- END CODE ----------------------------------------------------
```

### Columnas
- I: Número de intervalo
- >=: Límite inferior del intervalo
- <: Límite superior del intervalo
- Frecuencia: Cantidad de observaciones
- Frecuencia_Acumulada: Suma acumulada
- Frecuencia_Porcentual: Porcentaje del total
- Frecuencia_Porcentual_Acumulada: Porcentaje acumulado

### Uso
```sql
SELECT * FROM [Analisis_Cuantitativo_Juegos].[VW_TablaFrecuenciaEdad];
```