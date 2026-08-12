# AWS IAM Security Lab

Laboratorio practico, paso a paso, para aprender y demostrar experiencia real en **AWS Identity and Access Management (IAM)**: diseno de politicas de minimo privilegio, roles, MFA, deteccion de malas configuraciones y auditoria de accesos.

Este proyecto esta pensado para que cualquier persona -incluso sin experiencia previa en AWS- pueda seguirlo de principio a fin, entender el porque de cada decision de seguridad, y terminar con evidencia practica y reproducible (codigo, capturas, resultados de auditoria) para su portafolio.

## Por que este laboratorio

IAM es la base de la seguridad en AWS: la gran mayoria de incidentes de seguridad en la nube se originan por permisos mal configurados (roles demasiado permisivos, credenciales expuestas, falta de MFA, políticas con `"Action": "*"`). Dominar IAM es una habilidad central para roles de **SOC Analyst, Cloud Security y DevSecOps**.

## Objetivos de aprendizaje

Al completar este laboratorio, el usuario sera capaz de:

1. Crear usuarios, grupos y roles de IAM siguiendo el principio de minimo privilegio.
2. Escribir politicas JSON personalizadas (en vez de usar policies administradas demasiado amplias).
3. Configurar MFA obligatorio para acciones sensibles.
4. Usar roles con `AssumeRole` en vez de credenciales de larga duracion.
5. Detectar configuraciones inseguras usando IAM Access Analyzer y AWS Trusted Advisor.
6. Auditar actividad de IAM con CloudTrail.
7. Aplicar y destruir toda la infraestructura de forma reproducible con Terraform.

## Arquitectura del laboratorio

```
aws-iam-security-lab/
├── terraform/
│   ├── 01-users-groups/       # Usuarios y grupos con permisos minimos
│   ├── 02-least-privilege/    # Politicas JSON personalizadas por caso de uso
│   ├── 03-roles-assume-role/  # Roles cross-account y AssumeRole
│   ├── 04-mfa-enforcement/    # Politica que exige MFA para acciones sensibles
│   └── 05-audit-cloudtrail/   # CloudTrail + Athena para auditoria de eventos IAM
├── docs/
│   ├── 01-setup.md            # Configuracion inicial de la cuenta AWS y CLI
│   ├── 02-conceptos-iam.md    # Teoria: usuarios, roles, politicas, principal, condition
│   ├── 03-casos-inseguros.md  # Ejemplos de malas practicas y como corregirlas
│   └── 04-checklist-auditoria.md # Checklist de auditoria de seguridad IAM
└── README.md
```

## Requisitos previos

- Cuenta de AWS (se puede usar la capa gratuita / Free Tier)
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configurado con un usuario administrador **solo para este laboratorio** (nunca usar la cuenta root)
- Conocimientos basicos de linea de comandos

> Recomendacion de seguridad: usa una cuenta AWS separada o un sandbox, activa alertas de facturacion, y destruye los recursos (`terraform destroy`) al finalizar cada modulo para evitar costos inesperados.

## Modulo 1 - Usuarios y grupos con permisos minimos

Objetivo: crear una estructura base de usuarios agrupados por funcion (ej. `readonly-auditors`, `developers`), sin asignar permisos directamente a usuarios individuales.

Conceptos clave:
- Nunca asignar politicas directamente a un usuario; siempre a traves de un grupo.
- Usar policies administradas por AWS solo como punto de partida, luego reemplazarlas por politicas propias mas restrictivas.

```bash
cd terraform/01-users-groups
terraform init
terraform plan
terraform apply
```

## Modulo 2 - Politicas de minimo privilegio

Objetivo: escribir politicas JSON que otorguen unicamente los permisos estrictamente necesarios, usando `Condition` para restringir por IP, MFA o etiquetas (tags).

Ejemplo de politica restrictiva (solo lectura de un bucket S3 especifico):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::mi-bucket-lab",
        "arn:aws:s3:::mi-bucket-lab/*"
      ]
    }
  ]
}
```

El laboratorio incluye ejemplos comentados de politicas incorrectas (demasiado permisivas) versus su version corregida, para entender el razonamiento detras de cada restriccion.

## Modulo 3 - Roles y AssumeRole

Objetivo: eliminar el uso de credenciales de acceso de larga duracion (access keys) en aplicaciones y automatizaciones, sustituyendolas por roles temporales asumidos via `sts:AssumeRole`.

Incluye un ejemplo practico de un rol cross-account con condiciones de `ExternalId` para prevenir el problema de "confused deputy".

## Modulo 4 - Aplicacion de MFA obligatorio

Objetivo: bloquear cualquier accion sensible (borrar buckets, modificar politicas IAM, terminar instancias EC2) si el usuario no se autentico con MFA.

```json
{
  "Effect": "Deny",
  "NotAction": ["iam:*MFA*", "iam:ListUsers"],
  "Resource": "*",
  "Condition": {
    "BoolIfExists": { "aws:MultiFactorAuthPresent": "false" }
  }
}
```

## Modulo 5 - Auditoria con CloudTrail

Objetivo: habilitar CloudTrail para registrar toda la actividad de IAM (creacion de usuarios, cambios de politicas, intentos fallidos de asumir roles) y consultarla con Athena.

Este modulo entrega un checklist de auditoria (`docs/04-checklist-auditoria.md`) que replica lo que un SOC Analyst revisaria en una auditoria real de IAM:

- ¿Existen usuarios con access keys sin rotar hace mas de 90 dias?
- ¿Hay politicas con `"Action": "*"` y `"Resource": "*"`?
- ¿Todos los usuarios humanos tienen MFA activado?
- ¿Se usan roles en vez de access keys para servicios/aplicaciones?
- ¿El usuario root tiene actividad reciente? (no deberia tenerla)

## Como aprender de este repositorio

1. Lee primero `docs/02-conceptos-iam.md` si eres nuevo en IAM.
2. Sigue los modulos en orden (01 a 05); cada uno depende conceptualmente del anterior.
3. Ejecuta cada modulo con Terraform, observa los recursos creados en la consola de AWS, y luego destruyelos (`terraform destroy`) antes de continuar.
4. Revisa `docs/03-casos-inseguros.md` para entender configuraciones reales que causan brechas de seguridad.
5. Usa el checklist de auditoria como ejercicio final, aplicandolo a una cuenta AWS de prueba.

## Buenas practicas aplicadas en este proyecto

- Principio de minimo privilegio en cada politica
- Infraestructura como codigo (Terraform) para reproducibilidad
- Ningun secreto o credencial en el repositorio (ver `.gitignore`)
- Separacion de responsabilidades por modulo
- Documentacion enfocada en el "por que", no solo el "como"

## Roadmap

- [x] Modulo 1: usuarios y grupos
- [ ] Modulo 2: politicas de minimo privilegio (ejemplos adicionales)
- [ ] Modulo 3: roles y AssumeRole cross-account
- [ ] Modulo 4: enforcement de MFA
- [ ] Modulo 5: auditoria con CloudTrail + Athena
- [ ] Modulo 6 (futuro): integracion con AWS Config Rules para deteccion continua

## Motivacion

Este laboratorio forma parte de mi preparacion practica para roles de **SOC Analyst / Cloud Security**, con el objetivo de construir experiencia demostrable en seguridad de identidad y accesos en AWS, mas alla de la teoria de certificaciones.

## Autor

Wilfrido Perez Romero - [LinkedIn](https://linkedin.com/in/wilfridocostarica)
