// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Hasi';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get myDashboards => 'Mes tableaux de bord';

  @override
  String get addDashboard => 'Ajouter un tableau de bord';

  @override
  String get newDashboard => 'Nouveau tableau de bord';

  @override
  String get dashboardName => 'Nom du tableau de bord';

  @override
  String get cancel => 'Annuler';

  @override
  String get create => 'Créer';

  @override
  String get logout => 'Déconnexion';

  @override
  String get appearance => 'Apparence';

  @override
  String get editDashboard => 'Modifier le tableau de bord';

  @override
  String get includedDomains => 'Domaines inclus';

  @override
  String get specificEntities => 'Entités spécifiques';

  @override
  String get selectSpecificEntities =>
      'Sélectionnez des entités spécifiques à afficher même si leur domaine n\'est pas sélectionné ci-dessus.';

  @override
  String get connectingToHA => 'Connexion à Home Assistant...';

  @override
  String get noEntitiesFound => 'Aucune entité trouvée.';

  @override
  String get noEntitiesMatch =>
      'Aucune entité ne correspond à ce tableau de bord.';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get glassmorphism => 'Effet glassmorphism';

  @override
  String get glassmorphismSub => 'Cartes semi-transparentes avec flou';

  @override
  String get accentColor => 'Couleur d\'accentuation';

  @override
  String get brightness => 'Luminosité';

  @override
  String get current => 'Actuel';

  @override
  String get heat => 'Chauffage';

  @override
  String get cool => 'Refroidissement';

  @override
  String get off => 'Arrêt';

  @override
  String get auto => 'Auto';

  @override
  String get refresh => 'Actualiser';

  @override
  String get playing => 'Lecture';

  @override
  String get paused => 'En pause';

  @override
  String get cameraUnavailable => 'Caméra indisponible';

  @override
  String get noHistoryData => 'Pas de données d\'historique';

  @override
  String get language => 'Langue';

  @override
  String get english => 'Anglais';

  @override
  String get german => 'Allemand';

  @override
  String get spanish => 'Espagnol';

  @override
  String get french => 'Français';

  @override
  String get systemDefault => 'Par défaut du système';

  @override
  String get layout => 'Mise en page';

  @override
  String get columns => 'Colonnes';

  @override
  String get entitiesToDisplay => 'Entités à afficher';

  @override
  String get manuallySelectEntities =>
      'Sélectionnez manuellement chaque entité que vous souhaitez sur le tableau de bord.';

  @override
  String get selected => 'Sélectionné';

  @override
  String get searchEntities => 'Rechercher des entités...';

  @override
  String get deselectAll => 'Tout désélectionner';

  @override
  String get deleteDashboard => 'Supprimer le tableau de bord';

  @override
  String deleteConfirm(Object name) {
    return 'Êtes-vous sûr de vouloir supprimer \"$name\" ?';
  }

  @override
  String get delete => 'Supprimer';

  @override
  String get save => 'Enregistrer';

  @override
  String get findByArea => 'Trouver par zone';

  @override
  String get noAreasFound => 'Aucune zone trouvée';

  @override
  String get setAsDefault => 'Définir par défaut';

  @override
  String get defaultDashboardSub =>
      'Ce tableau de bord s\'ouvrira automatiquement au démarrage de l\'application.';

  @override
  String get cannotDeleteLastDashboard =>
      'Impossible de supprimer le dernier tableau de bord. Au moins un tableau de bord est requis.';

  @override
  String get setupDashboards => 'Setup Dashboards';

  @override
  String get createDashboards => 'Create Dashboards';

  @override
  String get noAreasFoundSetup => 'No Areas Found';

  @override
  String get noAreasFoundSetupSub =>
      'Create areas in Home Assistant to organize your entities, or create an empty dashboard to get started.';

  @override
  String get createEmptyDashboard => 'Create Empty Dashboard';

  @override
  String get welcomeToHasi => 'Welcome to Hasi!';

  @override
  String get selectAreasToCreateDashboards =>
      'Select areas to automatically create dashboards for each one.';

  @override
  String get areasSelected => 'areas selected';

  @override
  String get entity => 'entity';

  @override
  String get entities => 'entities';

  @override
  String get editMode => 'Edit Mode';
}
