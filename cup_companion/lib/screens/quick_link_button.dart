import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class QuickLinkButton extends StatelessWidget {
  final String coffeeShopUrl;

  QuickLinkButton({required this.coffeeShopUrl});

  Future<void> _launchURL() async {
    if (await canLaunchUrl(coffeeShopUrl as Uri)) {
      await canLaunchUrl(coffeeShopUrl as Uri);
    } else {
      throw 'Could not launch $coffeeShopUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.launch),
      onPressed: _launchURL,
    );
  }
}
