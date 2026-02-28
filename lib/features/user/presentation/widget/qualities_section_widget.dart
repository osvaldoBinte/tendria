// lib/features/user/presentation/widgets/qualities_section_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/services/translation_service.dart';
import 'package:tendria/common/settings/language_controller.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/user/presentation/controller/profile_controller.dart';
import 'package:tendria/features/user/presentation/controller/update_profile_controller.dart';

class QualitiesSectionWidget extends StatefulWidget {
  final bool isEditable;

  const QualitiesSectionWidget({
    Key? key,
    this.isEditable = false,
  }) : super(key: key);

  @override
  State<QualitiesSectionWidget> createState() =>
      _QualitiesSectionWidgetState();
}

class _QualitiesSectionWidgetState extends State<QualitiesSectionWidget> {
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
    // Traducir cuando cambie el idioma o las cualidades
    ever(_profile.userEntity, (_) => _translateQualities());
    ever(_translator.isReady, (_) => _translateQualities());
  }

  Future<void> _translateQualities() async {
    final lang = _l.lang;
    final qualities = _profile.qualities;

    if (qualities.isEmpty) return;

    // Si el idioma es español, usar nombres originales directamente
    if (lang == 'Español') {
      final map = {for (var q in qualities) q.name: q.name};
      _translated.assignAll(map);
      _lastLang = lang;
      return;
    }

    // Si ya tradujimos para este idioma, no repetir
    if (_lastLang == lang &&
        qualities.every((q) => _translated.containsKey(q.name))) {
      return;
    }

    // Traducir todos los nombres
    final names = qualities.map((q) => q.name).toList();
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final qualities = _profile.qualities;

      // Disparar traducción cuando cambie el idioma
      final currentLang = _l.lang;
      if (currentLang != _lastLang) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _translateQualities());
      }

      return GestureDetector(
        onTap: widget.isEditable
            ? () => _update.showEditQualities(
                  qualities.map((q) => q.id).toList(),
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
                      _l.t('qualities_title'),
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
                _l.t('qualities_subtitle'),
                style: ThemeColor.bodySmall.copyWith(
                  color: ThemeColor.textSecondaryColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),

              SizedBox(height: ThemeColor.paddingMedium),

              qualities.isEmpty
                  ? _buildEmptyState()
                  : Obx(() => Wrap(
                        spacing: ThemeColor.paddingSmall,
                        runSpacing: ThemeColor.paddingSmall,
                        children: qualities.take(3).map((quality) {
                          return _QualityChip(
                            label: _getLabel(quality.name),
                            onDelete: widget.isEditable
                                ? () =>
                                    _update.removeQuality(quality.id)
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
          _l.t('qualities_add'),
          style: ThemeColor.bodySmall.copyWith(
            color: ThemeColor.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}

class _QualityChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDelete;

  const _QualityChip({Key? key, required this.label, this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ThemeColor.paddingLarge,
        vertical: ThemeColor.paddingSmall + 2,
      ),
      decoration: BoxDecoration(
        color: ThemeColor.backgroundColorfondo,
        borderRadius: ThemeColor.circularBorderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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