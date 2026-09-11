# Inventario (POS)

Aplicación móvil de gestión e inventario para **Android**, desarrollada con Flutter. Permite administrar productos, categorías y usuarios con roles, registrar la actividad del sistema y operar sin conexión gracias a una arquitectura offline-first que sincroniza automáticamente con Cloud Firestore.

## Características

- **Autenticación** con correo y contraseña (Firebase Auth), con pantallas de presentación (splash) e inicio de sesión.
- **Dashboard** con estadísticas generales: total de productos, bajo stock, próximos a caducar y caducados.
- **Gestión de productos**: alta, edición, detalle y ajuste de stock, con estados visuales de stock y fecha de caducidad.
- **Gestión de categorías**: alta, edición y eliminación.
- **Gestión de usuarios** con roles `Empleado` y `Jefe`; solo el rol `Jefe` puede eliminar productos.
- **Registro de auditoría** de todas las acciones importantes (crear/editar/eliminar productos y categorías, cambios de stock, usuarios, inicios de sesión).
- **Modo oscuro / claro** automático, siguiendo el tema del sistema.
- **Offline-first**: los datos se almacenan localmente en SQLite y se sincronizan con Cloud Firestore cuando hay conexión.

## Reglas de negocio

- Se considera **stock bajo** un producto con existencia `<= 10` unidades.
- Se considera **próximo a caducar** un producto cuya fecha de caducidad esté a `<= 7` días.
- Solo el rol `Jefe` puede eliminar productos.
- Toda mutación de datos relevante queda registrada en la auditoría (local + remoto).

## Stack técnico

- Flutter / Dart
- Firebase Auth, Cloud Firestore
- Flutter Riverpod (gestión de estado)
- GoRouter (navegación)
- SQLite (sqflite) como caché local
- Freezed + JSON Serializable (modelos)
- Connectivity Plus (detección de conexión)

## Estructura del proyecto

```
lib/
├── core/            # Infraestructura: tema, enrutado, Firebase, base de datos, utilidades, widgets
└── features/        # Módulos de negocio (por capa data / domain / presentation)
    ├── auth/        # Autenticación y sesión
    ├── audit/       # Registro de auditoría
    ├── categories/  # Categorías
    ├── products/    # Productos
    ├── users/       # Usuarios y roles
    ├── dashboard/   # Estadísticas
    └── synchronization/  # Servicio de sincronización offline-first
```

Cada feature sigue una arquitectura en capas:
- `data/` — datasources (local SQLite y remoto Firestore), modelos y repositorios.
- `domain/` — servicios y modelos de dominio.
- `presentation/` — providers, vistas y widgets.

## Requisitos previos

- Flutter SDK `^3.13.2` (Dart `^3.13.2`).
- Proyecto de Firebase **`proyecto1001-e7f1a`**.
- La **API de Cloud Firestore** debe estar habilitada en el proyecto de Firebase/GCP; de lo contrario la app muestra un aviso en la pantalla de inicio de sesión.
- El archivo `android/app/google-services.json` ya está incluido en el repositorio; si configuras un proyecto distinto, reemplázalo con el generado por `flutterfire configure`.

## Puesta en marcha

```bash
flutter pub get
flutter run
```

## Pruebas

```bash
flutter test
```

## Utilidades

- `tool/reset_test_data.ps1` — script auxiliar para restablecer datos de prueba.