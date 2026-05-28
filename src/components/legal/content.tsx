/* eslint-disable react/no-unescaped-entities */
import Link from "next/link";
import type { LegalPageContent } from "./LegalPage";

const siteQuickLinks = [
  {
    label: "Confidentialité",
    href: "/confidentialite",
    description: "Politique générale de traitement des données du site.",
  },
  {
    label: "CGU",
    href: "/cgu",
    description: "Règles d'utilisation du site GUEZS HOUSE et de ses formulaires.",
  },
  {
    label: "Suppression des données",
    href: "/account-deletion",
    description: "Procédure publique de suppression des comptes et données.",
  },
];

const filmsQuickLinks = [
  {
    label: "Politique GUEZS Films",
    href: "/guezs-films/confidentialite",
    description:
      "Version dédiée à l'application mobile pour le Play Store et les utilisateurs de l'app.",
  },
  {
    label: "CGU GUEZS Films",
    href: "/guezs-films/cgu",
    description: "Conditions d'utilisation spécifiques à l'application mobile.",
  },
  {
    label: "Suppression des données",
    href: "/guezs-films/suppression-des-donnees",
    description:
      "URL dédiée à la suppression des comptes et données rattachés à GUEZS Films.",
  },
];

export const legalMentionsContent: LegalPageContent = {
  eyebrow: "Informations officielles",
  title: "Mentions légales",
  lastUpdated: "31 mars 2026",
  intro: (
    <>
      Cette page présente les informations légales relatives au site{" "}
      <strong>GUEZS HOUSE</strong>, à ses formulaires publics et à la section
      dédiée à l&apos;application mobile <strong>GUEZS Films</strong>.
    </>
  ),
  highlights: [
    {
      label: "Site concerné",
      value: <>guezshouse.com</>,
    },
    {
      label: "Responsable de publication",
      value: <>Yvette Mengue</>,
    },
    {
      label: "Contact",
      value: (
        <a
          href="mailto:contact@guezshouse.com"
          className="text-guezs-gold hover:underline"
        >
          contact@guezshouse.com
        </a>
      ),
    },
  ],
  quickLinks: [...siteQuickLinks, ...filmsQuickLinks.slice(0, 1)],
  sections: [
    {
      title: "Éditeur du site",
      paragraphs: [
        <>
          Le site est édité sous la marque <strong>GUEZS HOUSE</strong> depuis
          Yaoundé, Cameroun.
        </>,
        <>
          Pour toute question institutionnelle, commerciale, juridique ou
          relative à l&apos;application mobile GUEZS Films, vous pouvez écrire à{" "}
          <a
            href="mailto:contact@guezshouse.com"
            className="text-guezs-gold hover:underline"
          >
            contact@guezshouse.com
          </a>{" "}
          ou appeler le <a href="tel:+237697773548">+237 697 77 35 48</a>.
        </>,
      ],
    },
    {
      title: "Direction de la publication",
      paragraphs: [
        <>
          La publication du contenu éditorial, institutionnel et promotionnel du
          site est placée sous la responsabilité de{" "}
          <strong>Yvette Mengue</strong>.
        </>,
      ],
    },
    {
      title: "Hébergement et infrastructure",
      paragraphs: [
        <>
          Le site et certaines pages associées sont hébergés via une
          infrastructure cloud exploitée par Google, notamment{" "}
          <strong>Google Cloud Platform / Firebase</strong>.
        </>,
        <>
          L&apos;hébergement peut évoluer en fonction des besoins techniques,
          sans modification de l&apos;objet de ces mentions.
        </>,
      ],
    },
    {
      title: "Objet du site",
      paragraphs: [
        <>
          Le site présente les activités, services, événements, contenus et
          formulaires liés à GUEZS HOUSE ainsi que des informations de support
          pour la section et l&apos;application <strong>GUEZS Films</strong>.
        </>,
      ],
    },
    {
      title: "Propriété intellectuelle",
      paragraphs: [
        <>
          Les textes, visuels, vidéos, logos, marques, maquettes, interfaces et
          contenus publiés sur le site sont protégés par les droits de
          propriété intellectuelle applicables.
        </>,
        <>
          Toute reproduction, extraction, diffusion ou adaptation non autorisée
          de tout ou partie du site est interdite.
        </>,
      ],
    },
    {
      title: "Responsabilité",
      paragraphs: [
        <>
          GUEZS HOUSE s&apos;efforce de fournir des informations exactes et à
          jour. Malgré ce soin, le site peut contenir des erreurs, omissions ou
          indisponibilités temporaires.
        </>,
        <>
          Les liens vers des services tiers restent soumis aux conditions
          propres de ces services. GUEZS HOUSE n&apos;est pas responsable du
          contenu publié par des sites externes.
        </>,
      ],
    },
    {
      title: "Signalement et contact juridique",
      paragraphs: [
        <>
          Pour signaler un contenu, exercer un droit relatif à vos données, ou
          adresser une demande juridique, merci d&apos;écrire à{" "}
          <a
            href="mailto:contact@guezshouse.com"
            className="text-guezs-gold hover:underline"
          >
            contact@guezshouse.com
          </a>
          .
        </>,
      ],
      note: (
        <>
          Pour l&apos;application mobile GUEZS Films, les documents dédiés sont
          regroupés dans l&apos;espace{" "}
          <Link href="/guezs-films" className="text-guezs-gold hover:underline">
            /guezs-films
          </Link>
          .
        </>
      ),
    },
  ],
  footer: (
    <>
      Si vous devez renseigner des URL officielles dans le Play Store, utilisez
      de préférence les pages dédiées à l&apos;application mobile disponibles
      dans l&apos;espace{" "}
      <Link href="/guezs-films" className="text-guezs-gold hover:underline">
        GUEZS Films
      </Link>
      .
    </>
  ),
};

