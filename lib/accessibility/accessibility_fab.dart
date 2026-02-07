import 'package:flutter/material.dart';
import 'accessibility_state.dart';

class AccessibilityFAB extends StatefulWidget {
  const AccessibilityFAB({super.key});

  @override
  State<AccessibilityFAB> createState() => _AccessibilityFABState();
}

class _AccessibilityFABState extends State<AccessibilityFAB> {
  bool open = false;

  String _t(String en, String fr) {
    return AccessibilityState.language.value == 'fr' ? fr : en;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 90,
          right: 20,
          child: FloatingActionButton(
            heroTag: 'a11y',
            onPressed: () => setState(() => open = !open),
            child: const Text('🅰️', style: TextStyle(fontSize: 22)),
          ),
        ),

        if (open)
          Positioned(
            bottom: 160,
            right: 20,
            child: Material(
              elevation: 12,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 260,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _option('👁️', _t('Contrast', 'Contraste'), () {
                      AccessibilityState.cycle(AccessibilityState.contrast, 3);
                    }),
                    _option('📝', _t('Text Size', 'Taille du texte'), () {
                      AccessibilityState.cycle(AccessibilityState.textSize, 3);
                    }),
                    _option('↔️', _t('Spacing', 'Espacement'), () {
                      AccessibilityState.cycle(AccessibilityState.spacing, 3);
                    }),
                    _option(
                      AccessibilityState.language.value == 'fr'
                          ? '🇫🇷'
                          : '🇬🇧',
                      _t('English', 'Français'),
                      () {
                        AccessibilityState.toggleLanguage();
                        setState(() {});
                      },
                    ),
                    const Divider(),
                    _option('⟳', _t('Reset', 'Réinitialiser'), () {
                      AccessibilityState.reset();
                      setState(() => open = false);
                    }),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _option(String icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 20)),
      title: Text(label),
      onTap: onTap,
    );
  }
}
