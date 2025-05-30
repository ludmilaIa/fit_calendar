import 'package:flutter/material.dart';
import 'common/colors.dart';
import 'signup.dart';
import 'views/trainer_view.dart';
import 'views/fitter_view.dart';
import 'services/auth_service.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService authService = AuthService();
  String? _errorMessage;
  bool _isLoading = false;

  // Mock credentials for fallback or testing
  final Map<String, Map<String, String>> _mockUsers = {
    'coach@test.com': {
      'password': 'Test1234!!',
      'role': 'trainer',
    },
    'fitter@test.com': {
      'password': 'Test1234!!',
      'role': 'fitter',
    },
  };

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    final token = await authService.getToken();
    if (token != null && mounted) {
      // Get user data from storage or API to check role
      try {
        // Attempt to get user info using the token
        final userData = await authService.getUserInfo();
        
        if (userData['success']) {
          final userRole = userData['data']['role'] ?? userData['data']['user']['role'];
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => userRole == 'trainer' || userRole == 'Coach'
                  ? const TrainerView()
                  : const FitterView(),
            ),
          );
        } else {
          // If can't get user role, logout and stay on login screen
          await authService.clearToken();
        }
      } catch (e) {
        // If there's an error, clear token and stay on login screen
        await authService.clearToken();
      }
    }
  }

  void _handleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingresa email y contraseña';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await authService.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (response['success']) {
        final userData = response['data'];
        final userRole = userData['user']['role'];
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => userRole == 'trainer'
                ? const TrainerView()
                : const FitterView(),
          ),
        );
      } else {
        setState(() {
          _errorMessage = response['error'] ?? 'Error de inicio de sesión';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión';
      });
      
      // Fallback to mock users for testing if API fails
      if (_mockUsers.containsKey(email)) {
        final user = _mockUsers[email]!;
        if (user['password'] == password) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => user['role'] == 'trainer'
                  ? const TrainerView()
                  : const FitterView(),
            ),
          );
        } else {
          setState(() {
            _errorMessage = 'Contraseña incorrecta';
          });
        }
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                
                // Welcome title
                Text(
                  'Bienvenido',
                  style: TextStyle(
                    color: AppColors.neonBlue,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 48),
                
                // Email input
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
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
                
                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonBlue,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 32),
                
                // Registration text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Si todavia no tienes una cuenta ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpView(),
                          ),
                        );
                      },
                      child: Text(
                        'registrate',
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
