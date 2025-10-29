# Triggers y Automatización

## Trigger: TRG_SincronizarHijasDesdeMadre
Este trigger mantiene sincronizadas las tablas dimensionales y de hechos cuando se realizan cambios en la tabla principal `[dbo].[Tabla_Madre]`.

## Configuración
- **Tipo de Trigger**: AFTER (DESPUÉS de INSERT o UPDATE)
- **Tabla de origen**: `[dbo].[Tabla_Madre]`
- **Eventos que lo activan**: `INSERT`, `UPDATE`

## Tablas Virtuales
- `INSERTED`: Contiene los nuevos valores insertados o actualizados.
- `DELETED`: Disponible en operaciones `UPDATE`, contiene los valores anteriores.

## Tablas Afectadas
1. `[dbo].[Tabla_De_Dimension_Jugador]`
2. `[dbo].[Tabla_De_Dimension_Juego]`
3. `[dbo].[Tabla_De_Hechos_Comportamiento]`

## Lógica Implementada
1. **Verificación de clave primaria**: `ID_de_Jugador`
2. **Sincronización de datos del jugador**:
   - `Género`
   - `Edad`
   - `Ubicación`
3. **Sincronización de datos del juego**:
   - `Género_de_Juego`
   - `Dificultad_de_Juego`
4. **Sincronización de datos de comportamiento**:
   - `Sesiones_por_Semana`
   - `Duración_de_Sesión`
   - `Nivel_de_Jugador`
   - `Logros_Desbloqueados`
   - `Nivel_de_Enganche`
   - `Compra_en_Juego`
5. **Operaciones de sincronización**:
   - Uso de `MERGE` para realizar `INSERT` o `UPDATE` en tablas dimensionales.
   - Uso de `INSERT` y `UPDATE` en tabla de hechos según existencia previa del registro.
6. **Control de integridad**:
   - Manejo de transacciones para asegurar consistencia de datos.
   - Prevención de modificación del `ID_de_Jugador`.

## Impacto y Consideraciones
- Asegura consistencia entre tablas madre e hijas.
- Evita duplicidad y desactualización de datos.
- Puede impactar el rendimiento si se ejecuta sobre grandes volúmenes de datos.
- Requiere que las tablas hijas estén correctamente indexadas para eficiencia.

## Seguridad
- No permite la modificación del identificador principal (`ID_de_Jugador`).
- Requiere permisos adecuados para ejecutar `MERGE`, `INSERT`, `UPDATE`.
- Se recomienda auditar su ejecución en entornos productivos.

## Ejemplo de Activación
```sql
-- El trigger se activa automáticamente con:
INSERT INTO [dbo].[Tabla_Madre]
VALUES (...);

-- O con:
UPDATE [dbo].[Tabla_Madre]
SET columna = valor
WHERE condicion;
```