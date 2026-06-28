import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:nexora/core/theme/commanMethods.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              setState(() {
                isLoading = true;
              });
            },
            onPageFinished: (String url) {
              setState(() {
                isLoading = false;
              });
            },
          ),
        )
        ..loadRequest(
          Uri.parse('https://openai.com/en-GB/policies/row-privacy-policy/'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = getThemeBaseColors(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: colors.background,
        surfaceTintColor: colors.background,
      ),
      backgroundColor: colors.background,
      body: kIsWeb
          ? Center(
              child: ElevatedButton(
                onPressed: () => launchUrl(
                  Uri.parse(
                    'https://openai.com/en-GB/policies/row-privacy-policy/',
                  ),
                ),
                child: const Text('Open Privacy Policy'),
              ),
            )
          : Stack(
              children: [
                WebViewWidget(controller: controller),
                if (isLoading) const Center(child: CircularProgressIndicator()),
              ],
            ),
    );
  }
}
