---------------------------------------------------- BEGIN CODE --------------------------------------------------
/* Notamos que la tabla de dimensión juego le falta una Foreign Key de la tabla clasificacion_genero_juegos.
    Procedimiento para agregar la FK:
    Para ello empezamos modificando la tabla de dimensión juego. */
ALTER TABLE [dbo].[Tabla_De_Dimension_Juego]
ADD ID_de_Genero_Juego INT NULL;
GO
-- Por si cometemos algún error:
ALTER TABLE [dbo].[Tabla_De_Dimension_Juego]
DROP COLUMN ID_de_Genero_Juego;
GO
/* Ahora procedemos a actualizar la tabla de hechos comportamiento jugador con la información de la tabla de dimensión juego. */
UPDATE [dbo].[Tabla_De_Dimension_Juego]
SET ID_de_Genero_Juego = CGJ.ID_de_Juego
FROM [dbo].[Tabla_De_Dimension_Juego] TDJ
INNER JOIN [dbo].[Clasificacion_Genero_Juegos] CGJ
    ON TDJ.Género_de_Juego = CGJ.Género;
GO
-- Comprobamos que el código sea correcto antes de actualizar la tabla de dimension juego.
SELECT 
    *
FROM [dbo].[Tabla_De_Dimension_Juego] TDJ
INNER JOIN [dbo].[Clasificacion_Genero_Juegos] CGJ
    ON TDJ.Género_de_Juego = CGJ.Género
    ORDER BY ID_de_Jugador;
GO
-- Actualizamos y vemos el resultado.
SELECT * FROM [dbo].[Tabla_De_Dimension_Juego];
GO
/* Finalmente procedemos a agregar la Foreign Key. */
ALTER TABLE [dbo].[Tabla_De_Dimension_Juego]
ADD CONSTRAINT FK_Clasificacion_Genero_Juegos_Tabla_De_Dimension_Juego
FOREIGN KEY (ID_de_Genero_Juego)
REFERENCES [dbo].[Clasificacion_Genero_Juegos](ID_de_Juego);
GO
SELECT * FROM [dbo].[Tabla_De_Dimension_Juego];
GO
---------------------------------------------------- END CODE ----------------------------------------------------