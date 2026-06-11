import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'gradient_button.dart';
import 'glass_card.dart';

/// A premium dialog to enter a 6-digit promo code featuring our influencers
/// Polished version: Responsive, invisible input, and stable cross-platform behavior
class PromoCodeDialog extends StatefulWidget {
  final VoidCallback onSuccess;

  const PromoCodeDialog({super.key, required this.onSuccess});

  @override
  State<PromoCodeDialog> createState() => _PromoCodeDialogState();
}

class _PromoCodeDialogState extends State<PromoCodeDialog> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isError = false;
  bool _isLoading = false;
  String? _successInfluencer;

  @override
  void initState() {
    super.initState();
    // Auto-focus after dialog animation ends
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    if (value.length == 6) {
      _verifyCode(value);
    }
    if (_isError) {
      setState(() => _isError = false);
    }
  }

  Future<void> _verifyCode(String code) async {
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
          _controller.clear();
        });
        _focusNode.requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        blur: 20,
        opacity: 0.1,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        borderRadius: BorderRadius.circular(28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_successInfluencer != null) ...[
                _buildSuccessState()
              ] else ...[
                _buildInputState()
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
      ],
    );
  }

  Widget _buildInputState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ambassadrices avatars
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
        ),
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
        
        // Input Area
        Stack(
          alignment: Alignment.center,
          children: [
            // 1. Decorative squares (now slightly narrower for responsiveness)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                final char = _controller.text.length > index ? _controller.text[index] : '';
                final isFocused = _controller.text.length == index && _focusNode.hasFocus;
                
                return Container(
                  width: 35, // Reduced from 40 to fit smaller screens
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isError 
                          ? AppColors.error 
                          : (isFocused ? AppColors.primary : AppColors.border),
                      width: isFocused || _isError ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      char,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: _isError ? AppColors.error : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),
            
            // 2. Translucent hit-testable overlay
            // Positioned.fill to allow clicks everywhere on the Row
            // Using a low opacity to ensure it's still hit-testable but invisible
            Positioned.fill(
              child: Opacity(
                opacity: 0.0,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: _onChanged,
                  keyboardType: TextInputType.number,
                  showCursor: false,
                  enableInteractiveSelection: false,
                  style: const TextStyle(fontSize: 1),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: const InputDecoration(
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        if (_isError) ...[
          const SizedBox(height: 16),
          Text(
            'Code incorrect. Veuillez réessayer.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
        
        const SizedBox(height: 32),
        GradientButton(
          text: _isLoading ? 'Vérification...' : 'Débloquer',
          isLoading: _isLoading,
          onPressed: _controller.text.length == 6 ? () => _verifyCode(_controller.text) : null,
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
    );
  }

  Widget _buildInfluencerAvatar(String name, String assetPath) {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
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
