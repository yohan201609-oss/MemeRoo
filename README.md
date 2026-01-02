# 🦘 MemeRoo - Juegos Educativos de Animales

Una aplicación educativa de Flutter diseñada para niños, que incluye 8 juegos diferentes de memoria, habilidades y aprendizaje con animales. MemeRoo combina diversión y aprendizaje en una experiencia interactiva, colorida y con audio.

## 📱 Descripción

MemeRoo es un juego educativo multiplataforma desarrollado con Flutter que ofrece múltiples modos de juego centrados en animales. La aplicación está diseñada para ayudar a los niños a desarrollar habilidades de memoria, concentración, reconocimiento de patrones y coordinación mientras se divierten con música y efectos de sonido.

## 🎮 Juegos Disponibles

### 1. 🎴 Encuentra las Parejas
Juego clásico de memoria donde los jugadores deben encontrar pares de cartas con animales idénticos.
- **Mecánica**: Voltea dos cartas y encuentra las parejas
- **Niveles**: Fácil (6 cartas), Medio (12 cartas), Difícil (16 cartas)
- **Sistema de estrellas**: Basado en el número de movimientos realizados

### 2. 💧 Cascada de Animales
Empareja animales que caen desde la parte superior de la pantalla antes de que se acumulen demasiado.
- **Mecánica**: Toca animales que caen para emparejarlos
- **Objetivo**: Evitar que la pila de animales alcance la parte superior
- **Dificultad**: Aumenta progresivamente con la velocidad

### 3. 🔄 Secuencia Animal
Memoriza y repite secuencias de animales en el orden correcto.
- **Mecánica**: Observa la secuencia y luego repítela
- **Dificultad**: Aumenta progresivamente con cada nivel
- **Habilidades**: Memoria secuencial y concentración

### 4. 🧩 Rompecabezas Deslizante
Arrastra y coloca las piezas del rompecabezas en su posición correcta.
- **Mecánica**: Arrastra piezas para formar el rompecabezas completo
- **Niveles**: 2x2 (Fácil), 2x3 (Medio), 3x3 (Difícil)
- **Sistema de estrellas**: Basado en el tiempo de completado

### 5. 👁️ Adivina el Animal
Descubre el animal oculto revelando pistas progresivamente.
- **Mecánica**: El animal se revela gradualmente, adivínalo lo antes posible
- **Niveles**: Diferentes conjuntos de animales según la dificultad
- **Habilidades**: Reconocimiento visual y rapidez

### 6. 🌑 Sombras (Shadow Match)
Empareja animales con sus sombras correspondientes.
- **Mecánica**: Arrastra animales a sus sombras correctas
- **Niveles**: Diferentes cantidades de animales según la dificultad
- **Habilidades**: Reconocimiento de formas y asociación visual

### 7. 🤔 ¿Quién Soy? (Adivinanza con Pistas)
Adivina el animal basándote en pistas descriptivas.
- **Mecánica**: Lee las pistas y selecciona el animal correcto
- **Niveles**: Diferentes conjuntos de animales y pistas
- **Habilidades**: Comprensión lectora y conocimiento de animales

### 8. ✏️ Conecta los Puntos
Conecta los puntos en orden numérico para revelar el animal.
- **Mecánica**: Toca los puntos en secuencia numérica
- **Niveles**: Diferentes cantidades de puntos según la dificultad
- **Habilidades**: Secuencia numérica y coordinación mano-ojo

## ✨ Características

- 🎯 **8 modos de juego diferentes** con mecánicas únicas
- 🎵 **Sistema de audio completo** con música de fondo y efectos de sonido
- 🔊 **Control de volumen** independiente para música y efectos
- 📚 **Sistema de tutoriales** interactivo para cada juego
- ⭐ **Sistema de estrellas** para motivar a los jugadores
- 📊 **Persistencia de puntuaciones** usando SharedPreferences
- ⏱️ **Cronómetro** en varios juegos para medir el rendimiento
- 🎉 **Efectos de confeti** en las pantallas de victoria
- 🎨 **Diseño moderno** con Material Design 3
- 📱 **Orientación vertical** optimizada para móviles
- 🌈 **Interfaz colorida** y amigable para niños
- 💬 **Diálogos de confirmación** para acciones importantes
- 🎭 **Feedback visual** en botones y acciones
- ⚡ **Optimizaciones de rendimiento** con cache y throttling
- 📐 **Diseño responsivo** adaptado a diferentes tamaños de pantalla

