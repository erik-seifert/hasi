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
  String get dashboardSettings => 'Paramètres du tableau de bord';

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
  String get setupDashboards => 'Configurer les tableaux de bord';

  @override
  String get createDashboards => 'Créer des tableaux de bord';

  @override
  String get noAreasFoundSetup => 'Aucune zone trouvée';

  @override
  String get noAreasFoundSetupSub =>
      'Créez des zones dans Home Assistant pour organiser vos entités, ou créez un tableau de bord vide pour commencer.';

  @override
  String get createEmptyDashboard => 'Créer un tableau de bord vide';

  @override
  String get welcomeToHasi => 'Bienvenue sur Hasi !';

  @override
  String get selectAreasToCreateDashboards =>
      'Sélectionnez des zones pour créer automatiquement des tableaux de bord pour chacune.';

  @override
  String get areasSelected => 'zones sélectionnées';

  @override
  String get entity => 'entité';

  @override
  String get entities => 'entités';

  @override
  String get editMode => 'Mode édition';

  @override
  String get connectToHA => 'Se connecter à Home Assistant';

  @override
  String get discovery => 'Découverte';

  @override
  String get searchingForHA => 'Recherche d\'instances Home Assistant...';

  @override
  String get token => 'Jeton';

  @override
  String get credentials => 'Identifiants';

  @override
  String get longLivedToken => 'Jeton d\'accès longue durée';

  @override
  String get pasteToken => 'Coller le jeton';

  @override
  String get scanQRCode => 'Scanner le code QR';

  @override
  String get connectWithToken => 'Se connecter avec un jeton';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get password => 'Mot de passe';

  @override
  String get connectWithCredentials => 'Se connecter avec des identifiants';

  @override
  String get haUrl => 'URL Home Assistant';

  @override
  String get pleaseEnterUrl => 'Veuillez entrer l\'URL';

  @override
  String get pleaseEnterToken => 'Veuillez entrer le jeton';

  @override
  String get pleaseEnterUsername => 'Veuillez entrer le nom d\'utilisateur';

  @override
  String get pleaseEnterPassword => 'Veuillez entrer le mot de passe';

  @override
  String get loginFailed => 'Échec de la connexion';

  @override
  String get retry => 'Réessayer';

  @override
  String get assist => 'Assistant';

  @override
  String get assistCommandError => 'Je n\'ai pas pu traiter cette commande.';

  @override
  String get assistTypeCommand => 'Tapez une commande...';

  @override
  String get assistListening => 'Écoute...';

  @override
  String get ttsTest => 'Test TTS';

  @override
  String get ttsEngineStatus => 'État du moteur TTS';

  @override
  String ttsUsingNative(Object engine) {
    return 'Utilisation du TTS natif Linux : $engine';
  }

  @override
  String get ttsUsingFallback => 'Utilisation de flutter_tts (secours)';

  @override
  String get ttsTextToSpeak => 'Texte à prononcer';

  @override
  String get ttsEnterText => 'Entrez le texte à convertir en parole...';

  @override
  String get ttsSpeaking => 'Parle...';

  @override
  String get ttsSpeak => 'Parler';

  @override
  String get stop => 'Arrêter';

  @override
  String get ttsQuickTests => 'Tests rapides :';

  @override
  String get ttsTestHello => 'Bonjour';

  @override
  String get ttsTestHelloText => 'Bonjour, comment allez-vous ?';

  @override
  String get ttsTestNumbers => 'Nombres';

  @override
  String get ttsTestNumbersText => 'Un, deux, trois, quatre, cinq';

  @override
  String get ttsTestLongText => 'Texte long';

  @override
  String get ttsTestLongTextContent =>
      'Ceci est un test plus long pour démontrer comment le moteur de synthèse vocale gère plusieurs phrases. Cela devrait sonner naturel et clair.';

  @override
  String get addCustomWidget => 'Ajouter un widget personnalisé';

  @override
  String get editCustomWidget => 'Modifier le widget personnalisé';

  @override
  String get widgetType => 'Type de widget';

  @override
  String get markdownContent => 'Contenu Markdown';

  @override
  String get markdownHint =>
      'Entrez votre texte markdown ici...\n\nExemple :\n# Titre\n**Texte en gras**\n* Texte en italique\n- Élément de liste';

  @override
  String get imageFile => 'Fichier image';

  @override
  String get selectImage => 'Sélectionner une image';

  @override
  String get changeImage => 'Changer l\'image';

  @override
  String get imageFit => 'Ajustement de l\'image';

  @override
  String get fitWidth => 'Ajuster à la largeur';

  @override
  String get fitHeight => 'Ajuster à la hauteur';

  @override
  String errorPickingImage(Object error) {
    return 'Erreur lors de la sélection de l\'image : $error';
  }

  @override
  String get pleaseSelectImage => 'Veuillez sélectionner une image';

  @override
  String get addWidget => 'Ajouter un widget';

  @override
  String get customWidgets => 'Widgets personnalisés';

  @override
  String get textWidget => 'Widget de texte';

  @override
  String get textWidgetDescription =>
      'Ajouter du texte personnalisé avec formatage';

  @override
  String get imageWidget => 'Widget d\'image';

  @override
  String get imageWidgetDescription =>
      'Ajouter une image depuis votre appareil';

  @override
  String get homeAssistantEntities => 'Entités Home Assistant';

  @override
  String get removeColumn => 'Supprimer la colonne';

  @override
  String get addColumn => 'Ajouter une colonne';

  @override
  String get hasiDashboards => 'Tableaux de bord Hasi';

  @override
  String get manualEmpty => 'Manuel / Vide';

  @override
  String get viewRawRequestsResponses => 'Voir les requêtes et réponses brutes';

  @override
  String get noLogsFound => 'Aucun journal trouvé';

  @override
  String get logDetail => 'Détail du journal';
}
