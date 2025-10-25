---------------------------------------------------- BEGIN CODE --------------------------------------------------
/* Trigger para SINCRONIZAR los cambios de la Tabla_Madre hacia las tres tablas normalizadas (Dimensiones y Hechos).
    Se dispara DESPUÉS de cualquier INSERT o UPDATE. */
CREATE TRIGGER TRG_SincronizarHijasDesdeMadre
ON [dbo].[Tabla_Madre]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el ID_de_Jugador fue actualizado, ya que es la clave.
    -- Si el ID_de_Jugador fue modificado, la lógica de UPDATE no funcionaría correctamente.
    IF UPDATE(ID_de_Jugador)
    BEGIN
        RAISERROR('La columna ID_de_Jugador no debe ser modificada en la Tabla_Madre. No se ejecutará la sincronización.', 16, 1);
        RETURN;
    END

    -- 1. SINCRONIZACIÓN DE LA TABLA DIMENSIÓN JUGADOR (ID, Género, Edad, Ubicación)
    
    -- Usamos MERGE para manejar las inserciones y actualizaciones en un solo paso
    MERGE Tabla_De_Dimension_Jugador AS Target
    USING INSERTED AS Source
    ON (Target.ID_de_Jugador = Source.ID_de_Jugador)
    
    -- Cuando hay coincidencia (fila existe, es UPDATE)
    WHEN MATCHED THEN
        UPDATE SET 
            Target.Género = Source.Género,
            Target.Edad = Source.Edad,
            Target.Ubicación = Source.Ubicación
    
    -- Cuando NO hay coincidencia (fila no existe, es INSERT)
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (ID_de_Jugador, Género, Edad, Ubicación)
        VALUES (Source.ID_de_Jugador, Source.Género, Source.Edad, Source.Ubicación);


    -- 2. SINCRONIZACIÓN DE LA TABLA DIMENSIÓN JUEGO (ID, Género_de_Juego, Dificultad_de_Juego)
    
    MERGE Tabla_De_Dimension_Juego AS Target
    USING INSERTED AS Source
    ON (Target.ID_de_Jugador = Source.ID_de_Jugador)
    
    -- Cuando hay coincidencia (fila existe, es UPDATE)
    WHEN MATCHED THEN
        UPDATE SET 
            Target.Género_de_Juego = Source.Género_de_Juego,
            Target.Dificultad_de_Juego = Source.Dificultad_de_Juego
            -- Nota: ID_de_Genero_Juego (FK) no está en la tabla madre, no se actualiza
    
    -- Cuando NO hay coincidencia (fila no existe, es INSERT)
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (ID_de_Jugador, Género_de_Juego, Dificultad_de_Juego)
        VALUES (Source.ID_de_Jugador, Source.Género_de_Juego, Source.Dificultad_de_Juego);


    /* 3. SINCRONIZACIÓN DE LA TABLA DE HECHOS COMPORTAMIENTO
        (Nota: Esta tabla NO tiene PK por lo que no puede usar MERGE para UPDATE)
        Si es un INSERT, insertamos. Si es UPDATE, actualizamos TODAS las columnas excepto ID_de_Jugador. */

    -- Lógica para INSERT (sólo si es una nueva fila en INSERTED que no existía antes)
    IF EXISTS (SELECT 1 FROM INSERTED EXCEPT SELECT 1 FROM DELETED) -- Esto indica un INSERT completo
    BEGIN
        INSERT INTO Tabla_De_Hechos_Comportamiento (
            ID_de_Jugador, Sesiones_por_Semana, Duración_de_Sesión_en_Horas_en_Promedio, 
            Duración_de_Sesión_en_Minutos_en_Promedio, Nivel_de_Jugador, Logros_Desbloqueados, 
            Nivel_de_Enganche, Compra_en_Juego
        )
        SELECT 
            ID_de_Jugador, Sesiones_por_Semana, Duración_de_Sesión_en_Horas_en_Promedio, 
            Duración_de_Sesión_en_Minutos_en_Promedio, Nivel_de_Jugador, Logros_Desbloqueados, 
            Nivel_de_Enganche, Compra_en_Juego
        FROM INSERTED;
    END

    /* Lógica para UPDATE
        Este es el escenario más complejo, ya que la tabla de hechos no tiene PK.
        Sin una clave única, no podemos saber cuál fila específica actualizar.
        Lo más seguro y común en un modelo de hechos es INSERTAR una nueva fila para reflejar el estado actual. */
    IF EXISTS (SELECT 1 FROM INSERTED INTERSECT SELECT 1 FROM DELETED) -- Esto indica un UPDATE
    BEGIN
        -- Usamos UPDATE JOIN para actualizar la tabla de hechos con los nuevos valores de INSERTED
        UPDATE T
        SET 
            T.Sesiones_por_Semana = I.Sesiones_por_Semana,
            T.Duración_de_Sesión_en_Horas_en_Promedio = I.Duración_de_Sesión_en_Horas_en_Promedio,
            T.Duración_de_Sesión_en_Minutos_en_Promedio = I.Duración_de_Sesión_en_Minutos_en_Promedio,
            T.Nivel_de_Jugador = I.Nivel_de_Jugador,
            T.Logros_Desbloqueados = I.Logros_Desbloqueados,
            T.Nivel_de_Enganche = I.Nivel_de_Enganche,
            T.Compra_en_Juego = I.Compra_en_Juego
        FROM 
            Tabla_De_Hechos_Comportamiento AS T
        INNER JOIN 
            INSERTED AS I ON T.ID_de_Jugador = I.ID_de_Jugador;
        -- ADVERTENCIA: Esta actualización afectará potencialmente MÚLTIPLES filas de T si un jugador tiene más de un registro de hechos.
    END

END
GO
---------------------------------------------------- END CODE --------------------------------------------------