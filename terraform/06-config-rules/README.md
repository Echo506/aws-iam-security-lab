# Modulo 6 - Deteccion continua con AWS Config

## Objetivo

Los modulos 1 a 5 de este laboratorio configuran IAM de forma correcta (usuarios, minimo privilegio, roles, MFA) y el Modulo 5 agrega auditoria manual con CloudTrail. Este modulo cierra el ciclo con **deteccion continua**: usa AWS Config para evaluar de forma automatica y permanente si la configuracion de IAM se mantiene segura, sin depender de una revision manual periodica.

Esto refleja como trabaja un SOC Analyst o Cloud Security Engineer en un entorno real: no basta con configurar bien una vez, hay que monitorear que la configuracion no se degrade con el tiempo.

## Que crea este modulo

- Un bucket S3 (privado, con bloqueo de acceso publico) para almacenar el historial de configuracion.
- Un rol IAM que AWS Config asume para leer recursos y escribir en el bucket.
- Un `configuration recorder` y un `delivery channel`, que son los componentes que activan el registro continuo de AWS Config.
- Cuatro reglas administradas de AWS Config enfocadas en higiene de IAM:
  - `IAM_USER_MFA_ENABLED`: detecta usuarios de consola sin MFA.
  - `ROOT_ACCOUNT_MFA_ENABLED`: detecta si la cuenta root no tiene MFA.
  - `ACCESS_KEYS_ROTATED`: detecta access keys con mas de 90 dias sin rotar.
  - `IAM_POLICY_NO_STATEMENTS_WITH_ADMIN_ACCESS`: detecta politicas administradas con `"Action": "*"` y `"Resource": "*"`.

## Prerrequisitos

- Terraform >= 1.5.0
- Credenciales de AWS configuradas (`aws configure` o variables de entorno) con permisos sobre `config:*`, `s3:*` y `iam:*` en una cuenta de pruebas.
- Haber completado (o al menos leido) los modulos 01 a 05 para entender que esta siendo auditado.

> Nota: AWS Config tiene un costo por recurso evaluado y por regla activa. Este modulo esta pensado para activarse brevemente en una cuenta de pruebas y luego destruirse con `terraform destroy`. Revisa la [pagina de precios de AWS Config](https://aws.amazon.com/config/pricing/) antes de aplicar en una cuenta con muchos recursos.

## Como usarlo

```bash
cd terraform/06-config-rules
terraform init
terraform plan -var="account_suffix=tuiniciales123"
terraform apply -var="account_suffix=tuiniciales123"
```

La variable `account_suffix` es obligatoria porque los nombres de bucket S3 son unicos a nivel global; usa algo como tus iniciales + numeros para evitar colisiones.

## Como verificar

1. En la consola de AWS, ve a **AWS Config > Recorders** y confirma que el recorder esta activo (`Recording`).
2. Ve a **AWS Config > Rules** y revisa el estado de cumplimiento (`Compliant` / `Noncompliant`) de las cuatro reglas creadas.
3. Si tienes un usuario sin MFA en la cuenta de pruebas, la regla `iam-user-mfa-enabled` deberia marcarlo como `Noncompliant` unos minutos despues de aplicar.
4. Revisa el bucket S3 creado y confirma que AWS Config esta escribiendo snapshots de configuracion ahi.

## Limpieza

```bash
terraform destroy -var="account_suffix=tuiniciales123"
```

Esto elimina el recorder, el delivery channel, las reglas, el rol IAM y el bucket S3 (gracias a `force_destroy = true`, el bucket se borra aunque tenga objetos dentro).

## Relacion con el resto del laboratorio

| Modulo | Enfoque |
|---|---|
| 01 - usuarios y grupos | Fundacion: quien puede acceder |
| 02 - minimo privilegio | Que puede hacer cada quien |
| 03 - roles y AssumeRole | Acceso temporal y cross-account |
| 04 - MFA enforcement | Verificacion de identidad |
| 05 - auditoria con CloudTrail | Revision manual del pasado |
| 06 - AWS Config Rules | Deteccion automatica y continua del presente |

Este modulo es el mas avanzado del laboratorio porque combina IAM con un servicio de gobierno (AWS Config), un patron comun en arquitecturas de seguridad en la nube reales.
