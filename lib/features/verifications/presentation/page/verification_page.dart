import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tendria/common/settings/language_controller.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/user/presentation/controller/profile_controller.dart';
import 'package:tendria/features/verifications/domain/entities/get_verification_entity.dart';
import 'package:tendria/features/verifications/presentation/controller/verification_controller.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage>
    with SingleTickerProviderStateMixin {
  final VerificationController controller = Get.find<VerificationController>();
  final ProfileController profileController = Get.find<ProfileController>();
  final LanguageController _l = Get.find<LanguageController>();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _socialNetworks = [
    {'id': 'instagram', 'label': 'Instagram', 'icon': Icons.camera_alt},
    {'id': 'facebook', 'label': 'Facebook', 'icon': Icons.facebook},
    {'id': 'twitter', 'label': 'Twitter / X', 'icon': Icons.alternate_email},
    {'id': 'tiktok', 'label': 'TikTok', 'icon': Icons.music_video},
    {'id': 'linkedin', 'label': 'LinkedIn', 'icon': Icons.work},
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.backgroundColorfondo,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Obx(() {
          if (controller.isLoadingVerifications.value) {
            return Center(
              child: CircularProgressIndicator(color: ThemeColor.primaryColor),
            );
          }
          return RefreshIndicator(
            color: ThemeColor.primaryColor,
            onRefresh: controller.loadVerifications,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(ThemeColor.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: ThemeColor.paddingLarge),
                  _buildVerificationCard(
                    tipo: 'selfie',
                    icon: Icons.face,
                    title: _l.t('verify_selfie_title'),
                    subtitle: _l.t('verify_selfie_subtitle'),
                    onTap: _showSelfieSheet,
                  ),
                  const SizedBox(height: ThemeColor.paddingMedium),
                  _buildVerificationCard(
                    tipo: 'telefono',
                    icon: Icons.phone,
                    title: _l.t('verify_phone_title'),
                    subtitle: _l.t('verify_phone_subtitle'),
                    onTap: _showPhoneSheet,
                  ),
                  const SizedBox(height: ThemeColor.paddingMedium),
                  _buildVerificationCard(
                    tipo: 'red_social',
                    icon: Icons.share,
                    title: _l.t('verify_social_title'),
                    subtitle: _l.t('verify_social_subtitle'),
                    onTap: _showSocialSheet,
                  ),
                  const SizedBox(height: ThemeColor.paddingLarge),
                  _buildBenefitsSection(),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: ThemeColor.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: ThemeColor.iconColor, size: 20),
        onPressed: () => Get.back(),
      ),
      title: Text(
        _l.t('verify_title'),
        style: ThemeColor.headingSmall.copyWith(color: ThemeColor.textPrimary),
      ),
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  Widget _buildHeader() {
    return Obx(() {
      final verified = controller.verifiedCount;
      const total = 3;
      return Container(
        padding: const EdgeInsets.all(ThemeColor.paddingLarge),
        decoration: BoxDecoration(
          gradient: ThemeColor.primaryGradient,
          borderRadius: ThemeColor.extraLargeBorderRadius,
          boxShadow: [ThemeColor.darkShadow],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _l.t('verify_profile_verified'),
                    style: ThemeColor.headingSmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _l.t('verify_profile_desc'),
                    style: ThemeColor.bodySmall.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: ThemeColor.paddingMedium),
                  ClipRRect(
                    borderRadius: ThemeColor.circularBorderRadius,
                    child: LinearProgressIndicator(
                      value: verified / total,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$verified ${_l.t('verify_completed')}',
                    style: ThemeColor.caption.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(width: ThemeColor.paddingMedium),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$verified/$total',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildVerificationCard({
    required String tipo,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Obx(() {
      final verified = controller.isVerified(tipo);
      final pending = controller.isPending(tipo);
      final verification = controller.getVerification(tipo);

      final Color statusColor;
      final String statusLabel;
      final IconData statusIcon;

      if (verified) {
        statusColor = ThemeColor.successColor;
        statusLabel = _l.t('verify_status_verified');
        statusIcon = Icons.check_circle;
      } else if (pending) {
        statusColor = ThemeColor.warningColor;
        statusLabel = _l.t('verify_status_pending');
        statusIcon = Icons.hourglass_top;
      } else {
        statusColor = ThemeColor.textSecondaryColor;
        statusLabel = _l.t('verify_status_none');
        statusIcon = Icons.radio_button_unchecked;
      }

      return GestureDetector(
        onTap: (verified || pending) ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(ThemeColor.paddingMedium),
          decoration: BoxDecoration(
            color: ThemeColor.cardBackground,
            borderRadius: ThemeColor.largeBorderRadius,
            border: Border.all(
              color: verified
                  ? ThemeColor.successColor.withOpacity(0.3)
                  : pending
                  ? ThemeColor.warningColor.withOpacity(0.3)
                  : ThemeColor.subtleBorder,
              width: verified || pending ? 1.5 : 1,
            ),
            boxShadow: [ThemeColor.lightShadow],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: verified
                      ? ThemeColor.successColor.withOpacity(0.1)
                      : pending
                      ? ThemeColor.warningColor.withOpacity(0.1)
                      : ThemeColor.primaryColor.withOpacity(0.08),
                  borderRadius: ThemeColor.mediumBorderRadius,
                ),
                child: Icon(
                  icon,
                  color: verified
                      ? ThemeColor.successColor
                      : pending
                      ? ThemeColor.warningColor
                      : ThemeColor.primaryColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: ThemeColor.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: ThemeColor.subtitleMedium.copyWith(
                        color: ThemeColor.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _subtitleFromVerification(tipo, verification) ?? subtitle,
                      style: ThemeColor.bodySmall.copyWith(
                        color: ThemeColor.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ThemeColor.paddingSmall),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(statusIcon, color: statusColor, size: 22),
                  const SizedBox(height: 4),
                  Text(
                    statusLabel,
                    style: ThemeColor.caption.copyWith(color: statusColor),
                  ),
                ],
              ),
              if (!verified && !pending) ...[
                const SizedBox(width: ThemeColor.paddingSmall),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: ThemeColor.textSecondary,
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  String? _subtitleFromVerification(String tipo, GetVerificationEntity? v) {
    if (v == null) return null;
    switch (tipo) {
      case 'telefono':
        final n = v.phone?.numero;
        final p = v.phone?.pais;
        if (n != null) return '$n · $p';
      case 'red_social':
        final red = v.social?.red ?? '';
        final user = v.social?.username ?? '';
        if (user.isNotEmpty) {
          return '${red[0].toUpperCase()}${red.substring(1)} · @$user';
        }
      case 'selfie':
        return _l.t('verify_selfie_sent');
    }
    return null;
  }

  Widget _buildBenefitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _l.t('verify_benefits_title'),
          style: ThemeColor.subtitleMedium.copyWith(
            color: ThemeColor.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: ThemeColor.paddingMedium),
        _buildBenefitRow(
          Icons.favorite,
          _l.t('verify_benefit1_title'),
          _l.t('verify_benefit1_desc'),
        ),
        _buildBenefitRow(
          Icons.shield,
          _l.t('verify_benefit2_title'),
          _l.t('verify_benefit2_desc'),
        ),
        _buildBenefitRow(
          Icons.star,
          _l.t('verify_benefit3_title'),
          _l.t('verify_benefit3_desc'),
        ),
      ],
    );
  }

  Widget _buildBenefitRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ThemeColor.paddingMedium),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ThemeColor.primaryColor.withOpacity(0.08),
              borderRadius: ThemeColor.smallBorderRadius,
            ),
            child: Icon(icon, color: ThemeColor.primaryColor, size: 20),
          ),
          const SizedBox(width: ThemeColor.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ThemeColor.bodyMedium.copyWith(
                    color: ThemeColor.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: ThemeColor.bodySmall.copyWith(
                    color: ThemeColor.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPhoneSheet() {
    controller.clearPhoneForm(userCity: profileController.city);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SheetWrapper(
        title: _l.t('verify_phone_sheet_title'),
        icon: Icons.phone,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _l.t('verify_phone_country_label'),
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: ThemeColor.paddingSmall),
            Obx(() {
              final selected = controller.selectedCountry.value;
              return GestureDetector(
                onTap: _showCountryPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeColor.paddingLarge,
                    vertical: ThemeColor.paddingMedium,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeColor.surfaceColor,
                    borderRadius: ThemeColor.circularBorderRadius,
                  ),
                  child: Row(
                    children: [
                      if (controller.selectedCountryFlag.value.isNotEmpty) ...[
                        Text(
                          controller.selectedCountryFlag.value,
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          controller.selectedDialCode.value,
                          style: ThemeColor.bodyMedium.copyWith(
                            color: ThemeColor.tertiaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          selected,
                          style: ThemeColor.bodyMedium.copyWith(
                            color: ThemeColor.tertiaryColor,
                          ),
                        ),
                      ] else
                        Text(
                          _l.t('verify_phone_country_hint'),
                          style: ThemeColor.bodyMedium.copyWith(
                            color: ThemeColor.textSecondaryColor,
                          ),
                        ),
                      const Spacer(),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: ThemeColor.textSecondary,
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: ThemeColor.paddingMedium),
            Text(
              _l.t('verify_phone_number_label'),
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: ThemeColor.paddingSmall),
            Obx(() {
              final dialCode = controller.selectedDialCode.value;
              return TextField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                style: ThemeColor.bodyMedium.copyWith(
                  color: ThemeColor.textDarkColor,
                ),
                decoration: InputDecoration(
                  hintText: _l.t('verify_phone_number_hint'),
                  hintStyle: ThemeColor.bodyMedium.copyWith(
                    color: ThemeColor.textSecondaryColor,
                  ),
                  filled: true,
                  fillColor: ThemeColor.surfaceColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: ThemeColor.paddingLarge,
                    vertical: ThemeColor.paddingMedium,
                  ),
                  prefixIcon: dialCode.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          child: Text(
                            dialCode,
                            style: ThemeColor.bodyMedium.copyWith(
                              color: ThemeColor.tertiaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: ThemeColor.circularBorderRadius,
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: ThemeColor.circularBorderRadius,
                    borderSide: BorderSide(
                      color: ThemeColor.toggleBackground,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: ThemeColor.circularBorderRadius,
                    borderSide: BorderSide(
                      color: ThemeColor.primaryColor,
                      width: 1.5,
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: ThemeColor.paddingLarge),
            Obx(
              () => ThemeColor.widgetButton(
                text: _l.t('verify_send_btn'),
                isLoading: controller.isSubmittingPhone.value,
                onPressed: controller.submitPhone,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                fontSize: 15,
                borderRadius: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCountryPicker() {
    final searchController = TextEditingController();
    final RxList<Map<String, String>> filtered = RxList.from(
      VerificationController.countries,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: ThemeColor.backgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(ThemeColor.extraLargeRadius),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: ThemeColor.paddingMedium),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ThemeColor.dividerColor,
                borderRadius: ThemeColor.circularBorderRadius,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(ThemeColor.paddingLarge),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _l.t('verify_country_picker_title'),
                      style: ThemeColor.headingSmall.copyWith(
                        color: ThemeColor.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: ThemeColor.textSecondary),
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeColor.paddingLarge,
              ),
              child: TextField(
                controller: searchController,
                onChanged: (val) {
                  final q = val.toLowerCase();
                  filtered.assignAll(
                    VerificationController.countries.where(
                      (c) => c['name']!.toLowerCase().contains(q),
                    ),
                  );
                },
                style: ThemeColor.bodyMedium.copyWith(
                  color: ThemeColor.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: _l.t('verify_country_search_hint'),
                  hintStyle: ThemeColor.bodyMedium.copyWith(
                    color: ThemeColor.textSecondaryColor,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: ThemeColor.textSecondary,
                  ),
                  filled: true,
                  fillColor: ThemeColor.subtleBackground,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: ThemeColor.paddingMedium,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: ThemeColor.mediumBorderRadius,
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: ThemeColor.mediumBorderRadius,
                    borderSide: BorderSide(
                      color: ThemeColor.toggleBackground,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: ThemeColor.mediumBorderRadius,
                    borderSide: BorderSide(
                      color: ThemeColor.primaryColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: ThemeColor.paddingMedium),
            Divider(color: ThemeColor.dividerColor, height: 1),
            Expanded(
              child: Obx(
                () => ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    vertical: ThemeColor.paddingSmall,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: ThemeColor.dividerColor, height: 1),
                  itemBuilder: (_, i) {
                    final country = filtered[i];
                    final isSelected =
                        controller.selectedCountry.value == country['name'];
                    return ListTile(
                      onTap: () {
                        controller.selectCountry(country);
                        Get.back();
                      },
                      leading: Text(
                        country['flag']!,
                        style: const TextStyle(fontSize: 26),
                      ),
                      title: Text(
                        country['name']!,
                        style: ThemeColor.bodyMedium.copyWith(
                          color: ThemeColor.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: Text(
                        country['code']!,
                        style: ThemeColor.bodyMedium.copyWith(
                          color: ThemeColor.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      tileColor: isSelected
                          ? ThemeColor.primaryColor.withOpacity(0.06)
                          : null,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSocialSheet() {
    controller.clearSocialForm();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SheetWrapper(
        title: _l.t('verify_social_sheet_title'),
        icon: Icons.share,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _l.t('verify_social_network_label'),
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: ThemeColor.paddingSmall),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _socialNetworks.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final n = _socialNetworks[i];
                  return Obx(() {
                    final selected =
                        n['id'] == controller.selectedSocialNetwork.value;
                    return GestureDetector(
                      onTap: () => controller.onSocialNetworkChanged(n['id']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? ThemeColor.primaryColor
                              : ThemeColor.subtleBackground,
                          borderRadius: ThemeColor.circularBorderRadius,
                          border: Border.all(
                            color: selected
                                ? ThemeColor.primaryColor
                                : ThemeColor.subtleBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              n['icon'] as IconData,
                              size: 16,
                              color: selected
                                  ? Colors.white
                                  : ThemeColor.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              n['label'],
                              style: ThemeColor.bodySmall.copyWith(
                                color: selected
                                    ? Colors.white
                                    : ThemeColor.textSecondary,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            const SizedBox(height: ThemeColor.paddingMedium),
            ThemeColor.createLabeledTextField(
              label: _l.t('verify_username_label'),
              controller: controller.usernameController,
              hintText: _l.t('verify_username_hint'),
              isRequired: true,
              onChanged: controller.onUsernameChanged,
            ),
            const SizedBox(height: ThemeColor.paddingMedium),
            Obx(() {
              final url = controller.generatedSocialUrl.value;
              if (url.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _l.t('verify_url_generated'),
                    style: ThemeColor.bodySmall.copyWith(
                      color: ThemeColor.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeColor.paddingMedium,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeColor.subtleBackground,
                      borderRadius: ThemeColor.mediumBorderRadius,
                      border: Border.all(color: ThemeColor.subtleBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.link,
                          size: 16,
                          color: ThemeColor.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            url,
                            style: ThemeColor.bodySmall.copyWith(
                              color: ThemeColor.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: controller.openSocialProfile,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: ThemeColor.primaryColor,
                              borderRadius: ThemeColor.circularBorderRadius,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.open_in_new,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _l.t('verify_view_profile'),
                                  style: ThemeColor.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: ThemeColor.paddingSmall),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 13,
                        color: ThemeColor.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _l.t('verify_view_profile_hint'),
                          style: ThemeColor.caption.copyWith(
                            color: ThemeColor.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
            const SizedBox(height: ThemeColor.paddingLarge),
            Obx(
              () => ThemeColor.widgetButton(
                text: _l.t('verify_send_btn'),
                isLoading: controller.isSubmittingSocial.value,
                onPressed: controller.submitSocial,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                fontSize: 15,
                borderRadius: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSelfieSheet() {
    controller.clearSelfie();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SheetWrapper(
        title: _l.t('verify_selfie_sheet_title'),
        icon: Icons.face,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _l.t('verify_profile_photo_label'),
                        style: ThemeColor.caption.copyWith(
                          color: ThemeColor.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        final url = profileController.profilePhotoUrl;
                        final isUploading =
                            profileController.isUploadingProfilePhoto.value;

                        return GestureDetector(
                          onTap: (url.isEmpty && !isUploading)
                              ? () async {
                                  await profileController
                                      .pickProfilePhotoFromGallery();
                                }
                              : null,
                          child: Container(
                            height: 130,
                            decoration: BoxDecoration(
                              color: ThemeColor.subtleBackground,
                              borderRadius: ThemeColor.largeBorderRadius,
                              border: Border.all(
                                color: url.isEmpty
                                    ? ThemeColor.primaryColor.withOpacity(0.4)
                                    : ThemeColor.subtleBorder,
                                width: url.isEmpty ? 1.5 : 1,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: isUploading 
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 32,
                                        height: 32,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: ThemeColor.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _l.t('loading'),
                                        style: ThemeColor.caption.copyWith(
                                          color: ThemeColor.textSecondary,
                                        ),
                                      ),
                                    ],
                                  )
                                : url.isNotEmpty 
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        url,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: profileController
                                              .pickProfilePhotoFromGallery,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 6,
                                            ),
                                            color: Colors.black45,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.edit,
                                                  color: Colors.white,
                                                  size: 12,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _l.t('verify_change_photo'),
                                                  style: ThemeColor.caption
                                                      .copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ) 
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo,
                                        size: 32,
                                        color: ThemeColor.primaryColor,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _l.t('verify_add_photo'),
                                        style: ThemeColor.caption.copyWith(
                                          color: ThemeColor.primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _l.t('verify_photo_required'),
                                        style: ThemeColor.caption.copyWith(
                                          color: ThemeColor.textSecondary,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.compare_arrows,
                  color: ThemeColor.primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _l.t('verify_selfie_label'),
                        style: ThemeColor.caption.copyWith(
                          color: ThemeColor.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        final file = controller.selfieFile.value;
                        return GestureDetector(
                          onTap: controller.pickSelfie,
                          child: Container(
                            height: 130,
                            decoration: BoxDecoration(
                              color: ThemeColor.subtleBackground,
                              borderRadius: ThemeColor.largeBorderRadius,
                              border: Border.all(
                                color: file != null
                                    ? ThemeColor.primaryColor
                                    : ThemeColor.subtleBorder,
                                width: file != null ? 2 : 1,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: file != null
                                ? Image.file(file, fit: BoxFit.cover)
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        size: 36,
                                        color: ThemeColor.primaryColor,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _l.t('verify_take_selfie'),
                                        style: ThemeColor.caption.copyWith(
                                          color: ThemeColor.primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: ThemeColor.paddingSmall),
            Obx(() {
              if (controller.selfieFile.value == null) {
                return const SizedBox.shrink();
              }
              return TextButton.icon(
                onPressed: controller.pickSelfie,
                icon: Icon(Icons.refresh, color: ThemeColor.primaryColor),
                label: Text(
                  _l.t('verify_retake'),
                  style: TextStyle(color: ThemeColor.primaryColor),
                ),
              );
            }),
            const SizedBox(height: ThemeColor.paddingSmall),
            Container(
              padding: const EdgeInsets.all(ThemeColor.paddingMedium),
              decoration: BoxDecoration(
                color: ThemeColor.infoColor.withOpacity(0.08),
                borderRadius: ThemeColor.mediumBorderRadius,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: ThemeColor.infoColor,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _l.t('verify_selfie_info'),
                      style: ThemeColor.caption.copyWith(
                        color: ThemeColor.infoColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ThemeColor.paddingLarge),
            Obx(
              () => ThemeColor.widgetButton(
                text: _l.t('verify_send_selfie'),
                isLoading: controller.isSubmittingSelfie.value,
                onPressed: () =>
                    controller.submitSelfie(profileController.profilePhotoUrl),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                fontSize: 15,
                borderRadius: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetWrapper extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SheetWrapper({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: ThemeColor.backgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ThemeColor.extraLargeRadius),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ThemeColor.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ThemeColor.dividerColor,
                    borderRadius: ThemeColor.circularBorderRadius,
                  ),
                ),
              ),
              const SizedBox(height: ThemeColor.paddingMedium),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ThemeColor.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: ThemeColor.primaryColor, size: 22),
                  ),
                  const SizedBox(width: ThemeColor.paddingMedium),
                  Expanded(
                    child: Text(
                      title,
                      style: ThemeColor.headingSmall.copyWith(
                        color: ThemeColor.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: ThemeColor.textSecondary),
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: ThemeColor.paddingLarge),
              Divider(color: ThemeColor.dividerColor, height: 1),
              const SizedBox(height: ThemeColor.paddingLarge),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
