import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/widgets/alert/snackbar_helper.dart';
import 'package:tendria/features/chat/domain/usecase/get_chat_mensaje_usecase.dart';
import 'package:tendria/features/chat/domain/usecase/send_message_usecase.dart';
import 'package:tendria/features/chat/domain/entities/chat_entity.dart';
import 'package:tendria/features/chat/domain/entities/mensaje_entity.dart';
import 'package:tendria/features/chat/domain/entities/usuario_chat_entity.dart';
import 'package:tendria/features/chat/domain/entities/post_chat_entity.dart';

class ChatController extends GetxController {
  final GetChatMensajeUsecase getChatMensajeUsecase;
  final SendMessageUsecase sendMessageUsecase;

  ChatController({
    required this.getChatMensajeUsecase,
    required this.sendMessageUsecase,
  });

  // Controllers
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // Estados reactivos
  final Rx<ChatEntity?> chat = Rx<ChatEntity?>(null);
  final RxList<MensajeEntity> mensajes = <MensajeEntity>[].obs;
  final Rx<UsuarioChatEntity?> otroUsuario = Rx<UsuarioChatEntity?>(null);
  
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isTyping = false.obs;

  // Datos del chat
  late int chatId;
  String? userName;

  @override
  void onInit() {
    super.onInit();
    _loadArguments();
    loadChatMessages();
    
    // Listener para detectar cuando escribe
    messageController.addListener(_onMessageChanged);
  }

  @override
  void onClose() {
    messageController.removeListener(_onMessageChanged);
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // Cargar argumentos de navegación
  void _loadArguments() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    chatId = arguments?['chatId'] ?? 0;
    userName = arguments?['name'];
  }

  // Listener de cambios en el texto
  void _onMessageChanged() {
    isTyping.value = messageController.text.trim().isNotEmpty;
  }

  // Cargar mensajes del chat
  Future<void> loadChatMessages() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Ahora recibimos un ChatEntity directamente
      final result = await getChatMensajeUsecase.execute(chatId);
      
      chat.value = result;
      mensajes.value = result.mensajes;
      otroUsuario.value = result.otroUsuario;
      
      // Scroll al final después de cargar
      Future.delayed(Duration(milliseconds: 300), () {
        _scrollToBottom();
      });
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error al cargar mensajes: $e';
      print('Error loading chat messages: $e');
    } finally {
      isLoading.value = false;
    }
  }

 // Enviar mensaje
Future<void> sendMessage() async {
  final message = messageController.text.trim();
  
  if (message.isEmpty || isSending.value) return;

  try {
    isSending.value = true;

    // Limpiar campo de texto inmediatamente
    messageController.clear();

    // Enviar mensaje al servidor
    final postEntity = PostChatEntity(
      chatId: chatId,
      menssage: message,
    );

    await sendMessageUsecase.execute(postEntity);

    // Recargar mensajes para obtener el mensaje real del servidor
    await loadChatMessages();

  } catch (e) {
    // Restaurar el texto en el campo en caso de error
    messageController.text = message;
    showErrorSnackbar('No se pudo enviar el mensaje',);
  
    
    print('Error sending message: $e');
  } finally {
    isSending.value = false;
  }
}
  // Refrescar chat
  Future<void> refreshChat() async {
    await loadChatMessages();
  }

  // Scroll al final
  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Navegar al perfil del otro usuario
  void navigateToProfile() {
    if (otroUsuario.value != null) {
      Get.toNamed('/profile', arguments: {
        'userId': otroUsuario.value!.id,
      });
    }
  }

  // Formatear hora del mensaje
  String formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Hoy - mostrar solo hora
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      // Ayer
      return 'Ayer ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      // Esta semana
      final weekDays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      return '${weekDays[dateTime.weekday - 1]} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      // Más de una semana
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  // Verificar si debe mostrar separador de fecha
  bool shouldShowDateSeparator(int index) {
    if (index == 0) return true;
    
    final currentMessage = mensajes[index];
    final previousMessage = mensajes[index - 1];
    
    final currentDate = DateTime(
      currentMessage.enviadoEn.year,
      currentMessage.enviadoEn.month,
      currentMessage.enviadoEn.day,
    );
    
    final previousDate = DateTime(
      previousMessage.enviadoEn.year,
      previousMessage.enviadoEn.month,
      previousMessage.enviadoEn.day,
    );
    
    return currentDate != previousDate;
  }

  // Formatear separador de fecha
  String formatDateSeparator(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return 'Hoy';
    } else if (messageDate == yesterday) {
      return 'Ayer';
    } else if (now.difference(messageDate).inDays < 7) {
      final weekDays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
      return weekDays[dateTime.weekday - 1];
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}