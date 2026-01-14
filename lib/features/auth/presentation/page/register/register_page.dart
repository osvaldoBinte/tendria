import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/auth/presentation/page/register/register_controller.dart';
class RegisterPage extends GetView<RegisterController> {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: ThemeColor.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: ThemeColor.textDarkColor,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: ThemeColor.paddingLarge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              SizedBox(height: ThemeColor.paddingExtraLarge),
              _buildRegisterForm(),
              SizedBox(height: ThemeColor.paddingExtraLarge),
              _buildRegisterButton(),
              SizedBox(height: ThemeColor.paddingMedium),
              _buildLoginLink(),
              SizedBox(height: ThemeColor.paddingLarge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Crear Cuenta',
          style: ThemeColor.headingLarge.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: ThemeColor.textDarkColor,
          ),
        ),
        SizedBox(height: ThemeColor.paddingSmall),
        Text(
          'Completa el formulario para registrarte',
          style: ThemeColor.bodyMedium.copyWith(
            color: ThemeColor.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        children: [
          // Nombre
          Obx(
            () => ThemeColor.createLabeledTextField(
              label: 'Nombre completo',
              controller: controller.nameController,
              focusNode: controller.nameFocusNode,
              hintText: 'Juan Pérez',
              onSubmitted: (_) => controller.onNameSubmitted(),
              isRequired: true,
              errorText: controller.nameErrorMessage.value,
              showError: controller.nameError.value,
            ),
          ),

          SizedBox(height: ThemeColor.paddingMedium),

          // Email
          Obx(
            () => ThemeColor.createLabeledTextField(
              label: 'Correo electrónico',
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

          SizedBox(height: ThemeColor.paddingMedium),

          // Password
          Obx(
            () => ThemeColor.createLabeledTextField(
              label: 'Contraseña',
              controller: controller.passwordController,
              focusNode: controller.passwordFocusNode,
              hintText: 'Mínimo 8 caracteres',
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

          SizedBox(height: ThemeColor.paddingMedium),

          // Confirmar Password
          Obx(
            () => ThemeColor.createLabeledTextField(
              label: 'Confirmar contraseña',
              controller: controller.confirmPasswordController,
              focusNode: controller.confirmPasswordFocusNode,
              hintText: 'Repite tu contraseña',
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

          SizedBox(height: ThemeColor.paddingMedium),

          // Fecha de nacimiento
          _buildDatePicker(),

          SizedBox(height: ThemeColor.paddingMedium),

          // Género
          _buildGenderSelector(),

          SizedBox(height: ThemeColor.paddingMedium),

          // Altura
          ThemeColor.createLabeledTextField(
            label: 'Altura (cm)',
            controller: controller.heightController,
            focusNode: controller.heightFocusNode,
            hintText: '170',
            keyboardType: TextInputType.number,
            isRequired: true,
          ),

          SizedBox(height: ThemeColor.paddingMedium),

          // Idioma
          _buildLanguageSelector(),

          SizedBox(height: ThemeColor.paddingMedium),

          // Ciudad
          ThemeColor.createLabeledTextField(
            label: 'Ciudad',
            controller: controller.cityController,
            focusNode: controller.cityFocusNode,
            hintText: 'Ciudad de México',
            isRequired: true,
          ),

          SizedBox(height: ThemeColor.paddingMedium),

          // Ubicación
          _buildLocationButton(),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Fecha de nacimiento',
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textDarkColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                color: ThemeColor.errorColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: ThemeColor.paddingSmall),
        Obx(
          () => InkWell(
            onTap: () => _showDatePicker(),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ThemeColor.paddingLarge,
                vertical: ThemeColor.paddingMedium,
              ),
              decoration: BoxDecoration(
                color: ThemeColor.surfaceColor,
                borderRadius: ThemeColor.circularBorderRadius,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.dateOfBirth.value != null
                        ? '${controller.dateOfBirth.value!.day}/${controller.dateOfBirth.value!.month}/${controller.dateOfBirth.value!.year}'
                        : 'Selecciona tu fecha de nacimiento',
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
      ],
    );
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ThemeColor.primaryColor,
              onPrimary: ThemeColor.textLightColor,
              surface: ThemeColor.surfaceColor,
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

  Widget _buildGenderSelector() {
    final genders = ['Masculino', 'Femenino', 'Otro'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Género',
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textDarkColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                color: ThemeColor.errorColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: ThemeColor.paddingSmall),
        Obx(
          () => Wrap(
            spacing: ThemeColor.paddingSmall,
            runSpacing: ThemeColor.paddingSmall,
            children: genders.map((gender) {
              final isSelected = controller.selectedGender.value == gender;
              return InkWell(
                onTap: () => controller.selectGender(gender),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ThemeColor.paddingLarge,
                    vertical: ThemeColor.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? ThemeColor.primaryColor 
                        : ThemeColor.surfaceColor,
                    borderRadius: ThemeColor.circularBorderRadius,
                    border: Border.all(
                      color: isSelected 
                          ? ThemeColor.primaryColor 
                          : ThemeColor.dividerColor,
                    ),
                  ),
                  child: Text(
                    gender,
                    style: ThemeColor.bodyMedium.copyWith(
                      color: isSelected 
                          ? ThemeColor.textLightColor 
                          : ThemeColor.textDarkColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    final languages = ['Español', 'Inglés', 'Francés', 'Otro'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Idioma principal',
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textDarkColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                color: ThemeColor.errorColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: ThemeColor.paddingSmall),
        Obx(
          () => Wrap(
            spacing: ThemeColor.paddingSmall,
            runSpacing: ThemeColor.paddingSmall,
            children: languages.map((language) {
              final isSelected = controller.selectedLanguage.value == language;
              return InkWell(
                onTap: () => controller.selectLanguage(language),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ThemeColor.paddingLarge,
                    vertical: ThemeColor.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? ThemeColor.primaryColor 
                        : ThemeColor.surfaceColor,
                    borderRadius: ThemeColor.circularBorderRadius,
                    border: Border.all(
                      color: isSelected 
                          ? ThemeColor.primaryColor 
                          : ThemeColor.dividerColor,
                    ),
                  ),
                  child: Text(
                    language,
                    style: ThemeColor.bodyMedium.copyWith(
                      color: isSelected 
                          ? ThemeColor.textLightColor 
                          : ThemeColor.textDarkColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Ubicación',
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textDarkColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                color: ThemeColor.errorColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: ThemeColor.paddingSmall),
        Obx(
          () => SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: controller.isLoadingLocation.value 
                  ? null 
                  : controller.requestLocationPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.locationObtained.value
                    ? ThemeColor.successColor
                    : ThemeColor.primaryColor,
                foregroundColor: ThemeColor.textLightColor,
                disabledBackgroundColor: ThemeColor.primaryColor.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: ThemeColor.circularBorderRadius,
                ),
              ),
              icon: controller.isLoadingLocation.value
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ThemeColor.textLightColor,
                        ),
                      ),
                    )
                  : Icon(
                      controller.locationObtained.value
                          ? Icons.check_circle
                          : Icons.location_on,
                    ),
              label: Text(
                controller.locationObtained.value
                    ? 'Ubicación obtenida'
                    : 'Obtener mi ubicación',
                style: ThemeColor.buttonText,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: controller.isLoading.value 
              ? null 
              : controller.onRegisterTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeColor.primaryColor,
            foregroundColor: ThemeColor.textLightColor,
            disabledBackgroundColor: ThemeColor.primaryColor.withOpacity(0.6),
            shape: RoundedRectangleBorder(
              borderRadius: ThemeColor.circularBorderRadius,
            ),
            elevation: ThemeColor.elevationSmall,
            shadowColor: ThemeColor.shadowColor,
          ),
          child: controller.isLoading.value
              ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ThemeColor.textLightColor,
                    ),
                  ),
                )
              : Text(
                  'Crear Cuenta',
                  style: ThemeColor.buttonText.copyWith(
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿Ya tienes cuenta? ',
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
              decoration: TextDecoration.underline,
              decorationColor: ThemeColor.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}