---------------------------------------------------- BEGIN CODE --------------------------------------------------
/* Observamos que la tabla de dimensión juego no tiene una columna que identifique de manera única cada juego.
   Por lo que usaremos la tabla Clasificacion_Genero_Juegos para agregar una columna ID_de_Juego a la tabla de dimensión juego.
   Para ello utilizaremos una Tabla que relacione ambas tablas (esto para poder ser añadida después como Foreign Key). */
SELECT 
    CGJ.ID_de_Juego, 
    TDJ.Género_de_Juego,    
    TDJ.Dificultdad_de_Juego
INTO [dbo].[Relacion_Dimension_Juegos]
FROM [dbo].[Tabla_De_Dimension_Juego] TDJ
LEFT JOIN [dbo].[Clasificacion_Genero_Juegos] CGJ
    ON TDJ.Género_de_Juego = CGJ.Género;
GO

SELECT * FROM [dbo].[Relacion_Dimension_Juegos];
GO
---------------------------------------------------- END CODE ----------------------------------------------------