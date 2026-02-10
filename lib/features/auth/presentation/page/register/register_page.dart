import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/auth/domain/entities/user/registration_step.dart';
import 'package:tendria/features/auth/presentation/page/register/register_controller.dart';

class RegisterPage extends GetView<RegisterController> {
  const RegisterPage({Key? key}) : super(key: key);

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
              return _buildInterestsStep();
            case RegistrationStep.qualities:
              return _buildQualitiesStep();
          }
        }),
      ),
    );
  }

  // PASO 1: INFORMACIÓN BÁSICA
  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(ThemeColor.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ThemeColor.paddingExtraLarge),

            Text(
              'Empezar',
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
                  '¿Ya cuentas con un registro? ',
                  style: ThemeColor.bodyMedium.copyWith(
                    color: ThemeColor.textSecondaryColor,
                  ),
                ),
                GestureDetector(
                  onTap: controller.onLoginTap,
                  child: Text(
                    'Iniciar Sesión',
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
                label: 'Nombre Completo:',
                controller: controller.nameController,
                focusNode: controller.nameFocusNode,
                hintText: 'Karen Hernández Costa',
                onSubmitted: (_) => controller.onNameSubmitted(),
                isRequired: true,
                errorText: controller.nameErrorMessage.value,
                showError: controller.nameError.value,
              ),
            ),

            SizedBox(height: ThemeColor.paddingLarge),

            Obx(
              () => ThemeColor.createLabeledTextField(
                label: 'Correo electrónico:',
                controller: controller.emailController,
                focusNode: controller.emailFocusNode,
                hintText: 'correo@gmail.com',
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
                label: 'Crea una contraseña',
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
                label: 'Confirma tu contraseña:',
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
              'Al registrarte estas aceptando el Aviso de Privacidad y los Términos y Condiciones.',
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
                  'Registrarse',
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

  // PASO 2: INFORMACIÓN PERSONAL
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
                    'Iniciemos con lo\nbásico',
                    style: ThemeColor.headingLarge.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.textDarkColor,
                      height: 1.2,
                    ),
                  ),

                  SizedBox(height: ThemeColor.paddingExtraLarge * 1.5),

                  // Fecha de nacimiento
                  Text(
                    'Selecciona tu fecha de nacimiento',
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
                                  : '14/05/1993',
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

                 // En _buildPersonalInfoStep(), reemplaza la sección de género:

Text(
  '¿Cómo te identificas?',
  style: ThemeColor.bodyMedium.copyWith(
    color: ThemeColor.textDarkColor,
    fontWeight: FontWeight.w500,
  ),
),
SizedBox(height: ThemeColor.paddingMedium),

// Generar opciones dinámicamente desde genderOptions
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
                      label: 'Cuéntanos sobre ti:',
                      controller: controller.bioController,
                      focusNode: controller.bioFocusNode,
                      hintText: 'Escribe una breve biografía...',
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      isRequired: true, 
                      errorText: controller.bioErrorMessage.value,
                      showError: controller.bioError.value,
                      borderRadius: ThemeColor.smallBorderRadius
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

 Widget _buildGenderOption(String text, IconData icon, String value, {bool isCustom = false}) {
  return Obx(
    () {
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
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? ThemeColor.tertiaryColor : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? ThemeColor.tertiaryColor : ThemeColor.textSecondaryColor,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.circle,
                        color: Colors.white,
                        size: 12,
                      )
                    : null,
              ),
            ],
          ),
        ),
      );
    },
  );
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

  // PASO 3: ALTURA
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
                      'Esta información nos ayuda a\nmejorar tus coincidencias',
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
                      'Tu altura',
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
            final height = 154 + index;
            controller.selectHeight(height);
          },
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: 96,
            builder: (context, index) {
              final height = 154 + index;

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

  // PASO 4: INTERESES
  Widget _buildInterestsStep() {
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
                    'Elige tus intereses\nprincipales',
                    style: ThemeColor.headingLarge.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.textDarkColor,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: ThemeColor.paddingSmall),
                  Text(
                    'Tus gustos nos ayudan a encontrar mejores\ncoincidencias.',
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
                              hintText: 'Buscar intereses',
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
                          'Intereses populares',
                          style: ThemeColor.bodyMedium.copyWith(
                            color: ThemeColor.textDarkColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${controller.selectedInterests.length}/5 seleccionados',
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
                          'No hay intereses disponibles',
                          style: ThemeColor.bodyMedium.copyWith(
                            color: ThemeColor.textSecondaryColor,
                          ),
                        ),
                      );
                    }

                    return Wrap(
                      spacing: ThemeColor.paddingSmall,
                      runSpacing: ThemeColor.paddingSmall,
                      children: controller.interests.map((interest) {
                        final isSelected = controller.selectedInterests
                            .contains(interest.id);
                        return _buildInterestChip(
                          interest.name,
                          _getInterestIcon(interest.name),
                          isSelected,
                          () => controller.toggleInterest(interest.id),
                        );
                      }).toList(),
                    );
                  }),

                  SizedBox(height: ThemeColor.paddingLarge),

                  Center(
                    child: Text(
                      'si no se encuentran tus resultados escríbelos...',
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
      'Bailar': Icons.music_note,
      'Foodie': Icons.restaurant,
      'Conciertos': Icons.music_note,
      'Escribir': Icons.edit,
      'Café': Icons.coffee,
      'Arte': Icons.palette,
      'Museos y galerías': Icons.museum,
      'Yoga': Icons.self_improvement,
      'Perros': Icons.pets,
      'Libros': Icons.book,
      'Deportes': Icons.sports_soccer,
    };
    return icons[interest] ?? Icons.favorite;
  }

  // PASO 5: CUALIDADES
  Widget _buildQualitiesStep() {
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
                    'Lo que más aprecias en una\npersona',
                    style: ThemeColor.headingLarge.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.textDarkColor,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: ThemeColor.paddingSmall),
                  Text(
                    'Estas cualidades nos ayudan a crear mejores\ncoincidencias.',
                    style: ThemeColor.bodyMedium.copyWith(
                      color: ThemeColor.textSecondaryColor,
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: ThemeColor.paddingExtraLarge),

                  Obx(
                    () => Text(
                      'Lo que buscas en alguien        ${controller.selectedQualities.length}/3 seleccionados',
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
                          'No hay cualidades disponibles',
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
                          quality.name,
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

  // NAVEGACIÓN INFERIOR
  Widget _buildNavigationButtons({
    bool showSkip = false,
    bool isLastStep = false,
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
              onTap: isLastStep ? null : controller.nextStep,
              child: Text(
                'Omitir',
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
