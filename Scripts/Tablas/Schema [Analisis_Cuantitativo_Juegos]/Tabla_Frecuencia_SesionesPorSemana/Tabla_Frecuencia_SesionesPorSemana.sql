---------------------------------------------------- BEGIN CODE --------------------------------------------------
/* Ahora crearemos tablas de frecuencia con campos calculados y que podamos actualizar cada vez que necesitemos. */
CREATE TABLE [Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_SesionesPorSemana] (
    Intervalo INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
    Límite_Inferior DECIMAL(6,3) NULL,
    Límite_Superior DECIMAL(6,3) NULL,
    Marca_Clase DECIMAL (6,3) NULL, 
    Frecuencia INT NOT NULL,
    Frecuencia_Acumulada INT NULL,
    Frecuencia_Relativa DECIMAL(6,3) NULL,
    Frecuencia_Relativa_Acumulada DECIMAL(6,3) NULL,
    Frecuencia_Porcentual DECIMAL(6,3) NULL,
    Frecuencia_Porcentual_Acumulada DECIMAL(6,3) NULL,
);
GO
---------------------------------------------------- END CODE ----------------------------------------------------