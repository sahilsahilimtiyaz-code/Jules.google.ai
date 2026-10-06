import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import '../services/jules_api.dart';
import '../services/storage.dart';
import '../services/agent_state.dart';
import '../widgets/premium.dart';
import '../widgets/conical_glow.dart';
import 'session_detail.dart';

class SessionsTab extends StatefulWidget {
  const SessionsTab({super.key});
  @override
  State<SessionsTab> createState() => _SessionsTabState();
}

class _SessionsTabState extends State<SessionsTab> {
  List<dynamic>? _items;
  String? _error;
  bool _loading = true;
  String _query = '';
  String _filter = 'all'; // all | working | done

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final agent = context.read<AgentState>();
    setState(() { _loading = true; _error = null; });
    try {
      final key = await SecureStore().getApiKey();
      if (key == null || key.isEmpty) throw Exception('Set API key in Settings first');
      final list = await JulesApi(key).listSessions();
      if (!mounted) return;
      setState(() { _items = list; _loading = false; });
      agent.syncFromSessions(list);
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  bool _isWorking(Map m) {
    final st = (m['state'] ?? m['status'] ?? '').toString().toLowerCase();
    return st.contains('run') || st.contains('work') || st.contains('progress') ||
      st.contains('pending') || st.contains('active') || st.contains('creating') || st.contains('queued');
  }

  List<Map> get _visible {
    final all = (_items ?? []).whereType<Map>().toList();
    return all.where((s) {
      final title = (s is Map ? (s['title'] ?? s['name'] ?? '') : '').toString().toLowerCase();
      if (_query.isNotEmpty && !title.contains(_query.toLowerCase())) return false;
      if (_filter == 'working' && !(s is Map && _isWorking(s))) return false;
      if (_filter == 'done' && (s is Map && _isWorking(s))) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final vis = _visible;
    return SafeArea(
      child: RefreshIndicator(
        color: const Color(0xFF715CD7), onRefresh: _load,
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), children: [
          const Text('Sessions', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800))
            .animate().fadeIn(duration: 500.ms).slideY(begin: 0.25, end: 0),
          const Text('Tap a card for details • glow = AI coding',
            style: TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 12),
          // search
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search, size: 20),
              hintText: 'Search sessions…', isDense: true),
            onChanged: (v) => setState(() => _query = v),
          ).animate().fadeIn(delay: 80.ms),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            for (final f in ['all', 'working', 'done'])
              ChoiceChip(label: Text(f[0].toUpperCase() + f.substring(1)),
                selected: _filter == f, onSelected: (_) {
                  HapticFeedback.selectionClick();
                  setState(() => _filter = f);
                }),
          ]),
          const SizedBox(height: 12),
          if (_loading)
            ...List.generate(3, (i) => Shimmer.fromColors(
              baseColor: Colors.white10, highlightColor: Colors.white24,
              child: Container(height: 96, margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), color: Colors.white10)),
            )),
          if (_error != null)
            GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.error_outline, color: Colors.redAccent),
                SizedBox(width: 8), Text('Couldn’t load sessions',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 6),
              Text(_error!, style: const TextStyle(color: Colors.white60, fontSize: 12)),
              const SizedBox(height: 10),
              FilledButton.icon(icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                onPressed: () { HapticFeedback.mediumImpact(); _load(); }),
            ])).animate().shake(),
          if (!_loading && _error == null)
            for (var i = 0; i < vis.length; i++)
              Builder(builder: (_) {
                final s = vis[i];
                final title = (s['title'] ?? s['name'] ?? 'Session').toString();
                final sub = (s['state'] ?? s['status'] ?? '').toString();
                final working = _isWorking(s);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          transitionDuration: 450.ms,
                          pageBuilder: (_, __, ___) =>
                            SessionDetail(session: s, index: i, working: working),
                          transitionsBuilder: (_, anim, __, child) =>
                            FadeTransition(opacity: anim,
                              child: SlideTransition(
                                position: anim.drive(Tween(begin: const Offset(0.12, 0), end: Offset.zero)),
                                child: child)),
                        ),
                      );
                    },
                    child: ConicalGlowBorder(
                      active: working, radius: 22,
                      child: Container(
                        padding: const EdgeInsets.all(6), color: const Color(0xFF0A0A0A),
                        child: ListTile(
                          leading: Hero(tag: 'sess-$i', child: Container(width: 44, height: 44,
                            decoration: const BoxDecoration(shape: BoxShape.circle,
                              gradient: LinearGradient(colors: [Color(0xFF715CD7), Color(0xFF3B82F6)])),
                            child: Icon(working ? Icons.code : Icons.auto_awesome, color: Colors.white))),
                          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(working ? '$sub ● coding…' : sub,
                            style: TextStyle(color: working ? Colors.greenAccent : Colors.white60)),
                          trailing: const Icon(Icons.chevron_right, color: Color(0xFF715CD7)),
                        ),
                      ),
                    ).animate().fadeIn(delay: (i*70).ms, duration: 400.ms).slideY(begin: 0.15, end: 0),
                  ),
                );
              }),
          if (!_loading && _error == null && vis.isEmpty)
            GlassCard(child: Column(children: [
              const Icon(Icons.inbox_outlined, size: 40, color: Colors.white38),
              const SizedBox(height: 8),
              Text(_items == null || _items!.isEmpty
                ? 'No sessions yet. Tap + to create one — glow turns on while AI works.'
                : 'No matches for “$_query”. Try clearing search or filter.'),
              const SizedBox(height: 10),
              OutlinedButton.icon(icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'), onPressed: _load),
            ])).animate().fadeIn().scale(),
        ]),
      ),
    );
  }
}
