## Política y Guía de Seguridad — Base de Datos y Artefactos

Este documento describe las prácticas recomendadas para asegurar la base de datos y los artefactos relacionados del proyecto. Cubre control de accesos, cifrado, gestión de secretos, auditoría, hardening, cumplimiento y ejemplos prácticos (T-SQL) para implementar políticas mínimas.

### Objetivos
- Proteger la confidencialidad, integridad y disponibilidad (CIA) de los datos.  
- Establecer controles mínimos para acceso, auditoría y gestión de secretos.  
- Asegurar mecanismos repetibles y automatizables que se puedan validar en auditorías.

### Alcance
- Bases de datos (instancias SQL Server usadas por el proyecto), scripts en `Scripts/`, documentacion sensible, servidores de BI/ETL que acceden a los datos.

### Principios generales
- Principio de menor privilegio (least privilege).  
- Separation of duties: separar roles operativos (DBA/Infra) de roles de usuario de negocio.  
- Auditar cambios críticos (creación de logins/usuarios, cambios en roles, restores, backups).  
- No exponer credenciales en código; usar secreto manager (Azure Key Vault, HashiCorp Vault u otro).  

## Recomendaciones concretas

1) Gestión de accesos
- Usar cuentas de servicio administradas para procesos automatizados (no cuentas personales).  
- Evitar logins con privilegios elevados para uso diario.  
- Implementar grupos/roles en la base de datos y asignar permisos sobre schemas en vez de objetos individuales cuando sea viable.

Ejemplo mínimo para crear un login y un usuario contenido y asignar rol con permiso SELECT:

```sql
-- Crear Login (en el servidor) y Usuario en la BD
CREATE LOGIN [app_readonly_login] WITH PASSWORD = '<<PASSWORD-SEGURA-AQUI>>'; -- usar secreto manager en producción
USE [MiBase];
CREATE USER [app_readonly_user] FOR LOGIN [app_readonly_login];

-- Crear rol personalizado y asignar permisos sobre schema
CREATE ROLE db_data_reader_app;
GRANT SELECT ON SCHEMA::dbo TO db_data_reader_app;
ALTER ROLE db_data_reader_app ADD MEMBER [app_readonly_user];
```

Notas: en producción reemplace passwords por referencias a secretos (Key Vault), y prefiera autenticación con AAD/Managed Identity donde sea posible.

2) Principio de menor privilegio y roles
- Definir roles predecibles: `data_reader`, `data_analyst`, `etl_runner`, `db_admin` (este último muy restringido).  
- Evitar utilizar `sysadmin` para tareas regulares; delegar tareas específicas usando roles fijos y permisos escalables.

3) Encriptación y protección de datos
- Transparent Data Encryption (TDE) para cifrar datos en reposo (data files + log). Requiere administrar claves y certificados.
- Encriptación de backups: use opciones de backup con ENCRYPTION o cifrado a nivel de almacenamiento/KMS.
- Para datos sensibles a nivel de columna, evaluar Always Encrypted o Column-Level Encryption.

Ejemplo: activar TDE (pasos simplificados)

```sql
-- Crear Master Key (si no existe)
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<<MASTER-KEY-PASSWORD>>';

-- Crear certificado para TDE
CREATE CERTIFICATE TDECert WITH SUBJECT = 'Certificado TDE MiBase';

-- Crear la protección TDE en la base
USE [MiBase];
CREATE DATABASE ENCRYPTION KEY WITH ALGORITHM = AES_256 ENCRYPTION BY SERVER CERTIFICATE TDECert;
ALTER DATABASE [MiBase] SET ENCRYPTION ON;
```

4) Gestión de secretos y cadenas de conexión
- Guardar credenciales en: Azure Key Vault, AWS Secrets Manager, HashiCorp Vault o gestor corporativo.
- No versionar secretos ni credenciales en el repositorio. Use variables de entorno o referencias directas a Key Vault en despliegues.

