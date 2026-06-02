import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/settings/language_controller.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/purchase/domain/entity/purchase_entity.dart';
import 'package:tendria/features/purchase/presentation/controller/purchase_controller.dart';

class PurchasePage extends StatelessWidget {
  const PurchasePage({super.key});

  LanguageController get _l => Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PurchaseController>();

    return Obx(() => Scaffold(
          backgroundColor: ThemeColor.backgroundColor,
          appBar: AppBar(
            backgroundColor: ThemeColor.cardBackground,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: ThemeColor.iconColor,
                size: 20,
              ),
              onPressed: () => Get.offNamed(RoutesNames.homePage),
            ),
          ),
          body: Obx(() {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (controller.errorMessage.isNotEmpty) {
                _showSnackbar(context, controller.errorMessage.value,
                    isError: true);
                controller.clearMessages();
              }
              if (controller.successMessage.isNotEmpty) {
                _showSnackbar(context, controller.successMessage.value,
                    isError: false);
                controller.clearMessages();
              }
            });

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [ 
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
                  child: Text(
                    _l.t('purchase_title'),
                    style: ThemeColor.headingLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                      color: ThemeColor.textPrimary,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: Text(
                    _l.t('purchase_subtitle'),
                    style: ThemeColor.bodyMedium.copyWith(
                      color: ThemeColor.textSecondary,
                    ),
                  ),
                ),
 
                if (controller.isLoadingProducts.value)
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: ThemeColor.primaryColor,
                      ),
                    ),
                  )
                else if (controller.products.isEmpty)
                  Expanded(child: _buildEmptyState(controller))
                else
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.4,
                        ),
                        itemCount: controller.products.length,
                        itemBuilder: (_, index) {
                          final product = controller.products[index];
                          return _buildProductTile(controller, product);
                        },
                      ),
                    ),
                  ),

                const SizedBox(height: 8),
 
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: Text(
                    _l.t('purchase_payment_method'),
                    style: ThemeColor.bodyMedium.copyWith(
                      color: ThemeColor.textPrimary,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildPlatformBadge(),
                ),
 
                if (Platform.isAndroid) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildCouponField(controller),
                  ),
                ],

                const SizedBox(height: 20),
 
               SafeArea(
  top: false,  
  child:  Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Obx(() {
                    final isPurchasing = controller.isPurchasing.value;
                    final hasSelection =
                        controller.selectedProductId.value.isNotEmpty;

                    return SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: (isPurchasing || !hasSelection)
                            ? null
                            : () {
                                final product =
                                    controller.products.firstWhere(
                                  (p) =>
                                      p.productId ==
                                      controller.selectedProductId.value,
                                );
                                controller.buyProduct(product);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeColor.primaryColor,
                          disabledBackgroundColor:
                              ThemeColor.primaryColor.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: isPurchasing
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _l.t('purchase_buy_btn'),
                                style: ThemeColor.buttonText.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    );
                  }),
                ),
                ),
              ],
            );
          }),
        ));
  }
 
  Widget _buildProductTile(
      PurchaseController controller, PurchaseEntity product) {
    return Obx(() {
      final isSelected =
          controller.selectedProductId.value == product.productId;
      final priceLabel = controller.displayPrice(product);

      return GestureDetector(
        onTap: controller.isPurchasing.value
            ? null
            : () => controller.selectedProductId.value = product.productId,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isSelected
                ? ThemeColor.primaryColor.withOpacity(0.08)
                : ThemeColor.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? ThemeColor.primaryColor
                  : ThemeColor.dividerColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  priceLabel,
                  style: ThemeColor.subtitleLarge.copyWith(
                    color: isSelected
                        ? ThemeColor.primaryColor
                        : ThemeColor.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                ),
                if (product.credits != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt_rounded,
                          color: Colors.amber, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        '${product.credits} ${_l.t('purchase_credits')}',
                        style: ThemeColor.caption.copyWith(
                          color: ThemeColor.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
 
  Widget _buildPlatformBadge() {
    final isIOS = Platform.isIOS;
    return _PaymentChip(
      icon: isIOS ? Icons.apple : Icons.android,
      label: isIOS ? _l.t('purchase_appstore') : _l.t('purchase_googleplay'),
      selected: true,
    );
  }
 
  Widget _buildCouponField(PurchaseController controller) {
    return Obx(() {
      final hasCoupon = controller.couponCode.value.trim().isNotEmpty;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              _l.t('purchase_coupon_label'),
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textPrimary,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.couponController,
                  onChanged: (val) => controller.couponCode.value = val,
                  textCapitalization: TextCapitalization.characters,
                  style: ThemeColor.bodyMedium.copyWith(
                    color: ThemeColor.textPrimary,
                    letterSpacing: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: _l.t('purchase_coupon_hint'),
                    hintStyle: ThemeColor.bodyMedium.copyWith(
                      color: ThemeColor.textSecondaryColor,
                      letterSpacing: 0,
                    ),
                    filled: true,
                    fillColor: ThemeColor.cardBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.local_offer_outlined,
                      color: hasCoupon
                          ? ThemeColor.primaryColor
                          : ThemeColor.textSecondary,
                      size: 20,
                    ),
                    suffixIcon: hasCoupon
                        ? IconButton(
                            icon: Icon(
                              Icons.close,
                              color: ThemeColor.textSecondary,
                              size: 18,
                            ),
                            onPressed: controller.clearCoupon,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: ThemeColor.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: hasCoupon
                            ? ThemeColor.primaryColor.withOpacity(0.5)
                            : ThemeColor.dividerColor,
                        width: hasCoupon ? 1.5 : 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: ThemeColor.primaryColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              if (hasCoupon) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ThemeColor.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ThemeColor.successColor.withOpacity(0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: ThemeColor.successColor,
                    size: 22,
                  ),
                ),
              ],
            ],
          ),
          if (hasCoupon)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                _l.t('purchase_coupon_applied'),
                style: ThemeColor.caption.copyWith(
                  color: ThemeColor.successColor,
                ),
              ),
            ),
        ],
      );
    });
  }
 
  Widget _buildEmptyState(PurchaseController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined,
              size: 64, color: ThemeColor.disabledColor),
          const SizedBox(height: ThemeColor.paddingMedium),
          Text(
            _l.t('purchase_empty_title'),
            style: ThemeColor.subtitleMedium.copyWith(
              color: ThemeColor.textSecondary,
            ),
          ),
          const SizedBox(height: ThemeColor.paddingLarge),
          ThemeColor.widgetButton(
            text: _l.t('purchase_retry'),
            onPressed: controller.loadProducts,
            backgroundColor: ThemeColor.primaryColor,
            textColor: ThemeColor.textLightColor,
            fontSize: 14,
            borderRadius: ThemeColor.largeRadius,
          ),
        ],
      ),
    );
  }
 
  void _showSnackbar(BuildContext context, String message,
      {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: ThemeColor.bodyMedium
              .copyWith(color: ThemeColor.textLightColor),
        ),
        backgroundColor:
            isError ? ThemeColor.errorColor : ThemeColor.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: ThemeColor.mediumBorderRadius),
        margin: const EdgeInsets.all(ThemeColor.paddingMedium),
      ),
    );
  }
}
 
class _PaymentChip extends StatelessWidget {
  const _PaymentChip({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? ThemeColor.primaryColor.withOpacity(0.08)
                : ThemeColor.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? ThemeColor.primaryColor
                  : ThemeColor.dividerColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: ThemeColor.iconColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: ThemeColor.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ThemeColor.textPrimary,
                ),
              ),
            ],
          ),
        ));
  }
}