## Why

L'application "Prime Access" est nécéssaire pour gérer les accès à des lieux sécurisés via QR code. Elle permet aux utilisateurs de s'authentifier, scanner des QR codes aux points d'entrée, consulter leur historique de mouvements et gérer leurs informations de profil. Le projet part d'un template Flutter vierge et doit être entièrement construit.

## What Changes

- Mise en place d'un système d'authentification complet (connexion, inscription, validation des champs)
- Création d'un dashboard avec affichage du dernier mouvement enregistré et raccourci vers le scanner QR
- Implémentation d'un scanner QR avec demande de permission caméra, détection, confirmation et enregistrement local + distant du mouvement
- Construction d'un écran d'historique des mouvements avec filtres par date, lieu et type de mouvement (entrée/sortie)
- Développement d'un écran de gestion des lieux avec liste et recherche
- Mise en place d'un écran de profil permettant la modification des informations utilisateur
- Navigation complète avec `go_router` : bottom navigation bar et routes imbriquées
- Stockage local avec `hive` pour l'historique des mouvements en mode hors-ligne
- Intégration d'une API REST pour l'authentification et la synchronisation des données
- Remplacement complet du code boilerplate Flutter existant (app compteur)

## Capabilities

### New Capabilities
- `authentication`: Inscription, connexion, validation des formulaires, gestion de session et déconnexion
- `dashboard`: Vue d'accueil affichant le dernier mouvement enregistré et un bouton d'accès rapide au scanner QR
- `qr-scan`: Scan de QR code avec permission caméra, détection du contenu, écran de confirmation et enregistrement du mouvement (entrée/sortie)
- `movement-history`: Liste chronologique des mouvements avec filtres par date, lieu et type, avec support hors-ligne via Hive
- `place-management`: Liste des lieux disponibles avec barre de recherche et vue détaillée
- `user-profile`: Affichage et modification des informations du profil utilisateur (nom, email, photo)

### Modified Capabilities
<!-- Aucune capacité existante à modifier, le projet démarre d'un template vierge -->

## Impact

- **Code** : Remplacement intégral de `lib/main.dart` et ajout de l'arborescence complète dans `lib/` (features, services, models, routes, widgets)
- **Dépendances** : Ajout de `go_router`, `hive`, `hive_flutter`, `http` (ou `dio`), `mobile_scanner` (ou équivalent), `provider` (ou `riverpod`) dans `pubspec.yaml`
- **Configuration** : Ajout des permissions caméra dans `android/app/src/main/AndroidManifest.xml` et `ios/Runner/Info.plist`
- **API** : Définition des endpoints REST pour auth et synchronisation (backend non fourni, simulation ou service abstrait)
