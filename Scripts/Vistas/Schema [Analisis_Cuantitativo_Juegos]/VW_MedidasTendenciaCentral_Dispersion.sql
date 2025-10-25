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

SELECT * FROM [Analisis_Cuantitativo_Juegos].[VW_MedidasTendenciaCentral_Dispersion];
GO
---------------------------------------------------- END CODE ----------------------------------------------------