export const siteCguContent: LegalPageContent = {
  eyebrow: "Règles d'utilisation",
  title: "Conditions générales d'utilisation",
  lastUpdated: "31 mars 2026",
  intro: (
    <>
      Les présentes CGU encadrent l&apos;utilisation du site{" "}
      <strong>GUEZS HOUSE</strong>, de ses formulaires, de sa vitrine
      institutionnelle et de la section dédiée à GUEZS Films. Des règles plus
      ciblées pour l&apos;application mobile sont disponibles sur la page{" "}
      <Link href="/guezs-films/cgu" className="text-guezs-gold hover:underline">
        GUEZS Films / CGU
      </Link>
      .
    </>
  ),
  highlights: [
    {
      label: "Périmètre",
      value: <>Site web, formulaires publics, pages GUEZS Films.</>,
    },
    {
      label: "Acceptation",
      value: <>Toute navigation sur le site implique l'acceptation des CGU.</>,
    },
    {
      label: "Support",
      value: (
        <a
          href="mailto:contact@guezshouse.com"
          className="text-guezs-gold hover:underline"
        >
          contact@guezshouse.com
        </a>
      ),
    },
  ],
  quickLinks: [...filmsQuickLinks, siteQuickLinks[0]],
  sections: [
    {
      title: "Objet",
      paragraphs: [
        <>
          Le site permet de découvrir les univers GUEZS HOUSE, de prendre
          contact avec l&apos;équipe, de manifester un intérêt pour certaines
          offres et d&apos;accéder à des informations publiques sur GUEZS Films.
        </>,
      ],
    },
    {
      title: "Accès au site",
      paragraphs: [
        <>
          L&apos;accès au site est en principe libre et gratuit, sous réserve de
          disposer d&apos;une connexion Internet et d&apos;un équipement
          compatible.
        </>,
        <>
          Certaines fonctionnalités peuvent dépendre de services tiers,
          d&apos;une confirmation par email ou d&apos;une disponibilité
          technique temporaire.
        </>,
      ],
    },
    {
      title: "Utilisation autorisée",
      bullets: [
        <>utiliser le site conformément à sa finalité d'information et de contact,</>,
        <>
          transmettre des informations exactes, à jour et non trompeuses dans
          les formulaires,
        </>,
        <>
          ne pas porter atteinte à la sécurité, à l&apos;intégrité ou à la
          disponibilité du site,
        </>,
        <>
          ne pas reproduire ni exploiter les contenus sans autorisation
          préalable.
        </>,
      ],
    },
    {
      title: "Comportements interdits",
      bullets: [
        <>l&apos;envoi de contenus illicites, diffamatoires ou frauduleux,</>,
        <>l&apos;usurpation d'identité ou l'utilisation d'un faux contact,</>,
        <>
          l&apos;usage automatisé non autorisé, le scraping ou les tentatives
          d&apos;intrusion technique,
        </>,
        <>
          toute utilisation du site d&apos;une manière contraire aux lois
          applicables.
        </>,
      ],
    },
    {
      title: "Disponibilité et limitation de responsabilité",
      paragraphs: [
        <>
          GUEZS HOUSE peut modifier, suspendre ou interrompre tout ou partie du
          site, notamment pour maintenance, sécurité ou évolution éditoriale.
        </>,
        <>
          GUEZS HOUSE ne garantit pas une disponibilité permanente du service et
          n&apos;engage pas sa responsabilité pour les dommages indirects liés à
          l&apos;utilisation du site.
        </>,
      ],
    },
    {
      title: "Données personnelles",
      paragraphs: [
        <>
          Les traitements de données réalisés via le site sont décrits dans la{" "}
          <Link
            href="/confidentialite"
            className="text-guezs-gold hover:underline"
          >
            politique de confidentialité
          </Link>
          .
        </>,
      ],
    },
    {
      title: "Modification des CGU et droit applicable",
      paragraphs: [
        <>
          Les présentes CGU peuvent être modifiées à tout moment. La version
          affichée sur cette page est la version de référence.
        </>,
        <>
          Sauf règle impérative contraire, les présentes CGU sont interprétées
          conformément au droit applicable au Cameroun et tout différend relève
          en priorité d&apos;une tentative de résolution amiable.
        </>,
      ],
    },
  ],
  footer: (
    <>
      Si vous publiez ou exploitez l&apos;application mobile GUEZS Films sur le
      Play Store, utilisez les URL dédiées présentes dans{" "}
      <Link href="/guezs-films" className="text-guezs-gold hover:underline">
        l&apos;espace officiel GUEZS Films
      </Link>
      .
    </>
  ),
};

