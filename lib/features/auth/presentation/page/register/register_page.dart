import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/settings/language_controller.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/auth/domain/entities/user/registration_step.dart';
import 'package:tendria/features/auth/presentation/page/register/register_controller.dart';

class RegisterPage extends GetView<RegisterController> {
  const RegisterPage({Key? key}) : super(key: key);
  LanguageController get mycontroller => Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.backgroundColorfondo,
      body: SafeArea(
        child: Obx(() {
          switch (controller.currentStep.value) {
            case RegistrationStep.basicInfo:
              return _buildBasicInfoStep();
            case RegistrationStep.personalInfo:
              return _buildPersonalInfoStep();
            case RegistrationStep.physicalInfo:
              return _buildPhysicalInfoStep();
            case RegistrationStep.interests:
              return buildInterestsStep();
            case RegistrationStep.qualities:
              return buildQualitiesStep();
          }
        }),
      ),
    );
  }
 
  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(ThemeColor.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ThemeColor.paddingExtraLarge),

            Text(
              mycontroller.t('register_title'),
              style: ThemeColor.headingLarge.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: ThemeColor.textDarkColor,
              ),
            ),
            SizedBox(height: ThemeColor.paddingSmall),
            Row(
              children: [
                Text(
                  mycontroller.t('register_have_account'),
                  style: ThemeColor.bodyMedium.copyWith(
                    color: ThemeColor.textSecondaryColor,
                  ),
                ),
                GestureDetector(
                  onTap: controller.onLoginTap,
                  child: Text(
                    mycontroller.t('register_login'),
                    style: ThemeColor.bodyMedium.copyWith(
                      color: ThemeColor.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: ThemeColor.paddingExtraLarge * 1.5),

            Obx(
              () => ThemeColor.createLabeledTextField(
                label: mycontroller.t('register_name'),
                controller: controller.nameController,
                focusNode: controller.nameFocusNode,
                hintText: mycontroller.t('register_name_hint'),
                onSubmitted: (_) => controller.onNameSubmitted(),
                isRequired: true,
                errorText: controller.nameErrorMessage.value,
                showError: controller.nameError.value,
              ),
            ),

            SizedBox(height: ThemeColor.paddingLarge),

            Obx(
              () => ThemeColor.createLabeledTextField(
                label: mycontroller.t('register_email'),
                controller: controller.emailController,
                focusNode: controller.emailFocusNode,
                hintText: mycontroller.t('register_email_hint'),
                keyboardType: TextInputType.emailAddress,
                onSubmitted: (_) => controller.onEmailSubmitted(),
                isRequired: true,
                errorText: controller.emailErrorMessage.value,
                showError: controller.emailError.value,
              ),
            ),

            SizedBox(height: ThemeColor.paddingLarge),

            Obx(
              () => ThemeColor.createLabeledTextField(
                label: mycontroller.t('register_password'),
                controller: controller.passwordController,
                focusNode: controller.passwordFocusNode,
                hintText: '••••••••••',
                obscureText: !controller.showPassword.value,
                onSubmitted: (_) => controller.onPasswordSubmitted(),
                isRequired: true,
                errorText: controller.passwordErrorMessage.value,
                showError: controller.passwordError.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.showPassword.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: ThemeColor.textSecondaryColor,
                  ),
                  onPressed: () => controller.showPassword.toggle(),
                ),
              ),
            ),

            SizedBox(height: ThemeColor.paddingLarge),

            Obx(
              () => ThemeColor.createLabeledTextField(
                label: mycontroller.t('register_confirm_password'),
                controller: controller.confirmPasswordController,
                focusNode: controller.confirmPasswordFocusNode,
                hintText: '••••••••••',
                obscureText: !controller.showConfirmPassword.value,
                onSubmitted: (_) => controller.onConfirmPasswordSubmitted(),
                isRequired: true,
                errorText: controller.confirmPasswordErrorMessage.value,
                showError: controller.confirmPasswordError.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.showConfirmPassword.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: ThemeColor.textSecondaryColor,
                  ),
                  onPressed: () => controller.showConfirmPassword.toggle(),
                ),
              ),
            ),

            SizedBox(height: ThemeColor.paddingExtraLarge),

            Text(
              mycontroller.t('register_privacy'),
              style: ThemeColor.bodySmall.copyWith(
                color: ThemeColor.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: ThemeColor.paddingLarge),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: controller.nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColor.tertiaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: ThemeColor.mediumBorderRadius,
                  ),
                  elevation: 0,
                ),
                child: Text(
                  mycontroller.t('register_btn'),
                  style: ThemeColor.buttonText.copyWith(fontSize: 16),
                ),
              ),
            ),

            SizedBox(height: ThemeColor.paddingExtraLarge),
          ],
        ),
      ),
    );
  }
 
  Widget _buildPersonalInfoStep() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(ThemeColor.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: ThemeColor.paddingExtraLarge),

                  Text(
                    mycontroller.t('personal_title'),
                    style: ThemeColor.headingLarge.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.textDarkColor,
                      height: 1.2,
                    ),
                  ),

                  SizedBox(height: ThemeColor.paddingExtraLarge * 1.5),
 
                  Text(
                    mycontroller.t('personal_dob'),
                    style: ThemeColor.bodyMedium.copyWith(
                      color: ThemeColor.textDarkColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: ThemeColor.paddingMedium),
                  Obx(
                    () => InkWell(
                      onTap: () => _showDatePicker(),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ThemeColor.paddingLarge,
                          vertical: ThemeColor.paddingMedium + 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: ThemeColor.mediumBorderRadius,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              controller.dateOfBirth.value != null
                                  ? '${controller.dateOfBirth.value!.day.toString().padLeft(2, '0')}/${controller.dateOfBirth.value!.month.toString().padLeft(2, '0')}/${controller.dateOfBirth.value!.year}'
                                  : mycontroller.t('personal_dob_placeholder'),
                              style: ThemeColor.bodyMedium.copyWith(
                                color: controller.dateOfBirth.value != null
                                    ? ThemeColor.textDarkColor
                                    : ThemeColor.textSecondaryColor,
                              ),
                            ),
                            Icon(
                              Icons.calendar_today,
                              color: ThemeColor.textSecondaryColor,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: ThemeColor.paddingExtraLarge),

                  Text(
                    mycontroller.t('personal_gender'),
                    style: ThemeColor.bodyMedium.copyWith(
                      color: ThemeColor.textDarkColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: ThemeColor.paddingMedium),
 
                  ...controller.genderOptions.map((option) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: ThemeColor.paddingSmall),
                      child: _buildGenderOption(
                        option['label'] as String,
                        option['icon'] as IconData,
                        option['value'] as String,
                      ),
                    );
                  }).toList(),

                  SizedBox(height: ThemeColor.paddingExtraLarge),

                  Obx(
                    () => ThemeColor.createLabeledTextField(
                      label: mycontroller.t('personal_bio'),
                      controller: controller.bioController,
                      focusNode: controller.bioFocusNode,
                      hintText: mycontroller.t('personal_bio_hint'),
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      isRequired: true,
                      errorText: controller.bioErrorMessage.value,
                      showError: controller.bioError.value,
                      borderRadius: ThemeColor.smallBorderRadius,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildGenderOption(
    String text,
    IconData icon,
    String value, {
    bool isCustom = false,
  }) {
    return Obx(() {
      final isSelected = controller.selectedGender.value == value;

      return InkWell(
        onTap: () => controller.selectGender(value),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ThemeColor.paddingLarge,
            vertical: ThemeColor.paddingMedium + 2,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: ThemeColor.mediumBorderRadius,
            border: isSelected
                ? Border.all(color: ThemeColor.tertiaryColor, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? ThemeColor.tertiaryColor
                    : ThemeColor.textSecondaryColor,
                size: 24,
              ),
              SizedBox(width: ThemeColor.paddingMedium),
              Expanded(
                child: Text(
                  text,
                  style: ThemeColor.bodyMedium.copyWith(
                    color: ThemeColor.textDarkColor,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? ThemeColor.tertiaryColor
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? ThemeColor.tertiaryColor
                        : ThemeColor.textSecondaryColor,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(Icons.circle, color: Colors.white, size: 12)
                    : null,
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showDatePicker() async {
    final DateTime today = DateTime.now();
    final DateTime maxDate = DateTime(today.year - 18, today.month, today.day);

    final DateTime initialDate = DateTime(
      today.year - 25,
      today.month,
      today.day,
    );

    final DateTime minDate = DateTime(today.year - 100, today.month, today.day);

    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: initialDate,
      firstDate: minDate,
      lastDate: maxDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ThemeColor.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: ThemeColor.textDarkColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.selectDateOfBirth(picked);
    }
  }
 
  Widget _buildPhysicalInfoStep() {
    return Column(
      children: [
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(ThemeColor.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: ThemeColor.paddingExtraLarge),
                    Text(
                      mycontroller.t('physical_title'),
                      style: ThemeColor.headingMedium.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ThemeColor.textDarkColor,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: ThemeColor.paddingExtraLarge),
                    Text(
                      mycontroller.t('physical_height'),
                      style: ThemeColor.bodyMedium.copyWith(
                        color: ThemeColor.textDarkColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(child: _buildHeightPicker()),
            ],
          ),
        ),

        _buildNavigationButtons(showSkip: true),
      ],
    );
  }

  Widget _buildHeightPicker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        IgnorePointer(
          child: Container(
            height: 60,
            margin: EdgeInsets.symmetric(
              horizontal: ThemeColor.paddingExtraLarge * 2,
            ),
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
        ),

        ListWheelScrollView.useDelegate(
          controller: controller.heightScrollController,
          itemExtent: 60,
          diameterRatio: 1.5,
          perspective: 0.003,
          physics: FixedExtentScrollPhysics(),
          onSelectedItemChanged: (index) {
            final height = 100 + index;
            controller.selectHeight(height);
          },
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: 96,
            builder: (context, index) {
              final height = 100 + index;

              return Obx(() {
                final isSelected = height == controller.selectedHeight.value;

                return Container(
                  height: 60,
                  alignment: Alignment.center,
                  child: Text(
                    '$height cm',
                    style: ThemeColor.bodyLarge.copyWith(
                      color: isSelected
                          ? ThemeColor.textDarkColor
                          : ThemeColor.textSecondaryColor,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontSize: isSelected ? 20 : 16,
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }
 
  Widget buildInterestsStep() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(ThemeColor.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: ThemeColor.paddingExtraLarge),

                  Text(
                    mycontroller.t('interests_page_title'),
                    style: ThemeColor.headingLarge.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.textDarkColor,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: ThemeColor.paddingSmall),
                  Text(
                    mycontroller.t('interests_page_subtitle'),
                    style: ThemeColor.bodyMedium.copyWith(
                      color: ThemeColor.textSecondaryColor,
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: ThemeColor.paddingExtraLarge),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ThemeColor.paddingLarge,
                      vertical: ThemeColor.paddingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: ThemeColor.mediumBorderRadius,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: ThemeColor.textSecondaryColor,
                        ),
                        SizedBox(width: ThemeColor.paddingSmall),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: mycontroller.t('interests_search_hint'),
                              hintStyle: ThemeColor.bodyMedium.copyWith(
                                color: ThemeColor.textSecondaryColor,
                              ),
                              border: InputBorder.none,
                            ),
                            style: ThemeColor.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: ThemeColor.paddingLarge),

                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          mycontroller.t('interests_popular'),
                          style: ThemeColor.bodyMedium.copyWith(
                            color: ThemeColor.textDarkColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${controller.selectedInterests.length}/${controller.maxInterests} ${mycontroller.t('bs_interests_selected')}',
                          style: ThemeColor.bodyMedium.copyWith(
                            color: ThemeColor.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: ThemeColor.paddingMedium),

                  Obx(() {
                    if (controller.isLoadingInterests.value) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(ThemeColor.paddingExtraLarge),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ThemeColor.primaryColor,
                            ),
                          ),
                        ),
                      );
                    }

                    if (controller.interests.isEmpty) {
                      return Center(
                        child: Text(
                          mycontroller.t('bs_interests_load_error'),
                          style: ThemeColor.bodyMedium.copyWith(
                            color: ThemeColor.textSecondaryColor,
                          ),
                        ),
                      );
                    }

                    return Obx(
                      () => Wrap(
                        spacing: ThemeColor.paddingSmall,
                        runSpacing: ThemeColor.paddingSmall,
                        children: controller.interests.map((interest) {
                          final isSelected = controller.selectedInterests
                              .contains(interest.id);
                          return _buildInterestChip(
                            controller.getInterestLabel(interest.name),
                            _getInterestIcon(interest.name),
                            isSelected,
                            () => controller.toggleInterest(interest.id),
                          );
                        }).toList(),
                      ),
                    );
                  }),

                  SizedBox(height: ThemeColor.paddingLarge),

                  Center(
                    child: Text(
                      mycontroller.t('interests_custom_hint'),
                      style: ThemeColor.bodySmall.copyWith(
                        color: ThemeColor.textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: ThemeColor.paddingMedium),

                  SizedBox(height: ThemeColor.paddingExtraLarge),
                ],
              ),
            ),
          ),
        ),

        _buildNavigationButtons(showSkip: true),
      ],
    );
  }

  Widget _buildInterestChip(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
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
            color: isSelected ? ThemeColor.tertiaryColor : Colors.white,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : ThemeColor.textDarkColor,
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: ThemeColor.bodyMedium.copyWith(
                color: isSelected ? Colors.white : ThemeColor.textDarkColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getInterestIcon(String interest) {
    final icons = {
   
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
  Widget buildQualitiesStep() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(ThemeColor.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: ThemeColor.paddingExtraLarge),

                  Text(
                    mycontroller.t('qualities_page_title'),
                    style: ThemeColor.headingLarge.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.textDarkColor,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: ThemeColor.paddingSmall),
                  Text(
                    mycontroller.t('qualities_page_subtitle'),
                    style: ThemeColor.bodyMedium.copyWith(
                      color: ThemeColor.textSecondaryColor,
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: ThemeColor.paddingExtraLarge),

                  Obx(
                    () => Text(
                      '${mycontroller.t('qualities_counter_label')}  ${controller.selectedQualities.length}/${controller.maxQualities} ${mycontroller.t('bs_interests_selected')}',
                      style: ThemeColor.bodyMedium.copyWith(
                        color: ThemeColor.textDarkColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  SizedBox(height: ThemeColor.paddingMedium),

                  Obx(() {
                    if (controller.isLoadingQualities.value) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(ThemeColor.paddingExtraLarge),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ThemeColor.primaryColor,
                            ),
                          ),
                        ),
                      );
                    }

                    if (controller.qualities.isEmpty) {
                      return Center(
                        child: Text(
                          mycontroller.t('error'),
                          style: ThemeColor.bodyMedium.copyWith(
                            color: ThemeColor.textSecondaryColor,
                          ),
                        ),
                      );
                    }

                    return Wrap(
                      spacing: ThemeColor.paddingSmall,
                      runSpacing: ThemeColor.paddingSmall,
                      children: controller.qualities.map((quality) {
                        final isSelected = controller.selectedQualities
                            .contains(quality.id);
                        return _buildQualityChip(
                          controller.getQualityLabel(quality.name),
                          isSelected,
                          () => controller.toggleQuality(quality.id),
                        );
                      }).toList(),
                    );
                  }),

                  SizedBox(height: ThemeColor.paddingExtraLarge * 2),
                ],
              ),
            ),
          ),
        ),

        _buildNavigationButtons(showSkip: true, isLastStep: true),
      ],
    );
  }

  Widget _buildQualityChip(String label, bool isSelected, VoidCallback onTap) {
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
            color: isSelected ? ThemeColor.tertiaryColor : Colors.white,
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
 
  Widget _buildNavigationButtons({
    bool showSkip = false,
    bool isLastStep = false,
    VoidCallback? onSkip,
  }) {
    return Container(
      padding: EdgeInsets.all(ThemeColor.paddingLarge),
      decoration: BoxDecoration(color: ThemeColor.backgroundColorfondo),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => controller.currentStepIndex.value > 0
                ? GestureDetector(
                    onTap: controller.previousStep,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: ThemeColor.tertiaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  )
                : SizedBox(width: 56),
          ),

          if (showSkip)
            GestureDetector(
              onTap: isLastStep
                  ? controller.onRegisterTap
                  : (onSkip ?? controller.skipStep),
              child: Text(
                mycontroller.t('nav_skip'),
                style: ThemeColor.bodyMedium.copyWith(
                  color: ThemeColor.textSecondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            SizedBox(),

          Obx(() {
            final isLoading = controller.isLoading.value;

            return GestureDetector(
              onTap: isLoading
                  ? null
                  : (isLastStep
                        ? controller.onRegisterTap
                        : controller.nextStep),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isLoading
                      ? ThemeColor.tertiaryColor.withOpacity(0.6)
                      : ThemeColor.tertiaryColor,
                  shape: BoxShape.circle,
                ),
                child: isLoading
                    ? Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      )
                    : Icon(Icons.arrow_forward, color: Colors.white),
              ),
            );
          }),
        ],
      ),
    );
  }
}
