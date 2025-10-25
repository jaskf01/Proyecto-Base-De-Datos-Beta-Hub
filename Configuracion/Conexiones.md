# Conexiones

Este documento centraliza las instrucciones y ejemplos para conectar a las fuentes de datos usadas en el proyecto (principalmente SQL Server). Contiene ejemplos prácticos para desarrolladores, recomendaciones de seguridad, formatos de conexión (ODBC, SQLAlchemy), y plantillas para usar en scripts y en CI/CD.

---

## 1) Resumen y propósito
- Propósito: documentar cómo configurar y usar las conexiones a bases de datos desde entornos de desarrollo, scripts ETL y aplicaciones (por ejemplo `pivot_table_app`).
- Alcance: conexiones a SQL Server (local, dev, staging, prod), ejemplos con pyodbc/pymssql/SQLAlchemy, ODBC drivers en Windows, uso de variables de entorno y secret managers.

## 2) Principios de seguridad
- Nunca hardcodear credenciales en el código ni en el repositorio.
- Usar variables de entorno o gestores de secretos (Azure Key Vault, HashiCorp Vault, AWS Secrets Manager).
- Conceder los mínimos privilegios necesarios (principio de least privilege). Crear roles específicos para lectura-only o lectura-agregación según el job.
- Rotación periódica de credenciales y registro de acceso (auditoría).

## 3) Variables de entorno recomendadas
- NOMBRE: Descripción
	- DB_HOST: servidor o IP del servidor SQL
	- DB_PORT: puerto (por defecto 1433)
	- DB_NAME: nombre de la base de datos
	- DB_USER: usuario de conexión
	- DB_PASSWORD: contraseña (no en repo)
	- DB_DRIVER: driver ODBC (ej. "ODBC Driver 17 for SQL Server")
	- DB_TRUSTED: true/false para usar autenticación integrada

Ejemplo (.env local, NUNCA subir al repo):

```
DB_HOST=db-server.mycompany.local
DB_PORT=1433
DB_NAME=MiBase
DB_USER=svc_analytics
DB_PASSWORD=SuperSecreta123!
DB_DRIVER="ODBC Driver 17 for SQL Server"
DB_TRUSTED=false
```

## 4) Formatos de conexión

4.1 ODBC / pyodbc (Windows/WSL)

```python
import os
import pyodbc

conn_str = (
		f"DRIVER={{{os.environ['DB_DRIVER']}}};"
		f"SERVER={os.environ['DB_HOST']},{os.environ.get('DB_PORT','1433')};"
		f"DATABASE={os.environ['DB_NAME']};"
		f"UID={os.environ['DB_USER']};PWD={os.environ['DB_PASSWORD']}"
)
conn = pyodbc.connect(conn_str)

# ejemplo para ejecutar una query
cursor = conn.cursor()
cursor.execute('SELECT TOP 1 * FROM dbo.Tabla_Madre')
print(cursor.fetchone())
```

4.2 SQLAlchemy (recomendado para pandas)

```python
from sqlalchemy import create_engine
import urllib

params = urllib.parse.quote_plus(
		f"DRIVER={{{os.environ['DB_DRIVER']}}};SERVER={os.environ['DB_HOST']},{os.environ.get('DB_PORT','1433')};DATABASE={os.environ['DB_NAME']};UID={os.environ['DB_USER']};PWD={os.environ['DB_PASSWORD']}"
)
engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

df = pd.read_sql('SELECT TOP 10 * FROM dbo.Tabla_Madre', engine)
```

4.3 Connection string para Power BI / Excel (ODBC)

Usar el mismo driver ODBC y crear DSN si es necesario. Ejemplo de cadena:

```
Driver={ODBC Driver 17 for SQL Server};Server=tcp:db-server.mycompany.local,1433;Database=MiBase;Uid=svc_analytics;Pwd=***;Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;
```

## 5) Uso de Azure Key Vault (ejemplo)
- Recomendación: almacenar `DB_USER`/`DB_PASSWORD` en Key Vault y recuperar en runtime. En Python usar `azure-identity` y `azure-keyvault-secrets`.

Snippet (ejemplo):

```python
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

kv_uri = "https://<tu-keyvault>.vault.azure.net"
credential = DefaultAzureCredential()
client = SecretClient(vault_url=kv_uri, credential=credential)
secret = client.get_secret("db-password")
password = secret.value
```

## 6) Permisos y roles recomendados
- Role `read_analytics`: permisos SELECT en vistas y tablas analíticas.  
- Role `etl_loader`: permisos INSERT/UPDATE/DELETE solo en esquemas de staging y procedimientos de carga.
- Role `dba_admin`: reservado para administración (no recomendado para servicios automatizados).

## 7) Pruebas de conexión y diagnóstico
- Herramientas útiles:
	- `sqlcmd` (MS SQL client) para conectar y ejecutar queries desde línea de comandos.
	- `odbcinst -j` y `odbcinst -q -d` para listar drivers en Linux/WSL.
	- `pyodbc` prueba en Python como en el apartado 4.1.

Ejemplo con `sqlcmd`:

```bash
sqlcmd -S db-server.mycompany.local,1433 -U svc_analytics -P 'SuperSecreta123!' -d MiBase -Q "SELECT TOP 1 * FROM dbo.Tabla_Madre"
```

## 8) Plantilla de perfiles de conexión (YAML)
Guardar en `config/connections.yaml` (archivo seguro y fuera del control de versiones o encriptado):

```yaml
default:
	driver: "ODBC Driver 17 for SQL Server"
	host: "db-server.mycompany.local"
	port: 1433
	database: "MiBase"
	user: "svc_analytics"
	password_secret_name: "kv-db-password" # recuperarlo desde Key Vault

staging:
	host: "db-staging.mycompany.local"
	...
```

## 9) Ejemplo de integración con `pivot_table_app` (cómo referenciar conexiones)
- `pivot_table_app` puede leer `config/connections.yaml` y recuperar secret names de Key Vault. En el ejemplo de `pivot_table_app.md` la sección `db` puede mapearse a una entrada del YAML.

## 10) Consideraciones para entornos Windows
- Instalar ODBC Driver 17/18 para SQL Server: descargar desde Microsoft e instalar el MSI. Reiniciar si es necesario.
- En WSL, instalar unixODBC y driver msodbcsql17, configurar DSN en `/etc/odbc.ini` y `/etc/odbcinst.ini`.

## 11) Auditoría y registro
- Registrar intentos de conexión fallidos y éxitos en la auditoría central (por ejemplo, logs en Azure Monitor o ELK).  
- Mantener registros de cuándo se rotan secretos/credenciales.

## 12) Rotación y expiración de secretos
- Política: rotar contraseñas de servicio cada 90 días (u otra política corporativa).  
- Automatizar la rotación cuando sea posible y probar jobs después de rotación.

## 13) Troubleshooting común
- Error de login: comprobar credenciales, firewall y que la cuenta no esté bloqueada.
- Driver no encontrado: instalar ODBC driver correcto y verificar `odbcinst -j`.
- Timeouts: aumentar `Connection Timeout` o optimizar query (agregar filtros, usar índices).

## 14) Checklist para despliegue en producción
- Revisar que no hay credenciales en el repo.
- Probar conexión desde el entorno donde correrá el job (staging/prod).
- Configurar alertas si el job de conexión/report falla (on-call responsable).

---