export const sitePrivacyContent: LegalPageContent = {
  eyebrow: "Protection des données",
  title: "Politique de confidentialité",
  lastUpdated: "31 mars 2026",
  intro: (
    <>
      Cette politique s&apos;applique au site <strong>GUEZS HOUSE</strong>, aux
      formulaires publics, aux demandes de contact et aux parcours associés à
      GUEZS Films. Pour une URL plus explicite destinée à l&apos;application
      mobile, consultez aussi{" "}
      <Link
        href="/guezs-films/confidentialite"
        className="text-guezs-gold hover:underline"
      >
        la politique de confidentialité GUEZS Films
      </Link>
      .
    </>
  ),
  highlights: [
    {
      label: "Responsable",
      value: <>GUEZS HOUSE</>,
    },
    {
      label: "Canal d'exercice des droits",
      value: (
        <a
          href="mailto:contact@guezshouse.com"
          className="text-guezs-gold hover:underline"
        >
          contact@guezshouse.com
        </a>
      ),
    },
    {
      label: "Suppression des données",
      value: (
        <Link
          href="/account-deletion"
          className="text-guezs-gold hover:underline"
        >
          Procédure publique disponible ici
        </Link>
      ),
    },
  ],
  quickLinks: [...filmsQuickLinks, siteQuickLinks[2]],
  sections: [
    {
      title: "Données susceptibles d'être collectées",
      bullets: [
        <>
          données d&apos;identification et de contact fournies volontairement :
          nom, prénom, email, téléphone,
        </>,
        <>
          contenu des messages, demandes de contact, inscriptions ou réponses à
          un formulaire,
        </>,
        <>
          données techniques liées à la navigation ou à l&apos;accès au service
          : adresse IP, navigateur, pages consultées, journaux techniques,
        </>,
        <>
          informations liées à GUEZS Films lorsque vous demandez à être
          recontacté ou utilisez l&apos;application mobile.
        </>,
      ],
    },
    {
      title: "Finalités",
      bullets: [
        <>répondre à vos demandes et assurer un suivi commercial ou éditorial,</>,
        <>gérer les inscriptions à des listes d'intérêt ou événements,</>,
        <>améliorer la sécurité, la performance et la maintenance du site,</>,
        <>
          fournir un support relatif à GUEZS Films, y compris la suppression de
          compte ou de données,
        </>,
        <>respecter les obligations légales et traiter les demandes légitimes.</>,
      ],
    },
    {
      title: "Base de traitement",
      paragraphs: [
        <>
          Selon le contexte, les traitements reposent sur votre consentement,
          l&apos;exécution d&apos;une demande initiée par vous, l&apos;intérêt
          légitime de GUEZS HOUSE à exploiter ses services numériques ou le
          respect d&apos;obligations légales applicables.
        </>,
      ],
    },
    {
      title: "Partage et sous-traitance",
      paragraphs: [
        <>
          Les données peuvent être traitées par des prestataires techniques
          intervenant pour l&apos;hébergement, l&apos;infrastructure, la
          messagerie ou la maintenance.
        </>,
        <>
          GUEZS HOUSE ne vend pas vos données personnelles. Elles ne sont
          communiquées à des tiers que lorsque cela est nécessaire au
          fonctionnement du service, imposé par la loi ou demandé par vous.
        </>,
      ],
    },
    {
      title: "Durée de conservation",
      paragraphs: [
        <>
          Les données sont conservées pendant la durée utile à la finalité pour
          laquelle elles ont été collectées, puis supprimées, archivées ou
          anonymisées selon les contraintes opérationnelles et légales
          applicables.
        </>,
        <>
          Lorsqu&apos;une demande de suppression est validée, les données
          concernées sont supprimées ou désactivées dans un délai raisonnable,
          sous réserve des obligations de sécurité, de preuve ou de conformité.
        </>,
      ],
    },
    {
      title: "Sécurité",
      paragraphs: [
        <>
          GUEZS HOUSE met en œuvre des mesures techniques et organisationnelles
          adaptées pour limiter les accès non autorisés, les pertes, les
          altérations ou les divulgations de données.
        </>,
      ],
    },
    {
      title: "Vos droits",
      bullets: [
        <>demander l'accès aux données vous concernant,</>,
        <>demander la rectification ou la mise à jour de vos informations,</>,
        <>demander l'effacement ou la limitation du traitement,</>,
        <>retirer un consentement lorsque le traitement repose sur celui-ci,</>,
        <>introduire une réclamation auprès de l'autorité compétente si besoin.</>,
      ],
      note: (
        <>
          Les demandes peuvent être adressées à{" "}
          <a
            href="mailto:contact@guezshouse.com"
            className="text-guezs-gold hover:underline"
          >
            contact@guezshouse.com
          </a>{" "}
          ou via la page{" "}
          <Link
            href="/account-deletion"
            className="text-guezs-gold hover:underline"
          >
            Suppression des données
          </Link>
          .
        </>
      ),
    },
    {
      title: "Cookies et mesure d'audience",
      paragraphs: [
        <>
          Le site peut utiliser des traceurs strictement nécessaires au
          fonctionnement et, le cas échéant, des outils techniques de mesure
          d&apos;audience ou de sécurité.
        </>,
      ],
    },
  ],
  footer: (
    <>
      Pour une fiche Play Store, privilégiez l&apos;URL{" "}
      <Link
        href="/guezs-films/confidentialite"
        className="text-guezs-gold hover:underline"
      >
        /guezs-films/confidentialite
      </Link>{" "}
      et la page{" "}
      <Link
        href="/guezs-films/suppression-des-donnees"
        className="text-guezs-gold hover:underline"
      >
        /guezs-films/suppression-des-donnees
      </Link>
      .
    </>
  ),
};

