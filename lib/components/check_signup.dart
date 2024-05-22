import 'package:flutter/material.dart';
import 'package:daily_doii/utils/checkTextFormat.dart';

class PasswordCheck extends StatefulWidget {
  final TextEditingController passwordController;
  final TextEditingController repeatPasswordController;

  const PasswordCheck({
    super.key,
    required this.passwordController,
    required this.repeatPasswordController,
  });

  @override
  State<PasswordCheck> createState() => _PasswordCheckState();
}

class _PasswordCheckState extends State<PasswordCheck> {
  bool _containsUpperCase = false;
  bool _hasMinimumLength = false;
  bool _containsLetter = false;
  bool _passwordsMatch = false;

  @override
  void initState() {
    super.initState();
    _updatePasswordCheck();
    _addListenerToControllers();
  }

  void _addListenerToControllers() {
    widget.passwordController.addListener(_updatePasswordCheck);
    widget.repeatPasswordController.addListener(_updatePasswordCheck);
  }

  @override
  void dispose() {
    widget.passwordController.removeListener(_updatePasswordCheck);
    widget.repeatPasswordController.removeListener(_updatePasswordCheck);
    super.dispose();
  }

  void _updatePasswordCheck() {
    final password = widget.passwordController.text;
    final repeatPassword = widget.repeatPasswordController.text;

    CheckTextFormat checker = CheckTextFormat();

    setState(() {
      _containsUpperCase = checker.containsUpperCaseLetter(password);
      _hasMinimumLength = checker.hasMinimumLengthCheck(password);
      _containsLetter = checker.containsSmallLetterCheck(password);
      _passwordsMatch = _passwordsMatchCheck(password, repeatPassword);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Password Conditions:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFACB5BD)),
          ),
          const SizedBox(height: 8),
          _buildConditionRow(
            icon: _containsUpperCase ? Icons.check : Icons.close,
            color: _containsUpperCase ? Colors.green : Colors.red,
            text: "At least one capital letter",
          ),
          _buildConditionRow(
            icon: _hasMinimumLength ? Icons.check : Icons.close,
            color: _hasMinimumLength ? Colors.green : Colors.red,
            text: "At least 8 characters",
          ),
          _buildConditionRow(
            icon: _containsLetter ? Icons.check : Icons.close,
            color: _containsLetter ? Colors.green : Colors.red,
            text: "At least one small letter",
          ),
          _buildConditionRow(
            icon: _passwordsMatch ? Icons.check : Icons.close,
            color: _passwordsMatch ? Colors.green : Colors.red,
            text: "Repeat password has to match",
          ),
        ],
      ),
    );
  }

  Widget _buildConditionRow({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }

  bool _passwordsMatchCheck(String password, String repeatPassword) {
    if (password.isNotEmpty) {
      return password == repeatPassword;
    } else {
      return false;
    }
  }
}
