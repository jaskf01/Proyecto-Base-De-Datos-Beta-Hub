---------------------------------------------------- BEGIN CODE --------------------------------------------------
/* Observamos que carecemos de una clasificación de los géneros de juegos con los que estamos trabajanado.
    Procedemos a crear una tabla nueva para almacenar esta información. */
CREATE TABLE [dbo].[Clasificacion_Genero_Juegos] (
    ID_de_Juego INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    Género NVARCHAR(50) NOT NULL UNIQUE,
);
GO
-- En caso de cometer algún error:
DROP TABLE [dbo].[Clasificacion_Genero_Juegos];
GO
-- INSERTAMOS LOS GÉNEROS DE JUEGOS USADOS EN NUESTRA BASE DE DATOS.
INSERT INTO [dbo].[Clasificacion_Genero_Juegos] (Género)
VALUES
       ('Estrategia'),
       ('Deportes'),
       ('Acción'),
       ('Juego de Roles'),
       ('Simulación')
;
GO
SELECT * FROM [dbo].[Clasificacion_Genero_Juegos] ORDER BY ID_de_Juego;
GO
-- ESTRATEGIA, DEPORTES, ACCION, JUEGO DE ROLES, SIMULACION.
---------------------------------------------------- END CODE ----------------------------------------------------