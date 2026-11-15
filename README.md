# Sistema de Gestión de Inventario — API REST + Flutter (con Autenticación JWT)

Solución full-stack desarrollada para la asignatura **Electiva Profesional I - Desarrollo de Aplicaciones Móviles**. Comprende una **API REST** construida con **Node.js, Express y SQLite** protegida mediante **tokens JWT**, y una aplicación móvil multiplataforma desarrollada en **Flutter (Dart)** consumiendo servicios con **Dio**, inyección de headers Bearer mediante interceptor, persistencia segura de sesión (`flutter_secure_storage` y `shared_preferences`) y navegación declarativa con guards (`go_router`).

---

## Tabla de Contenido
1. [Arquitectura y Seguridad JWT](#arquitectura-y-seguridad-jwt)
2. [Estructura del Proyecto](#estructura-del-proyecto)
3. [Prerrequisitos](#prerrequisitos)
4. [Instalación y Puesta en Marcha](#instalación-y-puesta-en-marcha)
   - [Paso 1: Configurar y Levantar el Backend](#paso-1-configurar-y-levantar-el-backend)
   - [Paso 2: Configurar y Levantar la App Flutter](#paso-2-configurar-y-levantar-la-app-flutter)
5. [Credenciales de Prueba (Seed)](#credenciales-de-prueba-seed)
6. [Especificación de la API REST](#especificación-de-la-api-rest)
   - [Matriz de Endpoints](#matriz-de-endpoints)
   - [Esquema de Autenticación](#esquema-de-autenticación)
7. [Guía de Pruebas con cURL](#guía-de-pruebas-con-curl)
8. [Arquitectura del Frontend (Flutter)](#arquitectura-del-frontend-flutter)
   - [Almacenamiento Seguro vs Preferencias](#almacenamiento-seguro-vs-preferencias)
   - [Guards de Navegación y Rutas](#guards-de-navegación-y-rutas)
9. [Seguridad y Buenas Prácticas](#seguridad-y-buenas-prácticas)
10. [Despliegue](#despliegue)

---

## Arquitectura y Seguridad JWT

El sistema implementa una arquitectura desacoplada con autenticación stateless basada en tokens:

```
+-------------------------------------------------------------------------+
|                              Cliente Flutter                            |
|  - LoginView: Formulario con manejo de estados (carga/éxito/error 401) |
|  - StorageService:                                                      |
|      * flutter_secure_storage -> access_token (Keystore / Keyring)      |
|      * shared_preferences     -> datos no sensibles (nombre, email)     |
|  - AuthInterceptor (Dio):                                               |
|      * Inyecta: 'Authorization: Bearer <token>' en cada petición         |
|      * Captura 401: Limpia sesión y redirige a /login                   |
|  - AppRouter (go_router): Navigation Guard según estado de sesión       |
+------------------------------------+------------------------------------+
                                     |
                          HTTP / JSON con Bearer Token
                                     |
+------------------------------------v------------------------------------+
|                         Servidor Node.js / Express                      |
|  - POST /api/auth/login: Valida credenciales, compara hash bcrypt       |
|    y genera token firmado con JWT_SECRET.                               |
|  - authMiddleware: Lee 'Authorization: Bearer <token>', valida firma    |
|    y expiración. Si falla -> responde HTTP 401 Unauthorized.            |
|  - Endpoints protegidos: Todas las rutas CRUD /api/productos            |
+------------------------------------+------------------------------------+
                                     |
                          Driver better-sqlite3 (WAL)
                                     |
+------------------------------------v------------------------------------+
|                         Base de Datos SQLite 3                          |
|  - Tabla usuarios: id, nombre, email UNIQUE, password (hash bcrypt)     |
|  - Tabla productos: id, nombre, codigo UNIQUE, precio, cantidad, etc.   |
+-------------------------------------------------------------------------+
```

---

## Estructura del Proyecto

```
sistema_gestion_inventario/
├── backend/                  # Servidor Express + SQLite con JWT
│   ├── src/
│   │   ├── controllers/      # auth.controller.js y producto.controller.js
│   │   ├── middlewares/      # auth.middleware.js (validación Bearer JWT)
│   │   ├── routes/           # auth.routes.js y producto.routes.js
│   │   ├── validators/       # producto.validator.js (reglas de negocio 422)
│   │   ├── app.js            # Configuración Express y montaje de rutas
│   │   ├── db.js             # Conexión SQLite y DDL de tablas (productos y usuarios)
│   │   └── seed.js           # Semilla con productos y usuario de prueba bcrypt
│   ├── .env.example          # Plantilla de variables de entorno (PORT, DB_FILE, JWT_SECRET)
│   ├── api-tests.http        # Batería de pruebas HTTP con variables y token JWT
│   └── package.json          # Dependencias (express, better-sqlite3, jsonwebtoken, bcryptjs)
├── frontend/                 # Aplicación móvil Flutter
│   ├── lib/
│   │   ├── config/           # env_config.dart (lectura de BASE_URL)
│   │   ├── models/           # producto.dart y usuario.dart
│   │   ├── routes/           # app_router.dart (rutas nombradas + guardias de autenticación)
│   │   ├── services/         # auth_service.dart, storage_service.dart, auth_interceptor.dart,
│   │   │                     # producto_service.dart, auth_controller.dart, inventario_controller.dart
│   │   ├── themes/           # app_theme.dart (Material Design 3)
│   │   ├── views/            # login_view.dart, session_info_view.dart, dashboard_view.dart,
│   │   │                     # producto_list_view.dart, producto_detail_view.dart, producto_form_view.dart
│   │   ├── widgets/          # app_drawer.dart, confirm_dialog.dart, etc.
│   │   └── main.dart         # Punto de entrada con verificación asíncrona de sesión
│   ├── .env.example          # Plantilla de variables para Flutter
│   └── pubspec.yaml          # Dependencias (dio, go_router, flutter_secure_storage, shared_preferences)
└── README.md
```

---

## Prerrequisitos

- **Node.js**: versión 18 LTS o 20 LTS o superior.
- **Flutter SDK**: versión 3.19+ o superior.
- **Dart SDK**: versión 3.3+ o superior.
- **Emulador Android**, dispositivo móvil físico o escritorio Linux/macOS/Windows.

---

## Instalación y Puesta en Marcha

### Paso 1: Configurar y Levantar el Backend

1. Entrar al directorio del backend:
   ```bash
   cd backend
   ```

2. Instalar dependencias:
   ```bash
   npm install
   ```

3. Crear el archivo `.env` a partir de la plantilla:
   ```bash
   cp .env.example .env
   ```
   *El archivo contiene por defecto:*
   ```env
   PORT=3000
   DB_FILE=database.sqlite
   JWT_SECRET=super_secret_jwt_inventario_dev_key_2026
   JWT_EXPIRES_IN=2h
   ```

4. Ejecutar el seed para poblar la base de datos (crea usuario y catálogo):
   ```bash
   npm run seed
   ```

5. Iniciar el servidor:
   ```bash
   npm start
   ```
   *El backend quedará escuchando en `http://0.0.0.0:3000`.*

---

### Paso 2: Configurar y Levantar la App Flutter

1. Entrar al directorio del frontend:
   ```bash
   cd ../frontend
   ```

2. Instalar dependencias:
   ```bash
   flutter pub get
   ```

3. Configurar la URL base en el archivo `.env`:
   ```bash
   cp .env.example .env
   ```
   - **Para emulador Android oficial:** `BASE_URL=http://10.0.2.2:3000/api`
   - **Para celular físico por Wi-Fi:** `BASE_URL=http://<IP_DE_TU_PC>:3000/api`
   - **Para escritorio Linux o Web:** `BASE_URL=http://localhost:3000/api`

4. Ejecutar la aplicación:
   ```bash
   flutter run
   ```

---

## Credenciales de Prueba (Seed)

Para iniciar sesión en la aplicación o probar la API:

| Campo | Valor de Prueba |
|---|---|
| **Correo electrónico** | `admin@inventario.com` |
| **Contraseña** | `Admin123*` |
| **Rol / Nombre** | Administrador del Sistema |

> **Nota de Seguridad:** La contraseña está almacenada en la base de datos SQLite con hash salado mediante **bcrypt** (`$2a$10$...`), nunca en texto plano.

---

## Especificación de la API REST

### Matriz de Endpoints

| Método | Ruta | Acceso | Descripción | Códigos HTTP |
|---|---|---|---|---|
| `POST` | `/api/auth/login` | Público | Valida credenciales y genera token JWT | `200 OK`, `401 Unauthorized`, `422 Unprocessable` |
| `GET` | `/api/auth/perfil` | **Protegido (JWT)** | Devuelve información del usuario autenticado | `200 OK`, `401 Unauthorized` |
| `GET` | `/api/productos` | **Protegido (JWT)** | Lista todos los productos del inventario | `200 OK`, `401 Unauthorized` |
| `GET` | `/api/productos/:id` | **Protegido (JWT)** | Obtiene detalle de un producto | `200 OK`, `404 Not Found`, `401 Unauthorized` |
| `POST` | `/api/productos` | **Protegido (JWT)** | Crea un nuevo producto | `201 Created`, `401`, `422` |
| `PUT` | `/api/productos/:id` | **Protegido (JWT)** | Actualiza un producto existente | `200 OK`, `401`, `404`, `422` |
| `DELETE` | `/api/productos/:id` | **Protegido (JWT)** | Elimina físicamente un producto | `200 OK`, `401`, `404` |

---

## Guía de Pruebas con cURL

A continuación se presentan los comandos cURL exactos para verificar la autenticación y la protección de servicios:

### 1. Petición sin token a endpoint protegido (debe fallar con 401)
```bash
curl -i http://localhost:3000/api/productos
```
**Respuesta esperada:** `HTTP/1.1 401 Unauthorized`
```json
{
  "message": "Acceso no autorizado: encabezado Authorization no proporcionado"
}
```

### 2. Login con credenciales incorrectas (debe fallar con 401)
```bash
curl -i -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@inventario.com","password":"PasswordIncorrecta"}'
```
**Respuesta esperada:** `HTTP/1.1 401 Unauthorized`
```json
{
  "message": "Credenciales incorrectas: correo o contraseña no válidos"
}
```

### 3. Login correcto (obtiene token JWT)
```bash
curl -i -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@inventario.com","password":"Admin123*"}'
```
**Respuesta esperada:** `HTTP/1.1 200 OK`
```json
{
  "message": "Inicio de sesión exitoso",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "usuario": {
    "id": 1,
    "nombre": "Administrador del Sistema",
    "email": "admin@inventario.com"
  }
}
```

### 4. Petición CRUD con token JWT válido (200 OK)
```bash
# Guardar el token en una variable
TOKEN=$(curl -s -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@inventario.com","password":"Admin123*"}' | grep -o '"token":"[^"]*' | cut -d'"' -f4)

# Listar productos con el token Bearer
curl -i http://localhost:3000/api/productos \
  -H "Authorization: Bearer $TOKEN"
```

### 5. Petición con token manipulado o inválido (401)
```bash
curl -i http://localhost:3000/api/productos \
  -H "Authorization: Bearer token_falso_invalido"
```
**Respuesta esperada:** `HTTP/1.1 401 Unauthorized`
```json
{
  "message": "Token inválido o manipulado",
  "code": "INVALID_TOKEN"
}
```

---

## Arquitectura del Frontend (Flutter)

### Almacenamiento Seguro vs Preferencias

Siguiendo las mejores prácticas de seguridad en aplicaciones móviles:
- **`flutter_secure_storage`**: Utilizado **exclusivamente** para almacenar el `access_token` JWT. En Android utiliza el Android Keystore con SharedPreferences cifradas (`EncryptedSharedPreferences`), y en Linux/macOS utiliza el Keyring seguro del sistema operativo. Nunca se guarda en texto plano ni en almacenamiento desprotegido.
- **`shared_preferences`**: Utilizado para almacenar datos públicos y no sensibles de la sesión (nombre del usuario, correo electrónico) para renderizado rápido en la interfaz sin requerir descifrado criptográfico pesado.
- **Cero almacenamiento de contraseñas**: La contraseña nunca se persiste en ningún medio de almacenamiento local.

### Guards de Navegación y Rutas (`go_router`)

La navegación implementa protección reactiva con `refreshListenable: authController`:

| Ruta | Nombre | Protección | Comportamiento |
|---|---|---|---|
| `/login` | `login` | Pública | Si el usuario ya está autenticado, es redirigido automáticamente al Dashboard (`/`). |
| `/` | `dashboard` | **Protegida** | Si no hay sesión activa, redirige a `/login`. Muestra métricas consolidadas. |
| `/productos` | `productos` | **Protegida** | Catálogo interactivo de productos. |
| `/productos/nuevo` | `producto-nuevo` | **Protegida** | Formulario para registrar producto. |
| `/productos/:id` | `producto-detalle` | **Protegida** | Detalle completo de un producto. |
| `/productos/:id/editar` | `producto-editar` | **Protegida** | Formulario de edición precargado. |
| `/sesion` | `sesion` | **Protegida** | Pantalla con información del usuario, estado de sesión, token enmascarado y botón de cerrar sesión. |

---

## Seguridad y Buenas Prácticas

1. **Hash con Salt (Bcrypt):** Las contraseñas de los usuarios no se guardan en texto plano en la base de datos bajo ninguna circunstancia.
2. **Tokens Efímeros:** Los tokens cuentan con expiración definida (`JWT_EXPIRES_IN=2h`).
3. **Cero Secretos en el Repositorio:** El archivo `.env` está estrictamente ignorado en `.gitignore`. Se incluye únicamente `.env.example` con valores de plantilla.
4. **Manejo Centralizado de Expiración:** Si el token expira mientras el usuario usa la aplicación, el interceptor de Dio captura la respuesta `401`, borra los tokens del almacenamiento seguro y redirige al usuario al login con un mensaje explicativo ("Tu sesión ha expirado").

---

## Despliegue

**No aplica (desarrollo local)**.

De acuerdo con las instrucciones del taller, el despliegue en servicios de nube es opcional y no ha sido implementado. Todo el sistema ha sido configurado y verificado para su ejecución e integración en entorno de desarrollo local.