## 🛠️ Tecnologías Utilizadas

- **Flutter** >=3.0.0 <4.0.0
- **Provider** ^6.1.1 - Gestión de estado
- **Confetti** ^0.7.0 - Efectos visuales
- **Shared Preferences** ^2.2.2 - Persistencia de datos
- **Audioplayers** ^5.2.1 - Reproducción de audio

## 📋 Requisitos

- Flutter SDK >=3.0.0
- Dart SDK compatible
- Android Studio / VS Code con extensiones de Flutter
- Dispositivo Android o emulador (minSdk 21 - Android 5.0+)
- Java JDK 17 o superior

## 🚀 Instalación

1. **Clona el repositorio**
   ```bash
   git clone https://github.com/yohan201609-oss/MemeRoo.git
   cd MemeRoo
   ```

2. **Instala las dependencias**
   ```bash
   flutter pub get
   ```

3. **Configura los assets de audio** (opcional)
   - Coloca archivos `.wav` en `assets/sounds/` para efectos de sonido
   - Coloca archivos `.wav` en `assets/music/` para música de fondo
   - Ver `assets/sounds/README.md` y `assets/music/README.md` para más detalles

4. **Ejecuta la aplicación**
   ```bash
   flutter run
   ```

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                      # Punto de entrada de la aplicación
├── models/                        # Modelos de datos
│   ├── falling_animal_model.dart
│   ├── guess_animal_model.dart
│   ├── jigsaw_piece_model.dart
│   ├── memory_card.dart
│   └── sequence_animal_model.dart
├── providers/                     # Gestión de estado (Provider pattern)
│   ├── cascade_provider.dart
│   ├── dots_provider.dart
│   ├── game_provider.dart
│   ├── guess_provider.dart
│   ├── jigsaw_provider.dart
│   ├── riddle_provider.dart
│   ├── sequence_provider.dart
│   └── shadow_provider.dart
├── screens/                       # Pantallas de la aplicación
│   ├── main_menu_screen.dart
│   ├── settings_screen.dart
│   ├── home_screen.dart
│   ├── game_screen.dart
│   ├── victory_screen.dart
│   ├── cascade_*.dart
│   ├── dots_*.dart
│   ├── guess_*.dart
│   ├── jigsaw_*.dart
│   ├── riddle_*.dart
│   ├── sequence_*.dart
│   └── shadow_*.dart
├── widgets/                       # Componentes reutilizables
│   ├── card_widget.dart
│   ├── confetti_widget.dart
│   ├── confirmation_dialog.dart
│   ├── falling_animal_widget.dart
│   ├── feedback_icon_button.dart
│   ├── help_button.dart
│   ├── loading_indicator.dart
│   ├── pixelated_image_widget.dart
│   └── tutorial_dialog.dart
└── utils/                         # Utilidades
    ├── audio_manager.dart         # Gestión de audio
    ├── colors.dart
    ├── constants.dart
    ├── preferences_cache.dart     # Cache de preferencias
    ├── responsive_helper.dart     # Helpers responsivos
    └── tutorial_data.dart         # Datos de tutoriales
