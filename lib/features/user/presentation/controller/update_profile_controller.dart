import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/errors/convert_message.dart';
import 'package:tendria/common/services/auth_service.dart';
import 'package:tendria/common/services/translation_service.dart';
import 'package:tendria/common/settings/language_controller.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/common/widgets/alert/custom_alert_type.dart';
import 'package:tendria/common/widgets/alert/snackbar_helper.dart';
import 'package:tendria/features/catalog/domain/entities/catalog_entity.dart';
import 'package:tendria/features/catalog/domain/usecase/delete_interests_usecase.dart';
import 'package:tendria/features/catalog/domain/usecase/delete_qualities_usecase.dart';
import 'package:tendria/features/catalog/domain/usecase/fetch_interests_usecase.dart';
import 'package:tendria/features/catalog/domain/usecase/fetch_qualities_usecase.dart';
import 'package:tendria/features/catalog/domain/usecase/post_interests_usecase.dart';
import 'package:tendria/features/catalog/domain/usecase/post_qualities_usecase.dart';
import 'package:tendria/features/user/domain/entities/preferences_entity.dart';
import 'package:tendria/features/user/domain/entities/update_user_entity.dart';
import 'package:tendria/features/user/domain/usecase/delete_user_usecase.dart';
import 'package:tendria/features/user/domain/usecase/put_preferences_user_usecase.dart';
import 'package:tendria/features/user/domain/usecase/update_user_usecase.dart';
import 'package:tendria/features/user/presentation/controller/nearby_users_controller.dart';
import 'package:tendria/features/user/presentation/controller/profile_controller.dart';

class UpdateProfileController extends GetxController {
  final DeleteInterestsUsecase deleteInterestsUsecase;
  final DeleteQualitiesUsecase deleteQualitiesUsecase;
  final UpdateUserUsecase updateUserUsecase;
  final FetchInterestsUsecase fetchInterestsUsecase;
  final FetchQualitiesUsecase fetchQualitiesUsecase;
  final PostInterestsUsecase postInterestsUsecase;
  final PostQualitiesUsecase postQualitiesUsecase;
  final PutPreferencesUserUsecase putPreferencesUserUsecase;
  final DeleteUserUsecase deleteUserUsecase;

  UpdateProfileController({
    required this.deleteInterestsUsecase,
    required this.deleteQualitiesUsecase,
    required this.updateUserUsecase,
    required this.fetchInterestsUsecase,
    required this.fetchQualitiesUsecase,
    required this.postInterestsUsecase,
    required this.putPreferencesUserUsecase,
    required this.postQualitiesUsecase,
    required this.deleteUserUsecase,
  });

        final nearbyController = Get.find<NearbyUsersController>();
  // Estados
  final RxBool isUpdating = false.obs;
  final RxBool isDeletingInterest = false.obs;
  final RxBool isDeletingQuality = false.obs;
  final RxBool isLoadingInterests = false.obs;
  final RxBool isLoadingQualities = false.obs;
  final RxBool isSavingInterests = false.obs;
  final RxBool isSavingQualities = false.obs;

  // Catálogos
  final RxList<CatalogEntity> allInterests = <CatalogEntity>[].obs;
  final RxList<CatalogEntity> allQualities = <CatalogEntity>[].obs;

  // Traducciones del catálogo
  final RxMap<String, String> translatedInterests = <String, String>{}.obs;
  final RxMap<String, String> translatedQualities = <String, String>{}.obs;

  // Selección temporal
  final RxList<int> tempSelectedInterests = <int>[].obs;
  final RxList<int> tempSelectedQualities = <int>[].obs;

  final int maxInterests = 5;
  final int maxQualities = 3;

  ProfileController get _profile => Get.find<ProfileController>();
  TranslationService get _translator => Get.find<TranslationService>();
  LanguageController get _l => Get.find<LanguageController>();

  // ==========================================
  // HELPERS DE TRADUCCIÓN (datos dinámicos)
  // ==========================================

  Future<void> _translateInterestsCatalog() async {
    if (allInterests.isEmpty) return;
    final lang = _l.lang;
    if (lang == 'Español') {
      translatedInterests.assignAll(
          {for (var i in allInterests) i.name: i.name});
      return;
    }
    final names = allInterests.map((i) => i.name).toList();
    final results = await _translator.translateList(names, lang);
    final map = <String, String>{};
    for (int i = 0; i < names.length; i++) {
      map[names[i]] = results[i];
    }
    translatedInterests.assignAll(map);
  }

  Future<void> _translateQualitiesCatalog() async {
    if (allQualities.isEmpty) return;
    final lang = _l.lang;
    if (lang == 'Español') {
      translatedQualities.assignAll(
          {for (var q in allQualities) q.name: q.name});
      return;
    }
    final names = allQualities.map((q) => q.name).toList();
    final results = await _translator.translateList(names, lang);
    final map = <String, String>{};
    for (int i = 0; i < names.length; i++) {
      map[names[i]] = results[i];
    }
    translatedQualities.assignAll(map);
  }

  String _getInterestLabel(String name) =>
      translatedInterests[name] ?? name;

  String _getQualityLabel(String name) =>
      translatedQualities[name] ?? name;

  // ==========================================
  // ALTURA
  // ==========================================

