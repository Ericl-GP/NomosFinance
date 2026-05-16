import 'dart:math';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home.dart';
import 'login_screen.dart';
// Certifique-se de importar a sua tela de login caso o usuário queira voltar
// import 'login_screen.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final _authService = AuthService();
  bool _isLoading = false;

  // 1. Variáveis para guardar as mensagens de erro (se forem nulas, o campo fica normal)
  String? _passwordError;
  String? _confirmPasswordError;

  // 2. Função que valida a senha enquanto o usuário digita
  void _validatePassword(String value) {
    setState(() {
      if (value.isNotEmpty && value.length < 6) {
        _passwordError = 'A senha deve ter no mínimo 6 caracteres';
      } else {
        _passwordError = null;
      }
      
      // Também revalida a confirmação caso a senha principal mude
      if (_confirmPasswordController.text.isNotEmpty) {
        _validateConfirmPassword(_confirmPasswordController.text);
      }
    });
  }

  // 3. Função que valida a confirmação de senha
  void _validateConfirmPassword(String value) {
    setState(() {
      if (value.isNotEmpty && value != _passwordController.text) {
        _confirmPasswordError = 'As senhas não coincidem';
      } else {
        _confirmPasswordError = null;
      }
    });
  }
  
  // ... resto do seu código (_handleRegister, etc) ...

  void _handleRegister() async {
   // Na tela de Registro (register_screen.dart)
    
    // ... inicio da função _handleRegister ...
    
    final result = await _authService.register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    // Agora verificamos se 'success' é true
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta criada com sucesso! Entrando...'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Auto-login feito com sucesso! Vai para a tela de Posts
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const NomosFinance(), 
        ),
      );
    } else {
      // Aqui ele exibe a mensagem de erro vinda do Laravel (ex: E-mail já usado)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Erro desconhecido.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/pexels-karola-bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo ou Ícone
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_add, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Crie sua conta',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Junte-se à nossa plataforma',
                  style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                ),
                const SizedBox(height: 32),

                // Card do Formulário
                Container(
                  padding: const EdgeInsets.all(24),
                  width: max(500, 200),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildTextField(
                        label: 'Nome Completo',
                        controller: _nameController,
                        icon: Icons.person_outline,
                        placeholder: 'João da Silva',
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        label: 'E-mail',
                        controller: _emailController,
                        icon: Icons.email_outlined,
                        placeholder: 'seu@email.com',
                      ),
                      const SizedBox(height: 20),
                      // Campo de Senha
                      _buildTextField(
                        label: 'Senha',
                        controller: _passwordController,
                        icon: Icons.lock_outline,
                        isPassword: true,
                        placeholder: '••••••••',
                        errorText: _passwordError, // <-- Conectado
                        onChanged: _validatePassword, // <-- Conectado
                      ),
                      const SizedBox(height: 20),
                      
                      // Campo de Confirmar Senha
                      _buildTextField(
                        label: 'Confirmar Senha',
                        controller: _confirmPasswordController,
                        icon: Icons.lock_reset,
                        isPassword: true,
                        placeholder: '••••••••',
                        errorText: _confirmPasswordError, // <-- Conectado
                        onChanged: _validateConfirmPassword, // <-- Conectado
                      ),
                      const SizedBox(height: 30),

                      // Botão Registrar
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Cadastrar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(255, 198, 244, 123),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Link para voltar ao Login
                      TextButton(
                        onPressed: () {
                          // Volta para a tela anterior (LoginScreen)
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Já tem uma conta? Entre aqui',
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget utilitário idêntico ao do LoginScreen
 // Widget utilitário atualizado com suporte a erros
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    required String placeholder,
    String? errorText, // <-- Adicionamos isso
    Function(String)? onChanged, // <-- Adicionamos isso
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          onChanged: onChanged, // <-- Avisa a tela sempre que uma letra é digitada
          decoration: InputDecoration(
            hintText: placeholder,
            errorText: errorText, // <-- Se tiver erro, fica vermelho sozinho!
            prefixIcon: Icon(icon, size: 20),
            filled: true,
            fillColor: const Color.fromARGB(106, 50, 121, 76),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color.fromARGB(255, 211, 217, 210)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color.fromARGB(255, 241, 240, 240)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color.fromARGB(255, 88, 106, 144), width: 2),
            ),
            // Borda customizada para quando der erro
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}