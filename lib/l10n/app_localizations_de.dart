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
}
