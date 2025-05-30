import 'package:flutter/material.dart';
import 'common/colors.dart';
import 'common/toggle_button.dart';
import 'views/profile_setup.dart';
import 'services/auth_service.dart';
import 'package:logger/logger.dart';

Logger logger = Logger();

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  int selectedRole = 0; // 0 for Entrenador (coach), 1 for Fitters (student)
  final List<String> roleOptions = ['Entrenador', 'Fitters']; // Textos visibles
  final List<String> roleValues = ['Coach', 'Student']; // Valores para la API
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  bool _isValidEmail(String email) {
    // Expresión regular simple para validar email
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final role = roleValues[selectedRole]; // Usar el valor correcto para la API

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    // Validaciones
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingresa todos los campos';
        _isLoading = false;
      });
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() {
        _errorMessage = 'Por favor ingresa un email válido';
        _isLoading = false;
      });
      return;
    }

    if (password.length < 8) {
      setState(() {
        _errorMessage = 'La contraseña debe tener al menos 8 caracteres';
        _isLoading = false;
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Las contraseñas no coinciden';
        _isLoading = false;
      });
      return;
    }

    // Log para verificar los valores enviados
    logger.d('Enviando registro - Nombre: $name, Email: $email, Rol: $role');

    final result = await _authService.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: confirmPassword,
      role: role,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (result['success']) {
      // Store token for future API calls
      final token = result['data']['token'];
      
      // Navigate to profile setup using the common view
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileSetupView(
            token: token,
            email: email,
            isCoach: selectedRole == 0, // true si es coach, false si es fitter
          ),
        ),
      );
    } else {
      setState(() {
        _errorMessage = result['error'];
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBlack,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo placeholder
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.gray,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      'LOGO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Role selection toggle
                ToggleButtonGroup(
                  options: roleOptions, // Usar los textos visibles
                  onOptionSelected: (index) {
                    setState(() => selectedRole = index);
                    logger.d('Rol seleccionado: ${roleOptions[index]} (${roleValues[index]})');
                  },
                ),
                const SizedBox(height: 48),

                // Name input
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Nombre completo',
                    hintStyle: TextStyle(color: AppColors.gray),
                    filled: true,
                    fillColor: AppColors.darkGray.withAlpha(77),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryBlue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.neonBlue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Email input
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(color: AppColors.gray),
                    filled: true,
                    fillColor: AppColors.darkGray.withAlpha(77),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryBlue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.neonBlue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password input
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    hintStyle: TextStyle(color: AppColors.gray),
                    filled: true,
                    fillColor: AppColors.darkGray.withAlpha(77),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryBlue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.neonBlue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Password input
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Confirmar Contraseña',
                    hintStyle: TextStyle(color: AppColors.gray),
                    filled: true,
                    fillColor: AppColors.darkGray.withAlpha(77),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryBlue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.neonBlue, width: 2),
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 32),

                // Register Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonBlue,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          'Registrate',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 32),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Ya tienes una cuenta, ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'inicia sesion',
                        style: TextStyle(
                          color: AppColors.lightBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
