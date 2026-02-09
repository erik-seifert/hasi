// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Hasi';

  @override
  String get dashboard => 'Panel de control';

  @override
  String get myDashboards => 'Mis paneles';

  @override
  String get addDashboard => 'Añadir panel';

  @override
  String get newDashboard => 'Nuevo panel';

  @override
  String get dashboardName => 'Nombre del panel';

  @override
  String get cancel => 'Cancelar';

  @override
  String get create => 'Crear';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get appearance => 'Apariencia';

  @override
  String get editDashboard => 'Editar panel';

  @override
  String get includedDomains => 'Dominios incluidos';

  @override
  String get specificEntities => 'Entidades específicas';

  @override
  String get selectSpecificEntities =>
      'Seleccione entidades específicas para mostrar incluso si su dominio no está seleccionado arriba.';

  @override
  String get connectingToHA => 'Conectando con Home Assistant...';

  @override
  String get noEntitiesFound => 'No se encontraron entidades.';

  @override
  String get noEntitiesMatch => 'Ninguna entidad coincide con este panel.';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get glassmorphism => 'Efecto glassmorphism';

  @override
  String get glassmorphismSub => 'Tarjetas semitransparentes con desenfoque';

  @override
  String get accentColor => 'Color de acento';

  @override
  String get brightness => 'Brillo';

  @override
  String get current => 'Actual';

  @override
  String get heat => 'Calor';

  @override
  String get cool => 'Frío';

  @override
  String get off => 'Apagado';

  @override
  String get auto => 'Auto';

  @override
  String get refresh => 'Refrescar';

  @override
  String get playing => 'Reproduciendo';

  @override
  String get paused => 'Pausado';

  @override
  String get cameraUnavailable => 'Cámara no disponible';

  @override
  String get noHistoryData => 'Sin datos históricos';

  @override
  String get language => 'Idioma';

  @override
  String get english => 'Inglés';

  @override
  String get german => 'Alemán';

  @override
  String get spanish => 'Español';

  @override
  String get french => 'Francés';

  @override
  String get systemDefault => 'Predeterminado del sistema';

  @override
  String get layout => 'Diseño';

  @override
  String get columns => 'Columnas';

  @override
  String get entitiesToDisplay => 'Entidades a mostrar';

  @override
  String get manuallySelectEntities =>
      'Seleccione manualmente cada entidad que desee en el panel.';

  @override
  String get selected => 'Seleccionado';

  @override
  String get searchEntities => 'Buscar entidades...';

  @override
  String get deselectAll => 'Deseleccionar todo';

  @override
  String get deleteDashboard => 'Eliminar panel';

  @override
  String deleteConfirm(Object name) {
    return '¿Estás seguro de que quieres eliminar \"$name\"?';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String get save => 'Guardar';

  @override
  String get findByArea => 'Buscar por área';

  @override
  String get noAreasFound => 'No se encontraron áreas';

  @override
  String get setAsDefault => 'Establecer como predeterminado';

  @override
  String get defaultDashboardSub =>
      'Este panel se abrirá automáticamente al iniciar la aplicación.';

  @override
  String get cannotDeleteLastDashboard =>
      'No se puede eliminar el último panel. Se requiere al menos un panel.';

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
