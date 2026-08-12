# Modulo 04 - Enforcement de MFA y Politica de Contrasenas

## Objetivo

Implementar el control de seguridad de mayor impacto y menor costo en IAM: **exigir autenticacion multifactor (MFA)** para casi todas las acciones, y complementarlo con una politica de contrasenas robusta.

## Conceptos clave

- `aws:MultiFactorAuthPresent`: clave de condicion global que indica si la sesion actual se autentico con MFA.
- `BoolIfExists`: variante de la condicion que evalua correctamente incluso si la clave no esta presente (por ejemplo, en llamadas hechas con access keys, que no tienen este contexto).
- El patron `Deny` + `NotAction` es mas seguro que listar manualmente cada accion permitida: cualquier accion nueva de AWS queda bloqueada por defecto hasta que el usuario se autentique con MFA.

## Que crea este modulo

- `require-mfa-policy`: politica que deniega casi todas las acciones si no hay MFA presente, dejando siempre disponible la posibilidad de configurar el propio dispositivo MFA.
- Politica de contrasenas de la cuenta: longitud minima 14, mayusculas, minusculas, numeros, simbolos, expiracion cada 90 dias y prevencion de reutilizar las ultimas 5 contrasenas.
- (Opcional) Adjunta `require-mfa-policy` a los grupos indicados en `groups_requiring_mfa` (por ejemplo, los grupos creados en el modulo 01).

## Como ejecutarlo

```bash
cd terraform/04-mfa-enforcement
terraform init
terraform plan -var='groups_requiring_mfa=["readonly-auditors","developers"]'
terraform apply -var='groups_requiring_mfa=["readonly-auditors","developers"]'
```

> Nota: los grupos referenciados deben existir previamente (creados en el modulo 01) o Terraform fallara al intentar adjuntar la politica.

## Verificacion (evidencia para portafolio)

1. En IAM > Account settings, confirmar que la politica de contrasenas refleja los valores configurados.
2. Crear un usuario de prueba sin MFA, adjuntarle (via grupo) la politica `require-mfa-policy`, e intentar listar buckets S3: debe ser denegado.
3. Configurar un dispositivo MFA virtual para ese usuario e intentar la misma accion nuevamente: debe funcionar.
4. Documentar con capturas de pantalla el intento denegado y el intento exitoso.

## Limpieza

```bash
terraform destroy -var='groups_requiring_mfa=["readonly-auditors","developers"]'
```

## Leccion clave

Segun multiples informes de la industria, la gran mayoria de los compromisos de cuentas en la nube involucran credenciales robadas sin MFA. Forzar MFA a nivel de politica (no solo como "recomendacion") es uno de los controles mas efectivos que existen.
