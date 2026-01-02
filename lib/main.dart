import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'providers/cascade_provider.dart';
import 'providers/guess_provider.dart';
import 'providers/sequence_provider.dart';
import 'providers/jigsaw_provider.dart';
import 'providers/shadow_provider.dart';
import 'providers/riddle_provider.dart';
import 'providers/dots_provider.dart';
import 'screens/main_menu_screen.dart';
import 'utils/audio_manager.dart';
import 'utils/preferences_cache.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar cache de preferencias
  await PreferencesCache().init();

  // Inicializar audio
  await AudioManager().init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MemoryAnimalsApp());
}

class MemoryAnimalsApp extends StatefulWidget {
  const MemoryAnimalsApp({super.key});

  @override
  State<MemoryAnimalsApp> createState() => _MemoryAnimalsAppState();
}

class _MemoryAnimalsAppState extends State<MemoryAnimalsApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Iniciar música del menú
    AudioManager().playMusic('menu.wav');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pausar/reanudar música cuando la app va al fondo
    if (state == AppLifecycleState.paused) {
      AudioManager().pauseMusic();
    } else if (state == AppLifecycleState.resumed) {
      AudioManager().resumeMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => CascadeProvider()),
        ChangeNotifierProvider(create: (_) => GuessProvider()),
        ChangeNotifierProvider(create: (_) => SequenceProvider()),
        ChangeNotifierProvider(create: (_) => JigsawProvider()),
        ChangeNotifierProvider(create: (_) => ShadowProvider()),
        ChangeNotifierProvider(create: (_) => RiddleProvider()),
        ChangeNotifierProvider(create: (_) => DotsProvider()),
      ],
      child: MaterialApp(
        title: 'MemeRoo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'ComicSans',
        ),
        home: const MainMenuScreen(),
      ),
    );
  }
}
