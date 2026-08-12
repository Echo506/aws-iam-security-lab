# Modulo 02 - Politicas de Minimo Privilegio y Permissions Boundaries

## Objetivo

Aprender a escribir politicas IAM que otorgan exactamente los permisos necesarios, ni mas ni menos, y a usar **permissions boundaries** como una red de seguridad adicional.

## Conceptos clave

- **Minimo privilegio**: cada politica debe listar acciones y recursos especificos, evitando `"Action": "*"` y `"Resource": "*"` siempre que sea posible.
- **Condiciones (`Condition`)**: permiten restringir aun mas un permiso, por ejemplo limitando el acceso a un prefijo especifico dentro de un bucket S3.
- **Permissions boundary**: una politica que define el limite maximo de permisos que un rol o usuario puede tener, independientemente de que otras politicas se le asignen despues. Es una segunda capa de defensa.

## Que crea este modulo

- `least-privilege-log-reader`: politica que permite leer unicamente objetos bajo el prefijo `logs/` de un bucket especifico.
- `app-permissions-boundary`: politica de boundary que niega explicitamente acciones de IAM y Organizations, y solo permite S3 y CloudWatch Logs.

El archivo `main.tf` tambien incluye, comentado, un ejemplo de **mala practica** (`Action: "*", Resource: "*"`) unicamente con fines educativos: nunca se llega a crear en AWS.

## Como ejecutarlo

```bash
cd terraform/02-least-privilege
terraform init
terraform plan -var="logs_bucket_name=mi-bucket-logs-unico"
terraform apply -var="logs_bucket_name=mi-bucket-logs-unico"
```

## Verificacion (evidencia para portafolio)

1. En IAM > Policies, abrir `least-privilege-log-reader` y confirmar que el `Resource` esta acotado al bucket y prefijo especifico.
2. Abrir `app-permissions-boundary` y confirmar el efecto `Deny` sobre `iam:*` y `organizations:*`.
3. (Opcional) Adjuntar el boundary a un rol de prueba y verificar en el simulador de politicas de IAM (IAM Policy Simulator) que las acciones fuera del boundary son denegadas.

## Limpieza

```bash
terraform destroy -var="logs_bucket_name=mi-bucket-logs-unico"
```

## Leccion clave

Una politica de minimo privilegio limita el dano si las credenciales se filtran. Un permissions boundary limita el dano incluso si alguien, por error o intencionalmente, adjunta una politica demasiado permisiva a un rol.
