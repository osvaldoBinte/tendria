import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/controller/theme_controller.dart';
import 'package:tendria/common/theme/App_Theme.dart';

class DashboardHomeVip extends StatefulWidget {
  const DashboardHomeVip({Key? key}) : super(key: key);

  @override
  State<DashboardHomeVip> createState() => _DashboardHomeVipScreenState();
}

class _DashboardHomeVipScreenState extends State<DashboardHomeVip> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();

    return Obx(() {
      final mode = themeCtrl.themeMode.value; 
      return Scaffold(
        backgroundColor: ThemeColor.backgroundColorfondo,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 16),
                    _buildWelcome(),
                    const SizedBox(height: 24),
                    _buildLiveCreators(),
                    const SizedBox(height: 20),
                    _buildGiftsCard(),
                    const SizedBox(height: 16),
                    _buildBalanceCard(),
                    const SizedBox(height: 24),
                    _buildMarketplaceSection(),
                    const SizedBox(height: 28),
                    _buildRecentContentHeader(),
                    const SizedBox(height: 16),
                    _LockedPostCard(
                      name: 'Alex Mercer',
                      handle: '@mercerfit',
                      level: 'Nivel 3 - Oro',
                      credits: 50,
                      unlockedByCount: 50,
                    ),
                    const SizedBox(height: 20),
                    _UnlockedPostCard(
                      name: 'Elena V.',
                      handle: '@elenavisuals',
                      level: 'Nivel 2 - Plata',
                      unlockedByCount: 500,
                      caption:
                          'Detrás de escena de la sesión de hoy. Solo para '
                          'mis suscriptores, aquí pueden ver cómo montamos '
                          'la iluminación principal para lograr ese look '
                          'cinemático. 📸🎥',
                      likes: 892,
                      comments: 45,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
        
      );
    });
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: ThemeColor.backgroundColorfondo,
      child: Row(
        children: [
          Icon(Icons.menu_rounded, color: ThemeColor.iconColor),
          const SizedBox(width: 12),
          Text(
            'Tatendria VIP',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ThemeColor.textPrimary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ThemeColor.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_balance_wallet_rounded,
                    size: 14, color: Colors.black),
                const SizedBox(width: 6),
                Text(
                  '\$1,240.00',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 16,
            backgroundColor: ThemeColor.subtleBackground,
            child: Icon(Icons.person, size: 18, color: ThemeColor.iconColor),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bienvenido de nuevo, Tatendría',
          style: ThemeColor.headingSmall.copyWith(
            color: ThemeColor.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tu contenido exclusivo está listo para ser descubierto.',
          style: ThemeColor.bodyMedium.copyWith(
            color: ThemeColor.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLiveCreators() {
    final creators = [
      {'name': 'Elena V.', 'live': true},
      {'name': 'Marc J.', 'live': true},
      {'name': 'Sofi K.', 'live': false},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'CREADORES EN VIVO',
                  style: ThemeColor.caption.copyWith(
                    color: ThemeColor.textSecondary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            Text(
              'Ver todos',
              style: ThemeColor.caption.copyWith(color: ThemeColor.primaryColor),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: creators.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              final c = creators[i];
              final isLive = c['live'] as bool;
              return Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isLive
                          ? LinearGradient(
                              colors: [
                                ThemeColor.primaryColor,
                                ThemeColor.secondaryColor,
                              ],
                            )
                          : null,
                      border: !isLive
                          ? Border.all(color: ThemeColor.subtleBorder)
                          : null,
                    ),
                    child: Stack(
                      children: [
                        ClipOval(
                          child: Container(
                            color: ThemeColor.subtleBackground,
                            child: Icon(Icons.person,
                                color: ThemeColor.iconColor, size: 28),
                          ),
                        ),
                        if (isLive)
                          Positioned(
                            bottom: -2,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'LIVE',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    c['name'] as String,
                    style: ThemeColor.caption.copyWith(
                      color: ThemeColor.textPrimary,
                      fontSize: 11,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGiftsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColor.cardBackground,
        borderRadius: ThemeColor.mediumBorderRadius,
        border: Border.all(color: ThemeColor.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.card_giftcard_rounded, color: ThemeColor.primaryColor),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ThemeColor.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '3 Nuevos',
                  style: ThemeColor.caption.copyWith(
                    color: ThemeColor.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Regalos pendientes',
            style: ThemeColor.subtitleLarge.copyWith(
              color: ThemeColor.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tus fans han enviado detalles exclusivos para ti.',
            style: ThemeColor.bodySmall.copyWith(
              color: ThemeColor.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColor.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: ThemeColor.mediumBorderRadius,
                ),
                elevation: 0,
              ),
              child: Text(
                'Abrir regalos',
                style: ThemeColor.buttonText.copyWith(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeColor.primaryColor,
            ThemeColor.primaryColor.withOpacity(0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: ThemeColor.mediumBorderRadius,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MI BALANCE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '\$1,240.00',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: const [
                  Icon(Icons.trending_up_rounded, size: 14, color: Colors.black87),
                  SizedBox(width: 4),
                  Text(
                    '+12% esta semana',
                    style: TextStyle(fontSize: 11, color: Colors.black87),
                  ),
                ],
              ),
            ],
          ),
          const Icon(Icons.account_balance_wallet_rounded,
              color: Colors.black87, size: 30),
        ],
      ),
    );
  }

  Widget _buildMarketplaceSection() {
    final items = [
      {'title': 'Vuelo Privado: BTS', 'author': '@Vanesa_Exclusive', 'price': '\$49.99'},
      {'title': 'Colección "Gold Dust"', 'author': '@Tatendria_VIP', 'price': '\$25.00'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CONTENIDO MÁS VENDIDO',
              style: ThemeColor.caption.copyWith(
                color: ThemeColor.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            Text(
              'Explorar mercado',
              style: ThemeColor.caption.copyWith(color: ThemeColor.primaryColor),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: items.map((item) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: item == items.first ? 12 : 0,
                  left: item == items.last ? 12 : 0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: ThemeColor.cardBackground,
                    borderRadius: ThemeColor.mediumBorderRadius,
                    border: Border.all(color: ThemeColor.subtleBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Container(
                              height: 90,
                              width: double.infinity,
                              color: ThemeColor.subtleBackground,
                              child: Icon(Icons.image_rounded,
                                  color: ThemeColor.iconColor.withOpacity(0.3),
                                  size: 32),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item['price']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Center(
                              child: Icon(
                                Icons.lock_rounded,
                                color: Colors.white.withOpacity(0.9),
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title']!,
                              style: ThemeColor.bodySmall.copyWith(
                                color: ThemeColor.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Por ${item['author']}',
                              style: ThemeColor.caption.copyWith(
                                color: ThemeColor.textSecondary,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentContentHeader() {
    return Center(
      child: Text(
        'contenido reciente',
        style: ThemeColor.caption.copyWith(
          color: ThemeColor.textSecondary,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _LockedPostCard extends StatelessWidget {
  final String name;
  final String handle;
  final String level;
  final int credits;
  final int unlockedByCount;

  const _LockedPostCard({
    required this.name,
    required this.handle,
    required this.level,
    required this.credits,
    required this.unlockedByCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColor.cardBackground,
        borderRadius: ThemeColor.largeBorderRadius,
        border: Border.all(color: ThemeColor.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostHeader(name: name, handle: handle, level: level, levelColor: const Color(0xFFD4AF37)),
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.85),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ThemeColor.primaryColor.withOpacity(0.15),
                  ),
                  child: Icon(Icons.lock_rounded,
                      color: ThemeColor.primaryColor, size: 28),
                ),
                const SizedBox(height: 14),
                Text(
                  'Contenido Exclusivo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Esta publicación está reservada para miembros VIP o '
                    'requiere desbloqueo individual.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: ThemeColor.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_rounded, size: 14, color: Colors.black),
                      const SizedBox(width: 6),
                      Text(
                        'Desbloquear · $credits créditos',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(Icons.favorite_border_rounded,
                    size: 18, color: ThemeColor.textSecondary),
                const SizedBox(width: 16),
                Icon(Icons.mode_comment_outlined,
                    size: 18, color: ThemeColor.textSecondary),
                const Spacer(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: RichText(
              text: TextSpan(
                style: ThemeColor.bodySmall.copyWith(
                  color: ThemeColor.textSecondary,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: '$name  ',
                    style: TextStyle(
                      color: ThemeColor.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: '[Contenido bloqueado] actualmente se desbloqueó '
                        'por $unlockedByCount personas',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnlockedPostCard extends StatelessWidget {
  final String name;
  final String handle;
  final String level;
  final int unlockedByCount;
  final String caption;
  final int likes;
  final int comments;

  const _UnlockedPostCard({
    required this.name,
    required this.handle,
    required this.level,
    required this.unlockedByCount,
    required this.caption,
    required this.likes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColor.cardBackground,
        borderRadius: ThemeColor.largeBorderRadius,
        border: Border.all(color: ThemeColor.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostHeader(
            name: name,
            handle: handle,
            level: level,
            levelColor: const Color(0xFFB0B4BA),
            trailing: Icon(Icons.more_horiz_rounded, color: ThemeColor.iconColor),
          ),
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 260,
                color: ThemeColor.subtleBackground,
                child: Icon(Icons.image_rounded,
                    color: ThemeColor.iconColor.withOpacity(0.3), size: 40),
              ),
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            size: 13, color: ThemeColor.primaryColor),
                        const SizedBox(width: 6),
                        Text(
                          'CONTENIDO DESBLOQUEADO POR $unlockedByCount PERSONAS',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(Icons.favorite_rounded, size: 18, color: Colors.redAccent),
                const SizedBox(width: 6),
                Text('$likes', style: ThemeColor.bodySmall.copyWith(color: ThemeColor.textSecondary)),
                const SizedBox(width: 16),
                Icon(Icons.mode_comment_outlined, size: 18, color: ThemeColor.textSecondary),
                const SizedBox(width: 6),
                Text('$comments', style: ThemeColor.bodySmall.copyWith(color: ThemeColor.textSecondary)),
                const Spacer(),
                Icon(Icons.card_giftcard_rounded, size: 16, color: ThemeColor.primaryColor),
                const SizedBox(width: 4),
                Text(
                  'Enviar regalo',
                  style: ThemeColor.caption.copyWith(color: ThemeColor.primaryColor),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: RichText(
              text: TextSpan(
                style: ThemeColor.bodySmall.copyWith(
                  color: ThemeColor.textSecondary,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: '$name  ',
                    style: TextStyle(
                      color: ThemeColor.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: caption),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  final String name;
  final String handle;
  final String level;
  final Color levelColor;
  final Widget? trailing;

  const _PostHeader({
    required this.name,
    required this.handle,
    required this.level,
    required this.levelColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: ThemeColor.subtleBackground,
            child: Icon(Icons.person, color: ThemeColor.iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: ThemeColor.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: levelColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        level,
                        style: TextStyle(
                          color: levelColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  handle,
                  style: ThemeColor.caption.copyWith(
                    color: ThemeColor.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}