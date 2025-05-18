class Validators {
  // Validate Email
  static String? validateEmail(String email) {
    final RegExp emailRegex =
        RegExp(r'^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (email.isEmpty) {
      return 'Email cannot be empty';
    } else if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null; // Return null if valid
  }

  // Validate Name
  static String? validateName(String name) {
    if (name.isEmpty) {
      return 'Name cannot be empty';
    } else if (name.length < 3) {
      return 'Name must be at least 3 characters long';
    }
    return null; // Return null if valid
  }

  // Validate Question Text
  static String? validateQuestion(String question) {
    if (question.isEmpty) {
      return 'Question text cannot be empty';
    }
    return null; // Return null if valid
  }

  // Validate Options for a Question
  static String? validateOptions(List<String> options) {
    if (options.isEmpty || options.any((option) => option.isEmpty)) {
      return 'All options must be filled';
    } else if (options.length < 2) {
      return 'A question must have at least 2 options';
    }
    return null; // Return null if valid
  }
}
