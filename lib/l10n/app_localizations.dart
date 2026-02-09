import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Hasi'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @myDashboards.
  ///
  /// In en, this message translates to:
  /// **'My Dashboards'**
  String get myDashboards;

  /// No description provided for @addDashboard.
  ///
  /// In en, this message translates to:
  /// **'Add Dashboard'**
  String get addDashboard;

  /// No description provided for @newDashboard.
  ///
  /// In en, this message translates to:
  /// **'New Dashboard'**
  String get newDashboard;

  /// No description provided for @dashboardName.
  ///
  /// In en, this message translates to:
  /// **'Dashboard Name'**
  String get dashboardName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @editDashboard.
  ///
  /// In en, this message translates to:
  /// **'Edit Dashboard'**
  String get editDashboard;

  /// No description provided for @includedDomains.
  ///
  /// In en, this message translates to:
  /// **'Included Domains'**
  String get includedDomains;

  /// No description provided for @specificEntities.
  ///
  /// In en, this message translates to:
  /// **'Specific Entities'**
  String get specificEntities;

  /// No description provided for @selectSpecificEntities.
  ///
  /// In en, this message translates to:
  /// **'Select specific entities to show even if their domain is not selected above.'**
  String get selectSpecificEntities;

  /// No description provided for @connectingToHA.
  ///
  /// In en, this message translates to:
  /// **'Connecting to Home Assistant...'**
  String get connectingToHA;

  /// No description provided for @noEntitiesFound.
  ///
  /// In en, this message translates to:
  /// **'No entities found.'**
  String get noEntitiesFound;

  /// No description provided for @noEntitiesMatch.
  ///
  /// In en, this message translates to:
  /// **'No entities match this dashboard.'**
  String get noEntitiesMatch;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @glassmorphism.
  ///
  /// In en, this message translates to:
  /// **'Glassmorphism Effect'**
  String get glassmorphism;

  /// No description provided for @glassmorphismSub.
  ///
  /// In en, this message translates to:
  /// **'Semi-transparent cards with blur'**
  String get glassmorphismSub;

  /// No description provided for @accentColor.
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get accentColor;

  /// No description provided for @brightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightness;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @heat.
  ///
  /// In en, this message translates to:
  /// **'Heat'**
  String get heat;

  /// No description provided for @cool.
  ///
  /// In en, this message translates to:
  /// **'Cool'**
  String get cool;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @playing.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get playing;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @cameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable'**
  String get cameraUnavailable;

  /// No description provided for @noHistoryData.
  ///
  /// In en, this message translates to:
  /// **'No history data'**
  String get noHistoryData;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @layout.
  ///
  /// In en, this message translates to:
  /// **'Layout'**
  String get layout;

  /// No description provided for @columns.
  ///
  /// In en, this message translates to:
  /// **'Columns'**
  String get columns;

  /// No description provided for @entitiesToDisplay.
  ///
  /// In en, this message translates to:
  /// **'Entities to Display'**
  String get entitiesToDisplay;

  /// No description provided for @manuallySelectEntities.
  ///
  /// In en, this message translates to:
  /// **'Manually select each entity you want on the dashboard.'**
  String get manuallySelectEntities;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @searchEntities.
  ///
  /// In en, this message translates to:
  /// **'Search entities...'**
  String get searchEntities;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// No description provided for @deleteDashboard.
  ///
  /// In en, this message translates to:
  /// **'Delete Dashboard'**
  String get deleteDashboard;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteConfirm(Object name);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @findByArea.
  ///
  /// In en, this message translates to:
  /// **'Find by Area'**
  String get findByArea;

  /// No description provided for @noAreasFound.
  ///
  /// In en, this message translates to:
  /// **'No areas found'**
  String get noAreasFound;

  /// No description provided for @setAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as Default'**
  String get setAsDefault;

  /// No description provided for @defaultDashboardSub.
  ///
  /// In en, this message translates to:
  /// **'This dashboard will open automatically when you start the app.'**
  String get defaultDashboardSub;

  /// No description provided for @cannotDeleteLastDashboard.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete the last dashboard. At least one dashboard is required.'**
  String get cannotDeleteLastDashboard;

  /// No description provided for @setupDashboards.
  ///
  /// In en, this message translates to:
  /// **'Setup Dashboards'**
  String get setupDashboards;

  /// No description provided for @createDashboards.
  ///
  /// In en, this message translates to:
  /// **'Create Dashboards'**
  String get createDashboards;

  /// No description provided for @noAreasFoundSetup.
  ///
  /// In en, this message translates to:
  /// **'No Areas Found'**
  String get noAreasFoundSetup;

  /// No description provided for @noAreasFoundSetupSub.
  ///
  /// In en, this message translates to:
  /// **'Create areas in Home Assistant to organize your entities, or create an empty dashboard to get started.'**
  String get noAreasFoundSetupSub;

  /// No description provided for @createEmptyDashboard.
  ///
  /// In en, this message translates to:
  /// **'Create Empty Dashboard'**
  String get createEmptyDashboard;

  /// No description provided for @welcomeToHasi.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Hasi!'**
  String get welcomeToHasi;

  /// No description provided for @selectAreasToCreateDashboards.
  ///
  /// In en, this message translates to:
  /// **'Select areas to automatically create dashboards for each one.'**
  String get selectAreasToCreateDashboards;

  /// No description provided for @areasSelected.
  ///
  /// In en, this message translates to:
  /// **'areas selected'**
  String get areasSelected;

  /// No description provided for @entity.
  ///
  /// In en, this message translates to:
  /// **'entity'**
  String get entity;

  /// No description provided for @entities.
  ///
  /// In en, this message translates to:
  /// **'entities'**
  String get entities;

  /// No description provided for @editMode.
  ///
  /// In en, this message translates to:
  /// **'Edit Mode'**
  String get editMode;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
