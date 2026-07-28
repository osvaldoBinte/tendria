import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/controller/theme_controller.dart';
import 'package:tendria/common/theme/App_Theme.dart';

class creatorProfilePremium extends StatefulWidget {
  const creatorProfilePremium({Key? key}) : super(key: key);

  @override
  State<creatorProfilePremium> createState() => _creatorProfilePremiumScreenState();
}

class _creatorProfilePremiumScreenState extends State<creatorProfilePremium> {
  int _currentNavIndex = 4; 
  bool _isGridView = true;

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
          decoration: BoxDecoration(gradient: ThemeColor.vipBackgroundGradient),
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      const SizedBox(height: 20),
                      _buildAvatarAndName(),
                      const SizedBox(height: 20),
                      _buildSubscribeRow(),
                      const SizedBox(height: 18),
                      _buildStatsGrid(),
                      const SizedBox(height: 18),
                      _buildCountersRow(),
                      const SizedBox(height: 26),
                      _buildExclusiveContentHeader(),
                      const SizedBox(height: 14),
                      _buildContentGrid(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: ThemeColor.createBottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: (i) => setState(() => _currentNavIndex = i),
          iconPaths: const [
            'assets/icons/home.png',
            'assets/icons/explore.png',
            'assets/icons/publish.png',
            'assets/icons/balance.png',
            'assets/icons/profile.png',
          ],
          labels: const ['Inicio', 'Explorar', 'Publicar', 'Balance', 'Perfil'],
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

  Widget _buildAvatarAndName() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 110,
              height: 110,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [ThemeColor.primaryColor, ThemeColor.secondaryColor],
                ),
              ),
              child: ClipOval(
                child: Container(
                  color: ThemeColor.subtleBackground,
                  child: Icon(Icons.person, color: ThemeColor.iconColor, size: 48),
                ),
              ),
            ),
            Positioned(
              right: 6,
              bottom: 6,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                  border: Border.all(color: ThemeColor.backgroundColor, width: 3),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tatendría VIP',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                color: ThemeColor.primaryColor,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.verified_rounded, color: ThemeColor.primaryColor, size: 18),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '@TATENDRIA_ELITE',
          style: ThemeColor.caption.copyWith(
            color: ThemeColor.textSecondary,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSubscribeRow() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: ThemeColor.primaryColor,
                borderRadius: ThemeColor.circularBorderRadius,
              ),
              child: Center(
                child: Text(
                  'Suscribirse \$24.99/mes',
                  style: ThemeColor.buttonText.copyWith(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: ThemeColor.cardBackground.withOpacity(0.6),
            borderRadius: ThemeColor.mediumBorderRadius,
            border: Border.all(color: ThemeColor.subtleBorder),
          ),
          child: Icon(Icons.mail_outline_rounded,
              color: ThemeColor.primaryColor, size: 20),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      {'icon': Icons.military_tech_rounded, 'label': 'NIVEL', 'value': '4 · Black'},
      {'icon': Icons.show_chart_rounded, 'label': 'RANKING', 'value': 'Top 1%'},
      {'icon': Icons.bolt_rounded, 'label': 'RESPUESTA', 'value': 'Rápido'},
      {'icon': Icons.star_rounded, 'label': 'INSIGNIA', 'value': 'Elite'},
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.3,
      children: stats.map((s) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ThemeColor.cardBackground.withOpacity(0.6),
            borderRadius: ThemeColor.mediumBorderRadius,
            border: Border.all(color: ThemeColor.subtleBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ThemeColor.primaryColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(s['icon'] as IconData,
                    color: ThemeColor.primaryColor, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s['label'] as String,
                      style: ThemeColor.caption.copyWith(
                        color: ThemeColor.textSecondary,
                        fontSize: 9,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      s['value'] as String,
                      style: ThemeColor.bodyMedium.copyWith(
                        color: ThemeColor.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCountersRow() {
    final counters = [
      {'value': '42.5k', 'label': 'Seguidores'},
      {'value': '128', 'label': 'Publicaciones'},
      {'value': '\$1,240', 'label': 'Tu Gasto'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: counters.map((c) {
        return Column(
          children: [
            Text(
              c['value']!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: ThemeColor.primaryColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              c['label']!,
              style: ThemeColor.caption.copyWith(color: ThemeColor.textSecondary),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildExclusiveContentHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Contenido Exclusivo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            color: ThemeColor.textPrimary,
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _isGridView = true),
              child: Icon(
                Icons.grid_view_rounded,
                size: 20,
                color: _isGridView
                    ? ThemeColor.primaryColor
                    : ThemeColor.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => setState(() => _isGridView = false),
              child: Icon(
                Icons.view_agenda_outlined,
                size: 20,
                color: !_isGridView
                    ? ThemeColor.primaryColor
                    : ThemeColor.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContentGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.8,
      children: [
        _LockedContentCard(
          tag: 'TENDENCIA',
          tagColor: const Color(0xFFE85D8A),
          title: 'Desbloquear para\nver',
          footerIcon: Icons.remove_red_eye_outlined,
          footerText: '1,245',
        ),
        _VideoContentCard(
          tag: 'MÁS VENDIDO',
          tagColor: const Color(0xFFD4AF37),
          title: 'Video VIP',
          footerIcon: Icons.vpn_key_rounded,
          footerText: '843 Unlocks',
        ),
        _DescriptiveContentCard(
          title: 'de Oro',
          description:
              "Acceso exclusivo a la sesión fotográfica 'Midnight Bloom'",
          buttonText: 'Acceder',
        ),
        _LockedContentCard(
          tag: null,
          tagColor: Colors.transparent,
          title: 'Contenido bloqueado',
          footerIcon: null,
          footerText: null,
        ),
        _UnlockedContentCard(
          title: 'Sesión Terraza',
        ),
      ],
    );
  }
}

class _LockedContentCard extends StatelessWidget {
  final String? tag;
  final Color tagColor;
  final String title;
  final IconData? footerIcon;
  final String? footerText;

  const _LockedContentCard({
    required this.tag,
    required this.tagColor,
    required this.title,
    required this.footerIcon,
    required this.footerText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColor.cardBackground.withOpacity(0.7),
        borderRadius: ThemeColor.mediumBorderRadius,
        border: Border.all(color: ThemeColor.subtleBorder),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (tag != null)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tag!,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ThemeColor.primaryColor.withOpacity(0.15),
                  ),
                  child: Icon(Icons.lock_rounded,
                      color: ThemeColor.primaryColor, size: 20),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: ThemeColor.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (footerText != null)
            Positioned(
              bottom: 10,
              left: 10,
              child: Row(
                children: [
                  Icon(footerIcon, size: 12, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    footerText!,
                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _VideoContentCard extends StatelessWidget {
  final String tag;
  final Color tagColor;
  final String title;
  final IconData footerIcon;
  final String footerText;

  const _VideoContentCard({
    required this.tag,
    required this.tagColor,
    required this.title,
    required this.footerIcon,
    required this.footerText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: ThemeColor.mediumBorderRadius,
        border: Border.all(color: ThemeColor.subtleBorder),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: tagColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                tag,
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ThemeColor.primaryColor,
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.black, size: 26),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: ThemeColor.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: Row(
              children: [
                Icon(footerIcon, size: 12, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  footerText,
                  style: const TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptiveContentCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;

  const _DescriptiveContentCard({
    required this.title,
    required this.description,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ThemeColor.cardBackground.withOpacity(0.7),
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
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  color: ThemeColor.textPrimary,
                ),
              ),
              Icon(Icons.favorite_border_rounded,
                  size: 16, color: ThemeColor.textSecondary),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              description,
              style: ThemeColor.caption.copyWith(
                color: ThemeColor.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColor.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnlockedContentCard extends StatelessWidget {
  final String title;
  const _UnlockedContentCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColor.subtleBackground,
        borderRadius: ThemeColor.mediumBorderRadius,
        border: Border.all(color: ThemeColor.subtleBorder),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: ThemeColor.mediumBorderRadius,
            child: Icon(Icons.image_rounded,
                color: ThemeColor.iconColor.withOpacity(0.2), size: 36),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'DESBLOQUEADO',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}