# Política y Procedimientos de Respaldo

Este documento describe la política recomendada de respaldo (backup) para la base de datos y los artefactos del proyecto. Incluye estrategias, ejemplos de scripts (T-SQL y PowerShell), comprobaciones de integridad y un checklist operativo para ejecutar y validar respaldos.

## Objetivo
- Garantizar la disponibilidad y recuperación de los datos ante fallos, corrupción, borrados accidentales o desastres.  
- Definir procedimientos reproducibles y automatizables para respaldos regulares, almacenamiento seguro y pruebas periódicas de restauración.

## Alcance
- Bases de datos SQL Server usadas por el proyecto (`dbo` y `Analisis_Cuantitativo_Juegos`), scripts del repositorio, archivos de configuración críticos y artefactos de ETL.

## Principios
- 3-2-1: mantener al menos 3 copias de los datos, en 2 tipos de almacenamiento distintos, y 1 copia fuera de sitio (off-site).  
- Automatizar los respaldos y las comprobaciones.  
- Encriptar y controlar acceso a los archivos de respaldo.  
- Documentar y versionar los scripts de respaldo/restore en `Scripts/Procedimientos`.

## Estrategia de respaldo 

1) Backups de base de datos (SQL Server)
- Full backup: semanal (por ejemplo: domingo 02:00). Contiene todos los datos de la base.
- Differential backup: diario (excepto el día de full) a la 02:00 (captura los cambios desde el último full).
- Transaction log backup: cada 15 minutos (o según RPO requerido) para permitir recovery point-in-time.

2) Backups de archivos y scripts del repositorio
- Código y scripts: respaldos diarios de la carpeta `Scripts/` y `Documentacion/` o usar control de versiones (git) con backup del repositorio. Hacer snapshot nocturno y copia a almacenamiento externo.

3) Backups de configuraciones y secretos
- No almacenar secretos sin cifrar. Respaldar archivos de configuración no sensibles (plantillas) y mantener secretos en secreto manager (KeyVault, Vault) — si es necesario respaldarlos, hacerlo cifrados y con acceso restringido.

## Retención y almacenamiento
- Periodo de retención sugerido:
	- Full: conservar 8 semanas (56 días) mínimo.
	- Differential: conservar 4 semanas.
	- Log backups: conservar 7 días (útil para PITR), luego rotar a archivo comprimido o copiar fuera de sitio.
- Almacenamiento:
	- Local (servidor backup): copia inicial.
	- NAS/SMB o Fileshare de la organización.
	- Off-site: Azure Blob / AWS S3 / otro proveedor cloud (usar lifecycle rules para archivado a cold storage).

## Seguridad y cifrado
- Usar backup encryption (TDE + encriptación de backups) o cifrar los archivos de backup con claves gestionadas (Azure Key Vault, AWS KMS) antes de enviarlos off-site.
- Restringir permisos al directorio de backups y a las cuentas que pueden ejecutar restores.

## Monitoreo y alertas
- Monitorizar el job de backup (SQL Agent jobs o sistema de scheduling) y configurar alertas en caso de fallo.
- Comprobar el historial en `msdb.dbo.backupset` con queryes periódicas y enviar alertas si no hay backup exitoso en ventana esperada.

Ejemplo de comprobación de último backup (T-SQL):

```sql
SELECT
	database_name,
	MAX(backup_finish_date) AS last_backup
FROM msdb.dbo.backupset
GROUP BY database_name;
```

## Verificación de integridad de backups
- Ejecutar `RESTORE VERIFYONLY` sobre los archivos .bak para comprobar consistencia.

```sql
RESTORE VERIFYONLY FROM DISK = 'C:\\backups\\MiBD_FULL_20251025.bak';
```

## Procedimientos (scripts) — SQL Server

1) Backup full (T-SQL)

```sql
BACKUP DATABASE [MiBase]
TO DISK = N'\\\\backup-server\\backups\\MiBase_FULL_2025_10_25.bak'
WITH FORMAT, COMPRESSION, INIT, NAME = N'MiBase-Full-Backup-2025_10_25';
```

2) Backup differential

```sql
BACKUP DATABASE [MiBase]
TO DISK = N'\\\\backup-server\\backups\\MiBase_DIFF_2025_10_26.bak'
WITH DIFFERENTIAL, COMPRESSION, INIT, NAME = N'MiBase-Diff-2025_10_26';
```

3) Backup de transaction log (para bases en FULL recovery)

