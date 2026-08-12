# Modulo 03 - Roles IAM y AssumeRole

## Objetivo

Eliminar el uso de access keys de larga duracion. En lugar de credenciales estaticas, los servicios y las cuentas externas **asumen roles** que otorgan credenciales temporales via AWS STS.

## Conceptos clave

- **Trust policy (assume_role_policy)**: define QUIEN puede asumir el rol (un servicio de AWS, otra cuenta, un usuario federado).
- **Instance profile**: mecanismo que permite a una instancia EC2 asumir un rol automaticamente, sin necesidad de guardar credenciales en el servidor.
- **External ID**: un valor secreto compartido que se exige en la condicion de la trust policy para mitigar el problema de "confused deputy" en accesos cross-account.
- **max_session_duration**: limita el tiempo de vida de las credenciales temporales obtenidas al asumir el rol.

## Que crea este modulo

- `ec2-s3-readonly-role`: rol que las instancias EC2 pueden asumir para leer objetos de S3, junto con su instance profile.
- `cross-account-auditor-role`: rol pensado para que una cuenta externa de confianza (por ejemplo, la cuenta de seguridad central de una organizacion) pueda auditar IAM y CloudTrail en modo solo lectura, protegido con External ID.

## Como ejecutarlo

```bash
cd terraform/03-roles-assume-role
terraform init
terraform plan \
  -var="trusted_account_arn=arn:aws:iam::TU_CUENTA_CONFIANZA:root" \
  -var="external_id=un-valor-secreto-unico"
terraform apply \
  -var="trusted_account_arn=arn:aws:iam::TU_CUENTA_CONFIANZA:root" \
  -var="external_id=un-valor-secreto-unico"
```

## Verificacion (evidencia para portafolio)

1. En IAM > Roles, abrir `ec2-s3-readonly-role` y revisar la pestana "Trust relationships": debe permitir unicamente al servicio `ec2.amazonaws.com`.
2. Abrir `cross-account-auditor-role` y confirmar la condicion `sts:ExternalId` en su trust policy.
3. (Opcional) Lanzar una instancia EC2 de prueba con el instance profile `ec2-s3-readonly-profile` y ejecutar `aws sts get-caller-identity` desde dentro para confirmar que usa credenciales temporales del rol, sin access keys.
4. Probar el comando `aws sts assume-role` con el ARN del rol cross-account y el external id correcto (y luego con uno incorrecto, para confirmar que es rechazado).

## Limpieza

```bash
terraform destroy \
  -var="trusted_account_arn=arn:aws:iam::TU_CUENTA_CONFIANZA:root" \
  -var="external_id=un-valor-secreto-unico"
```

## Leccion clave

Las credenciales temporales obtenidas via AssumeRole expiran automaticamente y no quedan almacenadas en ningun servidor o archivo de configuracion, lo que reduce drasticamente el riesgo de robo de credenciales de larga duracion.
