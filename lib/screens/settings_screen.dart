import 'package:flutter/material.dart';
import '../utils/audio_manager.dart';
import '../utils/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _audio = AudioManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 28),
                      onPressed: () {
                        AudioManager().playTap();
                        Navigator.pop(context);
                      },
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Configuración',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSettingCard(
                      title: 'Audio',
                      icon: Icons.volume_up,
                      children: [
                        _buildSwitchTile(
                          title: 'Música',
                          subtitle: 'Música de fondo',
                          value: _audio.isMusicEnabled,
                          onChanged: (value) {
                            setState(() {
                              _audio.toggleMusic();
                            });
                          },
                        ),
                        if (_audio.isMusicEnabled)
                          _buildSliderTile(
                            title: 'Volumen de Música',
                            value: _audio.musicVolume,
                            onChanged: (value) {
                              setState(() {
                                _audio.setMusicVolume(value);
                              });
                            },
                          ),
                        const Divider(),
                        _buildSwitchTile(
                          title: 'Efectos de Sonido',
                          subtitle: 'Sonidos del juego',
                          value: _audio.isSfxEnabled,
                          onChanged: (value) {
                            setState(() {
                              _audio.toggleSfx();
                            });
                          },
                        ),
                        if (_audio.isSfxEnabled)
                          _buildSliderTile(
                            title: 'Volumen de Efectos',
                            value: _audio.sfxVolume,
                            onChanged: (value) {
                              setState(() {
                                _audio.setSfxVolume(value);
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSettingCard(
                      title: 'Acerca de',
                      icon: Icons.info_outline,
                      children: [
                        const ListTile(
                          title: Text('Versión'),
                          subtitle: Text('1.0.0+1'),
                        ),
                        const ListTile(
                          title: Text('Aplicación'),
                          subtitle: Text('MemeRoo - Juegos de Animales'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blue,
    );
  }

  Widget _buildSliderTile({
    required String title,
    required double value,
    required Function(double) onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Slider(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
      trailing: Text(
        '${(value * 100).toInt()}%',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }
}

