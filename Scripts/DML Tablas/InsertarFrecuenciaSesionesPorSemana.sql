---------------------------------------------------- BEGIN CODE --------------------------------------------------
/* Insertaremos los valores que tienen por predeterminado debido a la naturaleza de estas tablas y después
    procederemos a actualizar los campos calculados con un procedimiento almacenado. */
INSERT INTO [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_SesionesPorSemana](
    Límite_Inferior,
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
        (NULL,0,0,0,0,0,0,0,0),
        (0,1,0.5,0,0,0,0,0,0),
        (1,2,1.5,0,0,0,0,0,0),
        (2,3,2.5,0,0,0,0,0,0),
        (3,4,3.5,0,0,0,0,0,0),
        (4,5,4.5,0,0,0,0,0,0),
        (5,6,5.5,0,0,0,0,0,0),
        (6,7,6.5,0,0,0,0,0,0),
        (7,8,7.5,0,0,0,0,0,0),
        (8,9,8.5,0,0,0,0,0,0),
        (9,10,9.5,0,0,0,0,0,0),
        (11,NULL,0,0,0,0,0,0,0
        );
GO

-- Comprobamos insercción
SELECT * FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_SesionesPorSemana];
GO
---------------------------------------------------- END CODE ----------------------------------------------------