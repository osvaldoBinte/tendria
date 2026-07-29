import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/controller/theme_controller.dart';
import 'package:tendria/common/theme/App_Theme.dart';

class EliteAchievements extends StatefulWidget {
  const EliteAchievements({Key? key}) : super(key: key);

  @override
  State<EliteAchievements> createState() => _EliteAchievementsScreenState();
}

class _EliteAchievementsScreenState extends State<EliteAchievements> {
  int _currentNavIndex = 4;

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
          decoration: BoxDecoration(
            gradient: ThemeColor.vipBackgroundGradient2,
          ),
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      const SizedBox(height: 16),
                      _buildStatusCard(),
                      const SizedBox(height: 26),
                      _buildSectionHeader(
                        'Fidelidad',
                        Icons.emoji_events_outlined,
                      ),
                      const SizedBox(height: 14),
                      _buildBadgeGrid([
                        _BadgeData(
                          icon: Icons.calendar_today_rounded,
                          label: '3 Meses VIP',
                          unlocked: true,
                        ),
                        _BadgeData(
                          icon: Icons.star_rounded,
                          label: 'Fundador',
                          unlocked: true,
                        ),
                        _BadgeData(
                          icon: Icons.event_available_rounded,
                          label: '1 Año VIP',
                          unlocked: false,
                        ),
                        _BadgeData(
                          icon: Icons.local_offer_rounded,
                          label: 'Embajador',
                          unlocked: false,
                        ),
                      ]),
                      const SizedBox(height: 26),
                      _buildSectionHeader(
                        'Generosidad',
                        Icons.card_giftcard_rounded,
                      ),
                      const SizedBox(height: 14),
                      _buildBadgeGrid([
                        _BadgeData(
                          icon: Icons.redeem_rounded,
                          label: 'Primer Regalo',
                          unlocked: true,
                        ),
                        _BadgeData(
                          icon: Icons.wine_bar_rounded,
                          label: 'Socio Champagne',
                          unlocked: true,
                        ),
                        _BadgeData(
                          icon: Icons.volunteer_activism_rounded,
                          label: 'Filántropo',
                          unlocked: false,
                        ),
                        _BadgeData(
                          icon: Icons.diamond_rounded,
                          label: 'Mecenas Real',
                          unlocked: false,
                        ),
                      ]),
                      const SizedBox(height: 26),
                      _buildSectionHeader(
                        'Exclusividad',
                        Icons.lock_outline_rounded,
                      ),
                      const SizedBox(height: 14),
                      _buildBadgeGrid([
                        _BadgeData(
                          icon: Icons.remove_red_eye_rounded,
                          label: 'Primer Vistazo',
                          unlocked: true,
                        ),
                        _BadgeData(
                          icon: Icons.vpn_key_rounded,
                          label: 'Coleccionista',
                          unlocked: false,
                        ),
                        _BadgeData(
                          icon: Icons.auto_awesome_rounded,
                          label: 'Invitado Élite',
                          unlocked: false,
                        ),
                      ]),
                      const SizedBox(height: 28),
                      _buildSectionHeader(
                        'Desafíos en Marcha',
                        Icons.emoji_events_rounded,
                      ),
                      const SizedBox(height: 14),
                      _ChallengeCard(
                        icon: Icons.card_giftcard_rounded,
                        title: 'Mecenas de Champagne',
                        subtitle: 'Envía 5 regalos de Champagne',
                        current: 3,
                        total: 5,
                        reward: "Insignia 'Burbujas de Oro' + 500 Puntos",
                      ),
                      const SizedBox(height: 16),
                      _ChallengeCard(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Charlatán VIP',
                        subtitle: 'Envía 100 mensajes en chat privado',
                        current: 82,
                        total: 100,
                        reward: "Insignia 'Conexión Íntima' + Acceso Especial",
                      ),
                      const SizedBox(height: 16),
                      _ChallengeCard(
                        icon: Icons.military_tech_rounded,
                        title: 'Mecenas VIP',
                        subtitle: 'Completa 10 desafíos de generosidad',
                        current: 9,
                        total: 10,
                        reward: null,
                        note: '¡Estás a un paso de la gloria VIP!',
                      ),
                      const SizedBox(height: 28),
                      _buildFooterNote(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
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
        MediaQuery.of(context).padding.top + 12,
        16,
        12,
      ),
      color: Colors.transparent,
      child: Row(
        children: [
          Icon(Icons.menu_rounded, color: ThemeColor.iconColor),
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
            child: Icon(Icons.person, color: ThemeColor.iconColor, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColor.cardBackground.withOpacity(0.6),
        borderRadius: ThemeColor.largeBorderRadius,
        border: Border.all(color: ThemeColor.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ESTATUS ACTUAL',
            style: ThemeColor.caption.copyWith(
              color: ThemeColor.textSecondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tus Logros de Élite',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              color: ThemeColor.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nivel: Coleccionista de Oro',
                style: ThemeColor.bodyMedium.copyWith(
                  color: ThemeColor.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso de Nivel',
                style: ThemeColor.bodySmall.copyWith(
                  color: ThemeColor.textSecondary,
                ),
              ),
              Text(
                '75%',
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
              value: 0.75,
              minHeight: 7,
              backgroundColor: ThemeColor.toggleBackground,
              valueColor: AlwaysStoppedAnimation(ThemeColor.primaryColor),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Siguiente Insignia: Mecenas VIP',
              style: ThemeColor.caption.copyWith(
                color: ThemeColor.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.black,
                size: 18,
              ),
              label: Text(
                'Ver recompensas de nivel',
                style: ThemeColor.buttonText.copyWith(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColor.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: ThemeColor.mediumBorderRadius,
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(
                Icons.share_rounded,
                color: ThemeColor.textPrimary,
                size: 16,
              ),
              label: Text(
                'Compartir Perfil',
                style: TextStyle(color: ThemeColor.textPrimary, fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: ThemeColor.subtleBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: ThemeColor.mediumBorderRadius,
                ),
              ),
            ),
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
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: ThemeColor.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeGrid(List<_BadgeData> badges) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 12,
      childAspectRatio: 0.85,
      children: badges.map((b) => _AchievementBadge(data: b)).toList(),
    );
  }

  Widget _buildFooterNote() {
    return Column(
      children: [
        Icon(
          Icons.auto_awesome_rounded,
          color: ThemeColor.primaryColor.withOpacity(0.7),
          size: 22,
        ),
        const SizedBox(height: 10),
        Text(
          'Nuevos logros exclusivos se desbloquean con cada evento especial.',
          textAlign: TextAlign.center,
          style: ThemeColor.bodySmall.copyWith(
            color: ThemeColor.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _BadgeData {
  final IconData icon;
  final String label;
  final bool unlocked;

  _BadgeData({required this.icon, required this.label, required this.unlocked});
}

class _AchievementBadge extends StatelessWidget {
  final _BadgeData data;
  const _AchievementBadge({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: data.unlocked
                ? ThemeColor.primaryColor.withOpacity(0.15)
                : ThemeColor.subtleBackground,
            border: Border.all(
              color: data.unlocked
                  ? ThemeColor.primaryColor.withOpacity(0.6)
                  : ThemeColor.subtleBorder,
              width: 1.4,
            ),
          ),
          child: Icon(
            data.icon,
            color: data.unlocked
                ? ThemeColor.primaryColor
                : ThemeColor.textSecondary.withOpacity(0.4),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          data.label,
          textAlign: TextAlign.center,
          style: ThemeColor.caption.copyWith(
            color: data.unlocked
                ? ThemeColor.textPrimary
                : ThemeColor.textSecondary.withOpacity(0.5),
            fontSize: 10,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int current;
  final int total;
  final String? reward;
  final String? note;

  const _ChallengeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.current,
    required this.total,
    this.reward,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / total).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColor.cardBackground.withOpacity(0.6),
        borderRadius: ThemeColor.mediumBorderRadius,
        border: Border.all(color: ThemeColor.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ThemeColor.primaryColor.withOpacity(0.12),
                ),
                child: Icon(icon, color: ThemeColor.primaryColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: ThemeColor.bodyMedium.copyWith(
                        color: ThemeColor.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: ThemeColor.caption.copyWith(
                        color: ThemeColor.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
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
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: ThemeColor.toggleBackground,
              valueColor: AlwaysStoppedAnimation(ThemeColor.primaryColor),
            ),
          ),
          const SizedBox(height: 10),
          if (reward != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.card_giftcard_rounded,
                  size: 13,
                  color: ThemeColor.primaryColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Premio: $reward',
                    style: ThemeColor.caption.copyWith(
                      color: ThemeColor.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          if (note != null)
            Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 13,
                  color: ThemeColor.primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  note!,
                  style: ThemeColor.caption.copyWith(
                    color: ThemeColor.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
