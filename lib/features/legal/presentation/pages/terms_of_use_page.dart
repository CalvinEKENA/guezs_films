import 'package:flutter/material.dart';

import '../widgets/legal_page_scaffold.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  static const _sections = [
    LegalSectionData(
      icon: Icons.movie_creation_outlined,
      title: 'Objet du service',
      paragraphs: [
        'GUEZS FILMS donne accès à un catalogue de films, séries et contenus éditoriaux selon les disponibilités et droits associés.',
      ],
    ),
    LegalSectionData(
      icon: Icons.person_add_alt_rounded,
      title: 'Création de compte',
      paragraphs: [
        'L’utilisateur doit fournir des informations exactes, protéger ses identifiants et signaler toute utilisation non autorisée de son compte.',
      ],
    ),
    LegalSectionData(
      icon: Icons.lock_open_rounded,
      title: 'Accès aux contenus',
      paragraphs: [
        'Certains contenus peuvent nécessiter un code, un pass ou un accès premium. Les droits peuvent être limités dans le temps ou à un contenu précis.',
      ],
    ),
    LegalSectionData(
      icon: Icons.key_rounded,
      title: 'Codes ambassadeurs',
      paragraphs: [
        'Les codes ambassadeurs sont personnels ou soumis aux conditions de la campagne concernée. Ils peuvent expirer, être limités en nombre d’utilisations ou être désactivés en cas d’abus.',
      ],
    ),
    LegalSectionData(
      icon: Icons.person_outline_rounded,
      title: 'Usage personnel',
      paragraphs: [
        'Les contenus sont destinés à un usage personnel et privé, dans le respect des droits des producteurs, auteurs et ayants droit.',
      ],
    ),
    LegalSectionData(
      icon: Icons.block_rounded,
      title: 'Interdiction de partage non autorisé',
      paragraphs: [
        'Le partage d’accès, la copie, la redistribution, l’enregistrement ou la diffusion de vidéos sans autorisation sont interdits.',
      ],
    ),
    LegalSectionData(
      icon: Icons.cloud_outlined,
      title: 'Disponibilité du service',
      paragraphs: [
        'Le service peut être interrompu pour maintenance, incident réseau, indisponibilité d’un fournisseur ou évolution du catalogue. Une disponibilité permanente ne peut être garantie.',
      ],
    ),
    LegalSectionData(
      icon: Icons.download_for_offline_outlined,
      title: 'Téléchargements',
      paragraphs: [
        'Les téléchargements autorisés restent réservés à l’application et à l’appareil concerné. Ils ne donnent aucun droit de copie ou de redistribution.',
      ],
    ),
    LegalSectionData(
      icon: Icons.balance_outlined,
      title: 'Responsabilités',
      paragraphs: [
        'L’utilisateur est responsable de son équipement, de sa connexion et de l’usage de son compte. GUEZS FILMS s’efforce de fournir un service fiable dans les limites techniques raisonnables.',
      ],
    ),
    LegalSectionData(
      icon: Icons.person_off_outlined,
      title: 'Suspension de compte',
      paragraphs: [
        'Un compte ou un accès peut être suspendu en cas de fraude, partage abusif, atteinte à la sécurité ou violation grave des présentes conditions.',
      ],
    ),
    LegalSectionData(
      icon: Icons.update_rounded,
      title: 'Évolution du service',
      paragraphs: [
        'Le catalogue, les modalités d’accès et les fonctionnalités de paiement peuvent évoluer. Les changements importants seront présentés de manière appropriée.',
      ],
    ),
    LegalSectionData(
      icon: Icons.email_outlined,
      title: 'Contact',
      paragraphs: [
        'Pour toute question concernant ces conditions: support@guezsfilms.com.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const LegalPageScaffold(
      title: 'Conditions d’utilisation',
      introduction:
          'Ces conditions encadrent l’utilisation de GUEZS FILMS et la protection des contenus proposés sur la plateforme.',
      sections: _sections,
      notice:
          'Ces conditions constituent une base de travail et pourront être adaptées par un conseil juridique avant lancement public.',
    );
  }
}
