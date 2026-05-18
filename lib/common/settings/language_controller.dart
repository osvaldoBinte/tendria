import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/features/user/presentation/controller/profile_controller.dart';

class LanguageController extends GetxController {
  String get deviceLanguage => _deviceLanguage;

  String get _deviceLanguage {
    // Obtiene el locale del dispositivo (ej: "es", "en", "fr")
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    final languageCode = locale.languageCode;

    if (languageCode == 'es') return 'Español';
    if (languageCode == 'en') return 'Inglés';

    // Cualquier otro idioma → Inglés por defecto
    return 'Inglés';
  }

  String get lang {
    try {
      final profileLang = Get.find<ProfileController>().primarylanguage;
      if (_translations.containsKey(profileLang)) {
        return profileLang;
      }
      return _deviceLanguage;
    } catch (_) {
      return _deviceLanguage;
    }
  }

  String t(String key) => translate(key, lang);

  String translate(String key, String language) {
    return _translations[language]?[key] ??
        _translations['Español']?[key] ??
        key;
  }

  static const Map<String, Map<String, String>> _translations = {
    'Español': {
      // ── UpdateProfilePage ──────────────────────────
      'age_range': 'Rango de edad',
      'max_distance': 'Distancia máxima',
      'height': 'Altura',
      'my_gender': 'Mi Género',
      'language': 'Idioma',
      'birth_date': 'Fecha de nacimiento',
      'looking_for': 'Busco',
      'connection_type': 'Tipo de conexión',
      'delete_account': 'Eliminar cuenta',
      'no_limit': 'Máximo',

      // ── ProfilePage ────────────────────────────────
      'profile': 'Perfil',
      'discover': 'Descubrir perfiles cercanos',
      'photos': 'Fotos',
      'photos_hint': 'Toca + para agregar varias fotos de jalón',
      'my_biography': 'Mi Biografía',
      'add_status': 'Agregar estado',

      // ── LikedByUsersView ───────────────────────────
      'pending_chats': 'Match Pendientes',
      'unlock_hint': 'Desbloquea los chats para comenzar a conversar.',
      'unlock': 'Desbloquear',
      'connect': 'Conectar',

      // ── RadarScannerScreen ─────────────────────────
      'searching': 'Buscando conexiones...',
      'nearby': 'Perfiles que están cerca de ti',
      'search_btn': 'Buscar Perfiles Cercanos',
      'view_profile': 'Ver mi perfil',

      // ── MyMatchView ────────────────────────────────
      'stories': 'Historias',
      'my_story': 'Mi historia',
      'chats': 'Chats',
      'no_reply': 'Sin responder',
      'filter_chats': 'Filtrar chats',
      'filter_no_reply': 'Sin responder',
      'filter_no_reply_desc': 'Solo chats donde esperan tu respuesta',
      'clear_filters': 'Limpiar filtros',
      'search_hint': 'Buscar chats...',
      'your_turn': 'Tu turno',
      'start_chat': '¡Comienza a chatear!',
      'all_caught_up': '¡Todo al día! No tienes chats pendientes de respuesta',
      'see_all': 'Ver todos los chats',

      // ── InterestsSectionWidget ─────────────────────
      'interests_title': 'Intereses',
      'interests_subtitle': 'Muestra las cosas que te encantan',
      'interests_add': 'Agrega tus intereses',

      // ── QualitiesSectionWidget ─────────────────────
      'qualities_title': 'Cualidades que valoro',
      'qualities_subtitle':
          'Elige hasta 3 cualidades que valoras en una persona.',
      'qualities_add': 'Agrega cualidades que valoras',

      // ── Bottom sheets: Intereses ───────────────────
      'bs_interests_title': 'Elige tus intereses\nprincipales',
      'bs_interests_subtitle':
          'Tus gustos nos ayudan a encontrar mejores coincidencias.',
      'bs_interests_counter': 'Intereses populares',
      'bs_interests_selected': 'seleccionados',
      'bs_max_interests': 'Puedes seleccionar máximo 5 intereses',
      'bs_interests_saved': 'Intereses actualizados correctamente',
      'bs_interests_load_error': 'No se pudieron cargar los intereses',

      // ── Bottom sheets: Cualidades ──────────────────
      'bs_qualities_title': 'Lo que más aprecias en\nuna persona',
      'bs_qualities_subtitle':
          'Estas cualidades nos ayudan a crear mejores coincidencias.',
      'bs_qualities_counter': 'Lo que buscas en alguien',
      'bs_max_qualities': 'Puedes seleccionar máximo 3 cualidades',
      'bs_qualities_saved': 'Cualidades actualizadas correctamente',

      // ── Bottom sheets: Altura ──────────────────────
      'bs_height_title': 'Tu altura',
      'bs_height_subtitle':
          'Esta información nos ayuda a mejorar tus coincidencias.',

      // ── Bottom sheets: Género ──────────────────────
      'bs_gender_title': '¿Cuál es tu género?',
      'bs_gender_subtitle': 'Esta información es editable más adelante.',

      // ── Bottom sheets: Idioma ──────────────────────
      'bs_language_title': 'Tu idioma principal',
      'bs_language_subtitle': 'Puedes ajustar esto más tarde.',

      // ── Bottom sheets: Fecha nacimiento ───────────
      'bs_dob_title': 'Fecha de nacimiento',
      'bs_dob_subtitle': 'Debes ser mayor de 18 años.',
      'bs_dob_age_error': 'Debes tener al menos 18 años para registrarte.',

      // ── Bottom sheets: Busco ───────────────────────
      'bs_search_gender_title': '¿Qué tipo de personas te\ngustaría conocer?',
      'bs_search_gender_subtitle':
          'Esta preferencia es flexible y editable más adelante.',

      // ── Bottom sheets: Tipo de conexión ───────────
      'bs_connection_title': '¿Qué tipo de conexión\nquieres?',
      'bs_connection_subtitle': 'Selecciona la opción que vaya contigo.',

      // ── Bottom sheets: Rango de edad ──────────────
      'bs_age_range_title': 'Rango de edad',
      'bs_age_min': 'Mínimo',
      'bs_age_max': 'Máximo',

      // ── Bottom sheets: Distancia ───────────────────
      'bs_distance_title': 'Distancia máxima',
      'bs_no_limit_distance': 'Distancia máxima',

      // ── Bottom sheets: Biografía ───────────────────
      'bs_bio_title': 'Cuéntanos sobre ti',
      'bs_bio_subtitle':
          'Una buena biografía ayuda a generar mejores conexiones.',
      'bs_bio_hint': 'Escribe algo sobre ti...',

      // ── Bottom sheets: Estado ──────────────────────
      'bs_status_title': 'Tu estado',
      'bs_status_subtitle': 'Un estado corto que refleje cómo te sientes hoy.',
      'bs_status_hint': 'Ej: Buscando aventuras...',

      // ── Snackbars generales ────────────────────────
      'snack_no_changes': 'No hay cambios nuevos',
      'snack_updated': 'Actualizado correctamente',
      'snack_height_saved': 'Altura actualizada',
      'snack_gender_saved': 'Género actualizado',
      'snack_language_saved': 'Idioma actualizado',
      'snack_dob_saved': 'Fecha de nacimiento actualizada',
      'snack_search_gender_saved': 'Preferencia actualizada',
      'snack_connection_saved': 'Tipo de conexión actualizado',
      'snack_age_range_saved': 'Rango de edad actualizado',
      'snack_distance_saved': 'Distancia actualizada',
      'snack_bio_saved': 'Biografía actualizada',
      'snack_status_saved': 'Estado actualizado',
      'snack_interest_removed': 'Interés eliminado correctamente',
      'snack_quality_removed': 'Cualidad eliminada correctamente',
      'snack_photo_added': 'Tu foto se ha agregado correctamente',
      'snack_photo_removed': 'La foto se ha eliminado correctamente',
      'snack_could_not_update': 'No se pudo actualizar',
      'snack_could_not_delete': 'No se pudo eliminar',
      'snack_could_not_save_interests': 'No se pudieron guardar los intereses',
      'snack_could_not_save_qualities': 'No se pudieron guardar las cualidades',

      // ── Alertas generales ──────────────────────────
      'alert_delete_photo_title': 'Eliminar foto',
      'alert_delete_photo_msg': '¿Estás seguro que deseas eliminar esta foto?',
      'alert_logout_title': 'Cerrar sesión',
      'alert_logout_msg': '¿Estás seguro que deseas cerrar sesión?',
      'alert_delete_account_title': 'Eliminar cuenta',
      'alert_delete_account_msg':
          '¿Estás seguro? Esta acción es permanente y no se puede deshacer.',
      'alert_confirm': 'Aceptar',
      'alert_delete': 'Eliminar',

      // ── Compartidas ────────────────────────────────
      'years': 'años',
      'user': 'Usuario',
      'loading': 'Cargando...',
      'loading_chats': 'Cargando chats...',
      'loading_pending': 'Cargando chats pendientes...',
      'error_title': 'Error al cargar chats',
      'retry': 'REINTENTAR',
      'empty_title_chats': 'No tienes chats aún',
      'empty_subtitle_chats':
          'Comienza a dar likes para encontrar tu match perfecto',
      'empty_title_pending': 'No tienes match pendientes',
      'empty_subtitle_pending': 'Cuando alguien te escriba, aparecerá aquí',
      'explore': 'EXPLORAR PERFILES',
      'save': 'Guardar',
      'cancel': 'Cancelar',
      'error': 'Error',
      'accept': 'Aceptar',

      'no_more_profiles': 'No hay más perfiles',
      'no_more_profiles_desc':
          'No encontramos perfiles que coincidan con tus filtros actuales. Amplía tu rango de búsqueda para ver más personas.',
      'modify_preferences': 'Modificar preferencias',
      'try_again': 'Intentar de nuevo',

      // ── RegisterPage ───────────────────────────────
      'register_title': 'Empezar',
      'register_have_account': '¿Ya cuentas con un registro? ',
      'register_login': 'Iniciar Sesión',
      'register_name': 'Nombre Completo:',
      'register_name_hint': 'Karen Hernández Costa',
      'register_email': 'Correo electrónico:',
      'register_email_hint': 'correo@gmail.com',
      'register_password': 'Crea una contraseña',
      'register_confirm_password': 'Confirma tu contraseña:',
      'register_privacy':
          'Al registrarte estas aceptando el Aviso de Privacidad y los Términos y Condiciones.',
      'register_btn': 'Registrarse',

      'personal_title': 'Iniciemos con lo\nbásico',
      'personal_dob': 'Selecciona tu fecha de nacimiento',
      'personal_dob_placeholder': '14/05/1993',
      'personal_gender': '¿Cómo te identificas?',
      'personal_bio': 'Cuéntanos sobre ti:',
      'personal_bio_hint': 'Escribe una breve biografía...',

      'physical_title':
          'Esta información nos ayuda a\nmejorar tus coincidencias',
      'physical_height': 'Tu altura',

      'interests_page_title': 'Elige tus intereses\nprincipales',
      'interests_page_subtitle':
          'Tus gustos nos ayudan a encontrar mejores\ncoincidencias.',
      'interests_search_hint': 'Buscar intereses',
      'interests_popular': 'Intereses populares',
      'interests_custom_hint':
          'si no se encuentran tus resultados escríbelos...',

      'qualities_page_title': 'Lo que más aprecias en una\npersona',
      'qualities_page_subtitle':
          'Estas cualidades nos ayudan a crear mejores\ncoincidencias.',
      'qualities_counter_label': 'Lo que buscas en alguien',

      'nav_skip': 'Omitir',
      'login_title': 'Iniciar Sesión',
      'login_no_account': '¿Aún no tienes una cuenta? ',
      'login_register': 'Registrarse',
      'login_email': 'Correo electrónico:',
      'login_email_hint': 'correo@gmail.com',
      'login_password': 'Contraseña:',
      'login_remember': 'Recuérdame',
      'login_btn': 'Iniciar Sesión',

      'val_name_required': 'El nombre es requerido',
      'val_name_min': 'Mínimo 3 caracteres',
      'val_email_required': 'El correo es requerido',
      'val_email_invalid': 'Ingresa un correo válido',
      'val_password_required': 'La contraseña es requerida',
      'val_min_8': 'Mínimo 8 caracteres',
      'val_min_10': 'Mínimo 10 caracteres',
      'val_max_500': 'Máximo 500 caracteres',
      'val_passwords_no_match': 'Las contraseñas no coinciden',
      'val_dob_required': 'Selecciona tu fecha de nacimiento',
      'val_gender_required': 'Selecciona tu género',
      'val_custom_gender_required': 'Escribe cómo te identificas',
      'val_bio_required': 'La biografía es requerida',
      'val_bio_min': 'La biografía debe tener al menos 10 caracteres',
      'val_bio_max': 'La biografía debe tener máximo 500 caracteres',
      'val_height_required': 'Ingresa tu altura',
      'val_height_invalid': 'Ingresa una altura válida entre 100 y 250 cm',
      'val_interest_required': 'Selecciona al menos un interés',
      'val_max_interests': 'Solo puedes seleccionar hasta',
      'val_max_qualities': 'Solo puedes seleccionar hasta',
      'register_success': 'Registro exitoso. Por favor, inicia sesión.',

      'login_warning': 'Advertencia',
      'login_val_email': 'Por favor, ingresa tu correo',
      'login_val_password': 'Por favor, ingresa tu contraseña',
      'login_error_title': 'Acceso incorrecto',
      'chat_reconnecting': 'Reconectando...',
      'chat_no_connection': 'Sin conexión · Toca para reintentar',
      'chat_cost_info': 'Este mensaje tiene un costo de ',
      'chat_balance_info': 'Tus créditos actuales son de ',
      'chat_charge_info': 'El mensaje se cobrará solo cuando se envíe.',
      'chat_first_msg_sent': 'Primer mensaje enviado. Espera la respuesta.',
      'chat_hint_blocked': 'Espera la respuesta...',
      'chat_hint': 'Escribe un mensaje...',
      'chat_empty_title': 'Inicia la conversación',
      'chat_empty_subtitle': 'Envía el primer mensaje para comenzar',
      'chat_error_title': 'Error al cargar mensajes',
      'nearby_no_more': 'No hay más usuarios cercanos',
      'nearby_load_error': 'No se pudieron cargar los usuarios',
      'nearby_liked': '¡Te gusta',
      'nearby_removed_fav': 'removido de favoritos',
      'nearby_error_process': 'Error al procesar',
      'nearby_like_sent': '¡Le diste like a',
      'nearby_error_like': 'Error al dar like',
      'nearby_next_profile': 'Pasando al siguiente perfil',
      'nearby_error_reject': 'Error al rechazar',
      'nearby_superlike_sent': 'Le has enviado un Super Like a',
      'nearby_block_title': 'Bloquear usuario',
      'nearby_block_msg': '¿Estás seguro de que quieres bloquear a',
      'nearby_block_confirm': 'Bloquear',
      'nearby_blocked': 'ha sido bloqueado',
      'nearby_all_seen': 'Has visto todos los perfiles disponibles',
      'nearby_report_title': 'Reportar usuario',
      'nearby_report_msg': '¿Por qué quieres reportar a',
      'nearby_report_confirm': 'Reportar',
      'nearby_report_thanks':
          'Gracias por tu reporte. Revisaremos el perfil de',
      'nearby_send_message': 'Enviar mensaje',
      'nearby_view_profile': 'Ver perfil completo',
      'chat_credits': 'créditos',
      'location_required_title': 'Ubicación requerida',
      'location_required_desc':
          'Necesitamos tu ubicación para mostrarte usuarios cercanos',
      'enable_location': 'Activar ubicación',
      'open_settings': 'Abrir configuración',
      //PreferencesPage
      'pref_gender_title': '¿Qué tipo de personas te\ngustaría conocer?',
      'pref_gender_subtitle':
          'Esta preferencia es flexible y editable más adelante.',
      'pref_gender_hint':
          'Te mostraremos perfiles compatibles con tus preferencias.',
      'pref_connection_title': '¿Qué tipo de conexión\nquieres?',
      'pref_connection_subtitle':
          'Selecciona hasta dos opciones que vayan contigo.',
      'pref_connection_hint':
          'Mostraremos esta preferencia para mejorar tus coincidencias.',
      'pref_age_title': '¿Qué rango de edad\nprefieres?',
      'pref_age_subtitle': 'Puedes ajustar esto más tarde.',
      'pref_distance_title': 'Distancia máxima',
      'pref_distance_up_to': 'Hasta',
      'pref_photos_title': 'Preséntate con fotos',
      'pref_photos_subtitle':
          'Sube al menos 2 fotos que muestren tu esencia.\nLas mejores conexiones empiezan con buenas fotos.',
      'pref_selection_required': 'Selección requerida',
      'pref_select_gender': 'Selecciona un tipo de persona',
      'pref_select_connection': 'Selecciona al menos un tipo de conexión',
      'pref_invalid_range': 'Rango inválido',
      'pref_age_range_error':
          'La edad mínima no puede ser mayor que la edad máxima',
      'pref_photos_required': 'Fotos requeridas',
      'pref_photos_min': 'Debes subir al menos 2 fotos',
      'pref_interests_required': 'Intereses requeridos',
      'pref_qualities_required': 'Cualidades requeridas',
      'pref_select_quality': 'Debes seleccionar al menos una cualidad',
      'pref_limit_reached': 'Límite alcanzado',

      'pref_no_interests': 'No hay intereses disponibles',
      'pref_no_qualities': 'No hay cualidades disponibles',

      'pref_photos_max': 'Puedes subir máximo',
      'pref_photos_partial': 'Solo se agregaron',
      'pref_photos_pick_error': 'No se pudo seleccionar la foto',
      'pref_photo_take_error': 'No se pudo tomar la foto',
      'pref_add_photos': 'Agregar fotos',
      'pref_gallery_multiple': 'Galería (selección múltiple)',
      'pref_gallery_multiple_hint': 'Selecciona varias fotos de jalón',
      'pref_take_photo': 'Tomar foto',
      'pref_take_photo_hint': 'Captura una nueva foto',

      // ── Tutoriales ─────────────────────────────────
      'tutorial_start_profile':
          'Aquí puedes ver y editar la información de tu perfil',
      'tutorial_start_radar':
          'Radar: encuentra personas cercanas a tu ubicación',
      'tutorial_start_match':
          'Match: ve las personas que quieren conectar contigo',
      'tutorial_start_chat': 'Chat: sigue la conversación con tus conexiones',
      'tutorial_start_panic':
          'Botón de pánico: en caso de emergencia presionalo para llamar al 911 y pedir ayuda inmediata',

      'tutorial_profile_blocked':
          'Aquí puedes ver y gestionar los usuarios que has bloqueado',
      'tutorial_profile_notifications':
          'Gestiona tus notificaciones push y preferencias de alertas',
      'tutorial_profile_edit':
          'Edita tu perfil: nombre, edad, preferencias y más',
      'tutorial_profile_settings': 'opción para cerrar sesión',
      'tutorial_profile_credits':
          'Toca aquí para agregar más créditos a tu cuenta',
      'tutorial_profile_status':
          'Toca para editar tu mensaje de estado visible en el radar',

      'tutorial_update_age':
          'Edita el rango de edad de las personas con quienes prefieres conectar',
      'tutorial_update_distance':
          'Ajusta la distancia máxima de las personas con las que prefieres conectar',

      'tutorial_radar_slider':
          'Ajusta el radio de búsqueda para encontrar personas más cerca o más lejos de ti',
      'tutorial_radar_points':
          'Te damos un grupo pequeño de perfiles cercanos para que puedas ver a cada persona',
      'tutorial_radar_search': 'Vuelve a pulsar para ver más',
      'tutorial_radar_profile': 'Pulsa para ver los perfiles',
      'tutorial_skip': 'Omitir',

      // ── LikedByUsersView ───────────────────────────
      'liked_by_title': 'Les gusté',
      'liked_by_hint': 'Usuarios que te dieron like',
      'liked_by_tab': 'Les gusté',
      'pending_tab': 'Pendientes',
      'liked_by_view_profile': 'Ver perfil',
      'liked_by_empty_title': 'Nadie te ha dado like aún',
      'liked_by_empty_subtitle': 'Sigue explorando para conseguir más matches',
      'liked_by_error_title': 'Error al cargar likes',
      'liked_by_loading': 'Cargando likes...',

      //reportar 
      'report_title': 'Reportar a',
'report_select_reason': 'Selecciona el motivo del reporte',
'report_harassment': 'Acoso o intimidación',
'report_inappropriate': 'Contenido inapropiado',
'report_fake': 'Perfil falso o spam',
'report_offensive': 'Comportamiento ofensivo',
'report_minor': 'Menor de edad',
'report_other': 'Otro',
'report_desc_hint': 'Descripción (requerida)',
'report_desc_required': 'La descripción es requerida',
'report_also_block': 'También bloquear a',
'report_block_hint': 'No podrá contactarte ni ver tu perfil',
'report_send': 'Enviar reporte',
'report_send_and_block': 'Reportar y bloquear',
'report_success': 'Reporte enviado. Revisaremos el perfil de',
'report_block_success': 'ha sido reportado y bloqueado',
    },
    'Inglés': {
      // ── UpdateProfilePage ──────────────────────────
      'age_range': 'Age Range',
      'max_distance': 'Max Distance',
      'height': 'Height',
      'my_gender': 'My Gender',
      'language': 'Language',
      'birth_date': 'Date of Birth',
      'looking_for': 'Looking for',
      'connection_type': 'Connection Type',
      'delete_account': 'Delete Account',
      'no_limit': 'No limit',

      // ── ProfilePage ────────────────────────────────
      'profile': 'Profile',
      'discover': 'Discover nearby profiles',
      'photos': 'Photos',
      'photos_hint': 'Tap + to add multiple photos at once',
      'my_biography': 'My Biography',
      'add_status': 'Add status',

      // ── LikedByUsersView ───────────────────────────
      'pending_chats': 'Pending Match',
      'unlock_hint': 'Unlock chats to start chatting.',
      'unlock': 'Unlock',
      'connect': 'Connect',

      // ── RadarScannerScreen ─────────────────────────
      'searching': 'Looking for connections...',
      'nearby': 'Profiles near you',
      'search_btn': 'Find Nearby Profiles',
      'view_profile': 'View my profile',

      // ── MyMatchView ────────────────────────────────
      'stories': 'Stories',
      'my_story': 'My story',
      'chats': 'Chats',
      'no_reply': 'No reply',
      'filter_chats': 'Filter chats',
      'filter_no_reply': 'No reply',
      'filter_no_reply_desc': 'Only chats waiting for your reply',
      'clear_filters': 'Clear filters',
      'search_hint': 'Search chats...',
      'your_turn': 'Your turn',
      'start_chat': 'Start chatting!',
      'all_caught_up': 'All caught up! No pending chats',
      'see_all': 'See all chats',

      // ── InterestsSectionWidget ─────────────────────
      'interests_title': 'Interests',
      'interests_subtitle': 'Show the things you love',
      'interests_add': 'Add your interests',

      // ── QualitiesSectionWidget ─────────────────────
      'qualities_title': 'Qualities I value',
      'qualities_subtitle': 'Choose up to 3 qualities you value in a person.',
      'qualities_add': 'Add qualities you value',

      // ── Bottom sheets: Intereses ───────────────────
      'bs_interests_title': 'Choose your main\ninterests',
      'bs_interests_subtitle': 'Your interests help us find better matches.',
      'bs_interests_counter': 'Popular interests',
      'bs_interests_selected': 'selected',
      'bs_max_interests': 'You can select up to 5 interests',
      'bs_interests_saved': 'Interests updated successfully',
      'bs_interests_load_error': 'Could not load interests',

      // ── Bottom sheets: Cualidades ──────────────────
      'bs_qualities_title': 'What you appreciate most\nin a person',
      'bs_qualities_subtitle': 'These qualities help us create better matches.',
      'bs_qualities_counter': 'What you look for in someone',
      'bs_max_qualities': 'You can select up to 3 qualities',
      'bs_qualities_saved': 'Qualities updated successfully',

      // ── Bottom sheets: Altura ──────────────────────
      'bs_height_title': 'Your height',
      'bs_height_subtitle': 'This information helps us improve your matches.',

      // ── Bottom sheets: Género ──────────────────────
      'bs_gender_title': 'What is your gender?',
      'bs_gender_subtitle': 'This information can be edited later.',

      // ── Bottom sheets: Idioma ──────────────────────
      'bs_language_title': 'Your main language',
      'bs_language_subtitle': 'You can adjust this later.',

      // ── Bottom sheets: Fecha nacimiento ───────────
      'bs_dob_title': 'Date of birth',
      'bs_dob_subtitle': 'You must be over 18 years old.',
      'bs_dob_age_error': 'You must be at least 18 years old to register.',

      // ── Bottom sheets: Busco ───────────────────────
      'bs_search_gender_title': 'What kind of people would\nyou like to meet?',
      'bs_search_gender_subtitle':
          'This preference is flexible and editable later.',

      // ── Bottom sheets: Tipo de conexión ───────────
      'bs_connection_title': 'What kind of connection\ndo you want?',
      'bs_connection_subtitle': 'Select the option that suits you.',

      // ── Bottom sheets: Rango de edad ──────────────
      'bs_age_range_title': 'Age range',
      'bs_age_min': 'Minimum',
      'bs_age_max': 'Maximum',

      // ── Bottom sheets: Distancia ───────────────────
      'bs_distance_title': 'Max distance',
      'bs_no_limit_distance': 'Max distance',

      // ── Bottom sheets: Biografía ───────────────────
      'bs_bio_title': 'Tell us about yourself',
      'bs_bio_subtitle': 'A good biography helps generate better connections.',
      'bs_bio_hint': 'Write something about yourself...',

      // ── Bottom sheets: Estado ──────────────────────
      'bs_status_title': 'Your status',
      'bs_status_subtitle': 'A short status that reflects how you feel today.',
      'bs_status_hint': 'E.g: Looking for adventures...',

      // ── Snackbars generales ────────────────────────
      'snack_no_changes': 'No new changes',
      'snack_updated': 'Updated successfully',
      'snack_height_saved': 'Height updated',
      'snack_gender_saved': 'Gender updated',
      'snack_language_saved': 'Language updated',
      'snack_dob_saved': 'Date of birth updated',
      'snack_search_gender_saved': 'Preference updated',
      'snack_connection_saved': 'Connection type updated',
      'snack_age_range_saved': 'Age range updated',
      'snack_distance_saved': 'Distance updated',
      'snack_bio_saved': 'Biography updated',
      'snack_status_saved': 'Status updated',
      'snack_interest_removed': 'Interest removed successfully',
      'snack_quality_removed': 'Quality removed successfully',
      'snack_photo_added': 'Your photo has been added successfully',
      'snack_photo_removed': 'Photo removed successfully',
      'snack_could_not_update': 'Could not update',
      'snack_could_not_delete': 'Could not delete',
      'snack_could_not_save_interests': 'Could not save interests',
      'snack_could_not_save_qualities': 'Could not save qualities',

      // ── Alertas generales ──────────────────────────
      'alert_delete_photo_title': 'Delete photo',
      'alert_delete_photo_msg': 'Are you sure you want to delete this photo?',
      'alert_logout_title': 'Log out',
      'alert_logout_msg': 'Are you sure you want to log out?',
      'alert_delete_account_title': 'Delete account',
      'alert_delete_account_msg':
          'Are you sure? This action is permanent and cannot be undone.',
      'alert_confirm': 'Accept',
      'alert_delete': 'Delete',

      // ── Compartidas ────────────────────────────────
      'years': 'years',
      'user': 'User',
      'loading': 'Loading...',
      'loading_chats': 'Loading chats...',
      'loading_pending': 'Loading pending chats...',
      'error_title': 'Error loading chats',
      'retry': 'RETRY',
      'empty_title_chats': 'No chats yet',
      'empty_subtitle_chats':
          'Start liking profiles to find your perfect match',
      'empty_title_pending': 'No pending match',
      'empty_subtitle_pending':
          'When someone writes to you, it will appear here',
      'explore': 'EXPLORE PROFILES',
      'save': 'Save',
      'cancel': 'Cancel',
      'error': 'Error',
      'accept': 'Accept',
      'no_more_profiles': 'No more profiles',
      'no_more_profiles_desc':
          'We couldn\'t find profiles matching your current filters. Expand your search range to see more people.',
      'modify_preferences': 'Modify preferences',
      'try_again': 'Try again',
      // ── RegisterPage ───────────────────────────────
      'register_title': 'Get Started',
      'register_have_account': 'Already have an account? ',
      'register_login': 'Log In',
      'register_name': 'Full Name:',
      'register_name_hint': 'Karen Hernández Costa',
      'register_email': 'Email:',
      'register_email_hint': 'email@gmail.com',
      'register_password': 'Create a password',
      'register_confirm_password': 'Confirm your password:',
      'register_privacy':
          'By registering you accept the Privacy Policy and Terms & Conditions.',
      'register_btn': 'Register',

      'personal_title': 'Let\'s start with\nthe basics',
      'personal_dob': 'Select your date of birth',
      'personal_dob_placeholder': '14/05/1993',
      'personal_gender': 'How do you identify?',
      'personal_bio': 'Tell us about yourself:',
      'personal_bio_hint': 'Write a short biography...',

      'physical_title': 'This information helps us\nimprove your matches',
      'physical_height': 'Your height',

      'interests_page_title': 'Choose your main\ninterests',
      'interests_page_subtitle': 'Your interests help us find better\nmatches.',
      'interests_search_hint': 'Search interests',
      'interests_popular': 'Popular interests',
      'interests_custom_hint': 'If you can\'t find your results, write them...',

      'qualities_page_title': 'What you appreciate most\nin a person',
      'qualities_page_subtitle':
          'These qualities help us create better matches.',
      'qualities_counter_label': 'What you look for in someone',

      'nav_skip': 'Skip',
      'login_title': 'Log In',
      'login_no_account': 'Don\'t have an account yet? ',
      'login_register': 'Register',
      'login_email': 'Email:',
      'login_email_hint': 'email@gmail.com',
      'login_password': 'Password:',
      'login_remember': 'Remember me',
      'login_btn': 'Log In',
      'val_name_required': 'Name is required',
      'val_name_min': 'Minimum 3 characters',
      'val_email_required': 'Email is required',
      'val_email_invalid': 'Enter a valid email',
      'val_password_required': 'Password is required',
      'val_min_8': 'Minimum 8 characters',
      'val_min_10': 'Minimum 10 characters',
      'val_max_500': 'Maximum 500 characters',
      'val_passwords_no_match': 'Passwords do not match',
      'val_dob_required': 'Select your date of birth',
      'val_gender_required': 'Select your gender',
      'val_custom_gender_required': 'Write how you identify',
      'val_bio_required': 'Biography is required',
      'val_bio_min': 'Biography must have at least 10 characters',
      'val_bio_max': 'Biography must have at most 500 characters',
      'val_height_required': 'Enter your height',
      'val_height_invalid': 'Enter a valid height between 100 and 250 cm',
      'val_interest_required': 'Select at least one interest',
      'val_max_interests': 'You can only select up to',
      'val_max_qualities': 'You can only select up to',
      'register_success': 'Registration successful. Please log in.',
      'login_warning': 'Warning',
      'login_val_email': 'Please enter your email',
      'login_val_password': 'Please enter your password',
      'login_error_title': 'Incorrect access',
      'chat_reconnecting': 'Reconnecting...',
      'chat_no_connection': 'No connection · Tap to retry',
      'chat_cost_info': 'This message costs ',
      'chat_balance_info': 'Your current credits are ',
      'chat_charge_info': 'The message will be charged only when sent.',
      'chat_first_msg_sent': 'First message sent. Wait for a reply.',
      'chat_hint_blocked': 'Waiting for reply...',
      'chat_hint': 'Write a message...',
      'chat_empty_title': 'Start the conversation',
      'chat_empty_subtitle': 'Send the first message to begin',
      'chat_error_title': 'Error loading messages',
      'nearby_no_more': 'No more nearby users',
      'nearby_load_error': 'Could not load users',
      'nearby_liked': 'You like',
      'nearby_removed_fav': 'removed from favorites',
      'nearby_error_process': 'Error processing',
      'nearby_like_sent': 'You liked',
      'nearby_error_like': 'Error liking',
      'nearby_next_profile': 'Moving to next profile',
      'nearby_error_reject': 'Error rejecting',
      'nearby_superlike_sent': 'You sent a Super Like to',
      'nearby_block_title': 'Block user',
      'nearby_block_msg': 'Are you sure you want to block',
      'nearby_block_confirm': 'Block',
      'nearby_blocked': 'has been blocked',
      'nearby_all_seen': 'You have seen all available profiles',
      'nearby_report_title': 'Report user',
      'nearby_report_msg': 'Why do you want to report',
      'nearby_report_confirm': 'Report',
      'nearby_report_thanks':
          'Thanks for your report. We will review the profile of',
      'nearby_send_message': 'Send message',
      'nearby_view_profile': 'View full profile', 'chat_credits': 'credits',
      'location_required_title': 'Location required',
      'location_required_desc':
          'We need your location to show you nearby users',
      'enable_location': 'Enable location',
      'open_settings': 'Open settings',
      //PreferencesPage
      'pref_gender_title': 'What kind of people would\nyou like to meet?',
      'pref_gender_subtitle': 'This preference is flexible and editable later.',
      'pref_gender_hint':
          'We\'ll show you profiles compatible with your preferences.',
      'pref_connection_title': 'What kind of connection\ndo you want?',
      'pref_connection_subtitle': 'Select up to two options that suit you.',
      'pref_connection_hint':
          'We\'ll show this preference to improve your matches.',
      'pref_age_title': 'What age range\ndo you prefer?',
      'pref_age_subtitle': 'You can adjust this later.',
      'pref_distance_title': 'Max distance',
      'pref_distance_up_to': 'Up to',
      'pref_photos_title': 'Introduce yourself with photos',
      'pref_photos_subtitle':
          'Upload at least 2 photos that show your essence.\nThe best connections start with great photos.',
      'pref_selection_required': 'Selection required',
      'pref_select_gender': 'Select a type of person',
      'pref_select_connection': 'Select at least one connection type',
      'pref_invalid_range': 'Invalid range',
      'pref_age_range_error': 'Minimum age cannot be greater than maximum age',
      'pref_photos_required': 'Photos required',
      'pref_photos_min': 'You must upload at least 2 photos',
      'pref_interests_required': 'Interests required',
      'pref_qualities_required': 'Qualities required',
      'pref_select_quality': 'You must select at least one quality',
      'pref_limit_reached': 'Limit reached',

      'pref_no_interests': 'No interests available',
      'pref_no_qualities': 'No qualities available',

      'pref_photos_max': 'You can upload up to',
      'pref_photos_partial': 'Only',
      'pref_photos_pick_error': 'Could not select photo',
      'pref_photo_take_error': 'Could not take photo',
      'pref_add_photos': 'Add photos',
      'pref_gallery_multiple': 'Gallery (multiple selection)',
      'pref_gallery_multiple_hint': 'Select several photos at once',
      'pref_take_photo': 'Take photo',
      'pref_take_photo_hint': 'Capture a new photo',
      // ── Tutoriales ─────────────────────────────────
      'tutorial_start_profile':
          'Here you can view and edit your profile information',
      'tutorial_start_radar': 'Radar: find people near your location',
      'tutorial_start_match': 'Match: see people who want to connect with you',
      'tutorial_start_chat':
          'Chat: continue conversations with your connections',
      'tutorial_start_panic':
          'Panic button: in an emergency, press it to call 911 and get immediate help',

      'tutorial_profile_blocked':
          'Here you can view and manage users you have blocked',
      'tutorial_profile_notifications':
          'Manage your push notifications and alert preferences',
      'tutorial_profile_edit':
          'Edit your profile: name, age, preferences and more',
      'tutorial_profile_settings': 'option to log out',
      'tutorial_profile_credits':
          'Tap here to add more credits to your account',
      'tutorial_profile_status':
          'Tap to edit your status message visible on the radar',

      'tutorial_update_age':
          'Edit the age range of people you prefer to connect with',
      'tutorial_update_distance':
          'Adjust the maximum distance of people you prefer to connect with',

      'tutorial_radar_slider':
          'Adjust the search radius to find people closer or farther from you',
      'tutorial_radar_points':
          'We give you a small group of nearby profiles so you can see each person',
      'tutorial_radar_search': 'Tap again to see more',
      'tutorial_radar_profile': 'Tap to view profiles',
      'tutorial_skip': 'Skip',
      // ── LikedByUsersView ───────────────────────────
      'liked_by_title': 'They liked me',
      'liked_by_hint': 'Users who liked you',
      'liked_by_tab': 'Liked me',
      'pending_tab': 'Pending',
      'liked_by_view_profile': 'View profile',
      'liked_by_empty_title': 'Nobody has liked you yet',
      'liked_by_empty_subtitle': 'Keep exploring to get more matches',
      'liked_by_error_title': 'Error loading likes',
      'liked_by_loading': 'Loading likes...',

      //reportar
      'report_title': 'Report',
'report_select_reason': 'Select the reason for the report',
'report_harassment': 'Harassment or intimidation',
'report_inappropriate': 'Inappropriate content',
'report_fake': 'Fake profile or spam',
'report_offensive': 'Offensive behavior',
'report_minor': 'Minor',
'report_other': 'Other',
'report_desc_hint': 'Description (required)',
'report_desc_required': 'Description is required',
'report_also_block': 'Also block',
'report_block_hint': 'They won\'t be able to contact you or see your profile',
'report_send': 'Send report',
'report_send_and_block': 'Report and block',
'report_success': 'Report sent. We will review the profile of',
'report_block_success': 'has been reported and blocked',
    },
  };
}