  void showEditHeight(String currentValue) {
    final int initialHeight = int.tryParse(currentValue) ?? 170;
    final initialIndex = (initialHeight - 154).clamp(0, 95);
    final heightScrollController =
        FixedExtentScrollController(initialItem: initialIndex);
    final RxInt selectedHeight = initialHeight.obs;

    if (Get.context != null) {
      showModalBottomSheet(
        context: Get.context!,
        isScrollControlled: true,
        backgroundColor: ThemeColor.backgroundColorfondo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          height: Get.height * 0.6,
          padding: EdgeInsets.all(ThemeColor.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHandle(),
              SizedBox(height: ThemeColor.paddingLarge),
              Text(
                _l.t('bs_height_title'),
                style: ThemeColor.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ThemeColor.textDarkColor,
                ),
              ),
              SizedBox(height: ThemeColor.paddingSmall),
              Text(
                _l.t('bs_height_subtitle'),
                style: ThemeColor.bodyMedium.copyWith(
                  color: ThemeColor.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ThemeColor.paddingLarge),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildWheelHighlight(
                        horizontal: ThemeColor.paddingExtraLarge * 2),
                    ListWheelScrollView.useDelegate(
                      controller: heightScrollController,
                      itemExtent: 60,
                      diameterRatio: 1.5,
                      perspective: 0.003,
                      physics: FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        selectedHeight.value = 100 + index;
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 96,
                        builder: (context, index) {
                          final height = 100 + index;
                          return Obx(() {
                            final isSelected =
                                height == selectedHeight.value;
                            return _buildWheelItem(
                              label: '$height cm',
                              isSelected: isSelected,
                            );
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: ThemeColor.paddingMedium),
              _buildSaveButton(onPressed: () {
                Get.back();
                updateHeight(selectedHeight.value.toString());
              }),
              SizedBox(height: ThemeColor.paddingMedium),
            ],
          ),
        ),
      );
    }
  }

  // ==========================================
  // GÉNERO
  // ==========================================

  void showEditGender(String currentValue) {
    final List<Map<String, dynamic>> genderOptions = [
      {'label': 'Hombres', 'value': 'Hombre', 'icon': Icons.male},
      {'label': 'Mujeres', 'value': 'Mujer', 'icon': Icons.female},
      {
        'label': 'Persona no binaria',
        'value': 'No_binario',
        'icon': Icons.transgender
      },
    ];

    final RxString selected = currentValue.obs;

    if (Get.context != null) {
      showModalBottomSheet(
        context: Get.context!,
        isScrollControlled: true,
        backgroundColor: ThemeColor.backgroundColorfondo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(ThemeColor.paddingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHandle(),
                SizedBox(height: ThemeColor.paddingExtraLarge),
                _buildBsTitle(_l.t('bs_gender_title')),
                SizedBox(height: ThemeColor.paddingSmall),
                _buildBsSubtitle(_l.t('bs_gender_subtitle')),
                SizedBox(height: ThemeColor.paddingExtraLarge),
                ...genderOptions.map((option) => Padding(
                      padding: EdgeInsets.only(
                          bottom: ThemeColor.paddingSmall),
                      child: Obx(() {
                        final isSelected =
                            selected.value == option['value'];
                        return _buildRadioOption(
                          label: option['label'],
                          icon: option['icon'] as IconData,
                          isSelected: isSelected,
                          onTap: () =>
                              selected.value = option['value'],
                        );
                      }),
                    )),
                SizedBox(height: ThemeColor.paddingLarge),
                _buildSaveButton(onPressed: () {
                  Get.back();
                  updateGender(selected.value);
                }),
                SizedBox(height: ThemeColor.paddingMedium),
              ],
            ),
          ),
        ),
      );
    }
  }

  // ==========================================
  // IDIOMA
  // ==========================================

  void showEditLanguage(String currentValue) {
    _showSelectionBottomSheet(
      title: _l.t('bs_language_title'),
      subtitle: _l.t('bs_language_subtitle'),
      currentValue: currentValue,
      options: [
        {'label': 'Español', 'value': 'Español'},
        {'label': 'Inglés', 'value': 'Inglés'},
      ],
      onSave: (value) => updateLanguage(value),
    );
  }

  void _showSelectionBottomSheet({
    required String title,
    required String subtitle,
    required String currentValue,
    required List<Map<String, String>> options,
    required void Function(String value) onSave,
  }) {
    final RxString selected = currentValue.obs;

    if (Get.context != null) {
      showModalBottomSheet(
        context: Get.context!,
        isScrollControlled: true,
        backgroundColor: ThemeColor.backgroundColorfondo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(ThemeColor.paddingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHandle(),
                SizedBox(height: ThemeColor.paddingExtraLarge),
                _buildBsTitle(title),
                SizedBox(height: ThemeColor.paddingSmall),
                _buildBsSubtitle(subtitle),
                SizedBox(height: ThemeColor.paddingExtraLarge),
                ...options.map((option) => Padding(
                      padding: EdgeInsets.only(
                          bottom: ThemeColor.paddingSmall),
                      child: Obx(() {
                        final isSelected =
                            selected.value == option['value'];
                        return GestureDetector(
                          onTap: () =>
                              selected.value = option['value']!,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? ThemeColor.primaryColor
                                    : ThemeColor.textSecondaryColor,
                              ),
                              color: isSelected
                                  ? ThemeColor.primaryColor
                                      .withOpacity(0.1)
                                  : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    option['label']!,
                                    style:
                                        ThemeColor.bodyMedium.copyWith(
                                      color: ThemeColor.textDarkColor,
                                    ),
                                  ),
                                ),
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: isSelected
                                      ? ThemeColor.primaryColor
                                      : ThemeColor.textSecondaryColor,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    )),
                SizedBox(height: ThemeColor.paddingLarge),
                _buildSaveButton(onPressed: () {
                  Get.back();
                  onSave(selected.value);
                }),
                SizedBox(height: ThemeColor.paddingMedium),
              ],
            ),
          ),
        ),
      );
    }
  }

  // ==========================================
  // INTERESES
  // ==========================================

  Future<void> showEditInterests(List<int> currentIds) async {
    if (allInterests.isEmpty) {
      isLoadingInterests.value = true;
      try {
        final result = await fetchInterestsUsecase.execute();
        allInterests.value = result;
        await _translateInterestsCatalog();
      } catch (e) {
        showErrorSnackbar(_l.t('bs_interests_load_error'));
        isLoadingInterests.value = false;
        return;
      }
      isLoadingInterests.value = false;
    } else {
      await _translateInterestsCatalog();
    }

    tempSelectedInterests.value = List<int>.from(currentIds);

    if (Get.context != null) {
      showModalBottomSheet(
        context: Get.context!,
        isScrollControlled: true,
        backgroundColor: ThemeColor.backgroundColorfondo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              Container(
                padding: EdgeInsets.all(ThemeColor.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHandle(),
                    SizedBox(height: ThemeColor.paddingExtraLarge),
                    _buildBsTitle(_l.t('bs_interests_title'),
                        fontSize: 28),
                    SizedBox(height: ThemeColor.paddingSmall),
                    _buildBsSubtitle(
                        _l.t('bs_interests_subtitle')),
                    SizedBox(height: ThemeColor.paddingMedium),
                    Obx(() => Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _l.t('bs_interests_counter'),
                              style: ThemeColor.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: ThemeColor.textDarkColor,
                              ),
                            ),
                            Text(
                              '${tempSelectedInterests.length}/$maxInterests ${_l.t('bs_interests_selected')}',
                              style: ThemeColor.bodyMedium.copyWith(
                                color: ThemeColor.textSecondaryColor,
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(
                      horizontal: ThemeColor.paddingLarge),
                  child: Obx(() => Wrap(
                        spacing: ThemeColor.paddingSmall,
                        runSpacing: ThemeColor.paddingSmall,
                        children: allInterests.map((interest) {
                          final isSelected = tempSelectedInterests
                              .contains(interest.id);
                          return _buildInterestChipSheet(
                            label: _getInterestLabel(interest.name),
                            icon: _getInterestIcon(interest.name),
                            isSelected: isSelected,
                            onTap: () =>
                                _toggleTempInterest(interest.id),
                          );
                        }).toList(),
                      )),
                ),
              ),
              Container(
                padding: EdgeInsets.all(ThemeColor.paddingLarge),
                child: Obx(() => _buildSaveButton(
                      isLoading: isSavingInterests.value,
                      onPressed: isSavingInterests.value
                          ? null
                          : () async => await _saveInterests(),
                    )),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _toggleTempInterest(int id) {
    if (tempSelectedInterests.contains(id)) {
      tempSelectedInterests.remove(id);
    } else {
      if (tempSelectedInterests.length >= maxInterests) {
        showErrorSnackbar(_l.t('bs_max_interests'));
        return;
      }
      tempSelectedInterests.add(id);
    }
  }

  Future<void> _saveInterests() async {
    try {
      isSavingInterests.value = true;
      final currentIds =
          _profile.interests.map((i) => i.id).toList();
      final newIds = tempSelectedInterests
          .where((id) => !currentIds.contains(id))
          .toList();
      final removedIds = currentIds
          .where((id) => !tempSelectedInterests.contains(id))
          .toList();

      if (newIds.isEmpty && removedIds.isEmpty) {
        showSuccessSnackbar(_l.t('snack_no_changes'));
        Get.back();
        return;
      }
      if (newIds.isNotEmpty) await postInterestsUsecase.execute(newIds);
      if (removedIds.isNotEmpty) {
        await deleteInterestsUsecase.execute(removedIds);
      }
      await _profile.loadUserProfile();
      Get.back();
      showSuccessSnackbar(_l.t('bs_interests_saved'));
    } catch (e) {
      Get.back();
      showErrorSnackbar(
          '${_l.t('snack_could_not_save_interests')}: ${cleanExceptionMessage(e)}');
    } finally {
      isSavingInterests.value = false;
    }
  }

  // ==========================================
  // CUALIDADES
  // ==========================================

  Future<void> showEditQualities(List<int> currentIds) async {
    if (allQualities.isEmpty) {
      isLoadingQualities.value = true;
      try {
        final result = await fetchQualitiesUsecase.execute();
        allQualities.value = result;
        await _translateQualitiesCatalog();
      } catch (e) {
        isLoadingQualities.value = false;
        return;
      }
      isLoadingQualities.value = false;
    } else {
      await _translateQualitiesCatalog();
    }

    tempSelectedQualities.value = List<int>.from(currentIds);

    if (Get.context != null) {
      showModalBottomSheet(
        context: Get.context!,
        isScrollControlled: true,
        backgroundColor: ThemeColor.backgroundColorfondo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              Container(
                padding: EdgeInsets.all(ThemeColor.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHandle(),
                    SizedBox(height: ThemeColor.paddingExtraLarge),
                    _buildBsTitle(_l.t('bs_qualities_title'),
                        fontSize: 26),
                    SizedBox(height: ThemeColor.paddingSmall),
                    _buildBsSubtitle(
                        _l.t('bs_qualities_subtitle')),
                    SizedBox(height: ThemeColor.paddingMedium),
                    Obx(() => Text(
                          '${_l.t('bs_qualities_counter')}   ${tempSelectedQualities.length}/$maxQualities ${_l.t('bs_interests_selected')}',
                          style: ThemeColor.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: ThemeColor.textDarkColor,
                          ),
                        )),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(
                      horizontal: ThemeColor.paddingLarge),
                  child: Obx(() => Wrap(
                        spacing: ThemeColor.paddingSmall,
                        runSpacing: ThemeColor.paddingSmall,
                        children: allQualities.map((quality) {
                          final isSelected = tempSelectedQualities
                              .contains(quality.id);
                          return _buildQualityChipSheet(
                            label: _getQualityLabel(quality.name),
                            isSelected: isSelected,
                            onTap: () =>
                                _toggleTempQuality(quality.id),
                          );
                        }).toList(),
                      )),
                ),
              ),
              Container(
                padding: EdgeInsets.all(ThemeColor.paddingLarge),
                child: Obx(() => _buildSaveButton(
                      isLoading: isSavingQualities.value,
                      onPressed: isSavingQualities.value
                          ? null
                          : () async => await _saveQualities(),
                    )),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _toggleTempQuality(int id) {
    if (tempSelectedQualities.contains(id)) {
      tempSelectedQualities.remove(id);
    } else {
      if (tempSelectedQualities.length >= maxQualities) {
        showErrorSnackbar(_l.t('bs_max_qualities'));
        return;
      }
      tempSelectedQualities.add(id);
    }
  }

  Future<void> _saveQualities() async {
    try {
      isSavingQualities.value = true;
      final currentIds =
          _profile.qualities.map((q) => q.id).toList();
      final newIds = tempSelectedQualities
          .where((id) => !currentIds.contains(id))
          .toList();
      final removedIds = currentIds
          .where((id) => !tempSelectedQualities.contains(id))
          .toList();

      if (newIds.isEmpty && removedIds.isEmpty) {
        showSuccessSnackbar(_l.t('snack_no_changes'));
        Get.back();
        return;
      }
      if (newIds.isNotEmpty)
        await postQualitiesUsecase.execute(newIds);
      if (removedIds.isNotEmpty) {
        await deleteQualitiesUsecase.execute(removedIds);
      }
      await _profile.loadUserProfile();
      Get.back();
      showSuccessSnackbar(_l.t('bs_qualities_saved'));
    } catch (e) {
      Get.back();
      showErrorSnackbar(
          '${_l.t('snack_could_not_save_qualities')}: ${cleanExceptionMessage(e)}');
    } finally {
      isSavingQualities.value = false;
    }
  }

  // ==========================================
  // BIOGRAFÍA
  // ==========================================

  void showEditBio(String currentValue) {
    final TextEditingController textController =
        TextEditingController(text: currentValue);

    if (Get.context != null) {
      showModalBottomSheet(
        context: Get.context!,
        isScrollControlled: true,
        backgroundColor: ThemeColor.backgroundColorfondo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(ThemeColor.paddingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHandle(),
                SizedBox(height: ThemeColor.paddingExtraLarge),
                _buildBsTitle(_l.t('bs_bio_title')),
                SizedBox(height: ThemeColor.paddingSmall),
                _buildBsSubtitle(_l.t('bs_bio_subtitle')),
                SizedBox(height: ThemeColor.paddingExtraLarge),
                TextField(
                  controller: textController,
                  autofocus: true,
                  maxLines: 5,
                  maxLength: 300,
                  decoration: InputDecoration(
                    hintText: _l.t('bs_bio_hint'),
                    hintStyle: ThemeColor.bodyMedium.copyWith(
                      color: ThemeColor.textSecondaryColor,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: ThemeColor.mediumBorderRadius,
                      borderSide:
                          BorderSide(color: ThemeColor.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: ThemeColor.mediumBorderRadius,
                      borderSide:
                          BorderSide(color: ThemeColor.primaryColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: ThemeColor.mediumBorderRadius,
                      borderSide:
                          BorderSide(color: ThemeColor.dividerColor),
                    ),
                  ),
                ),
                SizedBox(height: ThemeColor.paddingLarge),
                _buildSaveButton(onPressed: () {
                  Get.back();
                  updateBio(textController.text.trim());
                }),
                SizedBox(height: ThemeColor.paddingMedium),
              ],
            ),
          ),
        ),
      );
    }
  }

  // ==========================================
  // ESTADO
  // ==========================================

  void showEditStatus(String currentValue) {
    final TextEditingController textController =
        TextEditingController(text: currentValue);

    if (Get.context != null) {
      showModalBottomSheet(
        context: Get.context!,
        isScrollControlled: true,
        backgroundColor: ThemeColor.backgroundColorfondo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(ThemeColor.paddingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHandle(),
                SizedBox(height: ThemeColor.paddingExtraLarge),
                _buildBsTitle(_l.t('bs_status_title')),
                SizedBox(height: ThemeColor.paddingSmall),
                _buildBsSubtitle(_l.t('bs_status_subtitle')),
                SizedBox(height: ThemeColor.paddingExtraLarge),
                TextField(
                  controller: textController,
                  autofocus: true,
                  maxLines: 2,
                  maxLength: 20,
                  decoration: InputDecoration(
                    hintText: _l.t('bs_status_hint'),
                    hintStyle: ThemeColor.bodyMedium.copyWith(
                      color: ThemeColor.textSecondaryColor,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: ThemeColor.mediumBorderRadius,
                      borderSide:
                          BorderSide(color: ThemeColor.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: ThemeColor.mediumBorderRadius,
                      borderSide:
                          BorderSide(color: ThemeColor.primaryColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: ThemeColor.mediumBorderRadius,
                      borderSide:
                          BorderSide(color: ThemeColor.dividerColor),
                    ),
                  ),
                ),
                SizedBox(height: ThemeColor.paddingLarge),
                _buildSaveButton(onPressed: () {
                  Get.back();
                  updateStatus(textController.text.trim());
                }),
                SizedBox(height: ThemeColor.paddingMedium),
              ],
            ),
          ),
        ),
      );
    }
  }

  // ==========================================
  // FECHA DE NACIMIENTO
  // ==========================================

  void showEditDateOfBirth(String currentValue) {
    DateTime initialDate = DateTime(2000, 1, 1);
    try {
      if (currentValue.isNotEmpty) {
        initialDate =
            DateTime.parse(currentValue.split('T').first);
      }
    } catch (_) {}

    final DateTime maxDate = DateTime(
      DateTime.now().year - 18,
      DateTime.now().month,
      DateTime.now().day,
    );

    final int maxYear = maxDate.year;
    final int minYear = 1940;
    final int yearCount = maxYear - minYear + 1;

    if (initialDate.isAfter(maxDate)) initialDate = maxDate;

    final Rx<DateTime> selectedDate = initialDate.obs;

    if (Get.context != null) {
      showModalBottomSheet(
        context: Get.context!,
        isScrollControlled: true,
        backgroundColor: ThemeColor.backgroundColorfondo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          height: Get.height * 0.65,
          padding: EdgeInsets.all(ThemeColor.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHandle(),
              SizedBox(height: ThemeColor.paddingExtraLarge),
              _buildBsTitle(_l.t('bs_dob_title')),
              SizedBox(height: ThemeColor.paddingSmall),
              _buildBsSubtitle(_l.t('bs_dob_subtitle'),
                  textAlign: TextAlign.center),
              SizedBox(height: ThemeColor.paddingLarge),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildWheelHighlight(
                        horizontal: ThemeColor.paddingMedium),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateWheel(
                            itemCount: 31,
                            initialIndex: initialDate.day - 1,
                            labelBuilder: (i) =>
                                '${(i + 1).toString().padLeft(2, '0')}',
                            onChanged: (i) {
                              selectedDate.value = DateTime(
                                  selectedDate.value.year,
                                  selectedDate.value.month,
                                  i + 1);
                            },
                          ),
                        ),
                        Expanded(
                          child: _buildDateWheel(
                            itemCount: 12,
                            initialIndex: initialDate.month - 1,
                            labelBuilder: (i) => _monthName(i + 1),
                            onChanged: (i) {
                              selectedDate.value = DateTime(
                                  selectedDate.value.year,
                                  i + 1,
                                  selectedDate.value.day);
                            },
                          ),
                        ),
                        Expanded(
                          child: _buildDateWheel(
                            itemCount: yearCount,
                            initialIndex:
                                initialDate.year - minYear,
                            labelBuilder: (i) =>
                                '${minYear + i}',
                            onChanged: (i) {
                              selectedDate.value = DateTime(
                                  minYear + i,
                                  selectedDate.value.month,
                                  selectedDate.value.day);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: ThemeColor.paddingMedium),
              _buildSaveButton(onPressed: () {
                final date = selectedDate.value;
                final formatted =
                    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                if (selectedDate.value.isAfter(maxDate)) {
                  showErrorSnackbar(_l.t('bs_dob_age_error'));
                  return;
                }
                Get.back();
                updateDateOfBirth(formatted);
              }),
              SizedBox(height: ThemeColor.paddingMedium),
            ],
          ),
        ),
      );
    }
  }

  // ==========================================
  // BUSCO
  // ==========================================

  void showEditSearchGender(String currentValue) {
    final List<Map<String, dynamic>> options = [
      {'label': 'Hombres', 'value': 'Hombre', 'icon': Icons.male},
      {'label': 'Mujeres', 'value': 'Mujer', 'icon': Icons.female},
      {
        'label': 'Persona no binaria',
        'value': 'No_binario',
        'icon': Icons.transgender
      },
      {'label': 'Todos', 'value': 'Todos', 'icon': Icons.people},
    ];

    final RxString selected = currentValue.obs;

    if (Get.context != null) {
      showModalBottomSheet(
        context: Get.context!,
        isScrollControlled: true,
        backgroundColor: ThemeColor.backgroundColorfondo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(ThemeColor.paddingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHandle(),
                SizedBox(height: ThemeColor.paddingExtraLarge),
                _buildBsTitle(_l.t('bs_search_gender_title')),
                SizedBox(height: ThemeColor.paddingSmall),
                _buildBsSubtitle(
                    _l.t('bs_search_gender_subtitle')),
                SizedBox(height: ThemeColor.paddingExtraLarge),
                ...options.map((option) => Padding(
                      padding: EdgeInsets.only(
                          bottom: ThemeColor.paddingSmall),
                      child: Obx(() {
                        final isSelected =
                            selected.value == option['value'];
                        return _buildRadioOption(
                          label: option['label'],
                          icon: option['icon'] as IconData,
                          isSelected: isSelected,
                          onTap: () =>
                              selected.value = option['value'],
                        );
                      }),
                    )),
                SizedBox(height: ThemeColor.paddingLarge),
                _buildSaveButton(onPressed: () {
                  Get.back();
                  updateSearchGender(selected.value);
                }),
                SizedBox(height: ThemeColor.paddingMedium),
              ],
            ),
          ),
        ),
      );
    }
  }

  // ==========================================
  // TIPO DE CONEXIÓN
  // ==========================================

  void showEditConnectionType(String currentValue) {
    final List<Map<String, String>> options = [
      {'label': 'Amistad y buena vibra', 'value': 'amistad'},
      {'label': 'Conocer gente y pasarla bien', 'value': 'citas'},
      {'label': 'Algo estable y con futuro', 'value': 'algo_serio'},
      {'label': 'Conexiones sin ataduras', 'value': 'casual'},
    ];

    final RxString selected = currentValue.obs;

    if (Get.context != null) {
      showModalBottomSheet(
        context: Get.context!,
        isScrollControlled: true,
        backgroundColor: ThemeColor.backgroundColorfondo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(ThemeColor.paddingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHandle(),
                SizedBox(height: ThemeColor.paddingExtraLarge),
                _buildBsTitle(_l.t('bs_connection_title')),
                SizedBox(height: ThemeColor.paddingSmall),
                _buildBsSubtitle(_l.t('bs_connection_subtitle')),
                SizedBox(height: ThemeColor.paddingExtraLarge),
                ...options.map((option) => Padding(
                      padding: EdgeInsets.only(
                          bottom: ThemeColor.paddingSmall),
                      child: Obx(() {
                        final isSelected =
                            selected.value == option['value'];
                        return InkWell(
                          onTap: () =>
                              selected.value = option['value']!,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ThemeColor.paddingLarge,
                              vertical:
                                  ThemeColor.paddingMedium + 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  ThemeColor.mediumBorderRadius,
                              border: isSelected
                                  ? Border.all(
                                      color:
                                          ThemeColor.primaryColor,
                                      width: 2)
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    option['label']!,
                                    style: ThemeColor.bodyMedium
                                        .copyWith(
                                      color:
                                          ThemeColor.textDarkColor,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? ThemeColor.primaryColor
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? ThemeColor.primaryColor
                                          : ThemeColor
                                              .textSecondaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Icon(Icons.circle,
                                          color: Colors.white,
                                          size: 12)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    )),
                SizedBox(height: ThemeColor.paddingLarge),
                _buildSaveButton(onPressed: () {
                  Get.back();
                  updateConnectionType(selected.value);
                }),
                SizedBox(height: ThemeColor.paddingMedium),
              ],
            ),
          ),
        ),
      );
    }
  }

  // ==========================================
  // RANGO DE EDAD
  // ==========================================

  void showEditAgeRange(int currentMin, int currentMax) {
    final RxInt selectedMin = currentMin.obs;
    final RxInt selectedMax = currentMax.obs;

    final minScrollController = FixedExtentScrollController(
        initialItem: (currentMin - 18).clamp(0, 62));
    final maxScrollController = FixedExtentScrollController(
        initialItem: (currentMax - 18).clamp(0, 62));

    if (Get.context != null) {
      showModalBottomSheet(
        context: Get.context!,
        isScrollControlled: true,
        backgroundColor: ThemeColor.backgroundColorfondo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          height: Get.height * 0.65,
          padding: EdgeInsets.all(ThemeColor.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHandle(),
              SizedBox(height: ThemeColor.paddingExtraLarge),
              _buildBsTitle(_l.t('bs_age_range_title')),
              SizedBox(height: ThemeColor.paddingSmall),
              Obx(() => _buildBsSubtitle(
                    'De ${selectedMin.value} a ${selectedMax.value} ${_l.t('years')}',
                    textAlign: TextAlign.center,
                  )),
              SizedBox(height: ThemeColor.paddingLarge),
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        _l.t('bs_age_min'),
                        style: ThemeColor.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ThemeColor.textDarkColor,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        _l.t('bs_age_max'),
                        style: ThemeColor.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ThemeColor.textDarkColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ThemeColor.paddingSmall),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildWheelHighlight(
                        horizontal: ThemeColor.paddingMedium),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateWheel(
                            itemCount: 63,
                            initialIndex:
                                (currentMin - 18).clamp(0, 62),
                            labelBuilder: (i) => '${18 + i}',
                            onChanged: (i) {
                              final val = 18 + i;
                              selectedMin.value = val;
                              if (val > selectedMax.value) {
                                selectedMax.value = val;
                                maxScrollController.jumpToItem(i);
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: _buildDateWheel(
                            itemCount: 63,
                            initialIndex:
                                (currentMax - 18).clamp(0, 62),
                            labelBuilder: (i) => '${18 + i}',
                            onChanged: (i) {
                              final val = 18 + i;
                              selectedMax.value = val;
                              if (val < selectedMin.value) {
                                selectedMin.value = val;
                                minScrollController.jumpToItem(i);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: ThemeColor.paddingMedium),
              _buildSaveButton(onPressed: () {
                Get.back();
                updateAgeRange(selectedMin.value, selectedMax.value);
              }),
              SizedBox(height: ThemeColor.paddingMedium),
            ],
          ),
        ),
      );
    }
  }

  // ==========================================
  // DISTANCIA
  // ==========================================

  void showEditDistance(int currentDistanceKm) {
    int initialIndex;
    if (currentDistanceKm < 1) {
      initialIndex = 0;
    } else if (currentDistanceKm >= 300) {
      initialIndex = 308;
    } else {
      initialIndex = 9 + (currentDistanceKm - 1).clamp(0, 299);
    }

    final RxInt selectedIndex = initialIndex.obs;

    String labelForIndex(int index) {
      if (index < 9) return '${(index + 1) * 100} m';
      final km = index - 9 + 1;
      return km >= 300 ? '∞  ${_l.t('no_limit')}' : '$km km';
    }

    double kmForIndex(int index) {
      if (index < 9) return ((index + 1) * 100) / 1000.0;
      return (index - 9 + 1).toDouble();
    }

    if (Get.context != null) {
      showModalBottomSheet(
        context: Get.context!,
        isScrollControlled: true,
        backgroundColor: ThemeColor.backgroundColorfondo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          height: Get.height * 0.6,
          padding: EdgeInsets.all(ThemeColor.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHandle(),
              SizedBox(height: ThemeColor.paddingExtraLarge),
              _buildBsTitle(_l.t('bs_distance_title')),
              SizedBox(height: ThemeColor.paddingSmall),
              Obx(() {
                final idx = selectedIndex.value;
                final label = idx == 308
                    ? _l.t('bs_no_limit_distance')
                    : idx < 9
                        ? 'Hasta ${(idx + 1) * 100} metros'
                        : 'Hasta ${idx - 9 + 1} km';
                return _buildBsSubtitle(label,
                    textAlign: TextAlign.center);
              }),
              SizedBox(height: ThemeColor.paddingLarge),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildWheelHighlight(
                        horizontal:
                            ThemeColor.paddingExtraLarge * 2),
                    _buildDateWheel(
                      itemCount: 309,
                      initialIndex: initialIndex,
                      labelBuilder: labelForIndex,
                      onChanged: (index) {
                        selectedIndex.value = index;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: ThemeColor.paddingMedium),
              _buildSaveButton(onPressed: () {
                Get.back();
                updateDistance(kmForIndex(selectedIndex.value));
              }),
              SizedBox(height: ThemeColor.paddingMedium),
            ],
          ),
        ),
      );
    }
  }

  // ==========================================
  // UPDATE MÉTODOS
  // ==========================================

  Future<void> updateStatus(String status) async =>
      await _updateUser(UpdateUserEntity(status: status),
          _l.t('snack_status_saved'));

  Future<void> updateHeight(String height) async =>
      await _updateUser(UpdateUserEntity(heightcm: height),
          _l.t('snack_height_saved'));

  Future<void> updateBio(String bio) async =>
      await _updateUser(
          UpdateUserEntity(bio: bio), _l.t('snack_bio_saved'));

  Future<void> updateGender(String gender) async =>
      await _updateUser(UpdateUserEntity(gender: gender),
          _l.t('snack_gender_saved'));

  Future<void> updateLanguage(String language) async =>
      await _updateUser(
          UpdateUserEntity(primarylanguage: language),
          _l.t('snack_language_saved'));

  Future<void> updateDateOfBirth(String date) async =>
      await _updateUser(UpdateUserEntity(dateofbirth: date),
          _l.t('snack_dob_saved'));

  Future<void> updateSearchGender(String searchGender) async =>
      await _updatePreferences(
          PreferencesEntity(searchgender: searchGender),
          _l.t('snack_search_gender_saved'));

  Future<void> updateConnectionType(String connectionType) async =>
      await _updatePreferences(
          PreferencesEntity(connectiontype: connectionType),
          _l.t('snack_connection_saved'));

  Future<void> updateAgeRange(int agemin, int agemax) async =>
      await _updatePreferences(
          PreferencesEntity(agemin: agemin, agemax: agemax),
          _l.t('snack_age_range_saved'));

  Future<void> updateDistance(double distancekm) async =>
      await _updatePreferences(
          PreferencesEntity(distancekm: distancekm),
          _l.t('snack_distance_saved'));

  /// Actualiza la ciudad del usuario silenciosamente (sin snackbar)
  Future<void> updateCity(String city) async {
    try {
      final user = _profile.userEntity.value;
      final completeEntity = UpdateUserEntity(
        name: user?.name,
        dateofbirth: user?.dateofbirth,
        gender: user?.gender,
        bio: user?.bio,
        heightcm: user?.heightcm?.toString(),
        primarylanguage: user?.primarylanguage,
       
        status: user?.status,
      );
      await updateUserUsecase.execute(completeEntity);
      await _profile.loadUserProfile();
    } catch (_) {
      // Silencioso — la ciudad es secundaria, no interrumpir el flujo
    }
  }

  Future<void> _updateUser(
      UpdateUserEntity entity, String successMsg) async {
    try {
      isUpdating.value = true;
      final user = _profile.userEntity.value;
      final completeEntity = UpdateUserEntity(
        name: entity.name ?? user?.name,
        dateofbirth: entity.dateofbirth ?? user?.dateofbirth,
        gender: entity.gender ?? user?.gender,
        bio: entity.bio ?? user?.bio,
        heightcm: entity.heightcm ?? user?.heightcm?.toString(),
        primarylanguage:
            entity.primarylanguage ?? user?.primarylanguage,
        status: entity.status ?? user?.status,
      );
      await updateUserUsecase.execute(completeEntity);
      await _profile.loadUserProfile();
          nearbyController.noMoreUsers.value = false;
                nearbyController.loadNearbyUsers();
      showSuccessSnackbar(successMsg);
    } catch (e) {
      showErrorSnackbar(
          '${_l.t('snack_could_not_update')}: ${cleanExceptionMessage(e)}');
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> _updatePreferences(
      PreferencesEntity entity, String successMsg) async {
    try {
      isUpdating.value = true;
      final current = _profile.userEntity.value?.preferences;
      final completeEntity = PreferencesEntity(
        searchgender: entity.searchgender ?? current?.searchgender,
        connectiontype:
            entity.connectiontype ?? current?.connectiontype,
        agemin: entity.agemin ?? current?.agemin,
        agemax: entity.agemax ?? current?.agemax,
        distancekm: entity.distancekm ?? current?.distancekm,
      );
      await putPreferencesUserUsecase.execute(completeEntity);
      await _profile.loadUserProfile();
                nearbyController.noMoreUsers.value = false;
                nearbyController.loadNearbyUsers();
      showSuccessSnackbar(successMsg);
    } catch (e) {
      showErrorSnackbar(
          '${_l.t('snack_could_not_update')}: ${cleanExceptionMessage(e)}');
    } finally {
      isUpdating.value = false;
    }
  }

  // ==========================================
  // DELETE
  // ==========================================

  Future<void> removeInterest(int interestId) async {
    try {
      isDeletingInterest.value = true;
      await deleteInterestsUsecase.execute([interestId]);
      await _profile.loadUserProfile();
      showSuccessSnackbar(_l.t('snack_interest_removed'));
    } catch (e) {
      showErrorSnackbar(
          '${_l.t('snack_could_not_delete')}: ${cleanExceptionMessage(e)}');
    } finally {
      isDeletingInterest.value = false;
    }
  }

  Future<void> removeQuality(int qualityId) async {
    try {
      isDeletingQuality.value = true;
      await deleteQualitiesUsecase.execute([qualityId]);
      await _profile.loadUserProfile();
      showSuccessSnackbar(_l.t('snack_quality_removed'));
    } catch (e) {
      showErrorSnackbar(
          '${_l.t('snack_could_not_delete')}: ${cleanExceptionMessage(e)}');
    } finally {
      isDeletingQuality.value = false;
    }
  }

  // ==========================================
  // DELETE ACCOUNT
  // ==========================================

  Future<void> deleteAccount() async {
    try {
      isUpdating.value = true;
      await deleteUserUsecase.execute();
      await AuthService().logout();
      Get.offAllNamed(RoutesNames.loginPage);
    } catch (e) {
      showErrorSnackbar(
          '${_l.t('snack_could_not_delete')}: ${cleanExceptionMessage(e)}');
    } finally {
      isUpdating.value = false;
    }
  }

  void confirmDeleteAccount() {
    if (Get.context != null) {
      showCustomAlert(
        context: Get.context!,
        title: _l.t('alert_delete_account_title'),
        message: _l.t('alert_delete_account_msg'),
        confirmText: _l.t('alert_delete'),
        cancelText: _l.t('cancel'),
        type: CustomAlertType.error,
        onCancel: () => Get.back(),
        onConfirm: () {
          Get.back();
          deleteAccount();
        },
      );
    }
  }

  // ==========================================
  // WIDGETS REUTILIZABLES (privados)
  // ==========================================

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildBsTitle(String text, {double fontSize = 26}) {
    return Text(
      text,
      style: ThemeColor.headingSmall.copyWith(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: ThemeColor.textDarkColor,
        height: 1.2,
      ),
    );
  }

  Widget _buildBsSubtitle(String text,
      {TextAlign textAlign = TextAlign.start}) {
    return Text(
      text,
      style: ThemeColor.bodyMedium.copyWith(
        color: ThemeColor.textSecondaryColor,
        height: 1.4,
      ),
      textAlign: textAlign,
    );
  }

  Widget _buildSaveButton(
      {VoidCallback? onPressed, bool isLoading = false}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeColor.primaryColor,
          padding:
              EdgeInsets.symmetric(vertical: ThemeColor.paddingMedium),
          shape: RoundedRectangleBorder(
            borderRadius: ThemeColor.mediumBorderRadius,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(_l.t('save'), style: ThemeColor.buttonText),
      ),
    );
  }

  Widget _buildWheelHighlight({double horizontal = 0}) {
    return IgnorePointer(
      child: Container(
        height: 60,
        margin: EdgeInsets.symmetric(horizontal: horizontal),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: ThemeColor.extraLargeBorderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWheelItem(
      {required String label, required bool isSelected}) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      child: Text(
        label,
        style: ThemeColor.bodyLarge.copyWith(
          color: isSelected
              ? ThemeColor.textDarkColor
              : ThemeColor.textSecondaryColor,
          fontWeight:
              isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: isSelected ? 20 : 16,
        ),
      ),
    );
  }

  Widget _buildRadioOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? ThemeColor.primaryColor
                : ThemeColor.textSecondaryColor,
          ),
          color: isSelected
              ? ThemeColor.primaryColor.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? ThemeColor.primaryColor
                  : ThemeColor.textSecondaryColor,
              size: 22,
            ),
            SizedBox(width: ThemeColor.paddingMedium),
            Expanded(
              child: Text(
                label,
                style: ThemeColor.bodyMedium
                    .copyWith(color: ThemeColor.textDarkColor),
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected
                  ? ThemeColor.primaryColor
                  : ThemeColor.textSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateWheel({
    required int itemCount,
    required int initialIndex,
    required String Function(int index) labelBuilder,
    required void Function(int index) onChanged,
  }) {
    final scrollController =
        FixedExtentScrollController(initialItem: initialIndex);
    final RxInt selected = initialIndex.obs;

    return ListWheelScrollView.useDelegate(
      controller: scrollController,
      itemExtent: 60,
      diameterRatio: 1.5,
      perspective: 0.003,
      physics: FixedExtentScrollPhysics(),
      onSelectedItemChanged: (index) {
        selected.value = index;
        onChanged(index);
      },
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          return Obx(() => _buildWheelItem(
                label: labelBuilder(index),
                isSelected: index == selected.value,
              ));
        },
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return months[month - 1];
  }

  // ==========================================
  // CHIPS
  // ==========================================

  Widget _buildInterestChipSheet({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ThemeColor.paddingMedium,
          vertical: ThemeColor.paddingSmall + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? ThemeColor.tertiaryColor : Colors.white,
          borderRadius: ThemeColor.circularBorderRadius,
          border: Border.all(
            color:
                isSelected ? ThemeColor.tertiaryColor : Colors.white,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 18,
                color: isSelected
                    ? Colors.white
                    : ThemeColor.textDarkColor),
            SizedBox(width: 6),
            Text(
              label,
              style: ThemeColor.bodyMedium.copyWith(
                color: isSelected
                    ? Colors.white
                    : ThemeColor.textDarkColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityChipSheet({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ThemeColor.paddingLarge,
          vertical: ThemeColor.paddingMedium - 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? ThemeColor.tertiaryColor : Colors.white,
          borderRadius: ThemeColor.circularBorderRadius,
          border: Border.all(
            color:
                isSelected ? ThemeColor.tertiaryColor : Colors.white,
          ),
        ),
        child: Text(
          label,
          style: ThemeColor.bodyMedium.copyWith(
            color: isSelected ? Colors.white : ThemeColor.textDarkColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // ICON HELPER
  // ==========================================

  IconData _getInterestIcon(String interest) {
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
    return icons[interest] ?? Icons.favorite;
  }
}