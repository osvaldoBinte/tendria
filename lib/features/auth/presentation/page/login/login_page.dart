import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/auth/presentation/page/login/login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: ThemeColor.paddingLarge,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(),
                SizedBox(height: ThemeColor.paddingExtraLarge * 2),
                _buildLoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
Widget _buildHeader() {
  return Column(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/logo/logo.png',
          width: 120,
          height: 120,
          cacheWidth: 240,
          cacheHeight: 240,
          filterQuality: FilterQuality.medium,
          // ✅ Manejo de error
          errorBuilder: (context, error, stackTrace) {
            print('❌ Error cargando logo: $error');
            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: ThemeColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.image_not_supported,
                size: 50,
                color: ThemeColor.primaryColor,
              ),
            );
          },
        ),
      ),
       SizedBox(height: ThemeColor.paddingLarge),
        Text(
          'Iniciar Sesión',
          style: ThemeColor.headingLarge.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: ThemeColor.textDarkColor,
          ),
        ),
        SizedBox(height: ThemeColor.paddingSmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¿Aún no tienes una cuenta? ',
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textSecondaryColor,
              ),
            ),
            GestureDetector(
              onTap: controller.onRegisterTap,
              child: Text(
                'Registrarse',
                style: ThemeColor.bodyMedium.copyWith(
                  color: ThemeColor.primaryColor,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: ThemeColor.primaryColor,
                ),
              ),
            ),
          ],
        ),
    ],
  );
}

  Widget _buildLoginForm() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThemeColor.createLabeledTextField(
            label: 'Correo electrónico:',
            controller: controller.emailController,
            focusNode: controller.emailFocusNode,
            hintText: 'correo@gmail.com',
            keyboardType: TextInputType.emailAddress,
            onSubmitted: (_) => controller.onemailSubmitted(),
          ),
          
          SizedBox(height: ThemeColor.paddingLarge),
          
          Obx(
            () => ThemeColor.createLabeledTextField(
              label: 'Contraseña:',
              controller: controller.passwordController,
              focusNode: controller.passwordFocusNode,
              hintText: '••••••••••',
              obscureText: !controller.showPassword.value,
              onSubmitted: (_) => controller.onPasswordSubmitted(),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.showPassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: ThemeColor.textSecondaryColor,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
            ),
          ),
          
          SizedBox(height: ThemeColor.paddingMedium),
          _buildRememberMeCheckbox(),
          SizedBox(height: ThemeColor.paddingExtraLarge),
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Row(
      children: [
        Text(
          'Recuérdame',
          style: ThemeColor.bodyMedium.copyWith(
            color: ThemeColor.textSecondaryColor,
          ),
        ),
        SizedBox(width: ThemeColor.paddingSmall),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: ThemeColor.primaryColor,
            borderRadius: ThemeColor.smallBorderRadius,
          ),
          child: Icon(
            Icons.check,
            color: ThemeColor.textLightColor,
            size: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.onLoginTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeColor.tertiaryColor,
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
                  'Iniciar Sesión',
                  style: ThemeColor.buttonText.copyWith(
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}