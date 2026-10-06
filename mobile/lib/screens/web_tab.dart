import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebTab extends StatefulWidget {
  const WebTab({super.key});
  @override
  State<WebTab> createState() => _WebTabState();
}

class _WebTabState extends State<WebTab> {
  late final WebViewController _c;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _c = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (p) => setState(() => _progress = p / 100),
        onPageFinished: (_) async {
          await _c.runJavaScript("""
            var s=document.createElement('style');
            s.innerHTML=`html,body{padding-bottom:90px!important;background:#000!important}
              button,a,input,textarea{min-height:44px!important;border-radius:14px!important}
              input,textarea{font-size:16px!important}`;
            document.head.appendChild(s);
          """);
        },
      ))
      ..loadRequest(Uri.parse('https://jules.google.com'));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 110),
        child: Column(children: [
          // gradient progress
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progress >= 1 ? 0 : _progress,
              minHeight: 3,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF715CD7)),
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 24)],
              ),
              clipBehavior: Clip.antiAlias,
              child: WebViewWidget(controller: _c),
            ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1)),
          ),
        ]),
      ),
    );
  }
}
