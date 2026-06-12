import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/premium_feedback.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../providers/user_profile_providers.dart';

class ProfileFormSheet extends ConsumerStatefulWidget {
  final String userId;
  final UserProfileEntity? existing;
  final ValueChanged<UserProfileEntity> onSaved;

  const ProfileFormSheet({
    super.key,
    required this.userId,
    this.existing,
    required this.onSaved,
  });

  @override
  ConsumerState<ProfileFormSheet> createState() => _ProfileFormSheetState();
}

class _ProfileFormSheetState extends ConsumerState<ProfileFormSheet> {
  late final TextEditingController _nameCtrl;
  String _emoji = '';
  int _colorIndex = 0;
  bool _isKids = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _nameCtrl.addListener(() {
      if (mounted) setState(() {});
    });
    _emoji = widget.existing?.emoji ?? UserProfileEntity.emojiOptions.first;
    _colorIndex = widget.existing?.colorIndex ?? 0;
    _isKids = widget.existing?.isKids ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      showPremiumSnackBar(
        context,
        message: 'Entrez un nom pour continuer.',
        tone: PremiumFeedbackTone.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(userProfileRepositoryProvider);
      if (widget.existing == null) {
        final newProfile = await repo.createProfile(
          userId: widget.userId,
          name: name,
          emoji: _emoji,
          colorIndex: _colorIndex,
          isKids: _isKids,
        );
        widget.onSaved(newProfile);
      } else {
        await repo.updateProfile(
          userId: widget.userId,
          profileId: widget.existing!.id,
          name: name,
          emoji: _emoji,
          colorIndex: _colorIndex,
          isKids: _isKids,
        );
        widget.onSaved(
          widget.existing!.copyWith(
            name: name,
            emoji: _emoji,
            colorIndex: _colorIndex,
            isKids: _isKids,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showPremiumSnackBar(
          context,
          message: 'Le profil n’a pas pu être enregistré.',
          tone: PremiumFeedbackTone.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Modifier le profil' : 'Créer un profil',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (_isLoading)
                    const CupertinoActivityIndicator(
                      color: AppColors.accentSoft,
                    )
                  else
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _nameCtrl.text.trim().isEmpty ? null : _submit,
                      child: Text(
                        'Enregistrer',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: _nameCtrl.text.trim().isEmpty
                              ? AppColors.textTertiary
                              : AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 32),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: UserProfileEntity.colorOptions[_colorIndex],
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: AppColors.accentSoft.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        image:
                            _emoji.startsWith('assets/') ||
                                _emoji.startsWith('http')
                            ? DecorationImage(
                                image: _emoji.startsWith('http')
                                    ? NetworkImage(_emoji) as ImageProvider
                                    : AssetImage(_emoji),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: Center(
                        child:
                            (!_emoji.startsWith('assets/') &&
                                !_emoji.startsWith('http'))
                            ? Text(_emoji, style: const TextStyle(fontSize: 48))
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CupertinoTextField(
                    controller: _nameCtrl,
                    placeholder: 'Nom du profil',
                    placeholderStyle: const TextStyle(
                      color: AppColors.textTertiary,
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Couleur', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(
                      UserProfileEntity.colorOptions.length,
                      (idx) {
                        final c = UserProfileEntity.colorOptions[idx];
                        final isSel = idx == _colorIndex;
                        return Semantics(
                          button: true,
                          selected: isSel,
                          label: 'Couleur ${idx + 1}',
                          child: Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: () => setState(() => _colorIndex = idx),
                              customBorder: const CircleBorder(),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSel
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Avatar', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: UserProfileEntity.emojiOptions.map((e) {
                      final isSel = e == _emoji;
                      final avatarIndex =
                          UserProfileEntity.emojiOptions.indexOf(e) + 1;
                      return Semantics(
                        button: true,
                        selected: isSel,
                        label: 'Avatar $avatarIndex',
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            onTap: () => setState(() => _emoji = e),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.background.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSel
                                      ? AppColors.accentSoft
                                      : AppColors.border,
                                  width: isSel ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child:
                                    e.startsWith('assets/') ||
                                        e.startsWith('http')
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: e.startsWith('http')
                                            ? Image.network(
                                                e,
                                                width: 44,
                                                height: 44,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.asset(
                                                e,
                                                width: 44,
                                                height: 44,
                                                fit: BoxFit.cover,
                                              ),
                                      )
                                    : Text(
                                        e,
                                        style: const TextStyle(fontSize: 26),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Profil enfant',
                                style: AppTextStyles.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'N\'afficher que des contenus adaptés.',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CupertinoSwitch(
                          value: _isKids,
                          activeTrackColor: AppColors.accentSoft,
                          onChanged: (val) => setState(() => _isKids = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
