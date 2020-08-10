import 'package:flutter/material.dart';

class DemoLocalization {
  final Locale locale;

  DemoLocalization(this.locale);
  
  static DemoLocalization of(BuildContext context) {
    return Localizations.of<DemoLocalization>(context, DemoLocalization);
  }
}