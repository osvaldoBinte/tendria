import 'package:get/get.dart';
import 'package:tendria/features/user/presentation/controller/profile_controller.dart';

class LanguageController extends GetxController {

  // ==========================================
  // HELPERS PÚBLICOS
  // ==========================================

  /// Idioma actual del usuario. Fallback: 'Español'
  String get lang {
    try {
      return Get.find<ProfileController>().primarylanguage;
    } catch (_) {
      return 'Español';
    }
  }

  /// Traduce una key al idioma actual del usuario
  String t(String key) => translate(key, lang);

  /// Traduce una key a un idioma específico
  String translate(String key, String language) {
    return _translations[language]?[key] ??
        _translations['Español']?[key] ??
        key;
  }

  // ==========================================
  // TRADUCCIONES
  // ==========================================

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
      'no_limit': 'Sin límite',

      // ── ProfilePage ────────────────────────────────
      'profile': 'Perfil',
      'discover': 'Descubrir perfiles cercanos',
      'photos': 'Fotos',
      'photos_hint': 'Toca + para agregar varias fotos de jalón',
      'my_biography': 'Mi Biografía',
      'add_status': 'Agregar estado',

      // ── LikedByUsersView ───────────────────────────
      'pending_chats': 'Chats Pendientes',
      'unlock_hint': 'Desbloquea los chats para comenzar a conversar.',
      'unlock': 'conectar',

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
      'qualities_subtitle': 'Elige hasta 3 cualidades que valoras en una persona.',
      'qualities_add': 'Agrega cualidades que valoras',

      // ── Bottom sheets: Intereses ───────────────────
      'bs_interests_title': 'Elige tus intereses\nprincipales',
      'bs_interests_subtitle': 'Tus gustos nos ayudan a encontrar mejores coincidencias.',
      'bs_interests_counter': 'Intereses populares',
      'bs_interests_selected': 'seleccionados',
      'bs_max_interests': 'Puedes seleccionar máximo 5 intereses',
      'bs_interests_saved': 'Intereses actualizados correctamente',
      'bs_interests_load_error': 'No se pudieron cargar los intereses',

      // ── Bottom sheets: Cualidades ──────────────────
      'bs_qualities_title': 'Lo que más aprecias en\nuna persona',
      'bs_qualities_subtitle': 'Estas cualidades nos ayudan a crear mejores coincidencias.',
      'bs_qualities_counter': 'Lo que buscas en alguien',
      'bs_max_qualities': 'Puedes seleccionar máximo 3 cualidades',
      'bs_qualities_saved': 'Cualidades actualizadas correctamente',

      // ── Bottom sheets: Altura ──────────────────────
      'bs_height_title': 'Tu altura',
      'bs_height_subtitle': 'Esta información nos ayuda a mejorar tus coincidencias.',

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
      'bs_search_gender_subtitle': 'Esta preferencia es flexible y editable más adelante.',

      // ── Bottom sheets: Tipo de conexión ───────────
      'bs_connection_title': '¿Qué tipo de conexión\nquieres?',
      'bs_connection_subtitle': 'Selecciona la opción que vaya contigo.',

      // ── Bottom sheets: Rango de edad ──────────────
      'bs_age_range_title': 'Rango de edad',
      'bs_age_min': 'Mínimo',
      'bs_age_max': 'Máximo',

      // ── Bottom sheets: Distancia ───────────────────
      'bs_distance_title': 'Distancia máxima',
      'bs_no_limit_distance': 'Sin límite de distancia',

      // ── Bottom sheets: Biografía ───────────────────
      'bs_bio_title': 'Cuéntanos sobre ti',
      'bs_bio_subtitle': 'Una buena biografía ayuda a generar mejores conexiones.',
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
      'alert_delete_account_msg': '¿Estás seguro? Esta acción es permanente y no se puede deshacer.',
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
      'empty_subtitle_chats': 'Comienza a dar likes para encontrar tu match perfecto',
      'empty_title_pending': 'No tienes chats pendientes',
      'empty_subtitle_pending': 'Cuando alguien te escriba, aparecerá aquí',
      'explore': 'EXPLORAR PERFILES',
      'save': 'Guardar',
      'cancel': 'Cancelar',
      'error': 'Error',
      'accept': 'Aceptar',
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
      'pending_chats': 'Pending Chats',
      'unlock_hint': 'Unlock chats to start chatting.',
      'unlock': 'connect',

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
      'bs_search_gender_subtitle': 'This preference is flexible and editable later.',

      // ── Bottom sheets: Tipo de conexión ───────────
      'bs_connection_title': 'What kind of connection\ndo you want?',
      'bs_connection_subtitle': 'Select the option that suits you.',

      // ── Bottom sheets: Rango de edad ──────────────
      'bs_age_range_title': 'Age range',
      'bs_age_min': 'Minimum',
      'bs_age_max': 'Maximum',

      // ── Bottom sheets: Distancia ───────────────────
      'bs_distance_title': 'Max distance',
      'bs_no_limit_distance': 'No distance limit',

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
      'alert_delete_account_msg': 'Are you sure? This action is permanent and cannot be undone.',
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
      'empty_subtitle_chats': 'Start liking profiles to find your perfect match',
      'empty_title_pending': 'No pending chats',
      'empty_subtitle_pending': 'When someone writes to you, it will appear here',
      'explore': 'EXPLORE PROFILES',
      'save': 'Save',
      'cancel': 'Cancel',
      'error': 'Error',
      'accept': 'Accept',
    },
  };
}