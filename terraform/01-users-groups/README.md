# Modulo 01 - Usuarios y Grupos con Permisos Minimos

## Objetivo

Este modulo introduce el principio mas importante de IAM: **nunca asignar politicas directamente a un usuario**. Todos los permisos se asignan a traves de grupos, agrupando usuarios por funcion (auditoria, desarrollo, etc.).

## Que crea este modulo

- Grupo `readonly-auditors`: acceso de solo lectura a S3 e IAM, pensado para tareas de auditoria.
- Grupo `developers`: acceso de lectura/escritura limitado a un bucket S3 especifico de desarrollo.
- (Opcional) Un usuario de ejemplo `lab-auditor-example`, controlado por la variable `create_example_user`.

## Requisitos previos

- Terraform >= 1.5
- Una cuenta de AWS con credenciales configuradas (`aws configure` o variables de entorno `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`)
- Permisos IAM suficientes para crear grupos, politicas y usuarios

## Como ejecutarlo

```bash
cd terraform/01-users-groups
terraform init
terraform plan -var="dev_bucket_name=mi-bucket-dev-unico"
terraform apply -var="dev_bucket_name=mi-bucket-dev-unico"
```

## Verificacion (evidencia para portafolio)

1. En la consola de AWS, ir a IAM > User groups y confirmar que existen `readonly-auditors` y `developers`.
2. Revisar las politicas inline de cada grupo y confirmar que siguen el principio de minimo privilegio (sin `"Action": "*"`).
3. Tomar captura de pantalla de los grupos y politicas creadas.

## Limpieza

```bash
terraform destroy -var="dev_bucket_name=mi-bucket-dev-unico"
```

## Leccion clave

Si mañana se necesita cambiar el acceso de 10 personas del equipo de desarrollo, basta con modificar la politica del grupo `developers` una sola vez, en lugar de editar 10 usuarios individualmente.
