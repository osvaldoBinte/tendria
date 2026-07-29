import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/controller/theme_controller.dart';
import 'package:tendria/common/theme/App_Theme.dart';

class AchievementsCenterVip extends StatefulWidget {
  const AchievementsCenterVip({Key? key}) : super(key: key);

  @override
  State<AchievementsCenterVip> createState() => _AchievementsCenterVipScreenState();
}

class _AchievementsCenterVipScreenState extends State<AchievementsCenterVip> {
  int _currentNavIndex = 2;  

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();

    return Obx(() {
      final mode = themeCtrl.themeMode.value;
      return Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SafeArea(
                top: false,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 16),
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildTopEngagementCard(),
                    const SizedBox(height: 16),
                    _buildTipRecordCard(),
                    const SizedBox(height: 28),
                    _buildSectionHeader('Insignias de Prestigio', Icons.workspace_premium_outlined),
                    const SizedBox(height: 14),
                    _PrestigeBadgeCard(
                      icon: Icons.verified_rounded,
                      iconColor: const Color(0xFF3B9BFF),
                      title: 'Verificado',
                      description: 'Identidad confirmada y confianza garantizada.',
                      state: _BadgeState.unlocked,
                    ),
                    const SizedBox(height: 14),
                    _PrestigeBadgeCard(
                      icon: Icons.military_tech_rounded,
                      iconColor: const Color(0xFFD4AF37),
                      title: 'Elite',
                      description: 'Creador de alto rendimiento con 1k+ suscriptores.',
                      state: _BadgeState.current,
                    ),
                    const SizedBox(height: 14),
                    _PrestigeBadgeCard(
                      icon: Icons.diamond_rounded,
                      iconColor: ThemeColor.textSecondary,
                      title: 'Diamante',
                      description: 'Nivel Leyenda. Requiere \$10k+ en ganancias totales.',
                      state: _BadgeState.locked,
                    ),
                    const SizedBox(height: 28),
                    _buildSectionHeader('Próximos Desafíos', Icons.rocket_launch_outlined),
                    const SizedBox(height: 14),
                    _ChallengeRow(
                      icon: Icons.lock_open_rounded,
                      title: '100 desbloqueos en un post',
                      current: 64,
                      total: 100,
                    ),
                    const SizedBox(height: 12),
                    _RewardChallengeRow(
                      icon: Icons.emoji_events_rounded,
                      title: 'Recibe una Corona VIP',
                      subtitle: 'Regalo especial de un suscriptor Top Tier.',
                    ),
                    const SizedBox(height: 28),
                    _buildSectionHeader('Recompensas Activas', Icons.card_giftcard_rounded),
                    const SizedBox(height: 14),
                    _ActiveRewardCard(
                      icon: Icons.camera_alt_rounded,
                      accentColor: const Color(0xFFD4AF37),
                      title: 'Filtro de Cámara VIP',
                      description: 'Lente "Golden Hour" exclusivo desbloqueado.',
                      actionLabel: 'Usar',
                      isActive: false,
                    ),
                    const SizedBox(height: 12),
                    _ActiveRewardCard(
                      icon: Icons.bolt_rounded,
                      accentColor: const Color(0xFFE85D8A),
                      title: 'Prioridad en Feed',
                      description: 'Tus posts aparecen primero durante 24h.',
                      actionLabel: 'Activo',
                      isActive: true,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildCustomBottomNav(),
      );
    });
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12,
        16,
        12,
      ),
      color: Colors.black,
      child: Row(
        children: [
          Icon(Icons.menu_rounded, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            'Tatendria VIP',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              color: ThemeColor.primaryColor,
            ),
          ),
          const Spacer(),
          CircleAvatar(
            radius: 18,
            backgroundColor: ThemeColor.subtleBackground,
            child: Icon(Icons.person, color: Colors.white70, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DASHBOARD DE ÉXITO',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: ThemeColor.primaryColor,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Logros del Creador',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            color: ThemeColor.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ThemeColor.primaryColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ThemeColor.primaryColor.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, size: 14, color: ThemeColor.primaryColor),
              const SizedBox(width: 6),
              Text(
                'Nivel Elite',
                style: TextStyle(
                  color: ThemeColor.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopEngagementCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: ThemeColor.mediumBorderRadius,
        border: Border.all(color: ThemeColor.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top 1% Mensual',
                style: TextStyle(
                  color: ThemeColor.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const Icon(Icons.trending_up_rounded, color: Color(0xFF4CAF50), size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Has superado al 99% de los creadores en engagement este mes.',
            style: TextStyle(color: ThemeColor.textvip, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso al Siguiente Hito',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              Text(
                '85%',
                style: TextStyle(
                  color: ThemeColor.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.85,
              minHeight: 6,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(ThemeColor.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipRecordCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: ThemeColor.mediumBorderRadius,
        border: Border.all(color: ThemeColor.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.account_balance_wallet_rounded, color: ThemeColor.primaryColor, size: 20),
          const SizedBox(height: 10),
          Text(
            'Récord de Propinas',
            style: TextStyle(color: ThemeColor.primaryColor , fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            '\$840.00',
            style: TextStyle(
              color: ThemeColor.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 26,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'En una sola sesión. ¡Impresionante!',
            style: TextStyle(color: ThemeColor.textvip   , fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: ThemeColor.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style:   TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: ThemeColor.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Inicio'},
      {'icon': Icons.search_rounded, 'label': 'Explorar'},
      {'icon': Icons.add_circle_outline_rounded, 'label': ''},
      {'icon': Icons.credit_card_rounded, 'label': 'Balance'},
      {'icon': Icons.person_rounded, 'label': 'Perfil'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (index) {
              final isSelected = index == _currentNavIndex;
              final isCenter = index == 2;

              if (isCenter) {
                return GestureDetector(
                  onTap: () => setState(() => _currentNavIndex = index),
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? ThemeColor.primaryColor.withOpacity(0.2) : null,
                      border: Border.all(color: ThemeColor.primaryColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: ThemeColor.primaryColor.withOpacity(0.5),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      items[index]['icon'] as IconData,
                      color: ThemeColor.primaryColor,
                      size: 24,
                    ),
                  ),
                );
              }

              return GestureDetector(
                onTap: () => setState(() => _currentNavIndex = index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[index]['icon'] as IconData,
                      size: 22,
                      color: isSelected ? Colors.white : Colors.white54,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[index]['label'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.white54,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

enum _BadgeState { unlocked, current, locked }

class _PrestigeBadgeCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final _BadgeState state;

  const _PrestigeBadgeCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = state == _BadgeState.locked;
    final isCurrent = state == _BadgeState.current;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: ThemeColor.mediumBorderRadius,
        border: Border.all(
          color: isCurrent
              ? ThemeColor.primaryColor.withOpacity(0.6)
              : ThemeColor.subtleBorder,
          width: isCurrent ? 1.4 : 1,
        ),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLocked
                      ? Colors.white.withOpacity(0.06)
                      : iconColor.withOpacity(0.15),
                  border: Border.all(
                    color: isLocked ? Colors.white24 : iconColor.withOpacity(0.5),
                  ),
                ),
                child: Icon(
                  icon,
                  color: isLocked ? Colors.white38 : iconColor,
                  size: 28,
                ),
              ),
              if (isCurrent)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              color: isLocked ? Colors.white38 : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isLocked ? Colors.white24 : Colors.white54,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final int current;
  final int total;

  const _ChallengeRow({
    required this.icon,
    required this.title,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / total).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: ThemeColor.mediumBorderRadius,
        border: Border.all(color: ThemeColor.subtleBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ThemeColor.primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: ThemeColor.primaryColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation(ThemeColor.primaryColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$current/$total',
            style: TextStyle(
              color: ThemeColor.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardChallengeRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _RewardChallengeRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: ThemeColor.mediumBorderRadius,
        border: Border.all(color: ThemeColor.subtleBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ThemeColor.primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: ThemeColor.primaryColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 20),
        ],
      ),
    );
  }
}

class _ActiveRewardCard extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String description;
  final String actionLabel;
  final bool isActive;

  const _ActiveRewardCard({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: ThemeColor.mediumBorderRadius,
        border: Border.all(color: ThemeColor.subtleBorder),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: accentColor, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            description,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.transparent
                            : ThemeColor.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                        border: isActive
                            ? Border.all(color: const Color(0xFF4CAF50))
                            : null,
                      ),
                      child: Text(
                        actionLabel,
                        style: TextStyle(
                          color: isActive ? const Color(0xFF4CAF50) : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}