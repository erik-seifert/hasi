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
  String get dashboardSettings => 'Configuración del panel';

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
  String get setupDashboards => 'Configurar paneles';

  @override
  String get createDashboards => 'Crear paneles';

  @override
  String get noAreasFoundSetup => 'No se encontraron áreas';

  @override
  String get noAreasFoundSetupSub =>
      'Crea áreas en Home Assistant para organizar tus entidades, o crea un panel vacío para empezar.';

  @override
  String get createEmptyDashboard => 'Crear panel vacío';

  @override
  String get welcomeToHasi => '¡Bienvenido a Hasi!';

  @override
  String get selectAreasToCreateDashboards =>
      'Selecciona áreas para crear automáticamente paneles para cada una.';

  @override
  String get areasSelected => 'áreas seleccionadas';

  @override
  String get entity => 'entidad';

  @override
  String get entities => 'entidades';

  @override
  String get editMode => 'Modo edición';

  @override
  String get connectToHA => 'Conectar a Home Assistant';

  @override
  String get discovery => 'Descubrimiento';

  @override
  String get searchingForHA => 'Buscando instancias de Home Assistant...';

  @override
  String get token => 'Token';

  @override
  String get credentials => 'Credenciales';

  @override
  String get longLivedToken => 'Token de acceso de larga duración';

  @override
  String get pasteToken => 'Pegar token';

  @override
  String get scanQRCode => 'Escanear código QR';

  @override
  String get connectWithToken => 'Conectar con token';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get password => 'Contraseña';

  @override
  String get connectWithCredentials => 'Conectar con credenciales';

  @override
  String get haUrl => 'URL de Home Assistant';

  @override
  String get pleaseEnterUrl => 'Por favor ingrese la URL';

  @override
  String get pleaseEnterToken => 'Por favor ingrese el token';

  @override
  String get pleaseEnterUsername => 'Por favor ingrese el nombre de usuario';

  @override
  String get pleaseEnterPassword => 'Por favor ingrese la contraseña';

  @override
  String get loginFailed => 'Error de inicio de sesión';

  @override
  String get retry => 'Reintentar';

  @override
  String get assist => 'Asistente';

  @override
  String get assistCommandError => 'No pude procesar ese comando.';

  @override
  String get assistTypeCommand => 'Escribe un comando...';

  @override
  String get assistListening => 'Escuchando...';

  @override
  String get ttsTest => 'Prueba de TTS';

  @override
  String get ttsEngineStatus => 'Estado del motor TTS';

  @override
  String ttsUsingNative(Object engine) {
    return 'Usando TTS nativo de Linux: $engine';
  }

  @override
  String get ttsUsingFallback => 'Usando flutter_tts (alternativo)';

  @override
  String get ttsTextToSpeak => 'Texto para hablar';

  @override
  String get ttsEnterText => 'Ingrese texto para convertir a voz...';

  @override
  String get ttsSpeaking => 'Hablando...';

  @override
  String get ttsSpeak => 'Hablar';

  @override
  String get stop => 'Detener';

  @override
  String get ttsQuickTests => 'Pruebas rápidas:';

  @override
  String get ttsTestHello => 'Hola';

  @override
  String get ttsTestHelloText => 'Hola, ¿cómo estás?';

  @override
  String get ttsTestNumbers => 'Números';

  @override
  String get ttsTestNumbersText => 'Uno, dos, tres, cuatro, cinco';

  @override
  String get ttsTestLongText => 'Texto largo';

  @override
  String get ttsTestLongTextContent =>
      'Esta es una prueba más larga para demostrar cómo el motor de texto a voz maneja múltiples oraciones. Debería sonar natural y claro.';

  @override
  String get addCustomWidget => 'Añadir widget personalizado';

  @override
  String get editCustomWidget => 'Editar widget personalizado';

  @override
  String get widgetType => 'Tipo de widget';

  @override
  String get markdownContent => 'Contenido Markdown';

  @override
  String get markdownHint =>
      'Ingrese su texto markdown aquí...\n\nEjemplo:\n# Título\n**Texto en negrita**\n* Texto en cursiva\n- Elemento de lista';

  @override
  String get imageFile => 'Archivo de imagen';

  @override
  String get selectImage => 'Seleccionar imagen';

  @override
  String get changeImage => 'Cambiar imagen';

  @override
  String get imageFit => 'Ajuste de imagen';

  @override
  String get fitWidth => 'Ajustar al ancho';

  @override
  String get fitHeight => 'Ajustar a la altura';

  @override
  String errorPickingImage(Object error) {
    return 'Error al seleccionar imagen: $error';
  }

  @override
  String get pleaseSelectImage => 'Por favor seleccione una imagen';

  @override
  String get addWidget => 'Añadir widget';

  @override
  String get customWidgets => 'Widgets personalizados';

  @override
  String get textWidget => 'Widget de texto';

  @override
  String get textWidgetDescription => 'Añadir texto personalizado con formato';

  @override
  String get imageWidget => 'Widget de imagen';

  @override
  String get imageWidgetDescription => 'Añadir una imagen desde tu dispositivo';

  @override
  String get homeAssistantEntities => 'Entidades de Home Assistant';

  @override
  String get removeColumn => 'Eliminar columna';

  @override
  String get addColumn => 'Añadir columna';

  @override
  String get hasiDashboards => 'Paneles de Hasi';

  @override
  String get manualEmpty => 'Manual / Vacío';

  @override
  String get viewRawRequestsResponses =>
      'Ver solicitudes y respuestas sin procesar';

  @override
  String get noLogsFound => 'No se encontraron registros';

  @override
  String get logDetail => 'Detalle del registro';
}
