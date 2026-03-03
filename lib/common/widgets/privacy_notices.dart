import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyView extends StatefulWidget {
  const PrivacyPolicyView({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyView> createState() => _PrivacyPolicyViewState();
}

class _PrivacyPolicyViewState extends State<PrivacyPolicyView> {
  WebViewController? controller; // Cambiar a nullable

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('mailto:') ||
                request.url.startsWith('tel:') ||
                request.url.startsWith('sms:')) {
              _launchUrl(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://app.setlistoficial.com/'));
  }
 Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (mounted) {
       
      }
    } catch (e) {
      if (mounted) {
        

      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar(
            backgroundColor: const Color(0xFF16222e),
            elevation: 0,
          ),
        ),
        body: controller != null 
          ? WebViewWidget(controller: controller!)
          : const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            height: 20,
            color: const Color(0xFF16222e),
          ),
        ),
      ),
    );
  }
}