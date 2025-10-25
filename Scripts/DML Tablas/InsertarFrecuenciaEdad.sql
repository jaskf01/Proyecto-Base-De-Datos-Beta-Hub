---------------------------------------------------- BEGIN CODE --------------------------------------------------
/* Insertaremos los valores que tienen por predeterminado debido a la naturaleza de estas tablas y después
    procederemos a actualizar los campos calculados con un procedimiento almacenado. */
INSERT INTO [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_Edad](
    Límite_Inferior,
    Clases_Inferior,
    Clases_Superior,
    Límite_Superior,
    Marca_Clase,
    Frecuencia,
    Frecuencia_Acumulada,
    Frecuencia_Relativa,
    Frecuencia_Relativa_Acumulada,
    Frecuencia_Porcentual,
    Frecuencia_Porcentual_Acumulada,
)
VALUES 
        (NULL, NULL, NULL, 15, 13.5,0,0,0,0,0,0),
        (15,15,17,17.125,16,0,0,0,0,0,0),
        (17.125,18,19,19.250,18.5,0,0,0,0,0,0),
        (19.250,20,21,21.375,20.5,0,0,0,0,0,0),
        (21.375,22,23,23.500,22.5,0,0,0,0,0,0),
        (23.500,24,25,25.625,24.5,0,0,0,0,0,0),
        (25.625,26,27,27.750,26.5,0,0,0,0,0,0),
        (27.750,28,29,29.875,28.5,0,0,0,0,0,0),
        (29.875,30,31,32,30.5,0,0,0,0,0,0),
        (32,32,34,34.125,33,0,0,0,0,0,0),
        (34.125,35,36,36.250,35.5,0,0,0,0,0,0),
        (36.250,37,38,38.375,37.5,0,0,0,0,0,0),
        (38.375,39,40,40.500,39.5,0,0,0,0,0,0),
        (40.500,41,42,42.625,41.5,0,0,0,0,0,0),
        (42.625,43,44,44.750,43.5,0,0,0,0,0,0),
        (44.750,45,46,46.875,45.5,0,0,0,0,0,0),
        (46.875,47,49,49,48,0,0,0,0,0,0),
        (49,NULL,NULL,NULL,0,0,0,0,0,0,0
        );
GO

-- Comprobamos insercción
SELECT * FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_Edad];
GO
---------------------------------------------------- END CODE ----------------------------------------------------