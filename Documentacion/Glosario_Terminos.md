# Glosario de Términos

Este glosario reúne definiciones cortas y precisas de los términos y conceptos usados en el proyecto. Está pensado para facilitar la lectura de la documentación técnica y el entendimiento entre equipos (Data Engineering, Análisis y Producto).

## Términos clave

- Tabla_Madre
	- Definición: Tabla fuente con los registros crudos (sin normalizar) que sirven como origen para procesos ETL y construcción de dimensiones y hechos.
	- Uso: fuente única de datos de entrada para transformaciones; idealmente inmutable y versionada por lotes.
  - Ficha: [Tabla_Madre](Tablas/Schema%20%5Bdbo%5D/Tabla_Madre.md)

- Tabla_de_Hechos_Comportamiento
	- Definición: Tabla de hechos que contiene medidas y eventos por jugador/juego (p.ej. duración de sesión, compras, eventos de juego).
	- Uso: esquema estrela: se une a dimensiones (jugador, juego, tiempo) para análisis analíticos y cubos.
  - Ficha: [Tabla_de_Hechos_Comportamiento](Tablas/Schema%20%5Bdbo%5D/Tabla_de_Hechos_Comportamiento.md)

- Tabla_de_Dimension_Jugador
	- Definición: Dimensión que contiene atributos descriptivos del jugador (edad, país, plataforma, segmento, etc.).
	- Uso: enriquecer hechos para filtrar, agrupar y segmentar análisis.
  - Ficha: [Tabla_de_Dimension_Jugador](Tablas/Schema%20%5Bdbo%5D/Tabla_de_Dimension_Jugador.md)

- Tabla_de_Dimension_Juego
	- Definición: Dimensión que contiene metadatos del juego (nombre, género, plataforma, monetización, fecha de lanzamiento).
  - Ficha: [Tabla_de_Dimension_Juego](Tablas/Schema%20%5Bdbo%5D/Tabla_de_Dimension_Juego.md)

- Clasificacion_Genero_Juegos
	- Definición: Catálogo/tabla de dominio con los géneros de juegos canónicos (p.ej. Estrategia, Acción, Deportes).
	- Uso: normalizar valores libres en `Genero_Juego` y evitar inconsistencias lingüísticas.
  - Ficha: [Clasificacion_Genero_Juegos](Tablas/Schema%20%5Bdbo%5D/Clasificacion_Genero_Juegos.md)

- Frecuencia (tabla de frecuencia)
	- Definición: Conteo de observaciones por clase/intervalo para una variable (ej. edades, sesiones por semana, duración de sesión).
	- Términos relacionados: Marca de clase (punto medio), Frecuencia relativa (Frecuencia / Total), Frecuencia acumulada.
  - Fichas de ejemplo: [Edad](Tablas/Schema%20%5BAnalisis_Cuantitativo_Juegos%5D/Tabla_Frecuencia_Edad.md), [SesionesPorSemana](Tablas/Schema%20%5BAnalisis_Cuantitativo_Juegos%5D/Tabla_Frecuencia_SesionesPorSemana.md), [DuracionSesionHoras](Tablas/Schema%20%5BAnalisis_Cuantitativo_Juegos%5D/Tabla_Frecuencia_DuracionSesionHoras.md)

- Marca de Clase
	- Definición: Valor representativo de una clase (usualmente el punto medio entre límite inferior y superior).

- Binning / Intervalo
	- Definición: Proceso de agrupar valores continuos en intervalos (clases) para construir tablas de frecuencia o histogramas.

- Top-coding
	- Definición: Técnica para agrupar o truncar valores extremos (p.ej. todas las duraciones > 8 h al bin `>8h`) para evitar sesgos por outliers y reducir cardinalidad.

- DDL (Data Definition Language)
	- Definición: Sentencias SQL para definir la estructura de la base de datos (CREATE TABLE, ALTER TABLE, DROP TABLE, etc.).

- DML (Data Manipulation Language)
	- Definición: Sentencias SQL para manipular datos (SELECT, INSERT, UPDATE, DELETE).

