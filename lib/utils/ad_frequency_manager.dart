/// Gestor de frecuencia de anuncios para evitar mostrar demasiados anuncios
/// y mejorar la experiencia del usuario, especialmente importante para apps infantiles
class AdFrequencyManager {
  static DateTime? _lastInterstitialShown;
  static const Duration _minTimeBetweenAds = Duration(minutes: 5); // Más tiempo entre anuncios
  static int _interstitialCountToday = 0;
  static const int _maxInterstitialsPerDay = 10;
  static DateTime? _lastResetDate;

  /// Verifica si se puede mostrar un anuncio intersticial
  /// Considera el tiempo desde el último anuncio y el límite diario
  static bool canShowInterstitial() {
    // Resetear contador si es un nuevo día
    _resetIfNewDay();

    // Verificar límite diario
    if (_interstitialCountToday >= _maxInterstitialsPerDay) {
      return false;
    }

    // Verificar tiempo mínimo entre anuncios
    if (_lastInterstitialShown == null) {
      return true;
    }

    final timeSince = DateTime.now().difference(_lastInterstitialShown!);
    return timeSince >= _minTimeBetweenAds;
  }

  /// Marca que se mostró un anuncio intersticial
  static void markInterstitialShown() {
    _lastInterstitialShown = DateTime.now();
    _interstitialCountToday++;
  }

  /// Resetea el contador si es un nuevo día
  static void _resetIfNewDay() {
    final now = DateTime.now();
    if (_lastResetDate == null) {
      _lastResetDate = now;
      return;
    }

    // Si es un día diferente, resetear contador
    if (now.year != _lastResetDate!.year ||
        now.month != _lastResetDate!.month ||
        now.day != _lastResetDate!.day) {
      _interstitialCountToday = 0;
      _lastResetDate = now;
    }
  }

  /// Obtiene el tiempo restante hasta que se pueda mostrar el siguiente anuncio
  static Duration? getTimeUntilNextAd() {
    if (_lastInterstitialShown == null) {
      return null;
    }

    final timeSince = DateTime.now().difference(_lastInterstitialShown!);
    if (timeSince >= _minTimeBetweenAds) {
      return null;
    }

    return _minTimeBetweenAds - timeSince;
  }

  /// Obtiene el número de anuncios mostrados hoy
  static int getInterstitialsShownToday() {
    _resetIfNewDay();
    return _interstitialCountToday;
  }

  /// Resetea todos los contadores (útil para testing)
  static void reset() {
    _lastInterstitialShown = null;
    _interstitialCountToday = 0;
    _lastResetDate = null;
  }
}
