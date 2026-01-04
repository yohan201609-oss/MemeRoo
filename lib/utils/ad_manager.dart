import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  // IDs de Prueba (comentados - usar solo para desarrollo local)
  // static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  // static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  // static const String _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  // IDs de PRODUCCIÓN (siempre activos)
  static const String _prodBannerAdUnitId = 'ca-app-pub-2612958934827252/7589067516';
  static const String _prodInterstitialAdUnitId = 'ca-app-pub-2612958934827252/5922786140';
  static const String _prodRewardedAdUnitId = 'ca-app-pub-2612958934827252/6876775164';

  // Usar siempre IDs de producción
  static String get bannerAdUnitId => _prodBannerAdUnitId;
  
  static String get interstitialAdUnitId => _prodInterstitialAdUnitId;
  
  static String get rewardedAdUnitId => _prodRewardedAdUnitId;

  // Anuncios actuales
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isBannerLoaded = false;
  bool _isInterstitialLoaded = false;
  bool _isRewardedLoaded = false;

  bool get isBannerLoaded => _isBannerLoaded;
  bool get isInterstitialLoaded => _isInterstitialLoaded;
  bool get isRewardedLoaded => _isRewardedLoaded;

  BannerAd? get bannerAd => _bannerAd;

  // Inicializar AdMob
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    
    // Configuración para apps de niños (COPPA)
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
        maxAdContentRating: MaxAdContentRating.g,
      ),
    );
  }

  // ===== BANNER AD =====
  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerLoaded = true;
          if (kDebugMode) {
            print('✅ Banner Ad cargado');
          }
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerLoaded = false;
          if (kDebugMode) {
            print('❌ Error cargando Banner: $error');
          }
          ad.dispose();
        },
      ),
    );
    
    _bannerAd?.load();
  }

  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerLoaded = false;
  }

  // ===== INTERSTITIAL AD =====
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          if (kDebugMode) {
            print('✅ Interstitial Ad cargado');
          }

          // Listener para cuando se cierre
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialLoaded = false;
              // Cargar el siguiente
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              if (kDebugMode) {
                print('❌ Error mostrando Interstitial: $error');
              }
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialLoaded = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('❌ Error cargando Interstitial: $error');
          }
          _isInterstitialLoaded = false;
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_isInterstitialLoaded && _interstitialAd != null) {
      _interstitialAd?.show();
    } else {
      if (kDebugMode) {
        print('⚠️ Interstitial no está listo');
      }
      loadInterstitialAd(); // Intentar cargar
    }
  }

  // ===== REWARDED AD =====
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoaded = true;
          if (kDebugMode) {
            print('✅ Rewarded Ad cargado');
          }

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              _isRewardedLoaded = false;
              loadRewardedAd(); // Cargar el siguiente
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              if (kDebugMode) {
                print('❌ Error mostrando Rewarded: $error');
              }
              ad.dispose();
              _rewardedAd = null;
              _isRewardedLoaded = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('❌ Error cargando Rewarded: $error');
          }
          _isRewardedLoaded = false;
        },
      ),
    );
  }

  void showRewardedAd({required Function() onUserEarnedReward}) {
    if (_isRewardedLoaded && _rewardedAd != null) {
      _rewardedAd?.show(
        onUserEarnedReward: (ad, reward) {
          if (kDebugMode) {
            print('🎁 Usuario ganó recompensa: ${reward.amount} ${reward.type}');
          }
          onUserEarnedReward();
        },
      );
    } else {
      if (kDebugMode) {
        print('⚠️ Rewarded Ad no está listo');
      }
      loadRewardedAd();
    }
  }

  // Limpiar todo
  void dispose() {
    disposeBannerAd();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