5) Enmascaramiento y protección de datos en uso
- Dynamic Data Masking: útil para reducir exposición en entornos no productivos. No sustituye al cifrado.
- Always Encrypted: proteger datos sensibles (p.ej. PII) de forma que la clave no esté disponible al motor DB en texto claro.

6) Row-Level Security (RLS)
- Implementar RLS para escenarios donde diferentes usuarios ven subconjuntos de filas.

7) Auditoría y logging
- Activar SQL Server Audit o Extended Events para registrar eventos críticos: inicios de sesión, cambios DDL (CREATE/ALTER/DROP), backups/restores, cambios en permisos.
- Retener logs de auditoría acorde a requisitos regulatorios.

Ejemplo básico de servidor audit (T-SQL):

```sql
-- Crear un Server Audit y una Audit Specification
CREATE SERVER AUDIT [Audit_MiBase]
TO FILE (FILEPATH = 'C:\\sql_audit\\', MAXSIZE = 100 MB, MAX_ROLLOVER_FILES = 20);
ALTER SERVER AUDIT [Audit_MiBase] WITH (STATE = ON);

-- Auditar acciones a nivel servidor (login failures) o base de datos (DDL)
USE [MiBase];
CREATE DATABASE AUDIT SPECIFICATION [DBAudit_MiBase]
FOR SERVER AUDIT [Audit_MiBase]
	ADD (SCHEMA_OBJECT_CHANGE_GROUP), -- DDL changes
	ADD (DATABASE_ROLE_MEMBER_CHANGE_GROUP)
WITH (STATE = ON);
```

8) Hardening y configuración de instancia
- Mantener servidor y motor parcheados con las actualizaciones de seguridad.  
- Restringir accesos de red: permitir sólo IPs/servicios necesarios (firewall) y usar redes privadas/vnets.  
- Forzar conexiones seguras (TLS) en conexiones cliente-DB.

9) Entornos no productivos
- No usar datos reales en entornos de desarrollo/test sin anonimizar o encriptar.  
- Implementar procedimientos de submuestreo y masking antes de copiar datos a non-prod.

10) Monitoreo y detección de anomalías
- Integrar logs en SIEM (ELK, Splunk, Azure Sentinel) para alertas sobre patrones inusuales: accesos nocturnos, extracciones masivas, cambios de esquema.

11) Recuperación ante incidentes
- Mantener playbook de incident response: pasos de contención, análisis forense (logs), restauración desde backup, rotación de credenciales si hay fuga.

## Procedimientos y Checklists

- Revisión trimestral de permisos: listar miembros de roles con privilegios altos y revisar justificaciones.
- Comprobación diaria: revisar fallos de login y jobs críticos (backup, ETL).

Consultas útiles para auditoría de permisos:

```sql
-- Listar miembros de roles fijos
SELECT rp.name AS role_name, mp.member_principal_id, mp.role_principal_id
FROM sys.database_role_members mp
JOIN sys.database_principals rp ON rp.principal_id = mp.role_principal_id;

-- Usuarios con permisos privilegiados (ejemplo simplificado)
SELECT name, type_desc FROM sys.server_principals WHERE IS_SRVROLEMEMBER('sysadmin', name) = 1;
```

## Operacional: despliegue seguro de credenciales
- No incluir contraseñas en scripts; usar `SqlCmd` con variables o `Invoke-Sqlcmd` con token/managed identity.
- Recomendado: usar identidades administradas en Azure o IAM roles en AWS para que las aplicaciones obtengan tokens sin credenciales embebidas.

## Requisitos de cumplimiento y privacidad
- Registrar requisitos regulatorios aplicables (p.ej. GDPR/LPD local) y adaptar retenciones, anonimización y logging según esos requisitos.

## Referencias y enlaces útiles
- `Configuracion/Respaldo.md` (política de backups) — vincular con procedimientos de restauración.
- Documentación de Azure Key Vault / AWS KMS / HashiCorp Vault.

---

