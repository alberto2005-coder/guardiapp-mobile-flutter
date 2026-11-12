# Guardiapp

[![Flutter](https://img.shields.io/badge/Flutter-3.10%2B-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![Provider](https://img.shields.io/badge/Estado-Provider-6E56CF)](https://pub.dev/packages/provider)
[![MIT](https://img.shields.io/badge/Licencia-MIT-green)](LICENSE)

[Español](#español) · [English](#english)

---

## Español

### Índice

- [Descripción](#descripción)
- [Características](#características)
- [Stack tecnológico](#stack-tecnológico)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Requisitos](#requisitos)
- [Instalación y ejecución](#instalación-y-ejecución)
- [Datos y alcance](#datos-y-alcance)
- [Licencia](#licencia)

### Descripción

**Guardiapp** es una aplicación **Flutter** para la gestión escolar diaria: directorio de profesores y alumnos, horarios, control de asistencia y solicitudes de ausencia. La interfaz está pensada para usarse en móvil, pero el mismo código compila para web y escritorio.

### Características

- **Inicio de sesión y registro** para profesores y administradores.
- **Directorio de profesores** con búsqueda, edición de perfil y disponibilidad.
- **Gestión de alumnos**: alta, edición y borrado con curso y contacto de los padres.
- **Horario interactivo** para organizar turnos y asignaturas.
- **Control de ausencias**: solicitud y aprobación de ausencias del profesorado.
- **Panel de resumen** con tarjetas, gráfico de asistencia y quién está disponible hoy.
- **Internacionalización** completa en español e inglés.
- **Modo oscuro** y fondos personalizables.

### Stack tecnológico

| Capa | Tecnología |
|---|---|
| Framework | Flutter (Dart) |
| Gestión de estado | `provider` con `AppState` y `ChangeNotifier` |
| Persistencia local | `shared_preferences` |
| UI | Google Fonts, iconos estilo Lucide, efectos *shimmer* y animaciones escalonadas |
| Utilidades | `intl`, `uuid`, `path_provider` |

### Estructura del proyecto

```text
guardiapp-mobile-flutter/
├── lib/
│   ├── main.dart                     # Arranque y configuración de Provider
│   ├── layout/main_layout.dart       # Barra de navegación y estructura común
│   ├── models/
│   │   ├── app_state.dart            # Estado global y persistencia
│   │   └── models.dart               # Profesor, alumno, clase y ausencia
│   ├── screens/
│   │   ├── auth/                     # Login y registro
│   │   ├── dashboard/                # Resumen, gráfico y widgets
│   │   ├── teachers/                 # Listado y edición de profesores
│   │   ├── students/                 # CRUD de alumnos
│   │   ├── schedule/                 # Horario interactivo
│   │   ├── absences/                 # Solicitudes y aprobaciones
│   │   └── settings/                 # Tema, idioma y fondos
│   ├── theme/app_theme.dart          # Temas claro y oscuro
│   ├── utils/app_strings.dart        # Traducciones ES/EN
│   └── widgets/skeleton_list.dart    # Carga con efecto shimmer
├── assets/backgrounds/               # Fondos seleccionables
├── test/                             # Pruebas de widgets
├── android/ · ios/ · web/ · windows/ · linux/ · macos/
├── LICENSE
└── README.md
```

### Requisitos

- **Flutter SDK 3.10.4** o superior y **Dart 3.0+**.
- **JDK 17+** para compilar en Android.
- VS Code o Android Studio con el plugin de Flutter.
- Un emulador, un dispositivo conectado o Chrome para la versión web.

### Instalación y ejecución

```bash
git clone https://github.com/alberto2005-coder/guardiapp-mobile-flutter.git
cd guardiapp-mobile-flutter
flutter pub get
flutter run
```

Otras plataformas:

```bash
flutter run -d chrome     # web
flutter run -d windows    # escritorio (macos / linux equivalentes)
flutter build apk --release
```

La APK de lanzamiento queda en `build/app/outputs/flutter-apk/app-release.apk`.

### Datos y alcance

Es un **proyecto de demostración**: el estado se guarda en `SharedPreferences` del propio dispositivo y el login se valida en local. No hay servidor, base de datos remota ni recuperación de contraseñas, así que no debe usarse tal cual para gestionar datos reales de un centro. Para producción haría falta un backend con autenticación real, permisos por rol y almacenamiento cifrado.

### Licencia

**MIT** — consulta [LICENSE](LICENSE).

---

## English

### Table of contents

- [Overview](#overview)
- [Features](#features)
- [Tech stack](#tech-stack)
- [Project structure](#project-structure)
- [Requirements](#requirements)
- [Installation and running](#installation-and-running)
- [Data and scope](#data-and-scope)
- [License](#license)

### Overview

**Guardiapp** is a **Flutter** app for day-to-day school management: a teacher and student directory, schedules, attendance tracking and absence requests. The UI targets phones, but the same code builds for web and desktop.

### Features

- **Sign-in and registration** for teachers and administrators.
- **Teacher directory** with search, profile editing and availability.
- **Student management**: create, edit and delete, including grade and parent contact details.
- **Interactive schedule** to organise shifts and subjects.
- **Absence tracking**: teachers request absences and admins approve them.
- **Summary dashboard** with cards, an attendance chart and who is in today.
- **Full internationalisation** in Spanish and English.
- **Dark mode** and customizable backgrounds.

### Tech stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State management | `provider` with `AppState` and `ChangeNotifier` |
| Local persistence | `shared_preferences` |
| UI | Google Fonts, Lucide-style icons, shimmer effects and staggered animations |
| Utilities | `intl`, `uuid`, `path_provider` |

### Project structure

```text
guardiapp-mobile-flutter/
├── lib/
│   ├── main.dart                     # Bootstrap and Provider setup
│   ├── layout/main_layout.dart       # Navigation bar and shared shell
│   ├── models/
│   │   ├── app_state.dart            # Global state and persistence
│   │   └── models.dart               # Teacher, student, class and absence
│   ├── screens/
│   │   ├── auth/                     # Login and registration
│   │   ├── dashboard/                # Summary, chart and widgets
│   │   ├── teachers/                 # Teacher list and editing
│   │   ├── students/                 # Student CRUD
│   │   ├── schedule/                 # Interactive schedule
│   │   ├── absences/                 # Requests and approvals
│   │   └── settings/                 # Theme, language and backgrounds
│   ├── theme/app_theme.dart          # Light and dark themes
│   ├── utils/app_strings.dart        # ES/EN translations
│   └── widgets/skeleton_list.dart    # Shimmer loading state
├── assets/backgrounds/               # Selectable backgrounds
├── test/                             # Widget tests
├── android/ · ios/ · web/ · windows/ · linux/ · macos/
├── LICENSE
└── README.md
```

### Requirements

- **Flutter SDK 3.10.4** or later and **Dart 3.0+**.
- **JDK 17+** for Android builds.
- VS Code or Android Studio with the Flutter plugin.
- An emulator, a connected device, or Chrome for the web build.

### Installation and running

```bash
git clone https://github.com/alberto2005-coder/guardiapp-mobile-flutter.git
cd guardiapp-mobile-flutter
flutter pub get
flutter run
```

Other platforms:

```bash
flutter run -d chrome     # web
flutter run -d windows    # desktop (macos / linux equivalents)
flutter build apk --release
```

The release APK lands in `build/app/outputs/flutter-apk/app-release.apk`.

### Data and scope

This is a **demo project**: state lives in the device's `SharedPreferences` and login is validated locally. There is no server, remote database or password recovery, so it should not be used as-is with real school data. Production use would need a backend with real authentication, role-based permissions and encrypted storage.

### License

**MIT** — see [LICENSE](LICENSE).
