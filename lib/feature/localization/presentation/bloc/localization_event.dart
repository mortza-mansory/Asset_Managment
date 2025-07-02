import 'package:flutter/material.dart';

abstract class LocalizationEvent {}

class GetInitialLocale extends LocalizationEvent {}

class ChangeLocale extends LocalizationEvent {
  final Locale locale;
  ChangeLocale(this.locale);
}