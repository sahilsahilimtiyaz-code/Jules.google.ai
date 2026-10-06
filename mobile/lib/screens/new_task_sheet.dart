import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/jules_api.dart';
import '../services/storage.dart';
import '../services/agent_state.dart';
import '../services/prompt_library.dart';
import '../src/core/tokens.dart';
import '../src/core/validators.dart';
import '../widgets/conical_glow.dart';

class NewTaskSheet extends StatefulWidget {
  const NewTaskSheet({super.key});
  @override
  State<NewTaskSheet> createState() => _NewTaskSheetState();
}

class _NewTaskSheetState extends State<NewTaskSheet> {
  final _repo = TextEditingController();
  final _branch = TextEditingController(text: 'main');
  final _prompt = TextEditingController();
  final _extra = TextEditingController();
  String _preset = 'architect';
  bool _deep = true;
  bool _history = false;
  bool _strict = true;
  bool _planApproval = false;
  String _mode = 'AUTO_CREATE_PR';
  bool _busy = false;
  bool _success = false;
  bool _preview = false;
  String? _msg;

  @override
  void dispose() {
    _repo.dispose();
    _branch.dispose();
    _prompt.dispose();
    _extra.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SecureStore().getRepo().then((v) { if (!mounted) return; if (v != null) _repo.text = v; });
  }

  String get _powerPrompt => buildPowerPrompt(
    presetId: _preset, task: _prompt.text.trim(),
    repo: _repo.text.trim().isEmpty ? 'OWNER/REPO' : _repo.text.trim(),
    branch: _branch.text.trim().isEmpty ? 'main' : _branch.text.trim(),
    deepContext: _deep, includeHistory: _history, strict: _strict,
  );

  Future<void> _submit() async {
    final agent = context.read<AgentState>();
    final key0 = await SecureStore().getApiKey();
    if (key0 == null || !Validators.looksLikeApiKey(key0)) {
      setState(() => _msg = 'Set a valid API key in Settings first');
      return;
    }
    if (!Validators.isRepoFullName(_repo.text)) {
      setState(() => _msg = 'Repo must be owner/name (e.g. google-labs-code/jules-action)');
      return;
    }
    if (!Validators.isPromptValid(_prompt.text, max: AppConstants.maxPromptChars)) {
      setState(() => _msg = 'Task required (max ${AppConstants.maxPromptChars} chars)');
      return;
    }
    if (!mounted) return;
    setState(() { _busy = true; _msg = null; _success = false; });
    agent.setWorking(true);
    try {
      final key = key0.trim();
      await SecureStore().saveRepo(_repo.text.trim());
      final res = await JulesApi(key).createSession(
        prompt: _powerPrompt,
        repoFullName: _repo.text.trim(),
        startingBranch: _branch.text.trim().isEmpty ? 'main' : _branch.text.trim(),
        requirePlanApproval: _planApproval,
        automationMode: _mode,
        extraContext: _extra.text,
      );
      if (!mounted) return;
      setState(() { _success = true; _msg = 'Sent ✓ ${res['name'] ?? ''} — glow ON while coding'; });
    } catch (e) {
      agent.setWorking(false);
      if (!mounted) return;
      setState(() => _msg = 'Error: $e');
    } finally {
      if (!mounted) return;
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final working = context.watch<AgentState>().isWorking;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: const Color(0xFF715CD7).withValues(alpha: 0.4)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: ConicalGlowBorder(
          active: _busy || working, radius: 24,
          child: Container(
            padding: const EdgeInsets.all(16), color: const Color(0xFF0A0A0A),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.white24))),
              const SizedBox(height: 10),
              Row(children: [
                const Expanded(child: Text('New powerful task',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
                if (_busy || working)
                  const Text('● AI working…', style: TextStyle(color: Colors.greenAccent, fontSize: 12))
                    .animate(onPlay: (c) => c.repeat()).fadeIn(duration: 500.ms).then().fadeOut(duration: 500.ms),
              ]),
              const SizedBox(height: 10),
              // preset chips
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final p in kPresets)
                  ChoiceChip(
                    label: Text('${p.icon} ${p.label}'),
                    selected: _preset == p.id,
                    onSelected: (_) => setState(() => _preset = p.id),
                  ),
              ]),
              const SizedBox(height: 6),
              Text(kPresets.firstWhere((e) => e.id == _preset).description,
                style: const TextStyle(color: Colors.white60, fontSize: 12)),
              const SizedBox(height: 10),
              TextField(controller: _repo, decoration: const InputDecoration(labelText: 'Repo owner/name')),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: TextField(controller: _branch, decoration: const InputDecoration(labelText: 'Branch'))),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _mode, decoration: const InputDecoration(labelText: 'Mode'),
                    items: const [
                      DropdownMenuItem(value: 'AUTO_CREATE_PR', child: Text('Auto PR')),
                      DropdownMenuItem(value: 'ASK_FOR_APPROVAL', child: Text('Ask approval')),
                    ],
                    onChanged: (v) => setState(() => _mode = v ?? _mode),
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              TextField(controller: _prompt, maxLines: 4,
                decoration: InputDecoration(labelText: 'Task (${_prompt.text.length} chars)',
                  hintText: 'Fix login crash on null token, add regression test…'),
                onChanged: (_) => setState(() {})),
              const SizedBox(height: 8),
              // power toggles
              Wrap(spacing: 6, children: [
                FilterChip(label: const Text('Deep'), selected: _deep, onSelected: (v) => setState(() => _deep = v)),
                FilterChip(label: const Text('History'), selected: _history, onSelected: (v) => setState(() => _history = v)),
                FilterChip(label: const Text('Strict'), selected: _strict, onSelected: (v) => setState(() => _strict = v)),
                FilterChip(label: const Text('Plan OK'), selected: _planApproval, onSelected: (v) => setState(() => _planApproval = v)),
              ]),
              const SizedBox(height: 8),
              TextField(controller: _extra, maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Extra context (optional)',
                  hintText: 'Paste stack trace, git show, failing test…')),
              const SizedBox(height: 8),
              Row(children: [
                TextButton(
                  onPressed: () => setState(() => _preview = !_preview),
                  child: Text(_preview ? 'Hide power prompt' : 'Preview power prompt (${_powerPrompt.length})'),
                ),
              ]),
              if (_preview)
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white10)),
                  child: Text(_powerPrompt, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                ).animate().fadeIn().slideY(begin: 0.1, end: 0),
              const SizedBox(height: 12),
              if (_success)
                Center(child: Container(width: 68, height: 68,
                  decoration: const BoxDecoration(shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Color(0xFF715CD7), Color(0xFF3B82F6)])),
                  child: const Icon(Icons.check, size: 36, color: Colors.white),
                ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack)),
              SizedBox(width: double.infinity, child: FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_success ? 'Send another powerful task' : 'Send powerful task to Jules'),
              )),
              if (_msg != null)
                Padding(padding: const EdgeInsets.only(top: 10), child: Text(_msg!)).animate().fadeIn(),
            ]),
          ),
        ),
      ),
    );
  }
}
