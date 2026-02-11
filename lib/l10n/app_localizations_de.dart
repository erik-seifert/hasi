// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Hasi';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get myDashboards => 'Meine Dashboards';

  @override
  String get addDashboard => 'Dashboard hinzufügen';

  @override
  String get newDashboard => 'Neues Dashboard';

  @override
  String get dashboardName => 'Dashboard Name';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get create => 'Erstellen';

  @override
  String get logout => 'Abmelden';

  @override
  String get appearance => 'Erscheinungsbild';

  @override
  String get editDashboard => 'Dashboard bearbeiten';

  @override
  String get includedDomains => 'Enthaltene Domänen';

  @override
  String get specificEntities => 'Spezifische Entitäten';

  @override
  String get selectSpecificEntities =>
      'Wählen Sie spezifische Entitäten aus, die angezeigt werden sollen, auch wenn ihre Domäne oben nicht ausgewählt ist.';

  @override
  String get connectingToHA =>
      'Verbindung zu Home Assistant wird hergestellt...';

  @override
  String get noEntitiesFound => 'Keine Entitäten gefunden.';

  @override
  String get noEntitiesMatch => 'Keine Entitäten entsprechen diesem Dashboard.';

  @override
  String get darkMode => 'Dunkelmodus';

  @override
  String get glassmorphism => 'Glassmorphismus-Effekt';

  @override
  String get glassmorphismSub => 'Halbtransparente Karten mit Weichzeichnung';

  @override
  String get accentColor => 'Akzentfarbe';

  @override
  String get brightness => 'Helligkeit';

  @override
  String get current => 'Aktuell';

  @override
  String get heat => 'Heizen';

  @override
  String get cool => 'Kühlen';

  @override
  String get off => 'Aus';

  @override
  String get auto => 'Auto';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get playing => 'Wiedergabe';

  @override
  String get paused => 'Pausiert';

  @override
  String get cameraUnavailable => 'Kamera nicht verfügbar';

  @override
  String get noHistoryData => 'Keine Verlaufsdaten';

  @override
  String get language => 'Sprache';

  @override
  String get english => 'Englisch';

  @override
  String get german => 'Deutsch';

  @override
  String get spanish => 'Spanisch';

  @override
  String get french => 'Französisch';

  @override
  String get systemDefault => 'Systemstandard';

  @override
  String get layout => 'Layout';

  @override
  String get columns => 'Spalten';

  @override
  String get entitiesToDisplay => 'Anzuzeigende Entitäten';

  @override
  String get manuallySelectEntities =>
      'Wählen Sie manuell jede Entität aus, die auf dem Dashboard erscheinen soll.';

  @override
  String get selected => 'Ausgewählt';

  @override
  String get searchEntities => 'Entitäten suchen...';

  @override
  String get deselectAll => 'Alle abwählen';

  @override
  String get deleteDashboard => 'Dashboard löschen';

  @override
  String deleteConfirm(Object name) {
    return 'Sind Sie sicher, dass Sie \"$name\" löschen möchten?';
  }

  @override
  String get delete => 'Löschen';

  @override
  String get save => 'Speichern';

  @override
  String get findByArea => 'Nach Bereich finden';

  @override
  String get noAreasFound => 'Keine Bereiche gefunden';

  @override
  String get setAsDefault => 'Als Standard festlegen';

  @override
  String get defaultDashboardSub =>
      'Dieses Dashboard wird beim Starten der App automatisch geöffnet.';

  @override
  String get cannotDeleteLastDashboard =>
      'Das letzte Dashboard kann nicht gelöscht werden. Mindestens ein Dashboard ist erforderlich.';

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

  @override
  String get connectToHA => 'Mit Home Assistant verbinden';

  @override
  String get discovery => 'Suche';

  @override
  String get searchingForHA => 'Suche nach Home Assistant Instanzen...';

  @override
  String get token => 'Token';

  @override
  String get credentials => 'Anmeldedaten';

  @override
  String get longLivedToken => 'Langlebiges Zugangs-Token';

  @override
  String get pasteToken => 'Token einfügen';

  @override
  String get scanQRCode => 'QR-Code scannen';

  @override
  String get connectWithToken => 'Mit Token verbinden';

  @override
  String get username => 'Benutzername';

  @override
  String get password => 'Passwort';

  @override
  String get connectWithCredentials => 'Mit Anmeldedaten verbinden';

  @override
  String get haUrl => 'Home Assistant URL';

  @override
  String get pleaseEnterUrl => 'Bitte URL eingeben';

  @override
  String get pleaseEnterToken => 'Bitte Token eingeben';

  @override
  String get pleaseEnterUsername => 'Bitte Benutzernamen eingeben';

  @override
  String get pleaseEnterPassword => 'Bitte Passwort eingeben';

  @override
  String get loginFailed => 'Anmeldung fehlgeschlagen';

  @override
  String get retry => 'Wiederholen';

  @override
  String get assist => 'Assistent';

  @override
  String get assistCommandError =>
      'Ich konnte diesen Befehl nicht verarbeiten.';

  @override
  String get assistTypeCommand => 'Befehl eingeben...';

  @override
  String get assistListening => 'Höre zu...';

  @override
  String get ttsTest => 'TTS-Test';

  @override
  String get ttsEngineStatus => 'TTS-Engine-Status';

  @override
  String ttsUsingNative(Object engine) {
    return 'Verwende native Linux TTS: $engine';
  }

  @override
  String get ttsUsingFallback => 'Verwende flutter_tts (Fallback)';

  @override
  String get ttsTextToSpeak => 'Zu sprechender Text';

  @override
  String get ttsEnterText => 'Text zur Sprachausgabe eingeben...';

  @override
  String get ttsSpeaking => 'Spreche...';

  @override
  String get ttsSpeak => 'Sprechen';

  @override
  String get stop => 'Stopp';

  @override
  String get ttsQuickTests => 'Schnelltests:';

  @override
  String get ttsTestHello => 'Hallo';

  @override
  String get ttsTestHelloText => 'Hallo, wie geht es dir?';

  @override
  String get ttsTestNumbers => 'Zahlen';

  @override
  String get ttsTestNumbersText => 'Eins, zwei, drei, vier, fünf';

  @override
  String get ttsTestLongText => 'Langer Text';

  @override
  String get ttsTestLongTextContent =>
      'Dies ist ein längerer Test, um zu demonstrieren, wie die Sprachausgabe mehrere Sätze verarbeitet. Es sollte natürlich und klar klingen.';

  @override
  String get addCustomWidget => 'Benutzerdefiniertes Widget hinzufügen';

  @override
  String get editCustomWidget => 'Benutzerdefiniertes Widget bearbeiten';

  @override
  String get widgetType => 'Widget-Typ';

  @override
  String get markdownContent => 'Markdown-Inhalt';

  @override
  String get markdownHint =>
      'Geben Sie hier Ihren Markdown-Text ein...\n\nBeispiel:\n# Titel\n**Fetter Text**\n* Kursiver Text\n- Listenelement';

  @override
  String get imageFile => 'Bilddatei';

  @override
  String get selectImage => 'Bild auswählen';

  @override
  String get changeImage => 'Bild ändern';

  @override
  String get imageFit => 'Bildanpassung';

  @override
  String get fitWidth => 'An Breite anpassen';

  @override
  String get fitHeight => 'An Höhe anpassen';

  @override
  String errorPickingImage(Object error) {
    return 'Fehler beim Auswählen des Bildes: $error';
  }

  @override
  String get pleaseSelectImage => 'Bitte wählen Sie ein Bild aus';

  @override
  String get addWidget => 'Widget hinzufügen';

  @override
  String get customWidgets => 'Benutzerdefinierte Widgets';

  @override
  String get textWidget => 'Text-Widget';

  @override
  String get textWidgetDescription =>
      'Benutzerdefinierten Text mit Formatierung hinzufügen';

  @override
  String get imageWidget => 'Bild-Widget';

  @override
  String get imageWidgetDescription => 'Ein Bild von Ihrem Gerät hinzufügen';

  @override
  String get homeAssistantEntities => 'Home Assistant Entitäten';

  @override
  String get removeColumn => 'Spalte entfernen';

  @override
  String get addColumn => 'Spalte hinzufügen';

  @override
  String get hasiDashboards => 'Hasi Dashboards';

  @override
  String get manualEmpty => 'Manuell / Leer';

  @override
  String get viewRawRequestsResponses => 'Rohe Anfragen und Antworten anzeigen';

  @override
  String get noLogsFound => 'Keine Protokolle gefunden';

  @override
  String get logDetail => 'Protokolldetails';
}