export const accountDeletionContent: LegalPageContent = {
  eyebrow: "Compte et données",
  title: "Politique de suppression des données",
  lastUpdated: "31 mars 2026",
  intro: (
    <>
      Cette page explique comment demander la suppression d&apos;un compte ou de
      données associés à <strong>GUEZS Films</strong> et, plus largement, aux
      services numériques de GUEZS HOUSE.
    </>
  ),
  highlights: [
    {
      label: "Canal de demande",
      value: (
        <a
          href="mailto:contact@guezshouse.com?subject=Suppression%20de%20mon%20compte%20GUEZS%20Films"
          className="text-guezs-gold hover:underline"
        >
          contact@guezshouse.com
        </a>
      ),
    },
    {
      label: "Objet recommandé",
      value: <>Suppression de mon compte GUEZS Films</>,
    },
    {
      label: "Délai cible",
      value: <>Traitement sous 30 jours maximum après vérification.</>,
    },
  ],
  quickLinks: [...filmsQuickLinks, siteQuickLinks[0]],
  sections: [
    {
      title: "Comment faire la demande",
      bullets: [
        <>
          envoyez un email à{" "}
          <a
            href="mailto:contact@guezshouse.com?subject=Suppression%20de%20mon%20compte%20GUEZS%20Films"
            className="text-guezs-gold hover:underline"
          >
            contact@guezshouse.com
          </a>{" "}
          depuis l&apos;adresse liée au compte, si possible,
        </>,
        <>
          indiquez votre nom, l&apos;email du compte concerné et, si utile, le
          numéro de téléphone associé,
        </>,
        <>
          précisez si vous demandez la suppression complète du compte, la
          suppression de certaines données ou simplement la fermeture d&apos;un
          accès inactif.
        </>,
      ],
    },
    {
      title: "Vérification de l'identité",
      paragraphs: [
        <>
          Afin d&apos;éviter les suppressions abusives, GUEZS HOUSE peut vous
          demander une confirmation complémentaire avant d&apos;exécuter la
          suppression.
        </>,
      ],
    },
    {
      title: "Données supprimées ou désactivées",
      bullets: [
        <>profil utilisateur et coordonnées rattachées au compte,</>,
        <>préférences, inscriptions, favoris et historiques liés au compte,</>,
        <>
          données de support ou d&apos;interaction lorsqu&apos;elles ne sont
          plus nécessaires,
        </>,
        <>accès techniques permettant de se reconnecter au compte supprimé.</>,
      ],
    },
    {
      title: "Données pouvant être conservées",
      bullets: [
        <>
          éléments strictement nécessaires au respect d&apos;obligations légales,
          comptables, de sécurité ou de preuve,
        </>,
        <>
          journaux techniques minimaux nécessaires à la prévention de la fraude
          ou à la sécurité des systèmes,
        </>,
        <>
          informations anonymisées ou agrégées ne permettant plus de vous
          identifier directement.
        </>,
      ],
    },
    {
      title: "Effets de la suppression",
      paragraphs: [
        <>
          Une fois la demande exécutée, l&apos;accès au compte est désactivé et
          les données concernées ne peuvent plus être restaurées, sauf
          conservation légale obligatoire.
        </>,
      ],
    },
    {
      title: "Besoin d'aide",
      paragraphs: [
        <>
          Toute question liée à la confidentialité ou à la suppression des
          données peut être adressée à{" "}
          <a
            href="mailto:contact@guezshouse.com"
            className="text-guezs-gold hover:underline"
          >
            contact@guezshouse.com
          </a>
          .
        </>,
      ],
      note: (
        <>
          Cette page est prévue pour être utilisée comme URL publique de
          suppression des données dans le cadre de GUEZS Films et des exigences
          du Play Store.
        </>
      ),
    },
  ],
  footer: (
    <>
      URL dédiée pour l&apos;application mobile :{" "}
      <Link
        href="/guezs-films/suppression-des-donnees"
        className="text-guezs-gold hover:underline"
      >
        /guezs-films/suppression-des-donnees
      </Link>
      .
    </>
  ),
};

