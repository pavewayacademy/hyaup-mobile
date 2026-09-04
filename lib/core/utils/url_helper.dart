import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlHelper {
  /// Safely opens external job application links with fallbacks
  static Future<bool> openExternalUrl(
    BuildContext context,
    String? urlString, {
    VoidCallback? onRedirectTracked,
  }) async {
    if (urlString == null || urlString.trim().isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No external application URL available.")),
        );
      }
      return false;
    }

    try {
      final Uri uri = Uri.parse(urlString.trim());
      
      // Notify tracking hook if provided
      onRedirectTracked?.call();

      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Could not open link: $urlString")),
          );
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid URL: $e")),
        );
      }
      return false;
    }
  }
}
