import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/access/domain/entities/watch_access_result.dart';
import '../../features/access/presentation/providers/watch_access_providers.dart';
import '../../features/player/domain/entities/player_content_request.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'gradient_button.dart';
import 'glass_card.dart';

class PromoCodeDialog extends ConsumerStatefulWidget {
  const PromoCodeDialog({
    super.key,
    required this.request,
    required this.onSuccess,
    this.onNoCode,
  });

  final PlayerContentRequest request;
  final ValueChanged<WatchAccessResult> onSuccess;
  final VoidCallback? onNoCode;

  @override
  ConsumerState<PromoCodeDialog> createState() => _PromoCodeDialogState();
}

class _PromoCodeDialogState extends ConsumerState<PromoCodeDialog> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;
  bool _isGranted = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _validateCode() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      setState(() {
        _message = 'Entrez un code d’accès.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    final result = await ref
        .read(watchAccessRepositoryProvider)
        .validateAccessCode(request: widget.request, code: code);

    if (!mounted) return;

    if (result.allowed) {
      setState(() {
        _isLoading = false;
        _isGranted = true;
        _message = result.message.isNotEmpty
            ? result.message
            : 'Accès accordé.';
      });
      await Future<void>.delayed(const Duration(milliseconds: 650));
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onSuccess(result);
      return;
    }

    setState(() {
      _isLoading = false;
      _isGranted = false;
      _message = result.message.isNotEmpty
          ? result.message
          : 'Accès refusé. Vérifiez votre code.';
    });
    _controller.clear();
    _focusNode.requestFocus();
  }

  void _handleNoCode() {
    Navigator.of(context).pop();
    widget.onNoCode?.call();
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
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isGranted
                    ? Icons.check_circle_outline_rounded
                    : Icons.lock_open_rounded,
                color: _isGranted ? AppColors.success : AppColors.primary,
                size: 52,
              ),
              const SizedBox(height: 16),
              Text(
                _isGranted ? 'Accès accordé' : 'Débloquer l’accès',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isGranted
                    ? 'Préparation de la lecture...'
                    : 'Entrez votre code ambassadeur ou votre code d’accès.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: !_isLoading && !_isGranted,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _validateCode(),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9-]')),
                  LengthLimitingTextInputFormatter(32),
                  _UpperCaseTextFormatter(),
                ],
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  letterSpacing: 1.5,
                ),
                decoration: InputDecoration(
                  labelText: 'Code',
                  hintText: 'VOTRE-CODE',
                  prefixIcon: const Icon(Icons.confirmation_number_outlined),
                  errorText: _message != null && !_isGranted ? _message : null,
                ),
              ),
              if (_message != null && _isGranted) ...[
                const SizedBox(height: 12),
                Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              GradientButton(
                text: _isLoading ? 'Validation...' : 'Valider',
                isLoading: _isLoading,
                onPressed: _isGranted ? null : _validateCode,
                width: double.infinity,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _isLoading ? null : _handleNoCode,
                child: Text(
                  'Je n’ai pas de code',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

void showPromoCodeDialog(
  BuildContext context, {
  required PlayerContentRequest request,
  required ValueChanged<WatchAccessResult> onSuccess,
  VoidCallback? onNoCode,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => PromoCodeDialog(
      request: request,
      onSuccess: onSuccess,
      onNoCode: onNoCode,
    ),
  );
}