export const filmsHubContent: LegalPageContent = {
  eyebrow: "Application mobile",
  title: "GUEZS Films",
  lastUpdated: "31 mars 2026",
  intro: (
    <>
      Espace officiel de support, de confidentialité et de conformité pour
      l&apos;application mobile <strong>GUEZS Films</strong>.
    </>
  ),
  highlights: [
    {
      label: "Usage principal",
      value: <>Support public et documents officiels pour l'application.</>,
    },
    {
      label: "Support",
      value: (
        <a
          href="mailto:contact@guezshouse.com"
          className="text-guezs-gold hover:underline"
        >
          contact@guezshouse.com
        </a>
      ),
    },
    {
      label: "Site vitrine",
      value: (
        <Link href="/#guezs-films" className="text-guezs-gold hover:underline">
          Section GUEZS Films du site
        </Link>
      ),
    },
  ],
  quickLinks: filmsQuickLinks,
  sections: [
    {
      title: "À quoi sert cette page",
      paragraphs: [
        <>
          Cette page centralise les documents dont les utilisateurs et les
          stores d&apos;applications peuvent avoir besoin : politique de
          confidentialité, conditions d&apos;utilisation, procédure de
          suppression des données et point de contact support.
        </>,
      ],
    },
    {
      title: "Documents disponibles",
      bullets: [
        <>
          <Link
            href="/guezs-films/confidentialite"
            className="text-guezs-gold hover:underline"
          >
            Politique de confidentialité GUEZS Films
          </Link>
        </>,
        <>
          <Link
            href="/guezs-films/cgu"
            className="text-guezs-gold hover:underline"
          >
            Conditions d'utilisation GUEZS Films
          </Link>
        </>,
        <>
          <Link
            href="/guezs-films/suppression-des-donnees"
            className="text-guezs-gold hover:underline"
          >
            Politique de suppression des données
          </Link>
        </>,
      ],
    },
    {
      title: "Contact",
      paragraphs: [
        <>
          Pour toute question sur l&apos;application, l&apos;assistance,
          l&apos;utilisation des données ou une demande liée au compte, écrivez
          à{" "}
          <a
            href="mailto:contact@guezshouse.com"
            className="text-guezs-gold hover:underline"
          >
            contact@guezshouse.com
          </a>
          .
        </>,
      ],
    },
  ],
  footer: (
    <>
      Cette page peut servir de support URL publique pour GUEZS Films. Pour la
      confidentialité et la suppression des données, utilisez de préférence les
      URLs spécifiques listées ci-dessus.
    </>
  ),
};

