import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/premium_feedback.dart';
import '../widgets/legal_page_scaffold.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  static final _sections = [
    const LegalSectionData(
      icon: Icons.manage_accounts_outlined,
      title: 'Assistance compte',
      paragraphs: [
        'Nous pouvons vous aider pour la connexion, la création de compte, les profils, les favoris ou la suppression de compte.',
      ],
    ),
    const LegalSectionData(
      icon: Icons.key_rounded,
      title: 'Accès vidéo et codes',
      paragraphs: [
        'Si un contenu demande un code ambassadeur, vérifiez sa saisie, sa période de validité et le contenu auquel il est associé.',
      ],
    ),
    const LegalSectionData(
      icon: Icons.play_circle_outline_rounded,
      title: 'Problème de lecture',
      paragraphs: [
        'En cas de lecture impossible, contrôlez votre connexion puis réessayez. Indiquez au support le titre concerné et le message affiché.',
      ],
    ),
    const LegalSectionData(
      icon: Icons.download_for_offline_outlined,
      title: 'Téléchargements',
      paragraphs: [
        'Les téléchargements hors-ligne sont actuellement réservés à l’application mobile et dépendent de l’espace disponible sur l’appareil.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LegalPageScaffold(
      title: 'Support GUEZS FILMS',
      introduction:
          'Notre équipe vous accompagne pour toute question liée à votre compte, à l’accès aux contenus, aux codes ambassadeurs, aux paiements futurs ou à la lecture vidéo.',
      sections: _sections,
      footer: [const _ContactCard()],
      notice:
          'Pour un traitement rapide, indiquez votre adresse email de compte, le titre du film ou de la série concernée et une capture du message d’erreur.',
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardObsidian,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorder(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contact', style: AppTextStyles.titleLarge),
          const SizedBox(height: 12),
          _ContactRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: 'support@guezsfilms.com',
            onTap: () => _openEmail(context),
          ),
          const Divider(height: 22),
          const _ContactRow(
            icon: Icons.chat_outlined,
            label: 'WhatsApp',
            value: 'À renseigner',
          ),
          const Divider(height: 22),
          const _ContactRow(
            icon: Icons.schedule_rounded,
            label: 'Horaires',
            value: 'Tous les jours, 9h – 18h',
          ),
        ],
      ),
    );
  }

  Future<void> _openEmail(BuildContext context) async {
    final opened = await launchUrl(
      Uri(scheme: 'mailto', path: 'support@guezsfilms.com'),
    );
    if (!opened && context.mounted) {
      showPremiumSnackBar(
        context,
        message: 'Ouvrez votre messagerie et écrivez à support@guezsfilms.com.',
        tone: PremiumFeedbackTone.info,
      );
    }
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(icon, color: AppColors.brandGoldLight),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTextStyles.labelMedium),
                    const SizedBox(height: 2),
                    Text(value, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.open_in_new_rounded,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
