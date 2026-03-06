import 'package:get/get.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/features/chat/domain/usecase/get_my_chats_usecase.dart';
import 'package:tendria/features/chat/domain/entities/chat_entity.dart';

class MyMatchController extends GetxController {
  final GetMyChatsUsecase getMyChatsUsecase;
  MyMatchController({required this.getMyChatsUsecase});

  // Estados reactivos
  final RxList<ChatEntity> chats = <ChatEntity>[].obs;
  final RxList<ChatEntity> filteredChats = <ChatEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;

  // ← NUEVO: filtro sin responder
  final RxBool filterPendingOnly = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadChats();
  }

  // Cargar chats
  Future<void> loadChats() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await getMyChatsUsecase.execute();
      chats.value = result;
      _applyFilters();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error al cargar chats: $e';
      print('Error loading chats: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Refrescar chats
  Future<void> refreshChats() async {
    await loadChats();
  }

  // Activar/desactivar búsqueda
  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      clearSearch();
    }
  }

  // Buscar chats
  void searchChats(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  // Limpiar búsqueda
  void clearSearch() {
    searchQuery.value = '';
    _applyFilters();
  }

  // ← NUEVO: toggle filtro sin responder
  void togglePendingFilter() {
    filterPendingOnly.value = !filterPendingOnly.value;
    _applyFilters();
  }

  // ← NUEVO: lógica centralizada de filtros
  void _applyFilters() {
    List<ChatEntity> result = List.from(chats);

    // Filtro: solo sin responder (último mensaje no es propio)
    if (filterPendingOnly.value) {
      result = result.where((chat) {
        final ultimo = chat.ultimoMensaje;
        return ultimo != null && !ultimo.esPropio;
      }).toList();
    }

    // Filtro: búsqueda por texto
    if (searchQuery.value.isNotEmpty) {
      final searchLower = searchQuery.value.toLowerCase();
      result = result.where((chat) {
        final nombre = chat.otroUsuario.nombre.toLowerCase();
        final mensaje = chat.ultimoMensaje?.mensaje?.toLowerCase() ?? '';
        return nombre.contains(searchLower) || mensaje.contains(searchLower);
      }).toList();
    }

    filteredChats.value = result;
  }

  // ← NUEVO: cuántos chats están sin responder
  int get pendingCount => chats
      .where((c) => c.ultimoMensaje != null && !c.ultimoMensaje!.esPropio)
      .length;

  // Navegar al chat
  void navigateToChat(int chatId, String name) {
    print('Navigating to chat with ID: $chatId and name: $name');
    Get.toNamed(RoutesNames.chatPage, arguments: {
      'chatId': chatId,
      'name': name,
      'goHomeIndex': 3,
    });
  }

  // Navegar al perfil
  void navigateToProfile(int userId) {
    Get.toNamed('/profile', arguments: {'userId': userId});
  }
}