import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/responsive_layout.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class LegalSectionData {
  const LegalSectionData({
    required this.icon,
    required this.title,
    required this.paragraphs,
    this.bullets = const [],
  });

  final IconData icon;
  final String title;
  final List<String> paragraphs;
  final List<String> bullets;
}

class LegalPageScaffold extends StatelessWidget {
  const LegalPageScaffold({
    super.key,
    required this.title,
    required this.introduction,
    required this.sections,
    this.notice,
    this.footer = const [],
  });

  final String title;
  final String introduction;
  final List<LegalSectionData> sections;
  final String? notice;
  final List<Widget> footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: ResponsiveLayout(
            builder: (context, responsive) => CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ResponsivePage(
                    maxWidth: 920,
                    padding: EdgeInsets.fromLTRB(
                      responsive.pagePadding,
                      12,
                      responsive.pagePadding,
                      40,
                    ),
                    child: SelectionArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LegalHeader(
                            title: title,
                            introduction: introduction,
                          ),
                          const SizedBox(height: 24),
                          ...sections.map(
                            (section) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _LegalSectionCard(section: section),
                            ),
                          ),
                          ...footer.map(
                            (widget) => Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: widget,
                            ),
                          ),
                          if (notice != null) ...[
                            const SizedBox(height: 22),
                            _LegalNotice(message: notice!),
                          ],
                        ],
                      ),
                    ),
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

class _LegalHeader extends StatelessWidget {
  const _LegalHeader({required this.title, required this.introduction});

  final String title;
  final String introduction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton.filledTonal(
          tooltip: 'Retour',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(Routes.profile);
            }
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(height: 24),
        Text(
          'GUEZS FILMS',
          style: AppTextStyles.overline.copyWith(
            color: AppColors.brandGoldLight,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 9),
        Text(title, style: AppTextStyles.displaySmall),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            introduction,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _LegalSectionCard extends StatelessWidget {
  const _LegalSectionCard({required this.section});

  final LegalSectionData section;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceObsidian.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorder(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.brandBlue.withValues(alpha: 0.46),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  section.icon,
                  color: AppColors.brandGoldLight,
                  size: 21,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(section.title, style: AppTextStyles.titleLarge),
              ),
            ],
          ),
          if (section.paragraphs.isNotEmpty) const SizedBox(height: 15),
          ...section.paragraphs.map(
            (paragraph) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Text(paragraph, style: AppTextStyles.bodyMedium),
            ),
          ),
          ...section.bullets.map(
            (bullet) => Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: Icon(
                      Icons.circle,
                      size: 5,
                      color: AppColors.brandGold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(bullet, style: AppTextStyles.bodyMedium),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalNotice extends StatelessWidget {
  const _LegalNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.brandGold.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brandGold.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.brandGoldLight,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}
