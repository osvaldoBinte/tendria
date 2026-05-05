import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/settings/language_controller.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/chat/domain/entities/mensaje_entity.dart';
import 'package:tendria/features/chat/presentation/page/chat_controller.dart';
import 'package:tendria/features/chat/presentation/page/connect.dart';
import 'package:tendria/features/like/presentation/controller/my_match_controller.dart';

class ChatPage extends GetView<ChatController> {
  const ChatPage({Key? key}) : super(key: key);

  MyMatchController get mycontroller => Get.find<MyMatchController>();
  LanguageController get _l => Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        FocusScope.of(context).unfocus();
        mycontroller.loadChats();
        if (controller.goHomeIndex.value >= 0) {
          Get.offAllNamed(
            RoutesNames.homePage,
            arguments: {'tab': controller.goHomeIndex.value},
          );
        } else {
          Get.back();
          mycontroller.loadChats();
        }
      },
      child: Listener(
        onPointerDown: (e) {
          controller.setPointerDown(e.position);
          controller.setPointerDownTime(DateTime.now());
        },
        onPointerUp: (e) {
          final distance = (e.position - controller.pointerDown).distance;
          final duration = DateTime.now().difference(
            controller.pointerDownTime,
          );
          if (distance < 10 && duration.inMilliseconds < 200) {
            FocusScope.of(context).unfocus();
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: ThemeColor.backgroundColor,
          appBar: _buildAppBar(),
          body: Column(
            children: [
              _buildConnectionIndicator(),
              Expanded(child: _buildBody()),
              _buildMessageInput(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ThemeColor.surfaceColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: ThemeColor.textPrimaryColor),
        onPressed: () {
          FocusScope.of(Get.context!).unfocus();
          if (controller.goHomeIndex.value >= 0) {
            mycontroller.loadChats(silent: true);
            Get.offAllNamed(
              RoutesNames.homePage,
              arguments: {'tab': controller.goHomeIndex.value},
            );
            print('silencio homePage');
          } else {
            Get.back();
            print('silencio');
            mycontroller.loadChats(silent: true);
          }
        },
      ),
      title: Obx(() {
        final usuario = controller.otroUsuario.value;

        return InkWell(
          onTap: () {
            FocusScope.of(Get.context!).unfocus();
            controller.navigateToProfile();
          },
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: ThemeColor.storyGradient,
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ThemeColor.surfaceColor,
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child:
                            (usuario?.fotoUrl != null &&
                                    usuario!.fotoUrl!.isNotEmpty) ||
                                controller.userPhoto != null
                            ? Image.network(
                                usuario?.fotoUrl?.isNotEmpty == true
                                    ? usuario!.fotoUrl!
                                    : controller.userPhoto!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildDefaultAvatar(),
                              )
                            : _buildDefaultAvatar(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      usuario?.nombre ?? controller.userName ?? _l.t('user'),
                      style: ThemeColor.subtitleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: ThemeColor.backgroundColorfondo,
      child: Icon(Icons.person, size: 24, color: ThemeColor.textSecondaryColor),
    );
  }

  Widget _buildConnectionIndicator() {
    return Obx(() {
      if (controller.isNewConversation.value) return const SizedBox.shrink();
      if (controller.isSignalRConnected.value) return const SizedBox.shrink();

      final isRetrying =
          controller.isRetrying.value ||
          Get.find<SignalRService>().isReconnecting.value;

      return GestureDetector(
        onTap: isRetrying ? null : controller.retrySignalRConnection,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: ThemeColor.warningColor.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isRetrying)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ThemeColor.warningColor,
                  ),
                )
              else
                Icon(Icons.refresh, size: 16, color: ThemeColor.warningColor),
              const SizedBox(width: 8),
              Text(
                isRetrying
                    ? _l.t('chat_reconnecting')
                    : _l.t('chat_no_connection'),
                style: ThemeColor.caption.copyWith(
                  color: ThemeColor.warningColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBody() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/fodochat.jpeg', fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.15)),
        ),
        Obx(() {
          if (!controller.isNewConversation.value) {
            if (controller.isLoading.value && controller.mensajes.isEmpty) {
              return _buildLoadingState();
            }
            if (controller.hasError.value && controller.mensajes.isEmpty) {
              return _buildErrorState();
            }
          }
          if (controller.mensajes.isEmpty) return _buildEmptyState();
          return _buildMessagesList();
        }),
      ],
    );
  }

  Widget _buildMessagesList() {
    return RefreshIndicator(
      onRefresh: controller.refreshChat,
      color: ThemeColor.primaryColor,
      backgroundColor: ThemeColor.surfaceColor,
      child: ListView.builder(
        controller: controller.scrollController,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: controller.mensajes.length,
        itemBuilder: (_, index) {
          final msg = controller.mensajes[index];
          return Column(
            children: [
              if (controller.shouldShowDateSeparator(index))
                _buildDateSeparator(msg.enviadoEn),
              _buildMessageBubble(msg),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateSeparator(DateTime dt) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: ThemeColor.backgroundColorfondo,
          borderRadius: ThemeColor.mediumBorderRadius,
        ),
        child: Text(
          controller.formatDateSeparator(dt),
          style: ThemeColor.caption.copyWith(
            color: ThemeColor.textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(MensajeEntity mensaje) {
    final isOwn = mensaje.esPropio;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isOwn
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOwn) ...[
            _buildMessageAvatar(mensaje.senderFoto),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: Get.width * 0.7),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isOwn
                    ? ThemeColor.primaryColor
                    : ThemeColor.surfaceColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ThemeColor.mediumRadius),
                  topRight: Radius.circular(ThemeColor.mediumRadius),
                  bottomLeft: Radius.circular(
                    isOwn ? ThemeColor.mediumRadius : 4,
                  ),
                  bottomRight: Radius.circular(
                    isOwn ? 4 : ThemeColor.mediumRadius,
                  ),
                ),
                boxShadow: [ThemeColor.lightShadow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (mensaje.mensaje != null && mensaje.mensaje!.isNotEmpty)
                    Text(
                      mensaje.mensaje!,
                      style: ThemeColor.bodyMedium.copyWith(
                        color: isOwn
                            ? ThemeColor.textLightColor
                            : ThemeColor.textPrimaryColor,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          controller.formatMessageTime(mensaje.enviadoEn),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ThemeColor.caption.copyWith(
                            color: isOwn
                                ? ThemeColor.textLightColor.withOpacity(0.7)
                                : ThemeColor.textSecondaryColor,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      if (isOwn) ...[
                        const SizedBox(width: 4),
                        _buildMessageStatus(mensaje.leidoEn),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isOwn) ...[
            const SizedBox(width: 8),
            _buildMessageAvatar(mensaje.senderFoto ?? controller.myPhoto),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageStatus(DateTime? leidoEn) {
    final isRead = leidoEn != null;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Icon(
        isRead ? Icons.done_all : Icons.done,
        key: ValueKey(isRead),
        size: 14,
        color: isRead ? Colors.blue[200] : Colors.white54,
      ),
    );
  }

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
                errorBuilder: (_, __, ___) => Icon(
                  Icons.person,
                  size: 18,
                  color: ThemeColor.textSecondaryColor,
                ),
              )
            : Icon(
                Icons.person,
                size: 18,
                color: ThemeColor.textSecondaryColor,
              ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Obx(() {
      final isNew = controller.isNewConversation.value;
      final blocked = isNew && controller.firstMessageSent.value;

      return Container(
        decoration: BoxDecoration(
          color: ThemeColor.surfaceColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.isNewConversation.value &&
                    !controller.firstMessageSent.value)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeColor.primaryColor.withOpacity(0.1),
                      borderRadius: ThemeColor.smallBorderRadius,
                      border: Border.all(
                        color: ThemeColor.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: ThemeColor.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Obx(
                            () => RichText(
                              text: TextSpan(
                                style: ThemeColor.caption.copyWith(
                                  color: ThemeColor.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  TextSpan(text: _l.t('chat_cost_info')),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Icon(
                                      Icons.bolt_rounded,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '${controller.balanceController.chatCost.toStringAsFixed(0)} ${_l.t('chat_credits')}. ',
                                  ),
                                  TextSpan(text: _l.t('chat_balance_info')),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Icon(
                                      Icons.bolt_rounded,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '${controller.balanceController.currentBalance.toStringAsFixed(0)}. ',
                                  ),
                                  TextSpan(text: _l.t('chat_charge_info')),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (blocked)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeColor.primaryColor.withOpacity(0.1),
                      borderRadius: ThemeColor.smallBorderRadius,
                      border: Border.all(
                        color: ThemeColor.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: ThemeColor.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _l.t('chat_first_msg_sent'),
                            style: ThemeColor.caption.copyWith(
                              color: ThemeColor.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                Row(
                  children: [
                    Expanded(
                      child: Opacity(
                        opacity: blocked ? 0.5 : 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: blocked
                                ? ThemeColor.disabledColor
                                : ThemeColor.backgroundColorfondo,
                            borderRadius: ThemeColor.circularBorderRadius,
                          ),
                          child: TextField(
                            controller: controller.messageController,
                            enabled: !blocked,
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.done,
                            style: ThemeColor.bodyMedium,
                            onTap: blocked
                                ? null
                                : () {
                                    Future.delayed(
                                      const Duration(milliseconds: 400),
                                      () {
                                        if (controller
                                            .scrollController
                                            .hasClients) {
                                          controller.scrollToBottom();
                                        }
                                      },
                                    );
                                  },
                            decoration: InputDecoration(
                              hintText: blocked
                                  ? _l.t('chat_hint_blocked')
                                  : _l.t('chat_hint'),
                              hintStyle: ThemeColor.bodyMedium.copyWith(
                                color: ThemeColor.textSecondaryColor,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            onSubmitted: blocked
                                ? null
                                : (_) {
                                    FocusScope.of(Get.context!).unfocus();
                                    controller.sendMessage();
                                  },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Obx(() {
                      final canSend =
                          !blocked &&
                          (controller.isNewConversation.value
                              ? !controller.isSending.value
                              : controller.isTyping.value &&
                                    !controller.isSending.value);

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: canSend
                              ? ThemeColor.primaryColor
                              : ThemeColor.disabledColor,
                          shape: BoxShape.circle,
                          boxShadow: canSend ? [ThemeColor.lightShadow] : [],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: canSend
                                ? () {
                                    FocusScope.of(Get.context!).unfocus();
                                    controller.sendMessage();
                                  }
                                : null,
                            borderRadius: BorderRadius.circular(100),
                            child: Center(
                              child: controller.isSending.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.send,
                                      color: canSend
                                          ? ThemeColor.textLightColor
                                          : ThemeColor.textSecondaryColor,
                                      size: 22,
                                    ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 24),
            Text(
              _l.t('chat_empty_title'),
              style: ThemeColor.headingSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _l.t('chat_empty_subtitle'),
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

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.primaryColor),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: ThemeColor.errorColor),
            const SizedBox(height: 16),
            Text(
              _l.t('chat_error_title'),
              style: ThemeColor.headingSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.loadChatMessages,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColor.primaryColor,
              ),
              child: Text(
                _l.t('retry'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
