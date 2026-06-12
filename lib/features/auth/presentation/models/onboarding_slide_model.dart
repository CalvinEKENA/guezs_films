import 'package:flutter/material.dart';

class OnboardingSlideModel {
  const OnboardingSlideModel({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.assetPath,
    required this.cardTitle,
    required this.cardSubtitle,
    required this.cardIcon,
    this.mobileImageAlignment = Alignment.topCenter,
    this.desktopImageAlignment = Alignment.center,
  });

  final String eyebrow;
  final String title;
  final String description;
  final String assetPath;
  final String cardTitle;
  final String cardSubtitle;
  final IconData cardIcon;
  final Alignment mobileImageAlignment;
  final Alignment desktopImageAlignment;
}

const onboardingSlides = [
  OnboardingSlideModel(
    eyebrow: 'SALLE PRIVÉE · 01',
    title: 'Le cinéma africain, dans son plus bel écrin.',
    description:
        'Découvrez des films, séries et histoires portées par des voix fortes, proches, vraies.',
    assetPath: 'assets/images/onboarding/onboarding_cinema_hall.webp',
    cardTitle: 'Une place vous attend',
    cardSubtitle: 'Installez-vous. La séance commence ici.',
    cardIcon: Icons.event_seat_rounded,
    mobileImageAlignment: Alignment.topCenter,
    desktopImageAlignment: Alignment.topCenter,
  ),
  OnboardingSlideModel(
    eyebrow: 'HISTOIRES · 02',
    title: 'Des histoires qui continuent après l’écran.',
    description:
        'Drames, séries, émotions, réalités, rêves : chaque contenu ouvre une porte.',
    assetPath: 'assets/images/onboarding/onboarding_story_cards.webp',
    cardTitle: 'Des regards singuliers',
    cardSubtitle: 'Des récits proches, intenses et inattendus.',
    cardIcon: Icons.auto_stories_rounded,
    mobileImageAlignment: Alignment.topCenter,
    desktopImageAlignment: Alignment.topCenter,
  ),
  OnboardingSlideModel(
    eyebrow: 'VOTRE RYTHME · 03',
    title: 'Regardez à votre rythme.',
    description:
        'Reprenez, explorez, gardez vos favoris et revenez à vos scènes marquantes.',
    assetPath: 'assets/images/onboarding/onboarding_private_room.webp',
    cardTitle: 'Votre séance, intacte',
    cardSubtitle: 'Reprenez là où l’émotion vous attend.',
    cardIcon: Icons.play_circle_fill_rounded,
    mobileImageAlignment: Alignment.center,
    desktopImageAlignment: Alignment.center,
  ),
  OnboardingSlideModel(
    eyebrow: 'ACCÈS PRIVILÉGIÉ · 04',
    title: 'Entrez quand vous êtes prêt.',
    description:
        'Codes, accès privés, avant-premières : GUEZS FILMS vous rapproche des créations à découvrir.',
    assetPath: 'assets/images/onboarding/onboarding_vip_access.webp',
    cardTitle: 'Invitation GUEZS FILMS',
    cardSubtitle: 'Codes privés et séances en avant-première.',
    cardIcon: Icons.local_activity_rounded,
    mobileImageAlignment: Alignment.topCenter,
    desktopImageAlignment: Alignment.topCenter,
  ),
];
