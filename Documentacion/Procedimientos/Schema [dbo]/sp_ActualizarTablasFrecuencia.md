# Procedimiento Almacenado: sp_ActualizarTablasFrecuencia
Este procedimiento actualiza las tablas de frecuencia para variables de análisis como Edad, Sesiones por Semana y Duración de Sesión en Horas.

## Parámetros
- `@FilasAfectadas INT OUTPUT`: Devuelve el número total de filas actualizadas.
- `@TablaTipo VARCHAR(50)`: Determina qué tabla se actualizará. Valores válidos:
  - `'Edad'`
  - `'SesionesPorSemana'`
  - `'DuracionSesionHoras'`

## Tablas Involucradas
### Tablas de origen
- `[dbo].[Tabla_De_Dimension_Jugador]` → Para análisis de edad.
- `[dbo].[Tabla_De_Hechos_Comportamiento]` → Para sesiones por semana y duración de sesión.

### Tablas de destino
- `[Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_Edad]`
- `[Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_SesionesPorSemana]`
- `[Analisis_Cuantitativo_Juegos].[Tabla_Frecuencia_DuracionSesionHoras]`

## Validaciones
- Verificación de valor válido en `@TablaTipo`. Si no coincide con los valores esperados, se lanza un error con `RAISERROR`.
- Uso de `ISNULL` para manejar posibles valores nulos en la frecuencia acumulada.
- Cálculos con `CAST` para evitar divisiones enteras y asegurar precisión decimal.

## Rendimiento
- El total de registros se calcula una sola vez por ejecución para mejorar eficiencia.
- Uso de bucles `WHILE` para recorrer intervalos de forma controlada.
- Actualización directa por intervalo con `UPDATE`, evitando operaciones innecesarias.

## Dependencias
- Requiere que las tablas de origen y destino estén correctamente creadas y pobladas.
- Depende de que los intervalos ya estén definidos en las tablas de frecuencia.
- Las columnas utilizadas deben existir y tener datos válidos.

## Seguridad
- No manipula datos sensibles ni realiza escrituras fuera de las tablas de frecuencia.
- No incluye control de acceso interno; se recomienda restringir su ejecución mediante roles o permisos en la base de datos.

## Casos de Uso
- Actualización periódica de estadísticas de comportamiento de jugadores.
- Preparación de datos para análisis cuantitativo y visualización.
- Automatización de cálculos estadísticos en dashboards o informes.
- Validación de distribución de datos en intervalos definidos.

## Ejemplo de Uso
```sql
DECLARE @RegistrosActualizados INT;
EXEC sp_ActualizarTablasFrecuencia
    @FilasAfectadas = @RegistrosActualizados OUTPUT,
    @TablaTipo = 'Edad';

SELECT 
    'Procedimiento Finalizado' AS Estado,
    @RegistrosActualizados AS Total_De_Filas_Actualizadas;
```