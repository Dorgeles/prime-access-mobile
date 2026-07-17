import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:prime_access/providers/auth_provider.dart';
import 'package:prime_access/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _ForgotPasswordSheet extends StatefulWidget {
  const _ForgotPasswordSheet({
    required this.apiService,
    required this.parentContext,
  });

  final ApiService apiService;
  final BuildContext parentContext;

  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  final TextEditingController _loginController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());
  final List<TextEditingController> _newPasswordControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _newPasswordFocusNodes = List.generate(
    4,
    (_) => FocusNode(),
  );
  final List<TextEditingController> _confirmPasswordControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _confirmPasswordFocusNodes = List.generate(
    4,
    (_) => FocusNode(),
  );

  int _step = 0;
  bool _isLoading = false;
  String? _errorMsg;

  String get _otpCode => _otpControllers.map((c) => c.text).join();
  String get _newPasswordCode =>
      _newPasswordControllers.map((c) => c.text).join();
  String get _confirmPasswordCode =>
      _confirmPasswordControllers.map((c) => c.text).join();

  bool _isComplete(List<TextEditingController> controllers) =>
      controllers.every((c) => c.text.length == 1);

  @override
  void dispose() {
    _loginController.dispose();
    for (final controller in [
      ..._otpControllers,
      ..._newPasswordControllers,
      ..._confirmPasswordControllers,
    ]) {
      controller.dispose();
    }
    for (final focusNode in [
      ..._otpFocusNodes,
      ..._newPasswordFocusNodes,
      ..._confirmPasswordFocusNodes,
    ]) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (_step == 1)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() {
                    _step = 0;
                    _errorMsg = null;
                  }),
                ),
              Text(
                _step == 0 ? 'Mot de passe oublié' : 'Nouveau mot de passe',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_step == 0)
            Text(
              'Entrez votre login pour recevoir un code de réinitialisation.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          if (_step == 1)
            Text(
              'Un code a été envoyé. Entrez-le avec votre nouveau mot de passe.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          if (_errorMsg != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMsg!,
                  style: TextStyle(color: Colors.red[700]),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          const SizedBox(height: 20),
          if (_step == 0) ...[
            TextFormField(
              controller: _loginController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Login',
                prefixIcon: Icon(Icons.person_outlined),
              ),
              onFieldSubmitted: (_) async {
                if (_loginController.text.trim().isEmpty || _isLoading) return;
                setState(() {
                  _isLoading = true;
                  _errorMsg = null;
                });
                final ok = await widget.apiService.sendResetPassword(
                  _loginController.text.trim(),
                );
                if (!mounted) return;
                setState(() {
                  _isLoading = false;
                  if (ok) {
                    _step = 1;
                  } else {
                    _errorMsg =
                        'Erreur lors de l\'envoi. Vérifiez votre login.';
                  }
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (_loginController.text.trim().isEmpty) {
                        setState(() {
                          _errorMsg = 'Veuillez entrer votre login';
                        });
                        return;
                      }
                      setState(() {
                        _isLoading = true;
                        _errorMsg = null;
                      });
                      final ok = await widget.apiService.sendResetPassword(
                        _loginController.text.trim(),
                      );
                      if (!mounted) return;
                      setState(() {
                        _isLoading = false;
                        if (ok) {
                          _step = 1;
                        } else {
                          _errorMsg =
                              'Erreur lors de l\'envoi. Vérifiez votre login.';
                        }
                      });
                    },
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Envoyer le code'),
            ),
          ],
          if (_step == 1) ...[
            Text(
              'Code reçu',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0 : 12),
                  child: SizedBox(
                    width: 52,
                    height: 60,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _otpFocusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        if (!mounted) return;
                        if (value.length == 1 &&
                            index < 3 &&
                            !_otpFocusNodes[index + 1].hasFocus) {
                          _otpFocusNodes[index + 1].requestFocus();
                        }
                        setState(() {});
                      },
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Text(
              'Nouveau code d\'accès',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0 : 12),
                  child: SizedBox(
                    width: 52,
                    height: 60,
                    child: TextField(
                      controller: _newPasswordControllers[index],
                      focusNode: _newPasswordFocusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      obscureText: true,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        if (!mounted) return;
                        if (value.length == 1 &&
                            index < 3 &&
                            !_newPasswordFocusNodes[index + 1].hasFocus) {
                          _newPasswordFocusNodes[index + 1].requestFocus();
                        }
                        setState(() {});
                      },
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Text(
              'Confirmer le code',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0 : 12),
                  child: SizedBox(
                    width: 52,
                    height: 60,
                    child: TextField(
                      controller: _confirmPasswordControllers[index],
                      focusNode: _confirmPasswordFocusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      obscureText: true,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        if (!mounted) return;
                        if (value.length == 1 &&
                            index < 3 &&
                            !_confirmPasswordFocusNodes[index + 1].hasFocus) {
                          _confirmPasswordFocusNodes[index + 1].requestFocus();
                        }
                        setState(() {});
                      },
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      final token = _otpCode;
                      final newPwd = _newPasswordCode;
                      final confirmPwd = _confirmPasswordCode;

                      if (!_isComplete(_otpControllers)) {
                        setState(() {
                          _errorMsg = 'Veuillez entrer le code reçu';
                        });
                        return;
                      }
                      if (!_isComplete(_newPasswordControllers)) {
                        setState(() {
                          _errorMsg = 'Veuillez entrer un nouveau code';
                        });
                        return;
                      }
                      if (newPwd != confirmPwd) {
                        setState(() {
                          _errorMsg = 'Les codes ne correspondent pas';
                        });
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                        _errorMsg = null;
                      });
                      final ok = await widget.apiService.resetPassword(
                        login: _loginController.text.trim(),
                        password: newPwd,
                        confirmPassword: confirmPwd,
                        token: token,
                      );
                      if (!mounted) return;
                      setState(() => _isLoading = false);
                      if (ok) {
                        Navigator.pop(context);
                        if (widget.parentContext.mounted) {
                          ScaffoldMessenger.of(
                            widget.parentContext,
                          ).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Mot de passe réinitialisé avec succès',
                              ),
                            ),
                          );
                        }
                      } else {
                        setState(() {
                          _errorMsg =
                              'Erreur lors de la réinitialisation. Vérifiez le code.';
                        });
                      }
                    },
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Réinitialiser'),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _otpControllers = List.generate(4, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    _loginController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _otpControllers.map((c) => c.text).join();
  bool get _isOtpComplete => _otpControllers.every((c) => c.text.length == 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Prime Access',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connectez-vous pour accéder à votre espace',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 40),
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      if (auth.errorMessage != null) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              auth.errorMessage!,
                              style: TextStyle(color: Colors.red[700]),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  TextFormField(
                    controller: _loginController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Login',
                      prefixIcon: Icon(Icons.person_outlined),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Le login est requis'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Code d\'accès',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return Padding(
                        padding: EdgeInsets.only(left: index == 0 ? 0 : 12),
                        child: SizedBox(
                          width: 56,
                          height: 64,
                          child: TextFormField(
                            controller: _otpControllers[index],
                            focusNode: _otpFocusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            obscureText: true,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              counterText: '',
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (value) {
                              if (!mounted) return;
                              if (value.length == 1 &&
                                  index < 3 &&
                                  !_otpFocusNodes[index + 1].hasFocus)
                                _otpFocusNodes[index + 1].requestFocus();
                              if (_isOtpComplete &&
                                  _formKey.currentState!.validate())
                                _handleLogin();
                              setState(() {});
                            },
                            onTapOutside: (_) {
                              if (!mounted) return;
                              if (index > 0 &&
                                  _otpControllers[index].text.isEmpty &&
                                  !_otpFocusNodes[index - 1].hasFocus)
                                _otpFocusNodes[index - 1].requestFocus();
                            },
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Entrez votre code à 4 chiffres',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      final isLoading = auth.status == AuthStatus.loading;
                      return ElevatedButton(
                        onPressed: isLoading ? null : _handleLogin,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Se connecter'),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _showForgotPassword,
                    child: const Text('Mot de passe oublié ?'),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: const Text('Pas encore de compte ? S\'inscrire'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;
    if (!_isOtpComplete) return;
    final auth = context.read<AuthProvider>();
    auth.login(_loginController.text.trim(), _otpCode);
  }

  void _showForgotPassword() {
    final apiService = context.read<ApiService>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) =>
          _ForgotPasswordSheet(apiService: apiService, parentContext: context),
    );
  }
}
