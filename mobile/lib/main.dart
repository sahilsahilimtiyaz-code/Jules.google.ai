import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'widgets/premium.dart';
import 'widgets/conical_glow.dart';
import 'services/agent_state.dart';
import 'services/theme_state.dart';
import 'screens/web_tab.dart';
import 'screens/sessions_tab.dart';
import 'screens/new_task_sheet.dart';
import 'screens/settings_tab.dart';

void main() => runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AgentState()),
      ChangeNotifierProvider(create: (_) => ThemeState()),
    ],
    child: const JulesApp(),
  ),
);

class JulesApp extends StatelessWidget {
  const JulesApp({super.key});
  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeState>().isDark;
    return MaterialApp(
      title: 'jules',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: const SplashGate(),
    );
  }
}

class SplashGate extends StatefulWidget {
  const SplashGate({super.key});
  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  @override
  void initState() {
    super.initState();
    Future.delayed(2100.ms, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: 700.ms,
          pageBuilder: (_, __, ___) => const HomeShell(),
          transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: ScaleTransition(scale: anim.drive(Tween(begin: 0.96, end: 1.0)), child: child)),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeState>().isDark;
    return Scaffold(
      body: AuroraBgLightAware(
        dark: dark,
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle, gradient: AppTheme.gradient,
                boxShadow: [BoxShadow(color: AppTheme.accent.withValues(alpha: 0.6), blurRadius: 60, spreadRadius: 10)],
              ),
              child: const Icon(Icons.auto_awesome, size: 54, color: Colors.white),
            )
            .animate().scale(duration: 800.ms, curve: Curves.easeOutBack)
            .then().shimmer(duration: 1200.ms, color: Colors.white54),
            const SizedBox(height: 22),
            const Text('jules', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800, letterSpacing: 1.2))
              .animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.3, end: 0),
            const SizedBox(height: 8),
            const Text('Same Jules. Phone magic.', style: TextStyle(color: Colors.white60))
              .animate().fadeIn(delay: 600.ms),
          ]),
        ),
      ),
    );
  }
}

class AuroraBgLightAware extends StatelessWidget {
  final bool dark;
  final Widget child;
  const AuroraBgLightAware({super.key, required this.dark, required this.child});
  @override
  Widget build(BuildContext context) {
    if (!dark) {
      return Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradientLight),
        child: child,
      );
    }
    return AuroraBg(child: child);
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final _controller = PageController();

  void _go(int i) {
    HapticFeedback.selectionClick();
    setState(() => _index = i);
    _controller.animateToPage(i, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  void _openNewTask() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent, barrierColor: Colors.black54,
      builder: (_) => const NewTaskSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeState>().isDark;
    return Scaffold(
      extendBody: true,
      body: AuroraBgLightAware(
        dark: dark,
        child: PageView(
          controller: _controller,
          onPageChanged: (i) => setState(() => _index = i),
          physics: const BouncingScrollPhysics(),
          children: const [WebTab(), SessionsTab(), ActivityTab(), SettingsTab()],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: _openNewTask,
        child: Container(
          width: 62, height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle, gradient: AppTheme.gradient,
            boxShadow: [BoxShadow(color: AppTheme.accent.withValues(alpha: 0.5), blurRadius: 24)],
          ),
          child: const Icon(Icons.add, size: 30, color: Colors.white),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
         .scale(begin: const Offset(1, 1), end: const Offset(1.06, 1.06), duration: 1800.ms),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        decoration: BoxDecoration(
          color: (dark ? Colors.black : Colors.white).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppTheme.accent.withValues(alpha: 0.35)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BottomAppBar(
            color: Colors.transparent, elevation: 0,
            shape: const CircularNotchedRectangle(), notchMargin: 10,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _tab(Icons.language, 'Web', 0, dark),
              _tab(Icons.auto_awesome, 'Sessions', 1, dark),
              const SizedBox(width: 56),
              _tab(Icons.timeline, 'Activity', 2, dark),
              _tab(Icons.settings, 'Settings', 3, dark),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _tab(IconData icon, String label, int i, bool dark) {
    final active = _index == i;
    final inactive = dark ? Colors.grey : Colors.grey.shade600;
    final activeC = dark ? Colors.white : Colors.black87;
    return InkWell(
      onTap: () => _go(i),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: active ? AppTheme.accent.withValues(alpha: 0.18) : Colors.transparent,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: active ? activeC : inactive, size: 22),
          Text(label, style: TextStyle(fontSize: 11, color: active ? activeC : inactive)),
          AnimatedContainer(
            duration: 300.ms, margin: const EdgeInsets.only(top: 3),
            height: 3, width: active ? 18 : 0,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), gradient: AppTheme.gradient),
          ),
        ]),
      ),
    );
  }
}

class ActivityTab extends StatelessWidget {
  const ActivityTab({super.key});
  @override
  Widget build(BuildContext context) {
    final agent = context.watch<AgentState>();
    final working = agent.isWorking;
    final steps = ['Session created', 'Jules working in cloud VM', 'PR opened for review', 'CI passed'];

    return SafeArea(
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), children: [
        Row(children: [
          const Expanded(child: Text('Activity', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              agent.setWorking(!working);
            },
            child: AnimatedContainer(
              duration: 300.ms,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: working ? Colors.green.withValues(alpha: 0.15) : Colors.white10,
                border: Border.all(color: working ? Colors.greenAccent : Colors.white24),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 8, height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    color: working ? Colors.greenAccent : Colors.grey)),
                const SizedBox(width: 6),
                Text(working ? 'AI WORKING' : 'IDLE',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                    color: working ? Colors.greenAccent : Colors.grey)),
              ]),
            ),
          ),
        ]).animate().fadeIn().slideY(begin: 0.2, end: 0),
        const SizedBox(height: 4),
        Text(working ? 'Conical glow ON — agent coding…' : 'Glow off — tap pill to simulate working',
          style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 14),
        ConicalGlowBorder(
          active: working, radius: 24,
          child: Container(
            padding: const EdgeInsets.all(14), color: const Color(0xFF0A0A0A),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 32, height: 32,
                  decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppTheme.gradient),
                  child: const Icon(Icons.smart_toy, size: 18, color: Colors.white)),
                const SizedBox(width: 10),
                const Expanded(child: Text('Agent chat',
                  style: TextStyle(fontWeight: FontWeight.w700))),
                if (working)
                  const Text('● coding…', style: TextStyle(color: Colors.greenAccent, fontSize: 12))
                    .animate(onPlay: (c) => c.repeat()).fadeIn(duration: 600.ms).then().fadeOut(duration: 600.ms),
              ]),
              const SizedBox(height: 10),
              const TextField(
                maxLines: 3,
                decoration: InputDecoration(hintText: 'Ask Jules… (same backend as web)'),
              ),
            ]),
          ),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.15, end: 0),
        const SizedBox(height: 14),
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ConicalGlowBorder(
              active: working && i == 1, radius: 20,
              child: Container(
                padding: const EdgeInsets.all(14), color: const Color(0xFF0A0A0A),
                child: Row(children: [
                  Container(width: 38, height: 38,
                    decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppTheme.gradient),
                    child: Icon(i == 1 && working ? Icons.code : Icons.check, size: 20, color: Colors.white)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(steps[i])),
                ]),
              ),
            ).animate().fadeIn(delay: (i * 120).ms, duration: 500.ms).slideX(begin: 0.15, end: 0),
          ),
      ]),
    );
  }
}
