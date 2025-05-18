import 'package:intl/intl.dart';

class Helpers {
  // Format Duration to HH:mm:ss
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  // Convert DateTime to String using the specified format
  static String formatDate(DateTime date, {String format = 'dd MMM yyyy'}) {
    final DateFormat formatter = DateFormat(format);
    return formatter.format(date);
  }

  // Calculate Score Percentage
  static double calculateScore(int correctAnswers, int totalQuestions) {
    if (totalQuestions == 0) return 0.0;
    return (correctAnswers / totalQuestions) * 100;
  }

  // Capitalize the first letter of a given string
  static String capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }
}
