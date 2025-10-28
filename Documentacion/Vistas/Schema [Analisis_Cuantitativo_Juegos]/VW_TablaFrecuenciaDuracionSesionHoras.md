# Descripción de Vistas

## VW_TablaFrecuenciaDuracionSesionHoras
Muestra la distribución de frecuencias de la duración de las sesiones en horas.
```sql
---------------------------------------------------- BEGIN CODE --------------------------------------------------
/* Después de la creación de todas las tablas necesarias en nuestra base de datos, como habíamos mencionado en un principio,
    Nos tendremos que ayudar de vistas a las que usuarios tengan acceso para hacer un reporte simulado de lo que sería
    el proyecto, por lo que procederemoos a crearlas */
-- Creamos nuestra cuarta Vista
CREATE VIEW [Analisis_Cuantitativo_Juegos].[VW_TablaFrecuenciaDuracionSesionHoras]
AS
    SELECT
        Intervalo AS I,
        Límite_Inferior AS '>=',
        Límite_Superior AS '<',
        Frecuencia,
        Frecuencia_Acumulada,
        Frecuencia_Porcentual,
        Frecuencia_Porcentual_Acumulada
    FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_DuracionSesionHoras]
    WHERE Intervalo = '2' OR Intervalo ='4' OR Intervalo = '6' OR Intervalo = '8' OR Intervalo = '10' OR Intervalo = '12' OR Intervalo = '14' OR
    Intervalo = '16' OR Intervalo = '17';
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
SELECT * FROM [Analisis_Cuantitativo_Juegos].[VW_TablaFrecuenciaDuracionSesionHoras];
```