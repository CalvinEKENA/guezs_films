import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guezs_films/core/routes/route_constants.dart';
import 'package:guezs_films/core/theme/app_colors.dart';
import 'package:guezs_films/core/theme/app_text_styles.dart';
import 'package:guezs_films/core/widgets/gradient_button.dart';
import 'package:guezs_films/core/widgets/glass_card.dart';
import 'package:guezs_films/features/auth/presentation/providers/auth_providers.dart';

/// Login page with email/password and social sign-in
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra is Map<String, dynamic> && extra.containsKey('isLogin')) {
      _isLogin = extra['isLogin'] as bool;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() => _isLogin = !_isLogin);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(authControllerProvider.notifier);

    if (_isLogin) {
      await controller.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } else {
      await controller.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for errors
    ref.listen<AsyncValue>(authControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      } else if (next is AsyncData && next.value != null) {
        context.go(Routes.home);
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AsyncLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryDark.withValues(alpha: 0.2),
                  AppColors.background,
                  AppColors.background,
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo section
                        _buildLogo()
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: -0.2, end: 0),

                        const SizedBox(height: 32),

                        // Form card with glassmorphism
                        GlassCard(
                              blur: 20,
                              opacity: 0.08,
                              padding: const EdgeInsets.all(24),
                              borderRadius: BorderRadius.circular(24),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Title
                                    Text(
                                      _isLogin ? 'Connexion' : 'Inscription',
                                      style: AppTextStyles.headlineLarge
                                          .copyWith(
                                            color: AppColors.textPrimary,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      _isLogin
                                          ? 'Bienvenue ! Connectez-vous pour continuer.'
                                          : 'Créez votre compte Guezs Films.',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),

                                    const SizedBox(height: 32),

                                    // Name field (only for signup)
                                    if (!_isLogin) ...[
                                      TextFormField(
                                        controller: _nameController,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              color: AppColors.textPrimary,
                                            ),
                                        decoration: const InputDecoration(
                                          labelText: 'Nom complet',
                                          prefixIcon: Icon(
                                            Icons.person_outline,
                                            color: AppColors.textTertiary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],

                                    // Email field
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                      decoration: const InputDecoration(
                                        labelText: 'Email',
                                        prefixIcon: Icon(
                                          Icons.email_outlined,
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Entrez votre email';
                                        }
                                        if (!value.contains('@')) {
                                          return 'Email invalide';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 16),

                                    // Password field
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: 'Mot de passe',
                                        prefixIcon: const Icon(
                                          Icons.lock_outlined,
                                          color: AppColors.textTertiary,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: AppColors.textTertiary,
                                          ),
                                          onPressed: () {
                                            setState(
                                              () => _obscurePassword =
                                                  !_obscurePassword,
                                            );
                                          },
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Entrez votre mot de passe';
                                        }
                                        if (value.length < 6) {
                                          return 'Minimum 6 caractères';
                                        }
                                        return null;
                                      },
                                    ),

                                    if (_isLogin) ...[
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () {
                                            context.push(Routes.forgotPassword);
                                          },
                                          child: Text(
                                            'Mot de passe oublié ?',
                                            style: AppTextStyles.labelMedium
                                                .copyWith(
                                                  color: AppColors.primary,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],

                                    const SizedBox(height: 24),

                                    // Submit button
                                    GradientButton(
                                      text: _isLogin
                                          ? 'Se connecter'
                                          : "S'inscrire",
                                      isLoading: isLoading,
                                      onPressed: _submit,
                                    ),

                                    const SizedBox(height: 24),

                                    // Divider
                                    Row(
                                      children: [
                                        const Expanded(
                                          child: Divider(
                                            color: AppColors.divider,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          child: Text(
                                            'ou',
                                            style: AppTextStyles.caption
                                                .copyWith(
                                                  color: AppColors.textTertiary,
                                                ),
                                          ),
                                        ),
                                        const Expanded(
                                          child: Divider(
                                            color: AppColors.divider,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 24),

                                    // Social login buttons
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (Platform.isAndroid ||
                                            Platform.isWindows)
                                          _SocialButton(
                                            assetPath:
                                                'assets/icons/google.png',
                                            onTap: () {
                                              ref
                                                  .read(
                                                    authControllerProvider
                                                        .notifier,
                                                  )
                                                  .signInWithGoogle();
                                            },
                                          ),
                                        if ((Platform.isAndroid ||
                                                Platform.isWindows) &&
                                            (Platform.isIOS ||
                                                Platform.isWindows))
                                          const SizedBox(width: 16),
                                        if (Platform.isIOS ||
                                            Platform.isWindows)
                                          _SocialButton(
                                            assetPath: 'assets/icons/apple.png',
                                            onTap: () {
                                              // TODO: Apple sign in
                                            },
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 200.ms)
                            .slideY(begin: 0.1, end: 0),

                        const SizedBox(height: 24),

                        // Toggle login/signup
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLogin
                                  ? "Pas encore de compte ?"
                                  : "Déjà un compte ?",
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: _toggleMode,
                              child: Text(
                                _isLogin ? "S'inscrire" : 'Se connecter',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Image.asset('assets/icons/logo.png', width: 100, height: 100),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback onTap;

  const _SocialButton({required this.assetPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Center(child: Image.asset(assetPath, width: 24, height: 24)),
      ),
    );
  }
}
