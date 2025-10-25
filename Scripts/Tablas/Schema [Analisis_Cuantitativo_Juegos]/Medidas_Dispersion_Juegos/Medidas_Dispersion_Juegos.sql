---------------------------------------------------- BEGIN CODE --------------------------------------------------
/* Crearemos una tabla para almacenar las medidas de dispersión de las variables de interés. */
CREATE TABLE [Analisis_Cuantitativo_Juegos].[Medidas_Dispersion_Juegos] (
    Variable NVARCHAR(50) NOT NULL,
    VARIANZA DECIMAL(18,2) NOT NULL,
    DESVIACIÓN_ESTÁNDAR DECIMAL(18,2) NOT NULL,
);
GO
/* En caso de cometer un error, borramos la tabla para volver a crearla. */
DROP TABLE [Analisis_Cuantitativo_Juegos].[Medidas_Dispersion_Juegos];
GO
/* Añadimos los campos calculados para cada columna en la tabla de medidas de dispersión. */
INSERT INTO [Analisis_Cuantitativo_Juegos].[Medidas_Dispersion_Juegos] (Variable, VARIANZA, DESVIACIÓN_ESTÁNDAR)
VALUES
        ('EDAD', 
        (SELECT VARP(Edad) FROM [dbo].[Tabla_De_Dimension_Jugador]), 
        (SELECT STDEVP(Edad) FROM [dbo].[Tabla_De_Dimension_Jugador])),
        ('SESIONES POR SEMANA',
        (SELECT VARP(Sesiones_por_Semana) FROM [dbo].[Tabla_De_Hechos_Comportamiento]), 
        (SELECT STDEVP(Sesiones_por_Semana) FROM [dbo].[Tabla_De_Hechos_Comportamiento])),
        ('DURACIÓN DE SESIÓN HORAS',
        (SELECT VARP(Duración_de_Sesión_en_Horas_en_Promedio) FROM [dbo].[Tabla_De_Hechos_Comportamiento]), 
        (SELECT STDEVP(Duración_de_Sesión_en_Horas_en_Promedio) FROM [dbo].[Tabla_De_Hechos_Comportamiento]));
GO
-- Comprobamos Insercción
SELECT * FROM [Analisis_Cuantitativo_Juegos].[Medidas_Dispersion_Juegos];
GO
---------------------------------------------------- END CODE ----------------------------------------------------