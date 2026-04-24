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
import 'package:tendria/features/user/presentation/controller/balance_controller.dart';
import 'package:tendria/features/user/presentation/controller/nearby_users_controller.dart';

class ChatController extends GetxController {
  final StartConversationsUsecase startConversationsUsecase;
  final PaymentsChatUsecase paymentsChatUsecase;
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

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

BalanceController get balanceController => Get.find<BalanceController>();
  final mensajes = RxList<MensajeEntity>([]);
  final Rx<UsuarioChatEntity?> otroUsuario = Rx<UsuarioChatEntity?>(null);
  final Rx<ChatEntity?> chat = Rx<ChatEntity?>(null);

  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isTyping = false.obs;
  final RxBool isSignalRConnected = false.obs;

  final RxBool isNewConversation = true.obs;
  final RxBool firstMessageSent = false.obs;

  late int targetUserId;
  int? chatId;
  String? userName;
  String? userPhoto;
  String? myPhoto;
  final RxInt goHomeIndex = (-1).obs;
  final RxInt goPerfilIndex = (-1).obs;

  // Usado por el Listener en ChatPage para distinguir tap vs scroll
  Offset pointerDown = Offset.zero;

  void setPointerDown(Offset position) {
    pointerDown = position;
  }

  late final SignalRService _signalRService;

@override
void onInit() {
  super.onInit();
 
  _signalRService = Get.find<SignalRService>();
 
  _loadArguments();
 
  _signalRService.escucharMensajesLeidos(_onMensajesLeidos);

  messageController.addListener(_onMessageChanged);

  if (!isNewConversation.value) {
    isSignalRConnected.value = _signalRService.isConnected.value;

    ever(_signalRService.isConnected, (bool connected) {
      isSignalRConnected.value = connected;
      if (connected) isRetrying.value = false;
      if (!connected) _autoReconnect();
    });

    ever(_signalRService.isReconnecting, (bool reconnecting) {
      if (reconnecting) isRetrying.value = true;
    });

    _subscribeToChat(); 
    loadChatMessages().then((_) => _marcarComoLeidos());
  }
} 
Future<void> _marcarComoLeidos() async {
  if (chatId == null) return;
  final otroId = otroUsuario.value?.id ?? 0;
  if (otroId == 0) return;
  await _signalRService.marcarMensajesLeidos(chatId!, otroId);
}

void _onMensajesLeidos(DateTime leidoEn) { 
  mensajes.value = mensajes.map((m) {
    if (m.esPropio && m.leidoEn == null) {
      return MensajeEntity(
        id: m.id,
        chatId: m.chatId,
        senderId: m.senderId,
        senderNombre: m.senderNombre,
        senderFoto: m.senderFoto,
        mensaje: m.mensaje,
        enviadoEn: m.enviadoEn,
        esPropio: m.esPropio,
        leidoEn: leidoEn, // ✅ marcar como leído
      );
    }
    return m;
  }).toList();
}
  @override
  void onClose() {
    messageController.removeListener(_onMessageChanged);
    messageController.dispose();
    scrollController.dispose();

    if (!isNewConversation.value && chatId != null) {
      _signalRService.unsubscribeFromChat(chatId!);
    }

    super.onClose();
  }

  void _loadArguments() {
    final args = Get.arguments as Map<String, dynamic>?;

    chatId = args?['chatId'] as int?;
    targetUserId = args?['userid'] ?? args?['userId'] ?? 0;
    userName = args?['name'];
    isNewConversation.value = (chatId == null);
    userPhoto = args?['photo'];
    myPhoto = args?['MyPhoto'];
    goHomeIndex.value = args?['goHomeIndex'] ?? -1;
    goPerfilIndex.value = args?['goPerfilIndex'] ?? -1;

    if (args?['otroUsuario'] != null) {
      otroUsuario.value = args!['otroUsuario'] as UsuarioChatEntity;
    }
  }

  Future<void> _subscribeToChat() async {
    try {
      await _signalRService.subscribeToChat(chatId!, _handleIncomingMessage);
    } catch (e) {
      print('Error suscribiéndose al chat: $e');
      _autoReconnect();
    }
  }

