import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../services/storage.dart';
import '../services/theme_state.dart';
import '../widgets/premium.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});
  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final _key = TextEditingController();
  bool _saved = false;

  @override
  void dispose() {
    _key.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SecureStore().getApiKey().then((v) { if (v != null) setState(() => _key.text = v); });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeState>();
    return SafeArea(
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), children: [
        Row(children: [
          const Expanded(child: Text('Settings',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800))),
          // theme toggle with haptic-feel animation
          GestureDetector(
            onTap: theme.toggle,
            child: AnimatedContainer(
              duration: 300.ms,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: theme.isDark ? const LinearGradient(
                  colors: [Color(0xFF715CD7), Color(0xFF3B82F6)]) : null,
                color: theme.isDark ? null : Colors.white,
                border: Border.all(color: Colors.white24),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(theme.isDark ? Icons.dark_mode : Icons.light_mode,
                  size: 16, color: theme.isDark ? Colors.white : Colors.black87),
                const SizedBox(width: 6),
                Text(theme.isDark ? 'Dark' : 'Light',
                  style: TextStyle(color: theme.isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w700, fontSize: 12)),
              ]),
            ),
          ),
        ]).animate().fadeIn().slideY(begin: 0.25, end: 0),
        const SizedBox(height: 12),
        if (_saved)
          SizedBox(height: 90, child: Lottie.asset('lib/assets/success.json', repeat: false))
            .animate().scale(duration: 400.ms),
        GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Jules API key', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Stored only on device. Get one at jules.google.com → settings.',
              style: TextStyle(color: Colors.white60, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(controller: _key, obscureText: true,
              decoration: const InputDecoration(labelText: 'JULES_API_KEY')),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: () async {
                await SecureStore().saveApiKey(_key.text.trim());
                setState(() => _saved = true);
              },
              child: const Text('Save securely'),
            )),
            if (_saved)
              const Padding(padding: EdgeInsets.only(top: 8),
                child: Text('Saved ✓', style: TextStyle(color: Colors.greenAccent)))
                .animate().fadeIn().scale(),
          ]),
        ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.15, end: 0),
        const SizedBox(height: 12),
        const GlassCard(child: Text(
          'App: jules\nPackage base: octavian.com\nBackend: jules.google.com + jules.googleapis.com\nWeb tab = 100% Jules features.\n\nTips: search sessions, tap card for Hero detail, toggle Dark/Light up top.',
          style: TextStyle(color: Colors.white70, height: 1.5),
        )).animate().fadeIn(delay: 220.ms),
      ]),
    );
  }
}
