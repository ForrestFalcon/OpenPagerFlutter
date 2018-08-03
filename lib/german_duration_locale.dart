import 'package:duration/locale.dart';

class GermanDurationLocale implements DurationLocale {
  const GermanDurationLocale();

  String year(int amount, [bool abbreviated = true]) {
    if (abbreviated)
      return 'y';
    else
      return 'Jahr' + (amount > 1 ? 'e' : '');
  }

  String month(int amount, [bool abbreviated = true]) {
    if (abbreviated)
      return 'mon';
    else
      return 'Monat' + (amount > 1 ? 'e' : '');
  }

  String week(int amount, [bool abbreviated = true]) {
    if (abbreviated)
      return 'w';
    else
      return 'Woche' + (amount > 1 ? 'n' : '');
  }

  String day(int amount, [bool abbreviated = true]) {
    if (abbreviated)
      return 'd';
    else
      return 'Tag' + (amount > 1 ? 'e' : '');
  }

  String hour(int amount, [bool abbreviated = true]) {
    if (abbreviated)
      return 'h';
    else
      return 'Stunde' + (amount > 1 ? 'n' : '');
  }

  String minute(int amount, [bool abbreviated = true]) {
    if (abbreviated)
      return 'm';
    else
      return 'Minute' + (amount > 1 ? 'n' : '');
  }

  String second(int amount, [bool abbreviated = true]) {
    if (abbreviated)
      return 's';
    else
      return 'Sekunde' + (amount > 1 ? 'n' : '');
  }

  String millisecond(int amount, [bool abbreviated = true]) {
    if (abbreviated)
      return 'ms';
    else
      return 'Millisekunde' + (amount > 1 ? 'n' : '');
  }

  String microseconds(int amount, [bool abbreviated = true]) {
    if (abbreviated)
      return 'us';
    else
      return 'Mikrosekunde' + (amount > 1 ? 'n' : '');
  }
}