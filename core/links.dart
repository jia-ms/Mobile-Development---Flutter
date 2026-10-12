import 'package:url_launcher/url_launcher.dart';


Future<void> OpenUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri==null) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<void> openWhatsApp(String phone, String message) =>
    OpenUrl('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');