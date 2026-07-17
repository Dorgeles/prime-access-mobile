## 1. Configuration et dépendances

- [x] 1.1 Ajouter les dépendances au `pubspec.yaml` (go_router, hive, hive_flutter, http, mobile_scanner, provider, permission_handler si nécessaire)
- [x] 1.2 Configurer les permissions caméra dans `AndroidManifest.xml` (android) et `Info.plist` (ios)
- [x] 1.3 Créer le thème et la configuration de l'app dans `lib/config/theme.dart`

## 2. Modèles de données

- [x] 2.1 Créer le modèle `User` (`lib/models/user.dart`)
- [x] 2.2 Créer le modèle `Movement` (`lib/models/movement.dart`) avec champ syncStatus
- [x] 2.3 Créer le modèle `Place` (`lib/models/place.dart`)

## 3. Services

- [x] 3.1 Créer `HiveService` (`lib/services/hive_service.dart`) pour l'initialisation et les opérations CRUD sur l'historique des mouvements
- [x] 3.2 Créer `ApiService` (`lib/services/api_service.dart`) comme classe abstraite avec une implémentation simulée (endpoints auth, mouvements, lieux, profil)
- [x] 3.3 Créer `AuthService` (`lib/services/auth_service.dart`) pour gérer login, register, logout, persistance du token

## 4. Providers (gestion d'état)

- [x] 4.1 Créer `AuthProvider` (`lib/providers/auth_provider.dart`) gérant l'état d'authentification, login, register, logout
- [x] 4.2 Créer `MovementProvider` (`lib/providers/movement_provider.dart`) gérant la liste des mouvements, CRUD, filtres, sync
- [x] 4.3 Créer `PlaceProvider` (`lib/providers/place_provider.dart`) gérant la liste des lieux et la recherche

## 5. Navigation

- [x] 5.1 Créer la configuration `go_router` (`lib/routes/router.dart`) avec ShellRoute pour le bottom nav (Dashboard, History, Places, Profile) et routes autonomes (Login, Register, Scanner, Confirmation, PlaceDetail)

## 6. Fonctionnalité Authentification

- [x] 6.1 Créer `LoginScreen` (`lib/features/auth/screens/login_screen.dart`) avec formulaire email/mot de passe et validation
- [x] 6.2 Créer `RegisterScreen` (`lib/features/auth/screens/register_screen.dart`) avec formulaire nom/email/mot de passe et validation
- [x] 6.3 Créer le redirect de garde auth dans le router (redirige vers login si non authentifié, vers dashboard si authentifié)

## 7. Fonctionnalité Dashboard

- [x] 7.1 Créer `DashboardScreen` (`lib/features/dashboard/screens/dashboard_screen.dart`) avec affichage du dernier mouvement et bouton scanner
- [x] 7.2 Créer le widget du dernier mouvement avec états : chargement, affichage, vide

## 8. Fonctionnalité Scan QR

- [x] 8.1 Créer `ScannerScreen` (`lib/features/qr_scan/screens/scanner_screen.dart`) avec gestion des permissions caméra et flux de détection
- [x] 8.2 Créer `ConfirmationScreen` (`lib/features/qr_scan/screens/confirmation_screen.dart`) avec inférence du type de mouvement (entrée/sortie) et boutons confirmer/annuler

## 9. Fonctionnalité Historique

- [x] 9.1 Créer `HistoryScreen` (`lib/features/history/screens/history_screen.dart`) avec liste chronologique des mouvements depuis Hive
- [x] 9.2 Créer les widgets de filtres (date picker, dropdown lieu, dropdown type) et logique de filtrage combiné

## 10. Fonctionnalité Gestion des lieux

- [x] 10.1 Créer `PlacesScreen` (`lib/features/places/screens/places_screen.dart`) avec liste et barre de recherche
- [x] 10.2 Créer `PlaceDetailScreen` (`lib/features/places/screens/place_detail_screen.dart`) avec vue détaillée du lieu

## 11. Fonctionnalité Profil

- [x] 11.1 Créer `ProfileScreen` (`lib/features/profile/screens/profile_screen.dart`) avec affichage des infos utilisateur et boutons logout / edit
- [x] 11.2 Créer `EditProfileScreen` (`lib/features/profile/screens/edit_profile_screen.dart`) avec formulaire de modification nom/email et validation

## 12. Assemblage final

- [x] 12.1 Remplacer `main.dart` par l'initialisation des services (Hive, Provider, Router) et le lancement de l'app
- [x] 12.2 Tester la navigation complète et le flux utilisateur de bout en bout