- ETL
	- Definición: Proceso de extracción, transformación y carga. En este proyecto se usa para limpiar `Tabla_Madre`, normalizar campos, poblar dimensiones y hechos, y calcular tablas estadísticas.

- Staging
	- Definición: Área intermedia (tabla o esquema) usada durante el ETL para cargar datos crudos, aplicar transformaciones y validar antes de moverlos a producción.

- SCD (Slowly Changing Dimension)
	- Definición: Estrategia para manejar cambios en dimensiones. Tipo 1: sobrescribir; Tipo 2: versionar con vigencia (start/end); Tipo 3: almacenar un historial limitado.

- FK / PK
	- FK (Foreign Key): Clave foránea que referencia la PK de otra tabla para mantener integridad referencial.
	- PK (Primary Key): Clave primaria que identifica unívocamente una fila en la tabla.

- Índice (Index)
	- Definición: Estructura que acelera búsquedas y joins en columnas frecuentemente consultadas. Tipos: clustered, nonclustered. Mantener balance entre lectura y costo de mantenimiento.

- Medidas de tendencia central
	- Media: Promedio aritmético.
	- Mediana: Percentil 50 (valor central de la distribución).
	- Moda: Valor con mayor frecuencia.

- Medidas de dispersión
	- Varianza: Promedio de las desviaciones al cuadrado respecto a la media. Distinción entre varianza poblacional (VARP) y muestral (VAR).
	- Desviación estándar: Raíz cuadrada de la varianza (poblacional STDEVP vs muestral STDEV).

- Percentil / PERCENTILE_CONT
	- Definición: Medida que indica el valor bajo el cual se encuentra un porcentaje de observaciones. `PERCENTILE_CONT` es una función analítica para calcular percentiles (mediana incluida) cuando el SGBD la soporta.


- Pivot table (tabla dinámica)
	- Definición: Transformación que reorienta filas a columnas agregadas (usada en análisis y reporting). En el proyecto se usa para crear vistas de resumen por `Genero_Juego`, `Pais`, etc.

- Cohorte
	- Definición: Grupo de usuarios definidos por una característica temporal (p. ej. fecha de alta). Se usan para análisis de retención y comportamiento a lo largo del tiempo.

- Batch / Job
	- Definición: Ejecución programada de procesos (ETL, cálculo de medidas, generación de tablas). Frecuencias típicas: diaria, semanal, mensual.

- Batch_ID
	- Definición: Identificador del lote de ingestión, útil para auditoría, re-procesos y trazabilidad.

- Catalogo / Tabla de dominio
	- Definición: Tabla con valores canónicos para una dimensión (p.ej. `Clasificacion_Genero_Juegos`, `Catalogo_Dificultad`) usada para normalizar y validar datos.

- KPI (Key Performance Indicator)
	- Definición: Métrica clave para el negocio (retención, ARPU, sesiones por usuario). Se calculan a partir de hechos y dimensiones.

- ARPU (Average Revenue Per User)
	- Definición: Ingreso promedio por usuario en un periodo determinado. Utilizado en análisis de monetización.

## Convenciones de nombres y buenas prácticas

- Nombres de columnas: evitar acentos y espacios; preferir `Limite_Inferior`, `Duracion_Sesion_Horas`, `Fecha_Registro`.
- Tablas de staging: prefijar con `stg_` o colocarlas en un esquema `staging`.
- Tablas analíticas: colocar en esquemas separados como `Analisis_Cuantitativo_Juegos` para separar datos transformados de los operacionales.
- Scripts: versionar y mantener en `Scripts/` con convenciones (DDL en `DDL Tablas`, DML en `DML Tablas`, procedimientos en `Procedimientos`).

## Enlaces rápidos (documentos relevantes)
- Estructura general de tablas: `Documentacion/TABLAS.md`  
- Diccionario de datos: `Documentacion/DICCIONARIO_DATOS.md`  
- Vistas y medidas estadísticas: `Documentacion/VISTAS.md`, `Documentacion/Medidas_Tendencia_Central_Juegos.md`, `Documentacion/Medidas_Dispersion_Juegos.md`  

---

