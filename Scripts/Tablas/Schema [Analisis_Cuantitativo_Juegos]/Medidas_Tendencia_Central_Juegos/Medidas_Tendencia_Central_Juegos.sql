---------------------------------------------------- BEGIN CODE --------------------------------------------------

/* Crearemos una tabla para almacenar las medidas de tendencia central de las variables de interés. */
CREATE TABLE [Analisis_Cuantitativo_Juegos].[Medidas_Tendencia_Central_Juegos] (
    Variable NVARCHAR(50) NOT NULL,
    RANGO DECIMAL(18,2) NOT NULL,
    MEDIA DECIMAL(18,2) NOT NULL,
    MEDIANA DECIMAL(18,2) NOT NULL,
    MODA DECIMAL(18,2) NOT NULL
);
GO
DROP TABLE [Analisis_Cuantitativo_Juegos].[Medidas_Tendencia_Central_Juegos];
GO
/* Añadimos los campos calculados para cada columna en la tabla de medidas de tendencia central. */
INSERT INTO [Analisis_Cuantitativo_Juegos].[Medidas_Tendencia_Central_Juegos] (Variable, RANGO, MEDIA, MEDIANA, MODA)
VALUES
        ('EDAD', 
        (SELECT MAX(Edad) - MIN(Edad) FROM [dbo].[Tabla_De_Dimension_Jugador]), 
        (SELECT ROUND(AVG(Edad),2) FROM [dbo].[Tabla_De_Dimension_Jugador]), 
        (SELECT TOP 1 PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Edad ASC) OVER() FROM [dbo].[Tabla_De_Dimension_Jugador]), 
        (SELECT TOP 1 WITH TIES Edad FROM [dbo].[Tabla_De_Dimension_Jugador] GROUP BY Edad ORDER BY COUNT(*) DESC)),
        ('SESIONES POR SEMANA',
        (SELECT MAX(Sesiones_por_Semana) - MIN(Sesiones_por_Semana) FROM [dbo].[Tabla_De_Hechos_Comportamiento]), 
        (SELECT AVG(Sesiones_por_Semana) FROM [dbo].[Tabla_De_Hechos_Comportamiento]), 
        (SELECT TOP 1 PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Sesiones_por_Semana ASC) OVER() FROM [dbo].[Tabla_De_Hechos_Comportamiento]), 
        (SELECT TOP 1 WITH TIES Sesiones_por_Semana FROM [dbo].[Tabla_De_Hechos_Comportamiento] GROUP BY Sesiones_por_Semana ORDER BY COUNT(*) DESC)),
        ('DURACIÓN DE SESIÓN HORAS',
        (SELECT MAX(Duración_de_Sesión_en_Horas_en_Promedio) - MIN(Duración_de_Sesión_en_Horas_en_Promedio) FROM [dbo].[Tabla_De_Hechos_Comportamiento]), 
        (SELECT ROUND(AVG(Duración_de_Sesión_en_Horas_en_Promedio),2) FROM [dbo].[Tabla_De_Hechos_Comportamiento]), 
        (SELECT TOP 1 PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Duración_de_Sesión_en_Horas_en_Promedio ASC) OVER() FROM [dbo].[Tabla_De_Hechos_Comportamiento]), 
        (SELECT TOP 1 WITH TIES Duración_de_Sesión_en_Horas_en_Promedio FROM [dbo].[Tabla_De_Hechos_Comportamiento] GROUP BY Duración_de_Sesión_en_Horas_en_Promedio ORDER BY COUNT(*) DESC));
GO
-- Comprobamos Insercción
SELECT * FROM [Analisis_Cuantitativo_Juegos].[Medidas_Tendencia_Central_Juegos];
GO
---------------------------------------------------- END CODE ----------------------------------------------------