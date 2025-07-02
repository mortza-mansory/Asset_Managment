import 'package:flutter/material.dart';

abstract class LocalizationState {
  final Locale locale;
  LocalizationState(this.locale);
}

class LocalizationInitial extends LocalizationState {
  LocalizationInitial() : super(const Locale('en'));
}

class LocalizationLoaded extends LocalizationState {
  LocalizationLoaded(Locale locale) : super(locale);
}