# Guardiapp - Flutter Widgets Project

A modern and comprehensive Flutter application designed for school management, featuring teacher and student directories, schedule management, and absence tracking.

Este es un proyecto de Flutter moderno y completo diseñado para la gestión escolar, que incluye directorios de profesores y alumnos, gestión de horarios y seguimiento de ausencias.

---

## 📑 Table of Contents | Índice de Contenido

- [English Version](#english-version)
  - [Features](#features)
  - [Tech Stack](#tech-stack)
  - [Prerequisites](#prerequisites)
  - [Getting Started](#getting-started)
  - [Project Structure](#project-structure)
- [Versión en Español](#versión-en-español)
  - [Características](#características)
  - [Stack Tecnológico](#stack-tecnológico)
  - [Requisitos Previos](#requisitos-previos)
  - [Primeros Pasos](#primeros-pasos)
  - [Estructura del Proyecto](#estructura-del-proyecto)

---

# English Version

## Features
- **Authentication**: Secure login system for teachers and administrators.
- **Teacher Management**: Directory with search, profile editing, and availability tracking.
- **Student Management**: Full CRUD for students including grade and parent contact info.
- **Schedule Management**: Interactive calendar to manage shifts and subjects.
- **Absence Tracking**: System for requesting and approving teacher absences.
- **Localization**: Full support for English and Spanish languages.
- **Customization**: Dark mode support and customizable backgrounds.

## Tech Stack
- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **UI Components**: Google Fonts, Lucide-like icons, Shimmer effects, Staggered animations.
- **Utilities**: Intl (localization), Uuid, Path Provider.

## Prerequisites
- **Flutter SDK**: `^3.10.4`
- **Dart SDK**: `^3.0.0`
- **IDE**: VS Code (recommended) or Android Studio.
- **Java**: JDK 17+ (for Android builds).

## Getting Started

### Installation
1. Clone the repository.
2. Navigate to the project root:
   ```bash
   cd guardiapp-mobile-flutter
   ```
3. Get dependencies:
   ```bash
   flutter pub get
   ```

### Running the App
- **Mobile (Android/iOS)**:
  ```bash
  flutter run
  ```
- **Web**:
  ```bash
  flutter run -d chrome
  ```
- **Desktop (Windows/macOS/Linux)**:
  ```bash
  flutter run -d windows # or macos/linux
  ```

## Project Structure
- `lib/models/`: Data models and State management (`AppState`).
- `lib/screens/`: UI screens for Auth, Dashboard, Students, Schedule, etc.
- `lib/utils/`: Helper classes and localization (`AppStrings`).
- `lib/theme/`: Custom application themes.
- `assets/`: Images, icons, and backgrounds.

---

# Versión en Español

## Características
- **Autenticación**: Sistema de inicio de sesión seguro para profesores y administradores.
- **Gestión de Profesores**: Directorio con búsqueda, edición de perfil y rastreo de disponibilidad.
- **Gestión de Estudiantes**: CRUD completo para alumnos, incluyendo curso e información de contacto de padres.
- **Gestión de Horarios**: Horario interactivo para gestionar turnos y asignaturas.
- **Seguimiento de Ausencias**: Sistema para solicitar y aprobar ausencias de profesores.
- **Localización**: Soporte completo para los idiomas inglés y español.
- **Personalización**: Soporte para modo oscuro y fondos personalizables.

## Stack Tecnológico
- **Framework**: Flutter (Dart)
- **Gestión de Estado**: Provider
- **Almacenamiento Local**: SharedPreferences
- **Componentes de UI**: Google Fonts, efectos Shimmer, animaciones escalonadas.
- **Utilidades**: Intl (localización), Uuid, Path Provider.

## Requisitos Previos
- **Flutter SDK**: `^3.10.4`
- **Dart SDK**: `^3.0.0`
- **IDE**: VS Code (recomendado) o Android Studio.
- **Java**: JDK 17+ (para compilación en Android).

## Primeros Pasos

### Instalación
1. Clona el repositorio.
2. Ve al directorio raíz del proyecto:
   ```bash
   cd guardiapp-mobile-flutter
   ```
3. Instala las dependencias:
   ```bash
   flutter pub get
   ```

### Ejecución de la App
- **Móvil (Android/iOS)**:
  ```bash
  flutter run
  ```
- **Web**:
  ```bash
  flutter run -d chrome
  ```
- **Escritorio (Windows/macOS/Linux)**:
  ```bash
  flutter run -d windows # o macos/linux
  ```

## Estructura del Proyecto
- `lib/models/`: Modelos de datos y gestión de estado (`AppState`).
- `lib/screens/`: Pantallas de UI (Auth, Dashboard, Alumnos, Horario, etc.).
- `lib/utils/`: Clases auxiliares y localización (`AppStrings`).
- `lib/theme/`: Temas personalizados de la aplicación.
- `assets/`: Imágenes, iconos y fondos de pantalla.
