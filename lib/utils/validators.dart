//Global validators
bool isValidEmail(String email) {
  final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
  return emailRegex.hasMatch(email.trim());
}

bool isValidPassword(String password) {
  // At least 6 charachters, 1 capital letter and 1 number
  final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d).{6,}$');
  return passwordRegex.hasMatch(password);
}

bool hasUnsafeCharacters(String input) {
  final unsafePattern = RegExp(r'[<>]|[\u0000-\u001F]');
  return unsafePattern.hasMatch(input);
}
