
class CheckTextFormat  {

  bool isValidEmailFormat(String email) {
    final RegExp emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool isValidCharacterFormatForName(String cadena) {
    RegExp regExp = RegExp(r'^[a-zA-ZáéíóúüñÁÉÍÓÚÜÑ\s]+$');
    return regExp.hasMatch(cadena);
  }

  bool containsUpperCaseLetter(String password) {
    return password.contains(RegExp(r'[A-Z]'));
  }

  bool hasMinimumLengthCheck(String password) {
    return password.length >= 8;
  }

  bool containsSmallLetterCheck(String password) {
    return password.contains(RegExp(r'[a-z]'));
  }

  bool isValidTextFormat(String text) {
    if (text.length >= 30 || text.isEmpty) {
      return false;
    } else {
      if (!isValidCharacterFormat(text)) {
        return false;
      }
      return true;
    }
  }

  bool isValidCharacterFormat(String cadena) {
    RegExp regExp = RegExp(r'^[a-zA-ZáéíóúüñÁÉÍÓÚÜÑ\s]+$');
    return regExp.hasMatch(cadena);
  }

  bool isValidPasswordFormat(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-zA-Z]'));
  }

  bool isRepeatPasswordCorrect(String repeatPassword, String password) {
    if (password== repeatPassword){
      return true;
    }
    return false;
  }
}