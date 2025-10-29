/* Lo que se realizó fue añadir las FK para la tabla de hechos comportamiento y dimension juego
    después se modificó los nombres de la tabla de medio, facil y dificil para poder maniobrar y crear nuevas que cumplan
    con las fk que se desean añadir sin modificar los datos.
    Por consiguiente, se crean las nuevas tablas y se añaden las fk para posteriormente eliminar las tablas originales. */


ALTER TABLE [dbo].[Tabla_De_Hechos_Comportamiento]
ADD CONSTRAINT FK_ID_de_Jugador_Tabla_De_Dimension_Jugador 
FOREIGN KEY (ID_de_Jugador) REFERENCES [dbo].[Tabla_De_Dimension_Jugador](ID_de_Jugador);
GO

ALTER TABLE [dbo].[Tabla_De_Dimension_Juego]
ADD CONSTRAINT FK_Tabla_De_Dimension_Juego_Tabla_De_Dimension_Jugador 
FOREIGN KEY (ID_de_Jugador) REFERENCES [dbo].[Tabla_De_Dimension_Jugador](ID_de_Jugador);
GO



ALTER TABLE [dbo].[Medio]
ADD CONSTRAINT FK_Medio_Tabla_De_Dimension_Jugador 
FOREIGN KEY (ID_de_Jugador) REFERENCES [dbo].[Tabla_De_Dimension_Jugador](ID_de_Jugador);
GO

SELECT 
    MP.ID_de_Jugador,
    MP.Género,
    MP.Edad,
    MP.Ubicación,
    MP.Género_de_Juego,
    MP.Dificultad_de_Juego,
    MP.Sesiones_por_Semana,
    MP.Duración_de_Sesión_en_Horas_en_Promedio,
    MP.Duración_de_Sesión_en_Minutos_en_Promedio,
    MP.Nivel_de_Jugador,
    MP.Logros_Desbloqueados,
    MP.Nivel_de_Enganche,
    MP.Compra_en_Juego
INTO [dbo].[Medio]
FROM [dbo].[Mediop] MP
LEFT JOIN [dbo].[Tabla_De_Dimension_Jugador] TDJ
ON TDJ.ID_de_Jugador = MP.ID_de_Jugador;
GO


ALTER TABLE [dbo].[Facil]
ADD CONSTRAINT FK_Facil_Tabla_De_Dimension_Jugador 
FOREIGN KEY (ID_de_Jugador) REFERENCES [dbo].[Tabla_De_Dimension_Jugador](ID_de_Jugador);
GO

SELECT 
    FP.ID_de_Jugador,
    FP.Género,
    FP.Edad,
    FP.Ubicación,
    FP.Género_de_Juego,
    FP.Dificultad_de_Juego,
    FP.Sesiones_por_Semana,
    FP.Duración_de_Sesión_en_Horas_en_Promedio,
    FP.Duración_de_Sesión_en_Minutos_en_Promedio,
    FP.Nivel_de_Jugador,
    FP.Logros_Desbloqueados,
    FP.Nivel_de_Enganche,
    FP.Compra_en_Juego
INTO [dbo].[Facil]
FROM [dbo].[Facilp] FP
LEFT JOIN [dbo].[Tabla_De_Dimension_Jugador] TDJ
ON TDJ.ID_de_Jugador = FP.ID_de_Jugador;
GO

ALTER TABLE [dbo].[Dificil]
ADD CONSTRAINT FK_Dificil_Tabla_De_Dimension_Jugador 
FOREIGN KEY (ID_de_Jugador) REFERENCES [dbo].[Tabla_De_Dimension_Jugador](ID_de_Jugador);
GO

SELECT 
    DP.ID_de_Jugador,
    DP.Género,
    DP.Edad,
    DP.Ubicación,
    DP.Género_de_Juego,
    DP.Dificultad_de_Juego,
    DP.Sesiones_por_Semana,
    DP.Duración_de_Sesión_en_Horas_en_Promedio,
    DP.Duración_de_Sesión_en_Minutos_en_Promedio,
    DP.Nivel_de_Jugador,
    DP.Logros_Desbloqueados,
    DP.Nivel_de_Enganche,
    DP.Compra_en_Juego
INTO [dbo].[Dificil]
FROM [dbo].[Dificilp] DP
LEFT JOIN [dbo].[Tabla_De_Dimension_Jugador] TDJ
ON TDJ.ID_de_Jugador = DP.ID_de_Jugador;
GO

ALTER TABLE [dbo].[Relacion_Dimension_Juegos]
ADD CONSTRAINT FK_Relacion_Dimension_Juegos_Clasificacion_Genero_Juegos 
FOREIGN KEY (ID_de_Juego) REFERENCES [dbo].[Clasificacion_Genero_Juegos](ID_de_Juego);
GO