import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/purchase/domain/entity/purchase_entity.dart';
import 'package:tendria/features/purchase/presentation/controller/purchase_controller.dart';

class PurchasePage extends StatelessWidget {
  const PurchasePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PurchaseController>();

    return Scaffold(
      backgroundColor: ThemeColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: ThemeColor.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: ThemeColor.textPrimaryColor,
            size: 20,
          ),
          onPressed: () => Get.offNamed(RoutesNames.homePage),
        ),
      ),
      body: Obx(() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (controller.errorMessage.isNotEmpty) {
            _showSnackbar(context, controller.errorMessage.value, isError: true);
            controller.clearMessages();
          }
          if (controller.successMessage.isNotEmpty) {
            _showSnackbar(context, controller.successMessage.value, isError: false);
            controller.clearMessages();
          }
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Título ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
              child: Text(
                'Adquirir Créditos',
                style: ThemeColor.headingLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Text(
                'Agrega créditos a tu cuenta y desbloquea más conexiones.',
                style: ThemeColor.bodyMedium.copyWith(
                  color: ThemeColor.textSecondaryColor,
                ),
              ),
            ),

            // ── Contenido principal ──────────────────────────────────
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

            // ── Método de pago ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Text(
                'Método de pago:',
                style: ThemeColor.bodyMedium.copyWith(
                  color: ThemeColor.textPrimaryColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildPlatformBadge(),
            ),

            const SizedBox(height: 20),

            // ── Botón comprar ────────────────────────────────────────
            Padding(
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
                            final product = controller.products.firstWhere(
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
                            'Comprar',
                            style: ThemeColor.buttonText.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                );
              }),
            ),
          ],
        );
      }),
    );
  }

  // ── Tile de producto ────────────────────────────────────────────────────
  Widget _buildProductTile(
      PurchaseController controller, PurchaseEntity product) {
    return Obx(() {
      final isSelected =
          controller.selectedProductId.value == product.productId;

      // displayPrice() devuelve precio real de la tienda si se conectó,
      // o product.price del backend como fallback.
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
                : ThemeColor.surfaceColor,
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
                        : ThemeColor.textPrimaryColor,
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
                        '${product.credits} créditos',
                        style: ThemeColor.caption.copyWith(
                          color: ThemeColor.textSecondaryColor,
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

  // ── Badge plataforma ────────────────────────────────────────────────────
  Widget _buildPlatformBadge() {
    final isIOS = Platform.isIOS;
    return _PaymentChip(
      icon: isIOS ? Icons.apple : Icons.android,
      label: isIOS ? 'App Store' : 'Google Play',
      selected: true,
    );
  }

  // ── Empty state ─────────────────────────────────────────────────────────
  Widget _buildEmptyState(PurchaseController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined,
              size: 64, color: ThemeColor.disabledColor),
          const SizedBox(height: ThemeColor.paddingMedium),
          Text(
            'Sin productos disponibles',
            style: ThemeColor.subtitleMedium
                .copyWith(color: ThemeColor.textSecondaryColor),
          ),
          const SizedBox(height: ThemeColor.paddingLarge),
          ThemeColor.widgetButton(
            text: 'Reintentar',
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

  // ── Snackbar ────────────────────────────────────────────────────────────
  void _showSnackbar(BuildContext context, String message,
      {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style:
              ThemeColor.bodyMedium.copyWith(color: ThemeColor.textLightColor),
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

// ── Chip de método de pago ──────────────────────────────────────────────────
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: selected
            ? ThemeColor.primaryColor.withOpacity(0.08)
            : ThemeColor.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? ThemeColor.primaryColor : ThemeColor.dividerColor,
          width: selected ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: ThemeColor.textPrimaryColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: ThemeColor.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: ThemeColor.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}