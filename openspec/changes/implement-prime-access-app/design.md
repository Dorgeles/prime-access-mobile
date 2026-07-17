## Context

Le projet "Prime Access" démarre d'un template Flutter vierge (SDK >=3.11.0). Aucune architecture, aucun service ni écran n'existe actuellement. L'application doit être entièrement construite pour permettre la gestion d'accès à des lieux sécurisés via QR code, avec support hors-ligne pour l'historique des mouvements.

Contraintes existantes : Flutter 3.x, Dart SDK ^3.11.0, Material Design, pas de backend fourni (l'API sera simulée ou abstraite).

## Goals / Non-Goals

**Goals:**
- Architecture évolutive en feature-first avec séparation claire des responsabilités
- Navigation fluide avec bottom nav + routes imbriquées (go_router)
- Support hors-ligne de l'historique avec Hive
- Gestion propre des permissions caméra pour le scan QR
- État global avec Provider pour la session utilisateur et les données
- Validation des formulaires d'authentification

**Non-Goals:**
- Backend réel (API simulée via un service abstrait)
- Tests unitaires et d'intégration (phase ultérieure)
- Internationalisation (i18n)
- Thème sombre (light theme uniquement)
- Notifications push
- Gestion de rôles administrateur

## Decisions

### 1. Architecture : Feature-first avec services centralisés

**Choix** : `lib/features/<feature>/screens/` pour les écrans, `lib/services/` pour la logique métier transversale, `lib/models/` pour les modèles de données, `lib/providers/` pour la gestion d'état.

**Raison** : Cette structure permet de regrouper tout le code lié à une fonctionnalité au même endroit (screens, widgets propres à la feature) tout en partageant les services et modèles communs. C'est le pattern recommandé pour les applis Flutter de taille moyenne.

**Alternative écartée** : Clean Architecture avec use cases/interfaces — trop lourd pour un MVP de cette taille.

### 2. State management : Provider

**Choix** : Package `provider` pour la gestion d'état réactive.

**Raison** : Recommandé par l'équipe Flutter, simple à prendre en main, adapté à la taille du projet. Suffisant pour gérer la session auth, la liste des mouvements et des lieux.

**Alternative écartée** : Riverpod — plus puissant mais plus complexe à configurer. BLoC — trop verbeux pour ce scope.

### 3. Navigation : go_router avec ShellRoute

**Choix** : `go_router` avec `ShellRoute` pour le bottom navigation bar et routes imbriquées.

**Raison** : go_router est le routeur officiel Flutter, supporte nativement les routes imbriquées et le deep linking. ShellRoute permet de conserver le bottom nav actif lors de la navigation entre les onglets.

**Alternative écartée** : Navigator 2.0 vanilla — trop verbeux. AutoRoute — dépendance supplémentaire non nécessaire.

### 4. Stockage local : Hive

**Choix** : `hive` + `hive_flutter` pour le stockage NoSQL local.

**Raison** : Hive est performant, ne nécessite pas de dépendances natives (contrairement à sqflite), idéal pour stocker des objets Dart directement. Parfait pour l'historique hors-ligne sans schéma SQL.

**Alternative écartée** : sqflite — nécessite SQL et des migrations, plus lourd pour un besoin simple. SharedPreferences — trop limité pour des données structurées.

### 5. Client HTTP : http

**Choix** : Package `http` pour les appels API REST.

**Raison** : Léger, natif Dart, suffisant pour les besoins d'auth et de synchro. Facile à mocker pour les tests futurs.

**Alternative écartée** : dio — plus riche (interceptors, retry) mais surdimensionné ici.

### 6. Scan QR : mobile_scanner

**Choix** : `mobile_scanner` pour la lecture de QR codes.

**Raison** : Package maintenu avec support Android/iOS récent, gestion des permissions intégrée, API simple avec flux de détection.

**Alternative écartée** : qr_code_scanner — moins maintenu, problèmes connus sur les versions récentes de Flutter.

## Risks / Trade-offs

- **[Risque] Absence de backend réel** → Les services API seront abstraits derrière une interface pour permettre un remplacement futur sans refonte.
- **[Risque] Hive peut être lent avec beaucoup de données** → L'historique sera paginé au chargement, pas de chargement complet en mémoire.
- **[Risque] Permission caméra refusée** → Prévoir un fallback UI clair avec explication et redirection vers les paramètres.
- **[Trade-off] Provider plutôt que Riverpod** → Moins de testabilité unitaire et pas de support natif du lazy loading, mais plus simple et plus rapide à implémenter.

## Open Questions

- Format exact du QR code (URL, JSON encodé, identifiant de lieu ?) — à définir avec l'équipe backend
- Endpoints API exacts — à documenter quand le backend sera disponible