```

## 🎯 Sistema de Niveles

Cada juego incluye tres niveles de dificultad:

- **Fácil**: Ideal para principiantes
- **Medio**: Desafío intermedio
- **Difícil**: Para jugadores avanzados

## ⭐ Sistema de Estrellas

Los jugadores pueden obtener hasta 3 estrellas según su rendimiento:

- **⭐⭐⭐ (3 estrellas)**: Rendimiento excelente
- **⭐⭐ (2 estrellas)**: Buen rendimiento
- **⭐ (1 estrella)**: Completado

Las estrellas se calculan según:
- **Encuentra las Parejas**: Número de movimientos
- **Rompecabezas Deslizante**: Tiempo de completado
- Otros juegos: Criterios específicos del juego

## 🔊 Sistema de Audio

La aplicación incluye un sistema completo de audio:

- **Música de fondo**: Reproducción continua en menú y durante el juego
- **Efectos de sonido**: Para acciones como toques, aciertos, errores, victorias
- **Control de volumen**: Sliders independientes para música y efectos
- **Persistencia**: Las preferencias de audio se guardan automáticamente
- **Gestión del ciclo de vida**: La música se pausa automáticamente cuando la app está en segundo plano

### Archivos de Audio Requeridos

Coloca los siguientes archivos en formato `.wav`:

**Efectos de sonido** (`assets/sounds/`):
- `tap.wav` - Sonido al tocar botones
- `success.wav` - Sonido de éxito/correcto
- `error.wav` - Sonido de error
- `win.wav` - Sonido de victoria
- `flip.wav` - Sonido al voltear carta
- `match.wav` - Sonido al hacer match

**Música de fondo** (`assets/music/`):
- `menu.wav` - Música del menú principal
- `game.wav` - Música durante el juego

Ver `assets/sounds/README.md` y `assets/music/README.md` para más detalles y fuentes recomendadas.

## 📚 Sistema de Tutoriales

Cada juego incluye un tutorial interactivo que se muestra automáticamente la primera vez que se juega:

- **Tutorial paso a paso**: Instrucciones claras y visuales
- **Opción "No mostrar de nuevo"**: Los usuarios pueden desactivar los tutoriales
- **Botón de ayuda**: Acceso rápido al tutorial desde cualquier pantalla de juego
- **Persistencia**: Las preferencias de tutorial se guardan localmente

## 🎨 Personalización

### Colores
Los colores se pueden personalizar en `lib/utils/colors.dart`

### Constantes del Juego
Las configuraciones de niveles, animales y umbrales se encuentran en `lib/utils/constants.dart`

### Audio
La configuración de audio se gestiona en `lib/utils/audio_manager.dart`

## 📦 Compilación

### Android (Debug)
```bash
flutter build apk --debug
```

### Android (Release)
Para compilar una versión release firmada:

1. **Crea el keystore** (si aún no lo has hecho):
   ```bash
   keytool -genkey -v -keystore android/app/memeroo-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias memeroo
   ```

2. **Configura las contraseñas** en `android/key.properties`:
   ```properties
   storePassword=TU_CONTRASEÑA
   keyPassword=TU_CONTRASEÑA
   keyAlias=memeroo
   storeFile=app/memeroo-keystore.jks
   ```

3. **Compila el APK**:
   ```bash
   flutter build apk --release
   ```

4. **O compila el App Bundle** (recomendado para Google Play):
   ```bash
   flutter build appbundle --release
   ```

El APK se generará en `build/app/outputs/flutter-apk/app-release.apk`  
El AAB se generará en `build/app/outputs/bundle/release/app-release.aab`

## 📱 Información de la Aplicación

- **Nombre del paquete**: `com.domynixa.memeroo`
- **Versión**: 1.0.0+1
- **MinSdk**: 21 (Android 5.0+)
- **TargetSdk**: 34
- **CompileSdk**: 34

## 🐛 Solución de Problemas

Si encuentras problemas al ejecutar la aplicación:

1. Asegúrate de tener Flutter instalado correctamente
2. Ejecuta `flutter doctor` para verificar la configuración
3. Limpia el proyecto: `flutter clean && flutter pub get`
4. Verifica que el logo esté en `assets/images/icon.png`
5. Si hay errores de audio, verifica que los archivos `.wav` existan en las carpetas correctas
6. Si hay problemas de compilación, verifica que el keystore esté configurado correctamente

## 🔒 Seguridad

- El archivo `android/key.properties` está en `.gitignore` y no debe subirse al repositorio
- Los archivos `.jks` y `.keystore` también están protegidos en `.gitignore`
- **Importante**: Guarda una copia segura de tu keystore y contraseñas, son necesarios para actualizar la app en Google Play

## 👨‍💻 Desarrollo

Este proyecto utiliza el patrón Provider para la gestión de estado. Cada juego tiene su propio provider que maneja la lógica del juego y notifica a la UI cuando hay cambios.

### Optimizaciones Implementadas

- **Cache de preferencias**: Reduce I/O de disco para SharedPreferences
- **Protección de dispose**: Previene llamadas a `notifyListeners()` en objetos disposed
- **Throttling**: Limita actualizaciones frecuentes en algunos providers
- **Const constructors**: Donde sea posible para mejor rendimiento
- **RepaintBoundary**: Para optimizar repintados innecesarios

## 📄 Licencia

Este proyecto es privado y está destinado para uso educativo.

## 🎉 ¡Disfruta jugando con MemeRoo!

---

**Versión**: 1.0.0+1  
**Package Name**: com.domynixa.memeroo  
**Repositorio**: [https://github.com/yohan201609-oss/MemeRoo.git](https://github.com/yohan201609-oss/MemeRoo.git)  
**Última actualización**: 2024
