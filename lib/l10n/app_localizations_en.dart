// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Hasi';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get myDashboards => 'My Dashboards';

  @override
  String get addDashboard => 'Add Dashboard';

  @override
  String get newDashboard => 'New Dashboard';

  @override
  String get dashboardName => 'Dashboard Name';

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String get logout => 'Logout';

  @override
  String get appearance => 'Appearance';

  @override
  String get editDashboard => 'Edit Dashboard';

  @override
  String get includedDomains => 'Included Domains';

  @override
  String get specificEntities => 'Specific Entities';

  @override
  String get selectSpecificEntities =>
      'Select specific entities to show even if their domain is not selected above.';

  @override
  String get connectingToHA => 'Connecting to Home Assistant...';

  @override
  String get noEntitiesFound => 'No entities found.';

  @override
  String get noEntitiesMatch => 'No entities match this dashboard.';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get glassmorphism => 'Glassmorphism Effect';

  @override
  String get glassmorphismSub => 'Semi-transparent cards with blur';

  @override
  String get accentColor => 'Accent Color';

  @override
  String get brightness => 'Brightness';

  @override
  String get current => 'Current';

  @override
  String get heat => 'Heat';

  @override
  String get cool => 'Cool';

  @override
  String get off => 'Off';

  @override
  String get auto => 'Auto';

  @override
  String get refresh => 'Refresh';

  @override
  String get playing => 'Playing';

  @override
  String get paused => 'Paused';

  @override
  String get cameraUnavailable => 'Camera unavailable';

  @override
  String get noHistoryData => 'No history data';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get german => 'German';

  @override
  String get spanish => 'Spanish';

  @override
  String get french => 'French';

  @override
  String get systemDefault => 'System Default';

  @override
  String get layout => 'Layout';

  @override
  String get columns => 'Columns';

  @override
  String get entitiesToDisplay => 'Entities to Display';

  @override
  String get manuallySelectEntities =>
      'Manually select each entity you want on the dashboard.';

  @override
  String get selected => 'Selected';

  @override
  String get searchEntities => 'Search entities...';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String get deleteDashboard => 'Delete Dashboard';

  @override
  String deleteConfirm(Object name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get findByArea => 'Find by Area';

  @override
  String get noAreasFound => 'No areas found';

  @override
  String get setAsDefault => 'Set as Default';

  @override
  String get defaultDashboardSub =>
      'This dashboard will open automatically when you start the app.';

  @override
  String get cannotDeleteLastDashboard =>
      'Cannot delete the last dashboard. At least one dashboard is required.';

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
  String get connectToHA => 'Connect to Home Assistant';

  @override
  String get discovery => 'Discovery';

  @override
  String get searchingForHA => 'Searching for Home Assistant instances...';

  @override
  String get token => 'Token';

  @override
  String get credentials => 'Credentials';

  @override
  String get longLivedToken => 'Long-Lived Access Token';

  @override
  String get pasteToken => 'Paste token';

  @override
  String get scanQRCode => 'Scan QR Code';

  @override
  String get connectWithToken => 'Connect with Token';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get connectWithCredentials => 'Connect with Credentials';

  @override
  String get haUrl => 'Home Assistant URL';

  @override
  String get pleaseEnterUrl => 'Please enter URL';

  @override
  String get pleaseEnterToken => 'Please enter token';

  @override
  String get pleaseEnterUsername => 'Please enter username';

  @override
  String get pleaseEnterPassword => 'Please enter password';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get retry => 'Retry';
}
