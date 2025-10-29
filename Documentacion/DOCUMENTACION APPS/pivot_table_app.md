# Pivot Table App

Resumen
- Aplicación ligera para generar tablas dinámicas (pivot tables) a partir de las tablas del proyecto (principalmente `dbo.Tabla_Madre` y `dbo.Tabla_de_Hechos_Comportamiento`).
- Soporta ejecución por lotes (batch) y modo interactivo (script/CLI). Produce salidas en CSV/Parquet o escribe resultados en la base de datos.

Propósito y casos de uso
- Análisis ad-hoc y generación automática de reportes pivotados por dimensiones (por ejemplo: sesiones por semana por género de juego). 
- Proveer datasets pivotados para dashboards y para exportación a BI (Excel/Tableau/Power BI).

Requisitos
- Python 3.8+ (recomendado 3.9+)
- Paquetes principales: pandas, sqlalchemy, pyodbc (o pymssql), pyyaml
- Driver ODBC para SQL Server (ej. "ODBC Driver 17 for SQL Server")

Instalación rápida

1) Crear y activar entorno virtual

```bash
python -m venv .venv
source .venv/Scripts/activate   # bash.exe en Windows
```

2) Instalar dependencias

```bash
pip install pandas sqlalchemy pyodbc pyyaml
```

Configuración (ejemplo concreto)
- Se recomienda poner la conexión en variables de entorno o en un archivo `config/pivot_config.yaml` (no subir credenciales al repo).

Ejemplo `config/pivot_config.yaml` (adaptado a `dbo.Tabla_Madre`):

```yaml
db:
	driver: "ODBC Driver 17 for SQL Server"
	server: "<SERVIDOR>"
	database: "<BASE_DATOS>"
	user: "<USUARIO>"
	password: "<PASSWORD>"

pivot:
	source_query: |
		SELECT ID_de_Jugador, Genero_Juego, Sesiones_por_Semana, Duracion_Sesion_Horas, Fecha_Registro
		FROM dbo.Tabla_Madre
		WHERE Fecha_Registro >= :fecha_inicio AND Fecha_Registro < :fecha_fin
	index: ['ID_de_Jugador']
	columns: ['Genero_Juego']
	values:
		Sesiones_por_Semana: 'sum'
	fill_value: 0

output:
	format: 'csv'   # csv | parquet | db
	path: './outputs/pivot_{date}.csv'

options:
	mode: 'batch'   # batch | interactive
```

Uso (CLI)

```bash
# ejecución batch con config y rango
python Scripts/SCRIPTS\ APPS/pivot_table_app.py --config config/pivot_config.yaml --fecha_inicio 2025-01-01 --fecha_fin 2025-01-31

# parámetro para salida parquet
python Scripts/SCRIPTS\ APPS/pivot_table_app.py --config config/pivot_config.yaml --output.format parquet
```

Ejemplo de código (extract + pivot con pandas)

```python
import pandas as pd
from sqlalchemy import create_engine
import yaml

cfg = yaml.safe_load(open('config/pivot_config.yaml'))
conn_str = (
		f"mssql+pyodbc://{cfg['db']['user']}:{cfg['db']['password']}@{cfg['db']['server']}/{cfg['db']['database']}"
		f"?driver={cfg['db']['driver'].replace(' ', '+')}"
)
engine = create_engine(conn_str)

query = cfg['pivot']['source_query']
params = {'fecha_inicio': '2025-01-01', 'fecha_fin': '2025-01-31'}
df = pd.read_sql(query, engine, params=params)

pivot = pd.pivot_table(
		df,
		index=cfg['pivot']['index'],
		columns=cfg['pivot']['columns'],
		values=list(cfg['pivot']['values'].keys()),
		aggfunc=cfg['pivot']['values'],
		fill_value=cfg['pivot'].get('fill_value', 0)
)

# export
pivot.to_csv(cfg['output']['path'].format(date='2025-01-31'))
```

Configuraciones de ejemplo concretas (use-cases)
- Pivot por `Genero_Juego` y `Sesiones_por_Semana` (sum): agrupar sesiones por género para un periodo.
- Pivot por `Pais` y `Plataforma` si enriqueces `Tabla_de_Dimension_Jugador` con `Pais` y `Plataforma`.

Buenas prácticas y performance
- Hacer agregaciones en la base cuando la tabla fuente es muy grande: ejecutar un SELECT con GROUP BY y luego pivotear solo el resultado reducido en memoria.
- Para pivots grandes (muchas columnas únicas) preferir escribir resultados en base o en archivo Parquet y no mantener todo en memoria.
- Limitar el rango temporal en la query para evitar lecturas completas si no es necesario.

Automatización (cron/Task Scheduler/Airflow)
- Ejemplo crontab para ejecución diaria a las 2:00 AM (ajustar rutas al entorno virtual):

```cron
0 2 * * * /c/Users/HOGAR/Desktop/DataAnalytics/Proyecto-Base-De-Datos-Beta-Hub-1/.venv/Scripts/python \
	/c/Users/HOGAR/Desktop/DataAnalytics/Proyecto-Base-De-Datos-Beta-Hub-1/Scripts/SCRIPTS\ APPS/pivot_table_app.py --config /c/Users/HOGAR/Desktop/DataAnalytics/Proyecto-Base-De-Datos-Beta-Hub-1/config/pivot_config.yaml
```

Interfaz (opcional)
- Si quieres una UI rápida, usar Streamlit o Dash. Ejemplo de comando para levantar UI con Streamlit:

```bash
streamlit run Scripts/SCRIPTS\ APPS/pivot_table_app.py -- --config config/pivot_config.yaml
```

Validaciones y tests
- Test mínimo: la función que produce el pivot debe devolver filas > 0 y columnas esperadas.
- Comprobar consistencia: SUM(original_values) == SUM(values_in_pivot) (si la agregación es sum).

Seguridad y gobernanza
- No escribir PII en salidas sin encriptación.
- Guardar credenciales en secretos (KeyVault / .env excluido del repo). Usar roles de base de datos con mínimo privilegio.

Despliegue (Docker) — ejemplo mínimo

```dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
CMD ["python", "Scripts/SCRIPTS APPS/pivot_table_app.py", "--config", "config/pivot_config.yaml"]
```

Checklist antes de ejecutar en producción
- Revisar query de origen y filtros de fechas.
- Probar en staging con datos limitados.
- Monitorizar tiempo de ejecución y uso de memoria.

Notas finales
- Este documento propone una implementación práctica y segura. Puedo generar el `pivot_table_app.py` de ejemplo dentro de `Scripts/SCRIPTS APPS/` con la lógica mostrada arriba (¿quieres que lo cree?), y un `requirements.txt` minimal.


