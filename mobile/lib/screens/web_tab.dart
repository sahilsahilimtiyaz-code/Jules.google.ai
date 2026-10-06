import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebTab extends StatefulWidget {
  const WebTab({super.key});
  @override
  State<WebTab> createState() => _WebTabState();
}

class _WebTabState extends State<WebTab> {
  static const home = 'https://jules.google.com';
  late final WebViewController _c;
  double _progress = 0;
  bool _canBack = false;
  bool _canFwd = false;

  @override
  void initState() {
    super.initState();
    _c = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (p) { if (mounted) setState(() => _progress = p / 100); },
        onPageFinished: (_) async {
          if (!mounted) return;
          setState(() => _progress = 1);
          final b = await _c.canGoBack();
          if (!mounted) return;
          setState(() => _canBack = b);
          final f = await _c.canGoForward();
          if (!mounted) return;
          setState(() => _canFwd = f);
          await _c.runJavaScript("""
            var s=document.createElement('style');
            s.innerHTML=`html,body{padding-bottom:90px!important;background:#000!important}
              button,a,input,textarea{min-height:44px!important;border-radius:14px!important}
              input,textarea{font-size:16px!important}`;
            document.head.appendChild(s);
          """);
        },
      ))
      ..loadRequest(Uri.parse(home));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 110),
        child: Column(children: [
          // toolbar: nav + status + actions
          Row(children: [
            _btn(Icons.arrow_back, _canBack, () async {
              await _c.goBack();
              if (!mounted) return;
              setState(() {
                _canBack = false;
              });
            }),
            _btn(Icons.arrow_forward, _canFwd, () => _c.goForward()),
            _btn(Icons.refresh, true, () => _c.reload()),
            const SizedBox(width: 6),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progress >= 1 ? 0 : _progress,
                  minHeight: 3,
                  backgroundColor:
                      Theme.of(context).dividerColor.withValues(alpha: 0.2),
                  valueColor:
                      const AlwaysStoppedAnimation(Color(0xFF715CD7)),
                ),
              ),
            ),
            const SizedBox(width: 6),
            _btn(Icons.open_in_new, true, () => launchUrl(
                Uri.parse(home), mode: LaunchMode.externalApplication)),
          ]).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: Theme.of(context)
                        .dividerColor
                        .withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 24)
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: WebViewWidget(controller: _c),
            ).animate().fadeIn(duration: 600.ms).scale(
                begin: const Offset(0.98, 0.98),
                end: const Offset(1, 1)),
          ),
        ]),
      ),
    );
  }

  Widget _btn(IconData icon, bool enabled, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 20),
      color: enabled
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).disabledColor,
      onPressed: enabled ? onTap : null,
      visualDensity: VisualDensity.compact,
    );
  }
}