export const filmsPrivacyContent: LegalPageContent = {
  eyebrow: "Application mobile",
  title: "Politique de confidentialité GUEZS Films",
  lastUpdated: "31 mars 2026",
  intro: (
    <>
      Cette politique décrit la manière dont les données personnelles sont
      traitées dans le cadre de l&apos;application mobile{" "}
      <strong>GUEZS Films</strong> et des demandes de support qui y sont liées.
    </>
  ),
  highlights: [
    {
      label: "Application concernée",
      value: <>GUEZS Films</>,
    },
    {
      label: "Support",
      value: (
        <a
          href="mailto:contact@guezshouse.com"
          className="text-guezs-gold hover:underline"
        >
          contact@guezshouse.com
        </a>
      ),
    },
    {
      label: "Suppression des données",
      value: (
        <Link
          href="/guezs-films/suppression-des-donnees"
          className="text-guezs-gold hover:underline"
        >
          URL publique dédiée
        </Link>
      ),
    },
  ],
  quickLinks: filmsQuickLinks,
  sections: [
    {
      title: "Données pouvant être traitées",
      bullets: [
        <>
          données de compte et de contact : nom, email, téléphone ou identifiant
          utilisateur,
        </>,
        <>
          informations que vous transmettez volontairement via l&apos;app ou le
          support,
        </>,
        <>
          données techniques nécessaires au fonctionnement du service, à la
          sécurité et au diagnostic,
        </>,
        <>
          informations relatives à vos préférences ou à votre historique
          d&apos;utilisation lorsque ces fonctionnalités existent dans l&apos;app.
        </>,
      ],
    },
    {
      title: "Pourquoi ces données sont utilisées",
      bullets: [
        <>créer, administrer ou sécuriser un compte utilisateur,</>,
        <>faire fonctionner les fonctionnalités proposées dans l'application,</>,
        <>répondre aux demandes de support et de suppression de compte,</>,
        <>améliorer la qualité, la stabilité et la sécurité du service,</>,
        <>respecter les obligations légales applicables.</>,
      ],
    },
    {
      title: "Partage des données",
      paragraphs: [
        <>
          Les données ne sont pas vendues. Elles peuvent être confiées à des
          prestataires techniques lorsque cela est nécessaire à
          l&apos;hébergement, au support, à la sécurité ou à la messagerie.
        </>,
      ],
    },
    {
      title: "Conservation",
      paragraphs: [
        <>
          Les données sont conservées aussi longtemps que nécessaire pour faire
          fonctionner le compte, fournir le support demandé et respecter les
          obligations applicables. Une suppression peut être demandée à tout
          moment selon la procédure dédiée.
        </>,
      ],
    },
    {
      title: "Sécurité",
      paragraphs: [
        <>
          Des mesures raisonnables sont mises en œuvre pour protéger les données
          contre l&apos;accès non autorisé, la perte, la divulgation ou
          l&apos;altération.
        </>,
      ],
    },
    {
      title: "Vos droits",
      bullets: [
        <>accéder à vos données et en demander une copie,</>,
        <>corriger des informations inexactes,</>,
        <>demander la suppression du compte ou de certaines données,</>,
        <>
          vous opposer à certains traitements lorsque la loi applicable le
          permet.
        </>,
      ],
      note: (
        <>
          Pour exercer ces droits, utilisez la page{" "}
          <Link
            href="/guezs-films/suppression-des-donnees"
            className="text-guezs-gold hover:underline"
          >
            Suppression des données
          </Link>{" "}
          ou contactez{" "}
          <a
            href="mailto:contact@guezshouse.com"
            className="text-guezs-gold hover:underline"
          >
            contact@guezshouse.com
          </a>
          .
        </>
      ),
    },
  ],
  footer: (
    <>
      Cette page est conçue pour être utilisée comme URL de politique de
      confidentialité publique de l&apos;application GUEZS Films.
    </>
  ),
};

