# Clasificación de Género de Juegos

## Resumen
Tabla de catálogo que mantiene la lista canónica de géneros de juegos. Actúa como tabla de referencia para normalizar el campo `Genero_Juego` en la `Tabla_Madre` y `Tabla_de_Dimension_Juego`, asegurando consistencia en ETL, análisis y reporting.

## Estructura
| Columna | Tipo | Nullable | Default | Descripción |
|---------|------|----------|----------|-------------|
| ID_de_Juego | INT | NO | IDENTITY(1,1) | Identificador único del género |
| Genero | VARCHAR(100) | NO | - | Nombre del género (e.g., "Estrategia", "Deportes") |
| Descripcion | VARCHAR(500) | SI | NULL | Descripción y ejemplos del género |
| Fecha_Creacion | DATETIME | NO | GETDATE() | Timestamp de creación del registro |
| Fuente | VARCHAR(100) | SI | NULL | Origen del dato (manual, sync_catalogo, API) |
| Estado | BIT | NO | 1 | Indica si el género está activo (1) o inactivo (0) |

## Claves
- **Clave Primaria**: `ID_de_Juego`
- **Claves Únicas**: 
  - `UQ_Genero` en columna `Genero`
- **Claves Foráneas referenciadas por**:
  - `[dbo].[Tabla_de_Dimension_Juego].ID_Genero` → `ID_de_Juego`
  - `[dbo].[Tabla_Madre].ID_Genero` → `ID_de_Juego`

## Índices
1. **PK_Clasificacion_Genero_Juegos** (clustered)
   - Columnas: (`ID_de_Juego`)
   - Tipo: CLUSTERED
   - Unicidad: UNIQUE

2. **UQ_Genero_Nombre**
   - Columnas: (`Genero`)
   - Tipo: NONCLUSTERED
   - Unicidad: UNIQUE
   - Utilidad: Búsquedas por nombre de género

3. **IX_Genero_Estado**
   - Columnas: (`Estado`) INCLUDE (`Genero`, `ID_de_Juego`)
   - Tipo: NONCLUSTERED
   - Utilidad: Filtrado de géneros activos/inactivos

## Objetos relacionados

### Tablas que la referencian
- `[dbo].[Tabla_de_Dimension_Juego]` - Dimensión principal de juegos
- `[dbo].[Tabla_Madre]` - Tabla principal con datos de juegos
- `[dbo].[Relacion_Dimension_Juegos]` - Tabla de relaciones entre juegos

### Vistas
- `[dbo].[VW_Generos_Activos]` - Vista de géneros activos
- `[dbo].[VW_Catalogo_Juegos]` - Vista del catálogo completo de juegos

### Procedimientos almacenados
- `[dbo].[sp_AgregarGenero]` - SP para insertar nuevo género
- `[dbo].[sp_ActualizarGenero]` - SP para actualizar género existente
- `[dbo].[sp_DesactivarGenero]` - SP para marcar género como inactivo

## Seguridad y clasificación

### Clasificación de datos
- **Nivel de sensibilidad**: BAJO
- **Tipo de datos**: Datos de referencia/maestros
- **Retención**: Permanente (tabla de catálogo)

### Permisos requeridos
- SELECT: roles `data_analyst`, `bi_reader`, `etl_reader`
- INSERT/UPDATE: rol `data_steward`, `etl_writer`
- DELETE: DENIED (usar campo Estado para inactivar)

### Notas de seguridad
- No contiene datos sensibles
- Cambios deben ser auditados (trigger de auditoría)
- Control de cambios vía proceso formal de gestión de maestros
- Solo usuarios autorizados pueden añadir/modificar géneros


## Valores iniciales recomendados
Se recomiendan los siguientes géneros como punto de partida; ajustar según el catálogo del producto:

1. Estrategia
2. Deportes
3. Acción
4. Juego de Roles
5. Simulación
6. Puzzle
7. Aventura
8. Carreras
9. Indie
10. Casual

## Integridad y uso en ETL
- FK sugerida: `Tabla_de_Dimension_Juego.ID_Genero` -> `Clasificacion_Genero_Juegos.ID_de_Juego`.
- Durante la ingesta (ETL): mapear variantes libres de `Genero_Juego` a `ID_de_Juego`. Si no existe correspondencia, insertar en staging para revisión o asignar al ID reservado `UNKNOWN`.
- Política recomendada: no permitir borrados en el catálogo; en su lugar, marcar `Estado` (activo/inactivo) si se requiere desactivación.

## DDL y notas de implementación

```sql
CREATE TABLE [dbo].[Clasificacion_Genero_Juegos] (
    ID_de_Juego INT IDENTITY(1,1) NOT NULL,
    Genero VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(500) NULL,
    Fecha_Creacion DATETIME NOT NULL DEFAULT GETDATE(),
    Fuente VARCHAR(100) NULL,
    Estado BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_Clasificacion_Genero_Juegos PRIMARY KEY CLUSTERED (ID_de_Juego),
    CONSTRAINT UQ_Genero UNIQUE NONCLUSTERED (Genero),
    CONSTRAINT CHK_Genero_NoVacio CHECK (LEN(TRIM(Genero)) > 0)
);

-- Índices adicionales
CREATE NONCLUSTERED INDEX IX_Genero_Estado ON [dbo].[Clasificacion_Genero_Juegos](Estado)
INCLUDE (Genero, ID_de_Juego);

-- Datos iniciales recomendados
INSERT INTO [dbo].[Clasificacion_Genero_Juegos] (Genero, Descripcion, Fuente) VALUES
('Estrategia', 'Juegos que requieren planificación y pensamiento táctico', 'inicial'),
('Deportes', 'Simulaciones y competencias deportivas', 'inicial'),
('Acción', 'Juegos basados en habilidad y reflejos', 'inicial'),
('Juego de Roles', 'RPGs y juegos de desarrollo de personajes', 'inicial'),
('Simulación', 'Simuladores realistas de actividades o sistemas', 'inicial'),
('Puzzle', 'Juegos de lógica y resolución de problemas', 'inicial'),
('Aventura', 'Juegos narrativos con exploración', 'inicial'),
('Carreras', 'Competencias de velocidad y conducción', 'inicial'),
('Indie', 'Juegos desarrollados por estudios independientes', 'inicial'),
('Casual', 'Juegos simples para sesiones cortas', 'inicial');
```

### Notas de implementación
- Incluye restricción de unicidad en `Genero`
- Campo `Estado` para soft-delete en lugar de eliminación física
- Índices optimizados para consultas comunes
- Datos iniciales con descripciones completas

## Buenas prácticas
- Mantener el catálogo en control de versiones y documentar cambios (añadir nuevo género, renombrar, desactivar).
- Usar este catálogo como fuente de verdad en los pipelines ETL para evitar inconsistencias lingüísticas.
- Proveer un proceso de revisión para nuevos géneros (propiedad, clasificación, ejemplos de pertenencia).

## Ejemplos de mapeo en ETL

```sql
-- Ejemplo: mapear texto libre a ID de catálogo
SELECT g.ID_de_Juego
FROM dbo.Clasificacion_Genero_Juegos g
WHERE LOWER(g.Genero) = LOWER(@GeneroEntrada);

-- Si no existe, enviar a tabla_staging para revisión manual
```

## Control de calidad y monitoreo
- Registrar casos no mapeados y frecuencias para priorizar ampliaciones del catálogo.
- Implementar tests de integración en el pipeline ETL que aseguren que todos los `Genero_Juego` en `Tabla_Madre` tienen correspondencia o están marcados para revisión.

---

