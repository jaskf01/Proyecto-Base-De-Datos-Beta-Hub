# Triggers y Automatización

## TRG_SincronizarHijasDesdeMadre
Este trigger mantiene sincronizadas las tablas dimensionales y de hechos cuando se realizan cambios en la Tabla_Madre.

### Activación
- Se dispara DESPUÉS de INSERT o UPDATE en [dbo].[Tabla_Madre]

### Tablas Afectadas
1. Tabla_De_Dimension_Jugador
2. Tabla_De_Dimension_Juego
3. Tabla_De_Hechos_Comportamiento

### Operaciones Realizadas
1. Verificación de ID_de_Jugador (clave)
2. Sincronización de datos del jugador
   - Género
   - Edad
   - Ubicación
3. Sincronización de datos del juego
   - Género_de_Juego
   - Dificultad_de_Juego
4. Sincronización de datos de comportamiento
   - Sesiones_por_Semana
   - Duración_de_Sesión
   - Nivel_de_Jugador
   - Logros_Desbloqueados
   - Nivel_de_Enganche
   - Compra_en_Juego

### Consideraciones Importantes
- El trigger evita la modificación del ID_de_Jugador
- Usa MERGE para manejar INSERT y UPDATE en las tablas dimensionales
- Para la tabla de hechos, realiza INSERT para nuevos registros y UPDATE para existentes
- Maneja transacciones para asegurar la integridad de los datos

### Ejemplo de Activación
```sql
-- El trigger se activa automáticamente con:
INSERT INTO [dbo].[Tabla_Madre]
VALUES (...);

-- O con:
UPDATE [dbo].[Tabla_Madre]
SET columna = valor
WHERE condicion;
```