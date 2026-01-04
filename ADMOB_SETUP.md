# 📱 Guía de Configuración de Google AdMob para MemeRoo

## ✅ Implementación Completada

La integración de Google AdMob ha sido completada exitosamente. El juego ahora incluye:

- ✅ **Banner Ads** en el menú principal
- ✅ **Interstitial Ads** entre selección de niveles
- ✅ **Sistema de frecuencia** para limitar anuncios (máximo 1 cada 3 minutos, 10 por día)
- ✅ **Configuración COPPA** para apps infantiles
- ✅ **IDs de prueba** configurados para desarrollo

---

## 🔧 Pasos para Configurar tus IDs Reales de AdMob

### Paso 1: Crear Cuenta de AdMob

1. Ve a: https://admob.google.com
2. Inicia sesión con tu cuenta de Google
3. Acepta los términos y condiciones
4. Completa la información de pago (necesaria para recibir ganancias)

### Paso 2: Crear Aplicación en AdMob

1. En la consola de AdMob → **Apps** → **Add App**
2. Selecciona: **¿Está en Google Play?** → No (por ahora)
3. **Nombre de la app:** MemeRoo
4. **Plataforma:** Android
5. **Categoría:** Familia - Juegos educativos
6. ⚠️ **IMPORTANTE:** Marca "La app está dirigida principalmente a niños"

### Paso 3: Crear Unidades de Anuncios

#### A. Banner Ad (Menu Principal)
1. En tu app → **Ad units** → **Add ad unit**
2. **Nombre:** Banner Menu Principal
3. **Formato:** Banner
4. Copia el **Ad unit ID** generado

#### B. Interstitial Ad (Entre Juegos)
1. **Add ad unit**
2. **Nombre:** Interstitial Entre Juegos
3. **Formato:** Interstitial
4. Copia el **Ad unit ID** generado

#### C. Rewarded Ad (Opcional - para futuras funcionalidades)
1. **Add ad unit**
2. **Nombre:** Recompensa Pista Extra
3. **Formato:** Rewarded
4. Copia el **Ad unit ID** generado

### Paso 4: Obtener App ID

1. En la página de tu app en AdMob
2. Copia el **App ID** (formato: `ca-app-pub-XXXXXXXXXXXXXXXX~AAAAAAAAAA`)

---

## 📝 Configurar IDs en el Código

### 1. Actualizar AndroidManifest.xml

Edita `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Reemplaza este valor con tu App ID real -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-TU-APP-ID-AQUI~AAAAAAAAAA"/>
```

### 2. Actualizar AdManager

Edita `lib/utils/ad_manager.dart`:

```dart
// Reemplaza estos valores con tus IDs reales
static const String _prodBannerAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/TU-BANNER-ID';
static const String _prodInterstitialAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/TU-INTERSTITIAL-ID';
static const String _prodRewardedAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/TU-REWARDED-ID';
```

---

## 🧪 Testing

### IDs de Prueba (Ya Configurados)

Los siguientes IDs de prueba están configurados y funcionan en modo debug:

- **Banner:** `ca-app-pub-3940256099942544/6300978111`
- **Interstitial:** `ca-app-pub-3940256099942544/1033173712`
- **Rewarded:** `ca-app-pub-3940256099942544/5224354917`

### Probar en Dispositivo Real

⚠️ **IMPORTANTE:** Los anuncios NO funcionan en emulador, debes usar un dispositivo real.

```bash
flutter run --release
```

O compila un APK:

```bash
flutter build apk --release
```

---

## ⚙️ Configuración Actual

### Sistema de Frecuencia de Anuncios

El sistema está configurado para:

- **Tiempo mínimo entre interstitials:** 3 minutos
- **Límite diario:** 10 interstitials por día
- **Reset automático:** Cada día a medianoche

Esto asegura una experiencia positiva para los usuarios, especialmente importante en apps infantiles.

### Configuración COPPA

La app está configurada para cumplir con COPPA (Children's Online Privacy Protection Act):

- ✅ `tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes`
- ✅ `maxAdContentRating: MaxAdContentRating.g`
- ✅ `FAMILY_SELF_CERTIFIED_ADS: true` en AndroidManifest

---

## 📍 Ubicaciones de Anuncios

### Banner Ad
- **Ubicación:** Parte inferior del menú principal
- **Carga:** Automática al abrir el menú
- **Disposición:** Automática al cerrar el menú

### Interstitial Ads
- **Ubicación:** Antes de iniciar un nivel (con límite de frecuencia)
- **Carga:** Automática al iniciar la app
- **Recarga:** Automática después de cada visualización

---

## 🚀 Próximos Pasos

1. **Crear cuenta de AdMob** y obtener tus IDs reales
2. **Reemplazar IDs de prueba** con tus IDs reales
3. **Probar en dispositivo real** con versión release
4. **Publicar en Google Play** (cuando estés listo)
5. **Monitorear ingresos** en la consola de AdMob

---

## 📊 Monitoreo de Ingresos

Una vez que publiques:

1. Ve a la consola de AdMob
2. Revisa la sección **Monetization**
3. Monitorea:
   - Impresiones de anuncios
   - Tasa de clics (CTR)
   - Ingresos estimados
   - RPM (Revenue Per Mille)

---

## ⚠️ Consideraciones Importantes

### Para Apps Infantiles:

1. **Cumplimiento COPPA:** Ya configurado ✅
2. **Contenido apropiado:** AdMob filtra automáticamente anuncios inapropiados
3. **Frecuencia limitada:** Ya implementado ✅
4. **No interrumpir gameplay:** Los anuncios solo aparecen entre pantallas ✅

### Mejores Prácticas:

- ✅ No mostrar anuncios durante el juego
- ✅ Limitar frecuencia de interstitials
- ✅ Banner no invasivo en menú
- ✅ Anuncios opcionales (rewarded) para funcionalidades extra

---

## 🐛 Solución de Problemas

### Los anuncios no aparecen:

1. Verifica que estés usando un dispositivo real (no emulador)
2. Verifica que estés en modo release o usando IDs de prueba
3. Revisa los logs en consola para errores
4. Verifica que los IDs estén correctamente configurados

### Error al cargar anuncios:

1. Verifica tu conexión a internet
2. Revisa que el App ID en AndroidManifest sea correcto
3. Verifica que los Ad Unit IDs sean correctos
4. Revisa la consola de AdMob para ver si hay problemas con tu cuenta

---

## 📞 Soporte

Para más información sobre AdMob:
- Documentación: https://developers.google.com/admob
- Soporte: https://support.google.com/admob

---

**¡Listo!** Tu app está configurada para monetizar con Google AdMob. Solo necesitas reemplazar los IDs de prueba con tus IDs reales cuando estés listo para publicar.
