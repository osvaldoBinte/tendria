// lib/features/user/presentation/widgets/interests_section_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/services/translation_service.dart';
import 'package:tendria/common/settings/language_controller.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/user/presentation/controller/profile_controller.dart';
import 'package:tendria/features/user/presentation/controller/update_profile_controller.dart';

class InterestsSectionWidget extends StatefulWidget {
  final bool isEditable;

  const InterestsSectionWidget({
    Key? key,
    this.isEditable = false,
  }) : super(key: key);

  @override
  State<InterestsSectionWidget> createState() =>
      _InterestsSectionWidgetState();
}

class _InterestsSectionWidgetState extends State<InterestsSectionWidget> {
  ProfileController get _profile => Get.find<ProfileController>();
  UpdateProfileController get _update =>
      Get.find<UpdateProfileController>();
  LanguageController get _l => Get.find<LanguageController>();
  TranslationService get _translator => Get.find<TranslationService>();

  // Cache local: nombre original → traducción actual
  final RxMap<String, String> _translated = <String, String>{}.obs;
  String _lastLang = '';

  @override
  void initState() {
    super.initState();
    ever(_profile.userEntity, (_) => _translateInterests());
    ever(_translator.isReady, (_) => _translateInterests());
  }

  Future<void> _translateInterests() async {
    final lang = _l.lang;
    final interests = _profile.interests;

    if (interests.isEmpty) return;

    if (lang == 'Español') {
      final map = {for (var i in interests) i.name: i.name};
      _translated.assignAll(map);
      _lastLang = lang;
      return;
    }

    if (_lastLang == lang &&
        interests.every((i) => _translated.containsKey(i.name))) {
      return;
    }

    final names = interests.map((i) => i.name).toList();
    final results = await _translator.translateList(names, lang);

    final map = <String, String>{};
    for (int i = 0; i < names.length; i++) {
      map[names[i]] = results[i];
    }

    _translated.assignAll(map);
    _lastLang = lang;
  }

  String _getLabel(String originalName) {
    return _translated[originalName] ?? originalName;
  }

  /// El icono siempre usa el nombre en español (clave del mapa)
  IconData _getInterestIcon(String originalName) {
    const icons = {
      'Pintura': Icons.brush,
      'Fotografía': Icons.camera_alt,
      'Arte': Icons.palette,
      'Cine': Icons.movie,
      'Videojuegos': Icons.videogame_asset,
      'Anime': Icons.auto_awesome,
      'Música en vivo': Icons.mic,
      'Rock': Icons.music_note,
      'Reggaetón': Icons.headphones,
      'Conciertos': Icons.music_note,
      'Festivales': Icons.festival,
      'Bailar': Icons.music_note,
      'Gimnasio': Icons.fitness_center,
      'Correr': Icons.directions_run,
      'Yoga': Icons.self_improvement,
      'Meditación': Icons.spa,
      'Deportes': Icons.sports_soccer,
      'Senderismo': Icons.terrain,
      'Viajar': Icons.flight_takeoff,
      'Playa': Icons.beach_access,
      'Café': Icons.coffee,
      'Vino': Icons.wine_bar,
      'Cocinar': Icons.restaurant_menu,
      'Foodie': Icons.restaurant,
      'Lectura': Icons.menu_book,
      'Libros': Icons.book,
      'Psicología': Icons.psychology,
      'Programación': Icons.code,
      'Emprendimiento': Icons.rocket_launch,
      'Startups': Icons.trending_up,
      'Criptomonedas': Icons.currency_bitcoin,
      'Autos deportivos': Icons.directions_car,
      'Nómada digital': Icons.laptop_mac,
      'Perros': Icons.pets,
      'Gatos': Icons.pets,
      'Relación seria': Icons.favorite,
      'Algo casual': Icons.sentiment_satisfied_alt,
      'Escribir': Icons.edit,
      'Museos y galerías': Icons.museum,
    };

    return icons[originalName] ?? Icons.favorite;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final interests = _profile.interests;

      // Disparar traducción si cambió el idioma
      final currentLang = _l.lang;
      if (currentLang != _lastLang) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _translateInterests());
      }

      return GestureDetector(
        onTap: widget.isEditable
            ? () => _update.showEditInterests(
                  interests.map((i) => i.id).toList(),
                )
            : null,
        child: Container(
          margin: EdgeInsets.symmetric(
              horizontal: ThemeColor.paddingLarge),
          padding: EdgeInsets.all(ThemeColor.paddingLarge),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: ThemeColor.largeBorderRadius,
            boxShadow: [ThemeColor.cardShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      _l.t('interests_title'),
                      style: ThemeColor.subtitleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ThemeColor.textDarkColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: ThemeColor.textSecondaryColor,
                  ),
                ],
              ),

              SizedBox(height: ThemeColor.paddingSmall),

              Text(
                _l.t('interests_subtitle'),
                style: ThemeColor.bodySmall.copyWith(
                  color: ThemeColor.textSecondaryColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),

              SizedBox(height: ThemeColor.paddingMedium),

              interests.isEmpty
                  ? _buildEmptyState()
                  : Obx(() => Wrap(
                        spacing: ThemeColor.paddingSmall,
                        runSpacing: ThemeColor.paddingSmall,
                        children: interests.take(4).map((interest) {
                          return _InterestChip(
                            // label traducido, icon por nombre original
                            label: _getLabel(interest.name),
                            icon: _getInterestIcon(interest.name),
                            onDelete: widget.isEditable
                                ? () => _update
                                    .removeInterest(interest.id)
                                : null,
                          );
                        }).toList(),
                      )),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Row(
      children: [
        Icon(
          Icons.add_circle_outline,
          size: 18,
          color: ThemeColor.textSecondaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          _l.t('interests_add'),
          style: ThemeColor.bodySmall.copyWith(
            color: ThemeColor.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}

class _InterestChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onDelete;

  const _InterestChip({
    Key? key,
    required this.label,
    required this.icon,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ThemeColor.paddingMedium,
        vertical: ThemeColor.paddingSmall + 2,
      ),
      decoration: BoxDecoration(
        color: ThemeColor.backgroundColorfondo,
        borderRadius: ThemeColor.circularBorderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: ThemeColor.textDarkColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textDarkColor,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onDelete,
              child: Icon(
                Icons.close,
                size: 16,
                color: ThemeColor.textSecondaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}