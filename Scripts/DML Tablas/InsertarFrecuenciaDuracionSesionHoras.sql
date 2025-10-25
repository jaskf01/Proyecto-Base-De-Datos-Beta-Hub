---------------------------------------------------- BEGIN CODE --------------------------------------------------
/* Insertaremos los valores que tienen por predeterminado debido a la naturaleza de estas tablas y después
    procederemos a actualizar los campos calculados con un procedimiento almacenado. */
INSERT INTO [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_DuracionSesionHoras](
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
        (0,0.5,0.25,0,0,0,0,0,0),
        (0.5,1,0.75,0,0,0,0,0,0),
        (1,1.5,1.25,0,0,0,0,0,0),
        (1.5,2,1.75,0,0,0,0,0,0),
        (2,2.5,2.25,0,0,0,0,0,0),
        (2.5,3,2.75,0,0,0,0,0,0),
        (3,3.5,3.25,0,0,0,0,0,0),
        (3.5,4,3.75,0,0,0,0,0,0),
        (4,4.5,4.25,0,0,0,0,0,0),
        (4.5,5,4.75,0,0,0,0,0,0),
        (5,5.5,5.25,0,0,0,0,0,0),
        (5.5,6,5.75,0,0,0,0,0,0),
        (6,6.5,6.25,0,0,0,0,0,0),
        (6.5,7,6.75,0,0,0,0,0,0),
        (7,7.5,7.25,0,0,0,0,0,0),
        (7.5,8,7.75,0,0,0,0,0,0),
        (8,NULL,0,0,0,0,0,0,0
        );
GO

-- Comprobamos insercción
SELECT * FROM [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_DuracionSesionHoras];
GO
---------------------------------------------------- END CODE ----------------------------------------------------