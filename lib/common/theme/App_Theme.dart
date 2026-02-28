import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeColor {
  // Colores principales - Tema de citas (Burdeos/Vino)
  static const Color primaryColor = Color(0xFF4A141E); // Burdeos principal
  static const Color secondaryColor = Color(0xFF8B2C4B); // Burdeos oscuro
  static const Color tertiaryColor = Color(0xFF2E3A44); // Dorado suave

  static const Color accentColor = Color(0xFFB83A5E); // Rosa burdeos claro
  static const Color radarScanner = Color.fromARGB(255, 103, 167, 93); // Burdeos principal

  // Colores de fondo
  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Colors.white; // Superficies blancas
  static const Color cardColor = Colors.white; // Cards blancas
  static final Color backgroundColorfondo = Color(0xFFEFEFEA);

  // Colores de texto
  static const Color textPrimaryColor = Colors.black87; // Texto principal
  static const Color textSecondaryColor = Color(0xFF5F6368); // Texto secundario
  static const Color textTertiaryColor = Color(0xFF656565); // Texto terciario
  static const Color textLightColor = Colors.white; // Texto claro
  static const Color textDarkColor = Colors.black;

  // Colores de estado
  static const Color successColor = Color(0xFF4CAF50); // Verde éxito
  static const Color warningColor = Color(0xFFF7770E); // Naranja advertencia
  static const Color errorColor = Color(0xFFFF3B3B); // Rojo error
  static const Color infoColor = Color(0xFF2196F3); // Azul información
  static const Color onlineColor = Color(0xFF4CAF50); // Verde online
//loading 
static final Color loaddingwithOpacity1 = const Color.fromARGB(255, 200, 200, 200).withOpacity(0.15);
static final Color loaddingwithOpacity3 = const Color.fromARGB(255, 180, 180, 180).withOpacity(0.35);
static final Color loadding = const Color.fromARGB(255, 160, 160, 160);

  // Colores específicos de la app
  static const Color badgeColor = primaryColor; // Color de badges "Tu turno"
  static const Color distanceBadgeColor = primaryColor; // Badge de distancia
  static const Color likeButtonColor = primaryColor; // Botón de like
  static const Color storyGradientStart = Color(
    0xFF8B2C4B,
  ); // Inicio gradiente historia
  static const Color storyGradientEnd = Color(
    0xFF4A1428,
  ); // Fin gradiente historia

  // Colores para navegación
  static const Color navbarSelectedColor = primaryColor;
  static final Color navbarUnselectedColor = Colors.grey.shade600;

  // Utilidades
  static final Color shadowColor = Colors.black.withOpacity(0.1);
  static final Color dividerColor = const Color(0xFFE0E0E0);
  static final Color disabledColor = Colors.grey.shade400;

  // Dimensiones
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 20.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;

  // BorderRadius
  static BorderRadius get smallBorderRadius =>
      BorderRadius.circular(smallRadius);
  static BorderRadius get mediumBorderRadius =>
      BorderRadius.circular(mediumRadius);
  static BorderRadius get largeBorderRadius =>
      BorderRadius.circular(largeRadius);
  static BorderRadius get extraLargeBorderRadius =>
      BorderRadius.circular(extraLargeRadius);
  static BorderRadius get circularBorderRadius => BorderRadius.circular(100);

  // Sombras
  static BoxShadow get lightShadow => BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );

  static BoxShadow get mediumShadow => BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 10,
    offset: const Offset(0, 4),
  );

  static BoxShadow get darkShadow => BoxShadow(
    color: Colors.black.withOpacity(0.15),
    blurRadius: 12,
    offset: const Offset(0, 6),
  );

  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );
  static BoxShadow get storyShadow => BoxShadow(
    color: Colors.black.withOpacity(0.15),
    spreadRadius: 2,
    blurRadius: 8,
    offset: const Offset(0, 4),
  );

  // Gradientes
  static LinearGradient get primaryGradient => LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get storyGradient => LinearGradient(
    colors: [storyGradientStart, storyGradientEnd],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static LinearGradient get storyOverlayGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.black.withOpacity(0.5), Colors.black.withOpacity(0.5)],
  );

  // Decoraciones
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardColor,
    borderRadius: mediumBorderRadius,
    boxShadow: [cardShadow],
  );

  static BoxDecoration get profileCardDecoration => BoxDecoration(
    color: cardColor,
    borderRadius: largeBorderRadius,
    boxShadow: [cardShadow],
  );

  // Estilos de texto
  static TextStyle get headingLarge => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static TextStyle get headingMedium => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static TextStyle get headingSmall => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static TextStyle get subtitleLarge => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static TextStyle get subtitleMedium => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimaryColor,
  );

  static TextStyle get bodyLarge =>
      const TextStyle(fontSize: 16, color: textPrimaryColor);

  static TextStyle get bodyMedium =>
      const TextStyle(fontSize: 14, color: textPrimaryColor);

  static TextStyle get bodySmall =>
      const TextStyle(fontSize: 12, color: textSecondaryColor);

  static TextStyle get caption =>
      const TextStyle(fontSize: 11, color: textSecondaryColor);

  static TextStyle get buttonText => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textLightColor,
  );

  static TextStyle get badgeText => const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textLightColor,
  );

  // Theme Data
  static ThemeData get themeData => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,

    colorScheme: ColorScheme.light(
      primary: primaryColor,
      onPrimary: textLightColor,
      secondary: secondaryColor,
      onSecondary: textLightColor,
      tertiary: accentColor,
      error: errorColor,
      onError: textLightColor,
      background: backgroundColor,
      onBackground: textPrimaryColor,
      surface: surfaceColor,
      onSurface: textPrimaryColor,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor,
      foregroundColor: textPrimaryColor,
      elevation: 0,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
    ),

    cardTheme: CardThemeData(
      color: cardColor,
      elevation: elevationSmall,
      shadowColor: shadowColor,
      shape: RoundedRectangleBorder(borderRadius: mediumBorderRadius),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: textLightColor,
        shape: RoundedRectangleBorder(borderRadius: mediumBorderRadius),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        textStyle: buttonText,
        elevation: elevationSmall,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: mediumBorderRadius,
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: mediumBorderRadius,
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: mediumBorderRadius,
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      labelStyle: const TextStyle(color: textSecondaryColor),
      hintStyle: TextStyle(color: textSecondaryColor.withOpacity(0.7)),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: navbarUnselectedColor,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),

    dividerTheme: DividerThemeData(color: dividerColor, thickness: 1, space: 1),

    iconTheme: const IconThemeData(color: textPrimaryColor, size: 24),
  );

  // ========================================
  // WIDGETS PERSONALIZADOS
  // ========================================
  static Widget createAppLogo({
    String imagePath = 'assets/logo/logo.png',
    double size = 150,
    EdgeInsets padding = const EdgeInsets.symmetric(
      horizontal: 60.0,
      vertical: 70.0,
    ),
  }) {
    return Padding(
      padding: padding,
      child: Center(
        child: ClipOval(
          child: Container(
            child: Center(
              child: Image.asset(imagePath, width: size, height: size),
            ),
          ),
        ),
      ),
    );
  }

  // Badge de "Tu turno"
  static Widget createTurnBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: badgeText),
    );
  }

  // Badge de distancia
  static Widget createDistanceBadge(String distance) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: distanceBadgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(distance, style: badgeText),
    );
  }

  static Widget createStoryRing({
    required Widget child,
    bool hasStory = true,
    bool isViewed = false,
    double size = 80,
    double borderWidth = 2,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasStory && !isViewed ? storyGradient : null,
        border:
            !hasStory || isViewed
                ? Border.all(color: Colors.grey[300]!, width: borderWidth)
                : null,
        boxShadow: [storyShadow],
      ),
      child: Container(
        margin: EdgeInsets.all(hasStory && !isViewed ? 3 : 0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border:
              hasStory && !isViewed
                  ? Border.all(color: Colors.white, width: borderWidth)
                  : null,
        ),
        child: ClipOval(child: child),
      ),
    );
  }


  static Widget widgetButton({
    VoidCallback? onPressed,
    String text = 'AGENDAR CITA',
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
    EdgeInsets? padding,
    double? borderRadius,
    bool showShadow = true,
    List<BoxShadow>? boxShadow,
    Color? borderColor,
    double? borderWidth,
    FontWeight? fontWeight,
    BoxShadow? customShadow,
    bool isLoading = false,
  }) {
    VoidCallback defaultOnPressed = () {
      try {} catch (e) {
        print('Error: StartController no encontrado');
      }
    };

    VoidCallback finalOnPressed =
        onPressed ?? (text == 'AGENDAR CITA' ? defaultOnPressed : () {});

    return MouseRegion(
      // ⬅️ Nuevo
      cursor: SystemMouseCursors.click, // ⬅️ Cambia el cursor al pasar el mouse
      child: GestureDetector(
        onTap: isLoading ? null : finalOnPressed,
        child: Container(
          padding: padding ?? EdgeInsets.symmetric(horizontal: 13, vertical: 2),
          decoration: BoxDecoration(
            color: isLoading
                ? (backgroundColor ?? ThemeColor.secondaryColor).withOpacity(
                    0.7,
                  )
                : (backgroundColor ?? ThemeColor.secondaryColor),
            borderRadius: BorderRadius.circular(borderRadius ?? 5),
            border: borderColor != null
                ? Border.all(color: borderColor, width: borderWidth ?? 1.0)
                : null,
            boxShadow: showShadow ? [customShadow ?? darkShadow] : null,
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: (fontSize ?? 12) + 8,
                    width: (fontSize ?? 12) + 8,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        textColor ?? Colors.white,
                      ),
                    ),
                  )
                : Text(
                    text,
                    style: GoogleFonts.rubik(
                      color: textColor ?? Colors.white,
                      fontSize: fontSize ?? 12,
                      fontWeight: fontWeight ?? FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
      ),
    );
  }

  // Botón circular de acción (like, etc)
  static Widget createCircularActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? backgroundColor,
    Color? iconColor,
    double size = 44,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          shape: BoxShape.circle,
          boxShadow: [lightShadow],
        ),
        child: Icon(icon, color: iconColor ?? primaryColor, size: size * 0.55),
      ),
    );
  }

  // Card de perfil recomendado
  static Widget createRecommendedProfileCard({
    required String imageUrl,
    required String name,
    required int age,
    required VoidCallback onTap,
    required VoidCallback onLike,
    double width = 280,
    double height = 320,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: profileCardDecoration,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: largeBorderRadius,
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: circularBorderRadius,
                    ),
                    child: Text('$name, $age', style: subtitleLarge),
                  ),
                  createCircularActionButton(
                    icon: Icons.favorite,
                    onTap: onLike,
                    iconColor: likeButtonColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card de perfil activo
  static Widget createActiveProfileCard({
    required String imageUrl,
    required String name,
    required int age,
    required String location,
    required double distance,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: cardDecoration,
        child: Row(
          children: [
            CircleAvatar(radius: 40, backgroundImage: NetworkImage(imageUrl)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name, style: subtitleLarge),
                      const SizedBox(width: 8),
                      createDistanceBadge('${distance.toInt()} km'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ubicación: $location',
                    style: bodyMedium.copyWith(color: textSecondaryColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Edad: $age años',
                    style: bodyMedium.copyWith(color: textSecondaryColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Botón de nueva gente
  static Widget createNewPeopleButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: circularBorderRadius,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: textLightColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Item de chat en lista
  static Widget createChatItem({
    required String imageUrl,
    required String name,
    required String lastMessage,
    required bool isYourTurn,
    required VoidCallback onTap,
    bool isOnline = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(imageUrl),
                ),
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: onlineColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: subtitleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isYourTurn) createTurnBadge('Tu turno'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    style: bodyMedium.copyWith(color: textSecondaryColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
static Widget createMainScaffold({
  required Widget body,
  required int currentIndex,
  required Function(int) onNavigationTap,
  required List<String> iconPaths,
  List<String>? labels, // ← nuevo
  Color? backgroundColor,
  Color? bottomNavBackgroundColor,
}) {
  return Scaffold(
    backgroundColor: backgroundColor ?? bottomNavBackgroundColor,
    body: body,
    bottomNavigationBar: createBottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onNavigationTap,
      iconPaths: iconPaths,
      labels: labels, // ← nuevo
      backgroundColor: bottomNavBackgroundColor,
    ),
  );
}

static Widget createBottomNavigationBar({
  required int currentIndex,
  required Function(int) onTap,
  required List<String> iconPaths,
  List<String>? labels, // ← nuevo
  Color? backgroundColor,
  Color? selectedItemColor,
  Color? unselectedItemColor,
}) {
  return Container(
    decoration: BoxDecoration(
      color: backgroundColor ?? Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 0,
          blurRadius: 4,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: SafeArea(
      child: Container(
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(iconPaths.length, (index) {
            final isSelected = currentIndex == index;
            return GestureDetector(
              onTap: () => onTap(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      iconPaths[index],
                      width: 26,
                      height: 26,
                      fit: BoxFit.contain,
                      color: isSelected ? ThemeColor.textPrimaryColor : null,
                    ),
                    if (labels != null && index < labels.length) ...[
                      const SizedBox(height: 4),
                      Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? ThemeColor.textPrimaryColor
                              : ThemeColor.textSecondaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    ),
  );
}

  /// Widget reutilizable para campos de texto con label
  /// Soporta email, password, text normal, etc.
  static Widget createLabeledTextField({
    required String label,
    required TextEditingController controller,
    FocusNode? focusNode,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    void Function(String)? onSubmitted,
    void Function(String)? onChanged,
    bool enabled = true,
    int maxLines = 1,
    String? errorText,
    bool showError = false,
    EdgeInsets? contentPadding,
    Color? fillColor,
    Color? labelColor,
    Color? textColor,
    Color? hintColor,
    Color? borderColor,
    Color? focusedBorderColor,
    BorderRadius? borderRadius,
    TextStyle? labelStyle,
    TextStyle? textStyle,
    TextStyle? hintStyle,
    double? labelSpacing,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Text(
              label,
              style:
                  labelStyle ??
                  bodyMedium.copyWith(
                    color: labelColor ?? textDarkColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  color: errorColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        SizedBox(height: labelSpacing ?? paddingSmall),

        // TextField
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onSubmitted: onSubmitted,
          onChanged: onChanged,
          enabled: enabled,
          maxLines: maxLines,
          style:
              textStyle ??
              bodyMedium.copyWith(color: textColor ?? textDarkColor),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle:
                hintStyle ??
                bodyMedium.copyWith(color: hintColor ?? textSecondaryColor),
            errorText: showError ? errorText : null,
            errorStyle: bodySmall.copyWith(color: errorColor, height: 1.5),
            filled: true,
            fillColor: fillColor ?? surfaceColor,
            contentPadding:
                contentPadding ??
                EdgeInsets.symmetric(
                  horizontal: paddingLarge,
                  vertical: paddingMedium,
                ),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: borderRadius ?? circularBorderRadius,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? circularBorderRadius,
              borderSide: showError
                  ? BorderSide(color: errorColor, width: 1.5)
                  : BorderSide.none,
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? circularBorderRadius,
              borderSide: BorderSide(
                color: (borderColor ?? dividerColor).withOpacity(0.5),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? circularBorderRadius,
              borderSide: BorderSide(
                color: showError
                    ? errorColor
                    : (focusedBorderColor ?? primaryColor),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? circularBorderRadius,
              borderSide: BorderSide(color: errorColor, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? circularBorderRadius,
              borderSide: BorderSide(color: errorColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