```sql
BACKUP LOG [MiBase]
TO DISK = N'\\\\backup-server\\backups\\MiBase_LOG_2025_10_26_1200.trn'
WITH NOFORMAT, INIT, COMPRESSION, NAME = N'MiBase-Log-2025_10_26-1200';
```

4) Restore básico (full + diff + logs)

```sql
-- Restaurar full
RESTORE DATABASE [MiBase] FROM DISK = N'\\\\backup-server\\backups\\MiBase_FULL_2025_10_25.bak' WITH NORECOVERY;

-- Restaurar diferencial (si aplica)
RESTORE DATABASE [MiBase] FROM DISK = N'\\\\backup-server\\backups\\MiBase_DIFF_2025_10_26.bak' WITH NORECOVERY;

-- Restaurar logs hasta un punto (ejemplo: hasta 2025-10-26 14:30)
RESTORE LOG [MiBase] FROM DISK = N'\\\\backup-server\\backups\\MiBase_LOG_2025_10_26_1200.trn' WITH NORECOVERY;
RESTORE LOG [MiBase] FROM DISK = N'\\\\backup-server\\backups\\MiBase_LOG_2025_10_26_1430.trn' WITH RECOVERY;
```

5) Verificación de restore (comprobaciones básicas)

```sql
-- Comprobar integridad de la base restaurada
DBCC CHECKDB ([MiBase]) WITH NO_INFOMSGS, ALL_ERRORMSGS;
```

## Procedimientos (scripts) — PowerShell (ejemplo de copia off-site a Azure Blob)

```powershell
# Recomendado: usar módulos Az.Storage y SqlServer
Import-Module Az.Storage
Import-Module SqlServer

# Ejemplo: copiar archivo .bak a Azure Blob
$context = (Get-AzStorageAccount -ResourceGroupName 'rg' -Name 'storageaccount').Context
Set-AzStorageBlobContent -File 'C:\\backups\\MiBase_FULL_2025_10_25.bak' -Container 'backups' -Blob 'MiBase_FULL_2025_10_25.bak' -Context $context
```

## Automatización
- Crear SQL Agent jobs para:
	- Full backup semanal
	- Differential backup diario
	- Transaction log backup cada 15 minutos
- Alternativa fuera de SQL Server: usar scripts PowerShell o cron jobs en un servidor de backup que ejecuten `sqlcmd` o `Invoke-Sqlcmd`.

## Comprobaciones automáticas (monitoreo)
- Query periódica en `msdb` para comprobar backups recientes (en las 24h / periodo esperado).
- Ejecutar `RESTORE VERIFYONLY` automáticamente y notificar fallos.

## Pruebas de recuperación (DR drills)
- Programar restauraciones completas en entorno de staging cada 4-8 semanas para validar procesos y tiempos de RTO.
- Documentar tiempos medidos y ajustar RTO/RPO en el SLA.

## Manejo de errores y comunicaciones
- Si falla un job de backup: generar alerta a responsables (email/Slack) y abrir incidencia en el sistema de tickets.
- Mantener logs de backup y restore centralizados para auditoría.

## Rotación y limpieza de backups
- Implementar tareas que eliminen archivos fuera del periodo de retención (p.ej. archivos .bak > 56 días) y que muevan a cold storage si procede.

Ejemplo de script T-SQL para listar backups antiguos (para borrado manual/automatizado):

```sql
SELECT
	backup_set_id,
	database_name,
	backup_start_date,
	physical_device_name
FROM msdb.dbo.backupmediafamily mf
JOIN msdb.dbo.backupset bs ON mf.media_set_id = bs.media_set_id
WHERE bs.backup_start_date < DATEADD(day, -56, GETDATE());
```

## Checklist operativo (pre-ejecución y post-ejecución)

Pre-ejecución:
- Revisar espacio disponible en disco del destino de backups.
- Confirmar estado de jobs en SQL Agent.

Post-ejecución:
- Verificar que los archivos .bak/.trn fueron generados y transferidos off-site.
- Ejecutar `RESTORE VERIFYONLY` sobre al menos una copia aleatoria.
- Comprobar entrada en `msdb.dbo.backupset` y enviar reporte diario.

## Roles y responsabilidades
- Data Engineering: responsable de configurar jobs y mantener scripts de respaldo.
- DBA/Infra: responsable de almacenamiento, rotación y seguridad (encriptación, permisos).
- Equipo de Producto: validar RPO/RTO y autorizar cambios en la política.

## Documentación y control de cambios
- Mantener este documento versionado en el repo y registrar cambios en el changelog (fecha, autor, motivo).

---

