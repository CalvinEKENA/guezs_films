import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'gradient_button.dart';
import 'glass_card.dart';

/// A premium dialog to enter a 6-digit promo code featuring our influencers
class PromoCodeDialog extends StatefulWidget {
  final VoidCallback onSuccess;

  const PromoCodeDialog({super.key, required this.onSuccess});

  @override
  State<PromoCodeDialog> createState() => _PromoCodeDialogState();
}

class _PromoCodeDialogState extends State<PromoCodeDialog> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isError = false;
  bool _isLoading = false;
  String? _successInfluencer;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyCode();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyCode() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 6) return;

    setState(() {
      _isLoading = true;
      _isError = false;
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    if (code == '123456' || code == '654321') {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _successInfluencer = code == '123456'
              ? 'Muriel Blanche'
              : 'Betty Christy';
        });

        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          Navigator.pop(context);
          widget.onSuccess();
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isError = true;
        });
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: GlassCard(
        blur: 20,
        opacity: 0.1,
        padding: const EdgeInsets.all(24),
        borderRadius: BorderRadius.circular(28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_successInfluencer != null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.green,
                    size: 60,
                  ),
                ).animate().scale().fadeIn(),
                const SizedBox(height: 20),
                Text(
                  'Code Validé !',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Merci d\'utiliser le code de $_successInfluencer',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ] else ...[
                SizedBox(
                      height: 65,
                      width: 115,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            child: _buildInfluencerAvatar(
                              'Muriel Blanche',
                              'assets/images/muriel_blanche.jpg',
                            ),
                          ),
                          Positioned(
                            left: 50,
                            child: _buildInfluencerAvatar(
                              'Betty Christy',
                              'assets/images/betty_christy.jpg',
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.2, end: 0),
                const SizedBox(height: 16),
                Text(
                  'Nos Ambassadrices',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Code d\'accès',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontFamily: 'Didot',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Entrez le code promo de votre influenceuse préférée.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return Flexible(
                      child:
                          Padding(
                                padding: EdgeInsets.only(
                                  right: index == 5 ? 0 : 4,
                                ),
                                child: SizedBox(
                                  height: 50,
                                  child: TextField(
                                    controller: _controllers[index],
                                    focusNode: _focusNodes[index],
                                    onChanged: (value) =>
                                        _onChanged(value, index),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.titleLarge.copyWith(
                                      color: _isError
                                          ? AppColors.error
                                          : AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(1),
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppColors.surfaceVariant
                                          .withValues(alpha: 0.5),
                                      contentPadding: EdgeInsets.zero,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: _isError
                                              ? AppColors.error.withValues(
                                                  alpha: 0.5,
                                                )
                                              : AppColors.border,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .animate(target: _isError ? 1 : 0)
                              .shake(duration: 400.ms, hz: 10),
                    );
                  }),
                ),
                if (_isError) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Code incorrect. Veuillez réessayer.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                    ),
                  ).animate().fadeIn(),
                ],
                const SizedBox(height: 32),
                GradientButton(
                  text: _isLoading ? 'Vérification...' : 'Débloquer',
                  isLoading: _isLoading,
                  onPressed: _verifyCode,
                  width: double.infinity,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Annuler',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfluencerAvatar(String name, String assetPath) {
    return Tooltip(
      message: name,
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.surfaceVariant,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper method to show the promo code dialog
void showPromoCodeDialog(
  BuildContext context, {
  required VoidCallback onSuccess,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => PromoCodeDialog(onSuccess: onSuccess),
  );
}