  Future<void> _autoReconnect() async {
    if (isRetrying.value || isSignalRConnected.value) return;

    print('🔄 Auto-reconectando SignalR desde ChatController...');

    await Future.delayed(const Duration(seconds: 2));

    if (_signalRService.isConnected.value) {
      try {
        if (chatId != null) {
          await _signalRService.subscribeToChat(
              chatId!, _handleIncomingMessage);
        }
      } catch (e) {
        print('❌ Error re-suscribiéndose: $e');
      }
      return;
    }

    await retrySignalRConnection();
  }

  void _handleIncomingMessage(MensajeEntity mensaje) {
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
      Future.delayed(const Duration(milliseconds: 100), scrollToBottom);
    }
  }

  bool _isNearBottom() {
    if (!scrollController.hasClients) return false;
    return (scrollController.position.maxScrollExtent -
            scrollController.position.pixels) <
        100;
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

  Future<void> loadChatMessages() async {
    if (chatId == null) return;
    try {
      isLoading.value = true;
      hasError.value = false;

      final result = await getChatMensajeUsecase.execute(chatId!);
      chat.value = result;

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
          leidoEn: m.leidoEn, // ✅ no olvides mapear este campo
        ))
    .toList();

      mensajes.value = lista;
      otroUsuario.value = result.otroUsuario;

      Future.delayed(const Duration(milliseconds: 300), scrollToBottom);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error al cargar mensajes: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshChat() => loadChatMessages();

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

    // ✅ Recargar balance después de descontar el costo
    if (Get.isRegistered<BalanceController>()) {
      await Get.find<BalanceController>().fetchBalance();
    }

    if (Get.isRegistered<NearbyUsersController>()) {
      Get.find<NearbyUsersController>().loadNearbyUsers();
    }

    showSuccessSnackbar('Mensaje enviado. Espera la respuesta.');
    Future.delayed(const Duration(milliseconds: 100), scrollToBottom);
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

    final tempId = DateTime.now().millisecondsSinceEpoch;
    final haySignalR = isSignalRConnected.value;

    try {
      isSending.value = true;
      messageController.clear();

      if (!haySignalR) {
        _addLocalMessage(message, tempId: tempId);
        Future.delayed(const Duration(milliseconds: 100), scrollToBottom);
      }

      final postEntity = PostChatEntity(chatId: chatId!, menssage: message);
      await sendMessageUsecase.execute(postEntity);
    } catch (e) {
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

    mensajes.value = [...mensajes.map((m) => m as MensajeEntity), nuevo];
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void navigateToProfile() {
    final uid = otroUsuario.value?.id ?? targetUserId;
    Get.toNamed(RoutesNames.userProfileDetailPage, arguments: {'userId': uid,'goPerfilIndex':goPerfilIndex,});
  }

String formatMessageTime(DateTime dt) {
  // ✅ Convertir de UTC a hora local del dispositivo
  final local = dt.toLocal();
  final now = DateTime.now();
  final diff = now.difference(local);

  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');

  if (diff.inDays == 0) return '$hh:$mm';
  if (diff.inDays == 1) return 'Ayer $hh:$mm';
  if (diff.inDays < 7) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return '${days[local.weekday - 1]} $hh:$mm';
  }
  return '${local.day}/${local.month}/${local.year}';
}

String formatDateSeparator(DateTime dt) {
  // ✅ Convertir de UTC a hora local del dispositivo
  final local = dt.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final msg = DateTime(local.year, local.month, local.day);

  if (msg == today) return 'Hoy';
  if (msg == today.subtract(const Duration(days: 1))) return 'Ayer';
  if (now.difference(msg).inDays < 7) {
    const days = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves',
      'Viernes', 'Sábado', 'Domingo'
    ];
    return days[local.weekday - 1];
  }
  return '${local.day}/${local.month}/${local.year}';
}

bool shouldShowDateSeparator(int index) {
  if (index == 0) return true;
  final cur = mensajes[index].enviadoEn.toLocal();
  final prev = mensajes[index - 1].enviadoEn.toLocal();
  return DateTime(cur.year, cur.month, cur.day) !=
      DateTime(prev.year, prev.month, prev.day);
}



  DateTime pointerDownTime = DateTime.now();

void setPointerDownTime(DateTime time) {
  pointerDownTime = time;
}
}