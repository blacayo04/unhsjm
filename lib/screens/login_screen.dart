import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _cargando = false;
  bool _crearCuenta = false;
  bool _ocultarPassword = true;

  Future<void> _autenticar() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _mostrarMensaje('Ingresa tu correo y contraseña.');
      return;
    }

    setState(() => _cargando = true);

    try {
      final auth = Supabase.instance.client.auth;

      if (_crearCuenta) {
        await auth.signUp(email: email, password: password);
      } else {
        await auth.signInWithPassword(email: email, password: password);
      }

      if (!mounted) return;

      if (auth.currentSession == null) {
        _mostrarMensaje(
          'Cuenta creada. Revisa tu correo para confirmar la cuenta '
          'y luego inicia sesión.',
        );
      }
    } on AuthException catch (e) {
      _mostrarMensaje(e.message);
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
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
      appBar: AppBar(title: const Text('UNHSJM - Acceso')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.inventory_2, size: 72, color: Colors.blue),
                const SizedBox(height: 16),
                Text(
                  _crearCuenta ? 'Crear cuenta' : 'Iniciar sesión',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _ocultarPassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _ocultarPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _ocultarPassword = !_ocultarPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _autenticar,
                    child: _cargando
                        ? const CircularProgressIndicator()
                        : Text(_crearCuenta ? 'Registrarme' : 'Entrar'),
                  ),
                ),
                TextButton(
                  onPressed: _cargando
                      ? null
                      : () {
                          setState(() {
                            _crearCuenta = !_crearCuenta;
                          });
                        },
                  child: Text(
                    _crearCuenta
                        ? 'Ya tengo una cuenta'
                        : 'Crear una cuenta nueva',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
