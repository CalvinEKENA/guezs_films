import 'package:flutter/material.dart';

import '../widgets/legal_page_scaffold.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const _sections = [
    LegalSectionData(
      icon: Icons.inventory_2_outlined,
      title: 'Données collectées',
      paragraphs: [
        'GUEZS FILMS peut collecter les informations de compte, les profils créés, les favoris, les données techniques de session et les informations nécessaires à l’accès aux contenus.',
      ],
    ),
    LegalSectionData(
      icon: Icons.tune_rounded,
      title: 'Utilisation des données',
      paragraphs: ['Les données sont utilisées pour:'],
      bullets: [
        'créer et sécuriser le compte;',
        'gérer l’accès aux films et séries;',
        'améliorer l’expérience;',
        'diagnostiquer les erreurs;',
        'prévenir la fraude.',
      ],
    ),
    LegalSectionData(
      icon: Icons.person_outline_rounded,
      title: 'Données de compte',
      paragraphs: [
        'L’adresse email, le nom d’affichage, les méthodes de connexion et les profils servent à identifier l’utilisateur et personnaliser son espace.',
      ],
    ),
    LegalSectionData(
      icon: Icons.play_circle_outline_rounded,
      title: 'Données de lecture',
      paragraphs: [
        'La position de reprise est actuellement enregistrée localement. Des informations techniques de lecture pourront être utilisées pour mesurer le démarrage, les interruptions et les erreurs.',
      ],
    ),
    LegalSectionData(
      icon: Icons.key_outlined,
      title: 'Codes d’accès et sessions',
      paragraphs: [
        'Les codes sont vérifiés côté serveur. Le code brut n’est pas conservé dans Firestore; une empreinte cryptographique et des informations de consommation peuvent être enregistrées.',
      ],
    ),
    LegalSectionData(
      icon: Icons.payments_outlined,
      title: 'Paiements futurs',
      paragraphs: [
        'Aucun paiement réel n’est actuellement intégré. Si cette fonction est ajoutée, les données de paiement seront traitées par un prestataire spécialisé et la politique sera complétée.',
      ],
    ),
    LegalSectionData(
      icon: Icons.security_rounded,
      title: 'Stockage et sécurité',
      paragraphs: [
        'Les données sont hébergées à l’aide de services Firebase. Des contrôles d’accès, règles serveur et mesures de sécurité sont appliqués selon la nature des données.',
      ],
    ),
    LegalSectionData(
      icon: Icons.share_outlined,
      title: 'Partage avec des tiers',
      paragraphs: [
        'Les données ne sont pas vendues. Elles peuvent être traitées par les prestataires techniques nécessaires au fonctionnement, à la sécurité et à l’hébergement du service.',
      ],
    ),
    LegalSectionData(
      icon: Icons.schedule_outlined,
      title: 'Durée de conservation',
      paragraphs: [
        'Les données sont conservées pendant la durée nécessaire au service, aux obligations applicables et à la prévention des abus. Les sessions techniques peuvent avoir une durée plus courte.',
      ],
    ),
    LegalSectionData(
      icon: Icons.verified_user_outlined,
      title: 'Droits de l’utilisateur',
      paragraphs: [
        'L’utilisateur peut demander l’accès, la correction ou la suppression de ses données, sous réserve des obligations légales et de sécurité applicables.',
      ],
    ),
    LegalSectionData(
      icon: Icons.email_outlined,
      title: 'Contact',
      paragraphs: [
        'Pour toute question relative aux données personnelles: support@guezsfilms.com.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const LegalPageScaffold(
      title: 'Politique de confidentialité',
      introduction:
          'Cette politique explique de manière claire comment GUEZS FILMS utilise les données nécessaires à son fonctionnement et à la protection des accès.',
      sections: _sections,
      notice:
          'Cette politique pourra être mise à jour avant le lancement public.',
    );
  }
}
