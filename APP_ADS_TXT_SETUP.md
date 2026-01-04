# 📄 Guía de Configuración de app-ads.txt

## ✅ Archivo Creado

El archivo `app-ads.txt` ya está creado en la raíz del proyecto con el contenido necesario:

```
google.com, pub-2612958934827252, DIRECT, f08c47fec0942fa0
```

## 🌐 Pasos para Publicar el Archivo

### Opción 1: Si Tienes un Sitio Web del Desarrollador

1. **Sube el archivo** `app-ads.txt` al dominio raíz de tu sitio web
   - Debe ser accesible en: `https://tudominio.com/app-ads.txt`
   - Ejemplo: Si tu sitio es `domynixa.com`, debe estar en `domynixa.com/app-ads.txt`

2. **Verifica que sea accesible**:
   - Abre tu navegador y visita `https://tudominio.com/app-ads.txt`
   - Debes ver el contenido del archivo

3. **Verifica en AdMob**:
   - Ve a tu consola de AdMob
   - Espera al menos 24 horas para que AdMob verifique el archivo
   - Revisa el estado en la sección de configuración

### Opción 2: Si NO Tienes Sitio Web (Recomendado para Desarrolladores)

#### A. Usar GitHub Pages (Gratis)

Si tu código está en GitHub:

1. **Crea una rama `gh-pages`**:
   ```bash
   git checkout -b gh-pages
   git push origin gh-pages
   ```

2. **Habilita GitHub Pages**:
   - Ve a Settings → Pages en tu repositorio de GitHub
   - Selecciona la rama `gh-pages` como fuente
   - Tu sitio estará en: `https://tuusuario.github.io/MemeRoo/app-ads.txt`

3. **Agrega el dominio a AdMob**:
   - En AdMob, configura el dominio: `tuusuario.github.io`
   - Espera 24 horas para verificación

#### B. Usar Firebase Hosting (Gratis)

1. **Instala Firebase CLI**:
   ```bash
   npm install -g firebase-tools
   ```

2. **Inicializa Firebase**:
   ```bash
   firebase init hosting
   ```

3. **Crea una carpeta `public`** y copia `app-ads.txt` ahí

4. **Despliega**:
   ```bash
   firebase deploy --only hosting
   ```

5. **Tu archivo estará en**: `https://tuproyecto.web.app/app-ads.txt`

#### C. Crear un Sitio Web Simple (5 minutos)

1. **Registra un dominio barato** (opcional, ~$10/año):
   - Namecheap, Google Domains, etc.
   - O usa un subdominio gratuito

2. **Usa un hosting gratuito**:
   - **Netlify** (gratis): Arrastra el archivo a netlify.com
   - **Vercel** (gratis): Conecta con GitHub y despliega
   - **GitHub Pages** (ver opción A arriba)

### Opción 3: Usar el Dominio de Google Play (No Recomendado)

Para apps de Google Play, teóricamente podrías usar el dominio `play.google.com`, pero:
- ⚠️ No es práctico (no puedes subir archivos ahí)
- ❌ No es recomendado por Google
- ✅ Mejor opción: Crear un sitio simple

## ⚠️ IMPORTANTE

1. **El dominio debe coincidir exactamente** con el que está registrado en:
   - Google Play Console (en la información de contacto)
   - AdMob (en la configuración de la app)

2. **Espera 24 horas** después de publicar para que AdMob verifique el archivo

3. **Verifica que el archivo sea accesible públicamente** (sin autenticación)

4. **El archivo debe estar en la raíz del dominio**, no en una subcarpeta

## 📋 Checklist

- [x] Archivo `app-ads.txt` creado con el contenido correcto
- [ ] Archivo publicado en un sitio web (dominio raíz)
- [ ] Archivo accesible públicamente (verificar en navegador)
- [ ] Dominio registrado en AdMob/Google Play Console
- [ ] Esperar 24 horas para verificación
- [ ] Verificar estado en consola de AdMob

## 🔗 Enlaces Útiles

- [Especificación app-ads.txt de IAB Tech Lab](https://iabtechlab.com/ads-txt/)
- [Documentación de Google AdMob sobre app-ads.txt](https://support.google.com/admob/answer/9363764)
- [Verificador de app-ads.txt](https://adstxt.guru/)

---

**Nota**: Si no tienes un sitio web todavía, la opción más rápida es usar **GitHub Pages** (si tienes el código en GitHub) o crear un sitio simple en **Netlify** o **Vercel** (gratis y muy fácil).
