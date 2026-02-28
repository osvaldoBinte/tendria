import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/errors/convert_message.dart';
import 'package:tendria/common/services/auth_service.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/widgets/alert/snackbar_helper.dart';
import 'package:tendria/features/chat/domain/entities/chat_entity.dart';
import 'package:tendria/features/chat/domain/entities/mensaje_entity.dart';
import 'package:tendria/features/chat/domain/entities/post_chat_entity.dart';
import 'package:tendria/features/chat/domain/entities/usuario_chat_entity.dart';
import 'package:tendria/features/chat/domain/usecase/get_chat_mensaje_usecase.dart';
import 'package:tendria/features/chat/domain/usecase/send_message_usecase.dart';
import 'package:tendria/features/chat/presentation/page/connect.dart';
import 'package:tendria/features/like/domain/usecase/payments_chat_usecase.dart';
import 'package:tendria/features/like/domain/usecase/start_conversations_usecase.dart';
import 'package:tendria/features/like/presentation/controller/my_match_controller.dart';
import 'package:tendria/features/user/presentation/controller/nearby_users_controller.dart';

class ChatController extends GetxController {
  // ── Use cases nuevas conversaciones ──
  final StartConversationsUsecase startConversationsUsecase;
  final PaymentsChatUsecase paymentsChatUsecase;

  // ── Use cases chat existente ──
  // 👇 Se eliminaron: connect, disconnect, join, leave, setupListener
  //    Ahora los maneja SignalRService
  final GetChatMensajeUsecase getChatMensajeUsecase;
  final SendMessageUsecase sendMessageUsecase;
  final AuthService authService;

  ChatController({
    required this.startConversationsUsecase,
    required this.paymentsChatUsecase,
    required this.getChatMensajeUsecase,
    required this.sendMessageUsecase,
    required this.authService,
  });

  // ── Controllers UI ──
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // ── Estado reactivo ──
  final RxList<MensajeEntity> mensajes = <MensajeEntity>[].obs;
  final Rx<UsuarioChatEntity?> otroUsuario = Rx<UsuarioChatEntity?>(null);
  final Rx<ChatEntity?> chat = Rx<ChatEntity?>(null);

  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isTyping = false.obs;
  final RxBool isSignalRConnected = false.obs;

  // ── Modo de operación ──
  final RxBool isNewConversation = true.obs;
  final RxBool firstMessageSent = false.obs;

  // ── IDs ──
  late int targetUserId;
  int? chatId;
  String? userName;

  // ── Referencia al servicio global ──
  late final SignalRService _signalRService;

  @override
  void onInit() {
    super.onInit();
    _signalRService = Get.find<SignalRService>();
    _loadArguments();
    messageController.addListener(_onMessageChanged);

    if (!isNewConversation.value) {
      _subscribeToChat(); // 👈 Solo suscribirse, el socket ya está vivo
      loadChatMessages();
    }
  }

  @override
  void onClose() {
    messageController.removeListener(_onMessageChanged);
    messageController.dispose();
    scrollController.dispose();

    // 👇 Solo desuscribirse del chat, NO desconectar el SignalR global
    if (!isNewConversation.value && chatId != null) {
      _signalRService.unsubscribeFromChat(chatId!);
    }

    super.onClose();
  }

  // ─────────────────────────────────────────
  //  INICIALIZACIÓN
  // ─────────────────────────────────────────

  void _loadArguments() {
    final args = Get.arguments as Map<String, dynamic>?;

    chatId = args?['chatId'] as int?;
    targetUserId = args?['userid'] ?? args?['userId'] ?? 0;
    userName = args?['name'];
    isNewConversation.value = (chatId == null);

    if (args?['otroUsuario'] != null) {
      otroUsuario.value = args!['otroUsuario'] as UsuarioChatEntity;
    }
  }

  // ─────────────────────────────────────────
  //  SIGNALR — Solo suscripción al chat
  // ─────────────────────────────────────────

  Future<void> _subscribeToChat() async {
    try {
      // Reflejar el estado de conexión del servicio global
      isSignalRConnected.value = _signalRService.isConnected.value;

      // Escuchar cambios futuros de conexión (ej: reconexión automática)
      ever(_signalRService.isConnected, (bool connected) {
        isSignalRConnected.value = connected;
      });

      // Suscribirse al chat específico
      // El SignalRService internamente llama joinChatUsecase
      await _signalRService.subscribeToChat(chatId!, _handleIncomingMessage);
    } catch (e) {
      isSignalRConnected.value = false;
      print('Error suscribiéndose al chat: $e');
    }
  }

