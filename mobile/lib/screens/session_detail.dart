import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/conical_glow.dart';

class SessionDetail extends StatelessWidget {
  final Map session;
  final int index;
  final bool working;
  const SessionDetail({super.key, required this.session, required this.index, required this.working});

  String _str(String k) => (session[k] ?? '').toString();

  @override
  Widget build(BuildContext context) {
    final title = (session['title'] ?? session['name'] ?? 'Session').toString();
    final state = (_str('state').isNotEmpty ? _str('state') : _str('status')).ifEmpty('unknown');
    final branch = _str('branch').ifEmpty(_str('startingBranch').ifEmpty('main'));
    final repo = _str('repo').ifEmpty(_str('repository').ifEmpty('—'));
    final updated = _str('updateTime').ifEmpty(_str('updatedTime').ifEmpty(''));
    final pr = _str('prUrl').ifEmpty(_str('pullRequestUrl').ifEmpty(_str('url')));

    return Scaffold(
      appBar: AppBar(title: const Text('Session')),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), children: [
        ConicalGlowBorder(
          active: working, radius: 24,
          child: Container(
            padding: const EdgeInsets.all(18), color: const Color(0xFF0A0A0A),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Hero(tag: 'sess-$index', child: Container(width: 56, height: 56,
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppTheme.gradient),
                child: Icon(working ? Icons.code : Icons.auto_awesome, color: Colors.white, size: 28))),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))
                .animate().fadeIn().slideY(begin: 0.15, end: 0),
              const SizedBox(height: 6),
              _pill(working ? '● WORKING' : state.toUpperCase(), working),
              const SizedBox(height: 12),
              _row('Repo', repo), _row('Branch', branch),
              if (updated.isNotEmpty) _row('Updated', updated),
              if (_str('prompt').isNotEmpty) ...[
                const SizedBox(height: 10),
                const Text('Prompt', style: TextStyle(color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 4),
                Text(_str('prompt'), maxLines: 8, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(height: 1.5)),
              ],
            ]),
          ),
        ),
        const SizedBox(height: 14),
        Row(children: [
          if (pr.isNotEmpty && pr.startsWith('http'))
            Expanded(child: FilledButton.icon(
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Open PR / link'),
              onPressed: () => launchUrl(Uri.parse(pr), mode: LaunchMode.externalApplication),
            )),
          if (pr.isNotEmpty && pr.startsWith('http')) const SizedBox(width: 10),
          Expanded(child: OutlinedButton.icon(
            icon: const Icon(Icons.share, size: 18),
            label: const Text('Share'),
            onPressed: () => Share.share('$title\n$state\n$pr\n${session.toString().substring(0, session.toString().length.clamp(0, 500))}'),
          )),
        ]).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15, end: 0),
        const SizedBox(height: 12),
        const Text('Raw (debug)', style: TextStyle(color: Colors.white38, fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white10)),
          child: Text(session.toString(), style: const TextStyle(fontSize: 11, color: Colors.white60)),
        ),
      ]),
    );
  }

  Widget _pill(String t, bool working) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
        color: working ? Colors.green.withOpacity(0.15) : Colors.white10,
        border: Border.all(color: working ? Colors.greenAccent : Colors.white24)),
      child: Text(t, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
        color: working ? Colors.greenAccent : Colors.white70)),
    );
  }

  Widget _row(String k, String v) {
    return Padding(padding: const EdgeInsets.only(top: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 74, child: Text(k, style: const TextStyle(color: Colors.white38, fontSize: 12))),
        Expanded(child: Text(v.isEmpty ? '—' : v, style: const TextStyle(fontSize: 13))),
      ]));
  }
}

extension _IfEmpty on String {
  String ifEmpty(String alt) => isEmpty ? alt : this;
}
