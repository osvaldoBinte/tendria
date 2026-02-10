import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/chat/domain/entities/mensaje_entity.dart';
import 'package:tendria/features/chat/presentation/page/chat_controller.dart';

class ChatPage extends GetView<ChatController> {
  const ChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.mensajes.isEmpty) {
                return _buildLoadingState();
              }

              if (controller.hasError.value && controller.mensajes.isEmpty) {
                return _buildErrorState();
              }

              if (controller.mensajes.isEmpty) {
                return _buildEmptyState();
              }

              return _buildMessagesList();
            }),
          ),

          // Input de mensaje
          _buildMessageInput(),
        ],
      ),
    );
  }

  // AppBar personalizado
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ThemeColor.surfaceColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: ThemeColor.textPrimaryColor,
        ),
        onPressed: () => Get.back(),
      ),
      title: Obx(() {
        final usuario = controller.otroUsuario.value;
        return InkWell(
          onTap: controller.navigateToProfile,
          child: Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: ThemeColor.storyGradient,
                ),
                child: Container(
                  margin: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ThemeColor.surfaceColor,
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: usuario?.fotoUrl != null && usuario!.fotoUrl!.isNotEmpty
                        ? Image.network(
                            usuario.fotoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar();
                            },
                          )
                        : _buildDefaultAvatar(),
                  ),
                ),
              ),
              SizedBox(width: 12),
              // Nombre
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      usuario?.nombre ?? controller.userName ?? 'Usuario',
                      style: ThemeColor.subtitleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Match',
                      style: ThemeColor.caption.copyWith(
                        color: ThemeColor.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      actions: [
        IconButton(
          icon: Icon(
            Icons.more_vert,
            color: ThemeColor.textPrimaryColor,
          ),
          onPressed: () {
            // Mostrar opciones del chat
            _showChatOptions();
          },
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: ThemeColor.backgroundColorfondo,
      child: Icon(
        Icons.person,
        size: 24,
        color: ThemeColor.textSecondaryColor,
      ),
    );
  }

  // Lista de mensajes
  Widget _buildMessagesList() {
    return RefreshIndicator(
      onRefresh: controller.refreshChat,
      color: ThemeColor.primaryColor,
      backgroundColor: ThemeColor.surfaceColor,
      child: ListView.builder(
        controller: controller.scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: ThemeColor.paddingMedium,
          vertical: ThemeColor.paddingSmall,
        ),
        itemCount: controller.mensajes.length,
        itemBuilder: (context, index) {
          final mensaje = controller.mensajes[index];
          final showDateSeparator = controller.shouldShowDateSeparator(index);

          return Column(
            children: [
              // Separador de fecha
              if (showDateSeparator)
                _buildDateSeparator(mensaje.enviadoEn),

              // Mensaje
              _buildMessageBubble(mensaje),
            ],
          );
        },
      ),
    );
  }

  // Separador de fecha
  Widget _buildDateSeparator(DateTime dateTime) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ThemeColor.paddingMedium),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ThemeColor.paddingMedium,
          vertical: ThemeColor.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: ThemeColor.backgroundColorfondo,
          borderRadius: ThemeColor.mediumBorderRadius,
        ),
        child: Text(
          controller.formatDateSeparator(dateTime),
          style: ThemeColor.caption.copyWith(
            color: ThemeColor.textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Burbuja de mensaje
  Widget _buildMessageBubble(MensajeEntity mensaje) {
    final isOwn = mensaje.esPropio;
    
    return Padding(
      padding: EdgeInsets.only(bottom: ThemeColor.paddingSmall),
      child: Row(
        mainAxisAlignment: isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar del otro usuario (solo si no es propio)
          if (!isOwn) ...[
            _buildMessageAvatar(mensaje.senderFoto),
            SizedBox(width: 8),
          ],

          // Contenedor del mensaje
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: Get.width * 0.7,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: ThemeColor.paddingMedium,
                vertical: ThemeColor.paddingSmall + 2,
              ),
              decoration: BoxDecoration(
                color: isOwn
                    ? ThemeColor.primaryColor
                    : ThemeColor.surfaceColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ThemeColor.mediumRadius),
                  topRight: Radius.circular(ThemeColor.mediumRadius),
                  bottomLeft: Radius.circular(isOwn ? ThemeColor.mediumRadius : 4),
                  bottomRight: Radius.circular(isOwn ? 4 : ThemeColor.mediumRadius),
                ),
                boxShadow: [ThemeColor.lightShadow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Texto del mensaje
                  if (mensaje.mensaje != null && mensaje.mensaje!.isNotEmpty)
                    Text(
                      mensaje.mensaje!,
                      style: ThemeColor.bodyMedium.copyWith(
                        color: isOwn
                            ? ThemeColor.textLightColor
                            : ThemeColor.textPrimaryColor,
                      ),
                    ),
                  SizedBox(height: 4),
                  
                  // Hora del mensaje
                  Text(
                    controller.formatMessageTime(mensaje.enviadoEn),
                    style: ThemeColor.caption.copyWith(
                      color: isOwn
                          ? ThemeColor.textLightColor.withOpacity(0.7)
                          : ThemeColor.textSecondaryColor,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Avatar propio (solo si es propio)
          if (isOwn) ...[
            SizedBox(width: 8),
            _buildMessageAvatar(mensaje.senderFoto),
          ],
        ],
      ),
    );
  }

  // Avatar en mensaje
  Widget _buildMessageAvatar(String? photoUrl) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ThemeColor.backgroundColorfondo,
      ),
      child: ClipOval(
        child: photoUrl != null && photoUrl.isNotEmpty
            ? Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person,
                    size: 18,
                    color: ThemeColor.textSecondaryColor,
                  );
                },
              )
            : Icon(
                Icons.person,
                size: 18,
                color: ThemeColor.textSecondaryColor,
              ),
      ),
    );
  }

  // Input de mensaje
  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColor.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ThemeColor.paddingSmall),
          child: Row(
            children: [
              // Campo de texto
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: ThemeColor.backgroundColorfondo,
                    borderRadius: ThemeColor.circularBorderRadius,
                  ),
                  child: TextField(
                    controller: controller.messageController,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    style: ThemeColor.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      hintStyle: ThemeColor.bodyMedium.copyWith(
                        color: ThemeColor.textSecondaryColor,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: ThemeColor.paddingMedium,
                        vertical: ThemeColor.paddingSmall + 2,
                      ),
                    ),
                    onSubmitted: (_) => controller.sendMessage(),
                  ),
                ),
              ),
              SizedBox(width: ThemeColor.paddingSmall),

              // Botón de enviar
              Obx(() {
                final isTyping = controller.isTyping.value;
                final isSending = controller.isSending.value;

                return AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isTyping
                        ? ThemeColor.primaryColor
                        : ThemeColor.disabledColor,
                    shape: BoxShape.circle,
                    boxShadow: isTyping ? [ThemeColor.lightShadow] : [],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isTyping && !isSending
                          ? controller.sendMessage
                          : null,
                      borderRadius: BorderRadius.circular(100),
                      child: Center(
                        child: isSending
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    ThemeColor.textLightColor,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.send,
                                color: ThemeColor.textLightColor,
                                size: 22,
                              ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // Estado de carga
  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          ThemeColor.primaryColor,
        ),
      ),
    );
  }

  // Estado de error
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ThemeColor.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: ThemeColor.errorColor,
            ),
            SizedBox(height: ThemeColor.paddingMedium),
            Text(
              'Error al cargar mensajes',
              style: ThemeColor.headingSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ThemeColor.paddingSmall),
            Text(
              controller.errorMessage.value,
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ThemeColor.paddingLarge),
            ThemeColor.widgetButton(
              text: 'REINTENTAR',
              onPressed: controller.loadChatMessages,
              backgroundColor: ThemeColor.primaryColor,
              textColor: ThemeColor.textLightColor,
            ),
          ],
        ),
      ),
    );
  }

  // Estado vacío
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ThemeColor.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(ThemeColor.paddingLarge),
              decoration: BoxDecoration(
                color: ThemeColor.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 60,
                color: ThemeColor.primaryColor,
              ),
            ),
            SizedBox(height: ThemeColor.paddingLarge),
            Text(
              'Inicia la conversación',
              style: ThemeColor.headingSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ThemeColor.paddingSmall),
            Text(
              'Envía el primer mensaje para comenzar',
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Mostrar opciones del chat
  void _showChatOptions() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: ThemeColor.surfaceColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(ThemeColor.largeRadius),
            topRight: Radius.circular(ThemeColor.largeRadius),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: EdgeInsets.only(top: ThemeColor.paddingSmall),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ThemeColor.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: ThemeColor.paddingMedium),

              // Opciones
              _buildChatOption(
                icon: Icons.person,
                title: 'Ver perfil',
                onTap: () {
                  Get.back();
                  controller.navigateToProfile();
                },
              ),
              _buildChatOption(
                icon: Icons.delete_outline,
                title: 'Eliminar conversación',
                textColor: ThemeColor.errorColor,
                onTap: () {
                  Get.back();
                  _showDeleteConfirmation();
                },
              ),
              SizedBox(height: ThemeColor.paddingSmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? ThemeColor.textPrimaryColor,
      ),
      title: Text(
        title,
        style: ThemeColor.bodyMedium.copyWith(
          color: textColor ?? ThemeColor.textPrimaryColor,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        backgroundColor: ThemeColor.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: ThemeColor.mediumBorderRadius,
        ),
        title: Text(
          '¿Eliminar conversación?',
          style: ThemeColor.headingSmall,
        ),
        content: Text(
          'Esta acción no se puede deshacer',
          style: ThemeColor.bodyMedium.copyWith(
            color: ThemeColor.textSecondaryColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancelar',
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textSecondaryColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // Implementar eliminación
            },
            child: Text(
              'Eliminar',
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}