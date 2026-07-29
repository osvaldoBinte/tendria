import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/controller/theme_controller.dart';
import 'package:tendria/common/theme/App_Theme.dart';

class ChatPremium extends StatefulWidget {
  const ChatPremium({Key? key}) : super(key: key);

  @override
  State<ChatPremium> createState() => _ChatPremiumScreenState();
}

class _ChatPremiumScreenState extends State<ChatPremium> {
  final TextEditingController _messageController = TextEditingController();
  int _currentNavIndex = 2;  

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();

    return Obx(() {
      final mode = themeCtrl.themeMode.value;
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(gradient: ThemeColor.vipBackgroundGradient2),
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    children: [
                      _buildDateDivider('HOY'),
                      const SizedBox(height: 16),
                      _buildEncryptedNotice(),
                      const SizedBox(height: 16),
                      _buildReceivedMessage(
                        text: '¡Hola corazón! Qué alegría verte por aquí en '
                            'el club privado. ✨',
                        time: '10:42 AM',
                      ),
                      const SizedBox(height: 16),
                      _buildLockedContentCard(),
                      const SizedBox(height: 16),
                      _buildReceivedMessage(
                        text: 'Me encanta la nueva sesión. Siempre superando '
                            'las expectativas. 🥂',
                        time: '10:45 AM',
                      ),
                    ],
                  ),
                ),
              ),
              _buildMessageInput(context),
            ],
          ),
        ), 
      );
    });
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 8,
        16,
        12,
      ),
      color: Colors.transparent,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                color: ThemeColor.iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: ThemeColor.subtleBackground,
                child: Icon(Icons.person, color: ThemeColor.iconColor, size: 22),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
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
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '@bellavips',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: ThemeColor.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.verified_rounded, color: ThemeColor.primaryColor, size: 15),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: ThemeColor.primaryColor.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'SOCIA VIP',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: ThemeColor.primaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'En línea',
                      style: ThemeColor.caption.copyWith(
                        color: ThemeColor.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.videocam_rounded, color: ThemeColor.primaryColor, size: 22),
          const SizedBox(width: 16),
          Icon(Icons.more_vert_rounded, color: ThemeColor.iconColor, size: 20),
        ],
      ),
    );
  }

  Widget _buildDateDivider(String label) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: ThemeColor.subtleBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: ThemeColor.caption.copyWith(
            color: ThemeColor.textSecondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildEncryptedNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: ThemeColor.primaryColor.withOpacity(0.1),
        borderRadius: ThemeColor.mediumBorderRadius,
        border: Border.all(color: ThemeColor.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline_rounded, size: 16, color: ThemeColor.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Conexión cifrada de extremo a extremo. Contenido exclusivo.',
              style: ThemeColor.bodySmall.copyWith(
                color: ThemeColor.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivedMessage({required String text, required String time}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: ThemeColor.cardBackground.withOpacity(0.85),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Text(
              text,
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textPrimary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              time,
              style: ThemeColor.caption.copyWith(
                color: ThemeColor.textSecondary,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedContentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: ThemeColor.largeBorderRadius,
        border: Border.all(color: ThemeColor.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ThemeColor.primaryColor.withOpacity(0.15),
              border: Border.all(color: ThemeColor.primaryColor.withOpacity(0.4)),
            ),
            child: Icon(Icons.lock_rounded, color: ThemeColor.primaryColor, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            'Desbloquear Contenido',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: ThemeColor.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set fotográfico exclusivo (5 imágenes)',
            textAlign: TextAlign.center,
            style: ThemeColor.bodyMedium.copyWith(
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: ThemeColor.primaryColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Desbloquear por  ',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Icon(Icons.diamond_rounded, size: 15, color: Colors.black),
                  const SizedBox(width: 4),
                  const Text(
                    '50',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: ThemeColor.backgroundColor.withOpacity(0.95),
        border: Border(top: BorderSide(color: ThemeColor.subtleBorder)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.add_circle_outline_rounded, color: ThemeColor.iconColor, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: ThemeColor.subtleBackground,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: ThemeColor.subtleBorder),
                  ),
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(color: ThemeColor.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje exclusivo...',
                      hintStyle: TextStyle(
                        color: ThemeColor.textSecondary,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ThemeColor.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.black, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: ThemeColor.secondaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.diamond_rounded, size: 14, color: ThemeColor.primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      'ENVIAR REGALO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: ThemeColor.primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  } 
}