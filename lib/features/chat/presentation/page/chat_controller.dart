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
final RxBool isRetrying = false.obs;

  // ── Controllers UI ──
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // ── Estado reactivo ──
final mensajes = RxList<MensajeEntity>([]);
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
  String? userPhoto;
  String? myPhoto;
final RxBool goHome = false.obs;

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
    userPhoto = args?['photo'];
    myPhoto = args?['MyPhoto'];


  goHome.value = args?['goHome'] == true;

    if (args?['otroUsuario'] != null) {
      otroUsuario.value = args!['otroUsuario'] as UsuarioChatEntity;
    }
  }

  // ─────────────────────────────────────────
  //  SIGNALR — Solo suscripción al chat
  // ─────────────────────────────────────────

Future<void> _subscribeToChat() async {
  try {
    isSignalRConnected.value = _signalRService.isConnected.value;

    // ✅ Cuando se desconecta, intenta reconectar automáticamente
    ever(_signalRService.isConnected, (bool connected) {
      isSignalRConnected.value = connected;
      if (!connected && !isNewConversation.value) {
        _autoReconnect();
      }
    });

    await _signalRService.subscribeToChat(chatId!, _handleIncomingMessage);
  } catch (e) {
    isSignalRConnected.value = false;
    print('Error suscribiéndose al chat: $e');
    _autoReconnect(); // ✅ Si falló al suscribirse, también reintenta
  }
}

Future<void> _autoReconnect() async {
  if (isRetrying.value || isSignalRConnected.value) return;

  print('🔄 Auto-reconectando SignalR desde ChatController...');
  
  // Pequeña espera para no chocar con el intento del SignalRService
  await Future.delayed(const Duration(seconds: 2));
  
  // Si el servicio global ya reconectó, solo re-suscribirse al chat
  if (_signalRService.isConnected.value) {
    try {
      if (chatId != null) {
        await _signalRService.subscribeToChat(chatId!, _handleIncomingMessage);
      }
    } catch (e) {
      print('❌ Error re-suscribiéndose: $e');
    }
    return;
  }

  // Si el servicio global sigue caído, forzar reconexión
  await retrySignalRConnection();
}void _handleIncomingMessage(MensajeEntity mensaje) {
  // Evitar duplicados por ID
  if (mensajes.any((m) => m.id == mensaje.id)) return;

  mensajes.value = [
    ...mensajes,
    MensajeEntity(
      id: mensaje.id,
      chatId: mensaje.chatId,
      senderId: mensaje.senderId,
      senderNombre: mensaje.senderNombre,
      senderFoto: mensaje.senderFoto,
      mensaje: mensaje.mensaje,
      enviadoEn: mensaje.enviadoEn,
      esPropio: mensaje.esPropio,
    ),
  ];

  if (mensaje.esPropio || _isNearBottom()) {
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }
}

bool _isNearBottom() {
  if (!scrollController.hasClients) return false;
  return (scrollController.position.maxScrollExtent -
          scrollController.position.pixels) < 100;
}

Future<void> retrySignalRConnection() async {
  if (isSignalRConnected.value || isRetrying.value) return;
  try {
    isRetrying.value = true;
    final token = await authService.getToken();
    if (token == null) return;
    await _signalRService.connect(token);
    if (_signalRService.isConnected.value && chatId != null) {
      await _signalRService.subscribeToChat(chatId!, _handleIncomingMessage);
    }
  } catch (e) {
    print('❌ Error reconectando: $e');
  } finally {
    isRetrying.value = false;
  }
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

    // ✅ Convierte cada item explícitamente a MensajeEntity
    final lista = (result.mensajes ?? [])
        .map((m) => MensajeEntity(
              id: m.id,
              chatId: m.chatId,
              senderId: m.senderId,
              senderNombre: m.senderNombre,
              senderFoto: m.senderFoto,
              mensaje: m.mensaje,
              enviadoEn: m.enviadoEn,
              esPropio: m.esPropio,
            ))
        .toList();

    mensajes.value = lista;
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
  }Future<void> _sendRegularMessage() async {
  final message = messageController.text.trim();
  if (message.isEmpty || isSending.value) return;

  final tempId = DateTime.now().millisecondsSinceEpoch;
  final haySignalR = isSignalRConnected.value;

  try {
    isSending.value = true;
    messageController.clear();

    // ✅ Solo agregar local si NO hay SignalR
    // Con SignalR: el mensaje llega por el socket y se muestra ahí
    // Sin SignalR: mostramos local para que el usuario vea algo
    if (!haySignalR) {
      _addLocalMessage(message, tempId: tempId);
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }

    final postEntity = PostChatEntity(chatId: chatId!, menssage: message);
    await sendMessageUsecase.execute(postEntity);

  } catch (e) {
    // Si falló, quitar el local si lo habíamos puesto
    if (!haySignalR) {
      mensajes.removeWhere((m) => m.id == tempId);
    }
    messageController.text = message;
    print('Error enviando mensaje: $e');
    showErrorSnackbar('No se pudo enviar el mensaje');
  } finally {
    isSending.value = false;
  }
}
void _addLocalMessage(String messageText, {int? tempId}) {
  final nuevo = MensajeEntity(
    id: tempId ?? DateTime.now().millisecondsSinceEpoch,
    chatId: chatId ?? targetUserId,
    senderId: 0,
    senderNombre: null,
    senderFoto: myPhoto,
    mensaje: messageText,
    enviadoEn: DateTime.now(),
    esPropio: true,
  );
  // Fuerza el tipo correcto creando una nueva lista
  mensajes.value = [...mensajes.map((m) => m as MensajeEntity), nuevo];
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