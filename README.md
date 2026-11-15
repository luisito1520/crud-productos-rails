# CRUD de Productos – Ruby on Rails

Actividad de la Guía de Trabajo No. 4 – *Aplicaciones y servicios web* (ITM).

Aplicación web hecha en **Ruby on Rails 8** que permite Crear, Leer, Actualizar y Eliminar
productos, con **páginas HTML** (listado, detalle y formularios) y una **API REST JSON**
que usan la misma lógica. Los datos se guardan en un archivo **JSON** (`storage/products.json`), sin base
de datos, tal como permite la guía.

Cada producto tiene: `id` (único, autoincremental), `nombre`, `descripcion`, `precio` y `cantidad`.

## Requisitos

- Ruby 3.3 o superior
- Bundler (`gem install bundler`)

## Instalación y ejecución

```bash
bundle install
```

```bash
bin/rails server
```

Abrir `http://localhost:3000` en el navegador para usar la aplicación. La API JSON queda
en `http://localhost:3000/api/products`.

## Estructura del proyecto

| Archivo | Rol |
|---|---|
| `app/services/product_repository.rb` | **Archivo principal**: lógica del CRUD y lectura/escritura del JSON |
| `app/models/product.rb` | Modelo `Product` con atributos y validaciones |
| `app/controllers/products_controller.rb` | Controlador de las páginas HTML |
| `app/views/products/*.html.erb` | Vistas: listado, detalle, nuevo, editar y formulario |
| `app/views/layouts/application.html.erb` | Plantilla general y estilos |
| `app/controllers/api/products_controller.rb` | Endpoints de la API JSON |
| `config/routes.rb` | Rutas `/products` (HTML) y `/api/products` (JSON) |
| `config/locales/es.yml` | Mensajes de validación en español |
| `test/services/product_repository_test.rb` | Pruebas unitarias del CRUD |
| `test/controllers/products_controller_test.rb` | Pruebas de las páginas HTML |
| `test/controllers/api/products_controller_test.rb` | Pruebas de la API JSON |
| `sonar-project.properties` | Configuración de SonarQube |

## Páginas (vistas)

| Ruta | Página |
|---|---|
| `/` o `/products` | Listado en tabla con botones Editar / Eliminar |
| `/products/new` | Formulario para crear |
| `/products/:id` | Detalle de un producto |
| `/products/:id/edit` | Formulario para editar |

Los errores de validación se muestran en el formulario, en español. Si se pide un producto
que no existe, se vuelve al listado con un mensaje de error.

## API JSON

| Método | Ruta | Acción | Error posible |
|---|---|---|---|
| GET | `/api/products` | Listar todos | – |
| GET | `/api/products/:id` | Ver uno | 404 si no existe |
| POST | `/api/products` | Crear | 422 si los datos son inválidos |
| PATCH | `/api/products/:id` | Actualizar | 404 / 422 |
| DELETE | `/api/products/:id` | Eliminar | 404 si no existe |

### Ejemplos con curl

```bash
curl -X POST http://localhost:3000/api/products -H "Content-Type: application/json" -d "{\"product\":{\"nombre\":\"Teclado\",\"descripcion\":\"Mecanico\",\"precio\":150000,\"cantidad\":10}}"
```

```bash
curl http://localhost:3000/api/products
```

```bash
curl -X PATCH http://localhost:3000/api/products/1 -H "Content-Type: application/json" -d "{\"product\":{\"cantidad\":5}}"
```

```bash
curl -X DELETE http://localhost:3000/api/products/1
```

## Pruebas

```bash
bin/rails test
```

35 pruebas (Minitest): lógica del CRUD, páginas HTML y API JSON. Cada operación CRUD tiene al menos un caso exitoso y un caso de
error (producto inexistente o datos inválidos). Al terminar se genera el reporte de
cobertura en `coverage/`.

## Calidad de código con SonarQube

1. Levantar SonarQube (por ejemplo con Docker):
   ```bash
   docker run -d --name sonarqube -p 9000:9000 sonarqube:community
   ```
2. Entrar a `http://localhost:9000` (usuario/clave inicial `admin`/`admin`), crear un
   proyecto local con la clave `crud-productos-rails` y generar un token.
3. Correr las pruebas para generar la cobertura: `bin/rails test`
4. Ejecutar el scanner desde la carpeta del proyecto:
   ```bash
   docker run --rm -e SONAR_HOST_URL=http://host.docker.internal:9000 -e SONAR_TOKEN=<tu_token> -v "%cd%:/usr/src" sonarsource/sonar-scanner-cli
   ```
   (en PowerShell usar `${PWD}` en lugar de `%cd%`).
