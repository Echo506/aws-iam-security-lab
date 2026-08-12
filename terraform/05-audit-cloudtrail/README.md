# Modulo 05 - Auditoria Centralizada con CloudTrail y CloudWatch

## Objetivo

Registrar toda la actividad de la cuenta de AWS (quien hizo que, cuando y desde donde) y generar alertas automaticas ante cambios sensibles en IAM. Sin esto, ninguno de los controles de los modulos anteriores es verificable ni auditable.

## Conceptos clave

- **CloudTrail**: servicio que registra cada llamada a la API de AWS realizada en la cuenta (quien, que accion, desde que IP, con que resultado).
- **Trail multi-region**: captura eventos en todas las regiones, incluyendo servicios globales como IAM.
- **Log file validation**: permite verificar criptograficamente que los archivos de log no fueron alterados despues de ser escritos.
- **CloudWatch Logs + Metric Filter + Alarm**: pipeline que convierte eventos de texto en metricas numericas, y dispara una alarma cuando ocurre un patron especifico (en este caso, cambios en politicas IAM).

## Que crea este modulo

- Un bucket S3 dedicado a logs, con bloqueo de acceso publico, cifrado y versionado habilitado.
- Una politica de bucket que permite unicamente al servicio de CloudTrail escribir en el bucket.
- Un trail multi-region que registra el 100% de los eventos de gestion (lectura y escritura).
- Un log group de CloudWatch, un metric filter que detecta eventos de creacion/adjuncion/eliminacion de politicas IAM, y una alarma asociada.

## Como ejecutarlo

```bash
cd terraform/05-audit-cloudtrail
terraform init
terraform plan -var="cloudtrail_bucket_name=mi-bucket-cloudtrail-unico"
terraform apply -var="cloudtrail_bucket_name=mi-bucket-cloudtrail-unico"
```

> El nombre del bucket S3 debe ser unico a nivel global en AWS.

## Verificacion (evidencia para portafolio)

1. En CloudTrail > Trails, confirmar que `aws-iam-lab-trail` esta activo y configurado como multi-region.
2. Realizar una accion de prueba (por ejemplo, crear una politica IAM de prueba) y verificar que aparece en CloudTrail > Event history en pocos minutos.
3. En CloudWatch > Alarms, confirmar que existe `iam-policy-changes-alarm` y revisar su historial tras la accion de prueba.
4. Descargar y revisar un archivo de log desde el bucket S3 para ver el detalle JSON de un evento (userIdentity, eventName, sourceIPAddress, etc.).

## Limpieza

```bash
terraform destroy -var="cloudtrail_bucket_name=mi-bucket-cloudtrail-unico"
```

> Nota: si el bucket tiene versionado habilitado y contiene objetos, es posible que sea necesario vaciarlo manualmente antes de que `terraform destroy` pueda eliminarlo.

## Leccion clave

"Si no esta en los logs, no paso" es el principio fundamental de cualquier equipo de SOC o respuesta a incidentes. CloudTrail es la fuente de verdad para investigar quien hizo un cambio, cuando lo hizo y si fue autorizado.

## Cierre del laboratorio

Con este modulo se completa el flujo de aprendizaje: usuarios y grupos organizados (01), permisos minimos y boundaries (02), acceso temporal sin credenciales estaticas (03), autenticacion multifactor obligatoria (04) y auditoria centralizada de todo lo anterior (05). Juntos, estos cinco modulos representan un modelo de gobierno de identidades solido y alineado con las mejores practicas de AWS.
