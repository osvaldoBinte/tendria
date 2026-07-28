import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/controller/theme_controller.dart';
import 'package:tendria/common/theme/App_Theme.dart';

class EarningsPanelVip extends StatefulWidget {
  const EarningsPanelVip({Key? key}) : super(key: key);

  @override
  State<EarningsPanelVip> createState() => _earningsPanelVipScreenState();
}

class _earningsPanelVipScreenState extends State<EarningsPanelVip> {
  int _currentNavIndex = 2;

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
          color: ThemeColor.backgroundColorfondo,
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
                      _buildGreeting(),
                      const SizedBox(height: 24),
                      _buildEarningsTodayCard(),
                      const SizedBox(height: 20),
                      _buildVipLevelCard(),
                      const SizedBox(height: 20),
                      _buildNewFollowersCard(),
                      const SizedBox(height: 20),
                      _buildAchievementsCard(),
                      const SizedBox(height: 20),
                      _buildBoostEarningsCard(),
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

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¡Increíble progreso, Tatendría!',
          style: ThemeColor.headingSmall.copyWith(
            color: ThemeColor.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Estás a solo \$260 de alcanzar tu meta mensual de \$1,500.',
          style: ThemeColor.bodyMedium.copyWith(
            color: ThemeColor.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsTodayCard() {
    final values = [0.35, 0.45, 0.3, 0.6, 0.55, 0.7, 1.0];
    final labels = ['L', 'M', 'M', 'J', 'V', 'S', 'Hoy'];

    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GANANCIAS HOY',
                style: ThemeColor.caption.copyWith(
                  color: ThemeColor.textSecondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ThemeColor.subtleBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  size: 16,
                  color: ThemeColor.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$142.50',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: ThemeColor.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      size: 14,
                      color: ThemeColor.live,
                    ),
                    const SizedBox(width: 2),
                    const Text(
                      '+12%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: ThemeColor.live,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(values.length, (i) {
                final isToday = i == values.length - 1;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FractionallySizedBox(
                      heightFactor: values[i],
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isToday
                              ? ThemeColor.primaryColor
                              : ThemeColor.subtleBackground,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Lunes',
                style: ThemeColor.caption.copyWith(
                  color: ThemeColor.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                'Hoy',
                style: ThemeColor.caption.copyWith(
                  color: ThemeColor.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVipLevelCard() {
    return _CardContainer(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tu Nivel VIP',
                style: ThemeColor.subtitleLarge.copyWith(
                  color: ThemeColor.textPrimary,
                ),
              ),
              Icon(
                Icons.military_tech_rounded,
                color: ThemeColor.primaryColor,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 130,
            height: 130,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 130,
                  height: 130,
                  child: CircularProgressIndicator(
                    value: 0.7,
                    strokeWidth: 6,
                    backgroundColor: ThemeColor.subtleBackground,
                    valueColor: AlwaysStoppedAnimation(ThemeColor.primaryColor),
                  ),
                ),
                Text(
                  '70%',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: ThemeColor.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nivel Oro',
            style: ThemeColor.subtitleLarge.copyWith(
              color: ThemeColor.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Próximo: Diamante',
            style: ThemeColor.bodySmall.copyWith(
              color: ThemeColor.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColor.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: ThemeColor.mediumBorderRadius,
                ),
                elevation: 0,
              ),
              child: Text(
                'Ver Ventajas VIP',
                style: ThemeColor.buttonText.copyWith(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewFollowersCard() {
    final followers = [
      {
        'name': 'Marco Aurelio',
        'subtitle': 'Suscripción Premium',
        'amount': '+\$15',
      },
      {'name': 'Elena S.', 'subtitle': 'Propina recibida', 'amount': '+\$50'},
      {'name': 'Carlos G.', 'subtitle': 'Nuevo Fan', 'amount': null},
    ];

    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nuevos Seguidores',
                style: ThemeColor.subtitleLarge.copyWith(
                  color: ThemeColor.textPrimary,
                ),
              ),
              Text(
                '+24 hoy',
                style: ThemeColor.bodySmall.copyWith(
                  color: ThemeColor.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...followers.map((f) {
            final amount = f['amount'] as String?;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: ThemeColor.subtleBackground,
                    child: Icon(
                      Icons.person,
                      color: ThemeColor.iconColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f['name'] as String,
                          style: ThemeColor.bodyMedium.copyWith(
                            color: ThemeColor.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          f['subtitle'] as String,
                          style: ThemeColor.caption.copyWith(
                            color: ThemeColor.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  amount != null
                      ? Text(
                          amount,
                          style: TextStyle(
                            color: ThemeColor.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        )
                      : Icon(
                          Icons.trending_up_rounded,
                          color: ThemeColor.textSecondary,
                          size: 18,
                        ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAchievementsCard() {
    final achievements = [
      {
        'label': 'Top 1%',
        'icon': 'assets/icons/star_rounded.png',
        'unlocked': true,
      },
      {
        'label': 'Racha 30',
        'icon': 'assets/icons/calendar_month_rounded.png',
        'unlocked': true,
      },
      {
        'label': 'Récord \$',
        'icon': 'assets/icons/diamond_rounded.png',
        'unlocked': true,
      },
      {
        'label': 'Siguiente',
        'icon': 'assets/icons/lock_rounded.png',
        'unlocked': false,
      },
    ];

    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tus Logros',
                style: ThemeColor.subtitleLarge.copyWith(
                  color: ThemeColor.textPrimary,
                ),
              ),
              Icon(
                Icons.emoji_events_rounded,
                color: ThemeColor.primaryColor,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: achievements.map((a) {
              final unlocked = a['unlocked'] as bool;
              return Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: unlocked
                          ? ThemeColor.primaryColor.withOpacity(0.12)
                          : ThemeColor.subtleBackground,
                      border: Border.all(
                        color: unlocked
                            ? ThemeColor.primaryColor.withOpacity(0.5)
                            : ThemeColor.subtleBorder,
                      ),
                    ),
                    child: Image.asset(
                      a['icon'] as String,
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    a['label'] as String,
                    style: ThemeColor.caption.copyWith(
                      color: unlocked
                          ? ThemeColor.textSecondary
                          : ThemeColor.textSecondary.withOpacity(0.4),
                      fontSize: 10,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ThemeColor.subtleBackground,
              borderRadius: ThemeColor.mediumBorderRadius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RANKING GLOBAL',
                      style: ThemeColor.caption.copyWith(
                        color: ThemeColor.primaryColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '#142',
                      style: TextStyle(
                        color: ThemeColor.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.65,
                    minHeight: 6,
                    backgroundColor: ThemeColor.toggleBackground,
                    valueColor: AlwaysStoppedAnimation(ThemeColor.primaryColor),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '"Tu contenido está entre el 5% más visto este mes."',
                  style: ThemeColor.caption.copyWith(
                    color: ThemeColor.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoostEarningsCard() {
    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Impulsa tus\nganancias',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: ThemeColor.primaryColor,
                    height: 1.3,
                  ),
                ),
              ),
              Icon(
                Icons.auto_awesome_rounded,
                color: ThemeColor.primaryColor.withOpacity(0.6),
                size: 26,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Tatendría, los datos muestran que tus seguidores aman el '
            'contenido tipo "Behind the Scenes". Publicar uno ahora podría '
            'aumentar tus ingresos de hoy en un 15%.',
            style: ThemeColor.bodyMedium.copyWith(
              color: ThemeColor.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                color: Colors.black,
                size: 18,
              ),
              label: Text(
                'Publicar Contenido VIP',
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
        ],
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;
  const _CardContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ThemeColor.cardBackground.withOpacity(0.6),
        borderRadius: ThemeColor.largeBorderRadius,
        border: Border.all(color: ThemeColor.subtleBorder),
      ),
      child: child,
    );
  }
}