export const filmsCguContent: LegalPageContent = {
  eyebrow: "Application mobile",
  title: "Conditions d'utilisation GUEZS Films",
  lastUpdated: "31 mars 2026",
  intro: (
    <>
      Ces conditions encadrent l&apos;accès et l&apos;utilisation de
      l&apos;application mobile <strong>GUEZS Films</strong>.
    </>
  ),
  highlights: [
    {
      label: "Application",
      value: <>GUEZS Films</>,
    },
    {
      label: "Support",
      value: (
        <a
          href="mailto:contact@guezshouse.com"
          className="text-guezs-gold hover:underline"
        >
          contact@guezshouse.com
        </a>
      ),
    },
    {
      label: "Confidentialité",
      value: (
        <Link
          href="/guezs-films/confidentialite"
          className="text-guezs-gold hover:underline"
        >
          Politique dédiée
        </Link>
      ),
    },
  ],
  quickLinks: filmsQuickLinks,
  sections: [
    {
      title: "Acceptation",
      paragraphs: [
        <>
          L&apos;installation, l&apos;accès ou l&apos;utilisation de GUEZS Films
          implique l&apos;acceptation des présentes conditions.
        </>,
      ],
    },
    {
      title: "Accès au service",
      paragraphs: [
        <>
          Certaines fonctionnalités peuvent nécessiter la création d&apos;un
          compte, la fourniture d&apos;informations exactes ou une connexion
          Internet active.
        </>,
      ],
    },
    {
      title: "Engagements de l'utilisateur",
      bullets: [
        <>utiliser l'application conformément à sa finalité,</>,
        <>fournir des informations exactes et personnelles,</>,
        <>
          respecter les droits de propriété intellectuelle et les autres
          utilisateurs,
        </>,
        <>
          ne pas perturber le fonctionnement ou contourner les mécanismes de
          sécurité.
        </>,
      ],
    },
    {
      title: "Compte et sécurité",
      paragraphs: [
        <>
          Vous êtes responsable des actions réalisées via votre compte et devez
          protéger vos identifiants, le cas échéant.
        </>,
      ],
    },
    {
      title: "Disponibilité et évolution",
      paragraphs: [
        <>
          GUEZS HOUSE peut faire évoluer, corriger, suspendre ou interrompre
          certaines fonctionnalités de GUEZS Films sans garantie de
          disponibilité permanente.
        </>,
      ],
    },
    {
      title: "Propriété intellectuelle",
      paragraphs: [
        <>
          L&apos;application, ses éléments visuels, son nom, sa charte et ses
          contenus demeurent protégés par les droits applicables.
        </>,
      ],
    },
    {
      title: "Suppression du compte et contact",
      paragraphs: [
        <>
          Vous pouvez demander la suppression de votre compte à tout moment via{" "}
          <Link
            href="/guezs-films/suppression-des-donnees"
            className="text-guezs-gold hover:underline"
          >
            la page dédiée
          </Link>
          .
        </>,
        <>
          Toute question peut être adressée à{" "}
          <a
            href="mailto:contact@guezshouse.com"
            className="text-guezs-gold hover:underline"
          >
            contact@guezshouse.com
          </a>
          .
        </>,
      ],
    },
  ],
  footer: (
    <>
      Ces conditions complètent les CGU générales du site, mais priment pour
      l&apos;usage spécifique de l&apos;application mobile GUEZS Films.
    </>
  ),
};