  void _handleIncomingMessage(MensajeEntity mensaje) {
    final exists = mensajes.any((m) => m.id == mensaje.id);
    if (!exists) {
      mensajes.add(mensaje);
      if (mensaje.esPropio || _isNearBottom()) {
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      }
    }
  }

bool _isNearBottom() {
  if (!scrollController.hasClients) return false;
  return (scrollController.position.maxScrollExtent -
          scrollController.position.pixels) < 100;
}
  // ─────────────────────────────────────────
  //  CARGA DE MENSAJES
  // ─────────────────────────────────────────

  Future<void> loadChatMessages() async {
    if (chatId == null) return;
    try {
      isLoading.value = true;
      hasError.value = false;

      final result = await getChatMensajeUsecase.execute(chatId!);
      chat.value = result;
      mensajes.value = result.mensajes ?? [];
      otroUsuario.value = result.otroUsuario;

      Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error al cargar mensajes: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshChat() => loadChatMessages();

  // ─────────────────────────────────────────
  //  ENVÍO DE MENSAJES
  // ─────────────────────────────────────────

  void _onMessageChanged() {
    if (isNewConversation.value && firstMessageSent.value) {
      if (messageController.text.isNotEmpty) messageController.clear();
      isTyping.value = false;
      return;
    }
    isTyping.value = messageController.text.trim().isNotEmpty;
  }

  Future<void> sendMessage() async {
    if (isNewConversation.value) {
      await _sendFirstMessage();
    } else {
      await _sendRegularMessage();
    }
  }

  Future<void> _sendFirstMessage() async {
    if (firstMessageSent.value || isSending.value) return;

    final message = messageController.text.trim();
    if (message.isEmpty) return;

    try {
      isSending.value = true;
      messageController.clear();

      final postEntity = PostChatEntity(
        chatId: targetUserId,
        menssage: message,
      );

      await startConversationsUsecase.execute(postEntity);

      _addLocalMessage(message);
      firstMessageSent.value = true;
      isTyping.value = false;

      if (Get.isRegistered<NearbyUsersController>()) {
        Get.find<NearbyUsersController>().loadNearbyUsers();
      }

      showSuccessSnackbar('Mensaje enviado. Espera la respuesta.');
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    } catch (e) {
      messageController.text = message;
      showErrorSnackbar('No se pudo enviar: ${cleanExceptionMessage(e)}');
    } finally {
      isSending.value = false;
    }
  }

  Future<void> _sendRegularMessage() async {
    final message = messageController.text.trim();
    if (message.isEmpty || isSending.value) return;

    try {
      isSending.value = true;
      messageController.clear();

      final postEntity = PostChatEntity(chatId: chatId!, menssage: message);
      await sendMessageUsecase.execute(postEntity);
      // El mensaje regresa por SignalR automáticamente
    } catch (e) {
      messageController.text = message;
      showErrorSnackbar('No se pudo enviar el mensaje');
    } finally {
      isSending.value = false;
    }
  }

  void _addLocalMessage(String messageText) {
    mensajes.add(MensajeEntity(
      id: DateTime.now().millisecondsSinceEpoch,
      chatId: targetUserId,
      senderId: 0,
      senderNombre: null,
      senderFoto: null,
      mensaje: messageText,
      enviadoEn: DateTime.now(),
      esPropio: true,
    ));
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // ─────────────────────────────────────────
  //  NAVEGACIÓN Y UTILIDADES
  // ─────────────────────────────────────────

  void navigateToProfile() {
    final uid = otroUsuario.value?.id ?? targetUserId;
    Get.toNamed(RoutesNames.userProfileDetailPage, arguments: {'userId': uid});
  }

  String formatMessageTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    if (diff.inDays == 0) return '$hh:$mm';
    if (diff.inDays == 1) return 'Ayer $hh:$mm';
    if (diff.inDays < 7) {
      const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      return '${days[dt.weekday - 1]} $hh:$mm';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  bool shouldShowDateSeparator(int index) {
    if (index == 0) return true;
    final cur = mensajes[index].enviadoEn;
    final prev = mensajes[index - 1].enviadoEn;
    return DateTime(cur.year, cur.month, cur.day) !=
        DateTime(prev.year, prev.month, prev.day);
  }

  String formatDateSeparator(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msg = DateTime(dt.year, dt.month, dt.day);
    if (msg == today) return 'Hoy';
    if (msg == today.subtract(const Duration(days: 1))) return 'Ayer';
    if (now.difference(msg).inDays < 7) {
      const days = [
        'Lunes', 'Martes', 'Miércoles', 'Jueves',
        'Viernes', 'Sábado', 'Domingo'
      ];
      return days[dt.weekday - 1];
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}