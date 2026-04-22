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
        backgroundColor: ThemeColor.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: ThemeColor.textPrimaryColor,
            size: 20,
          ),
          onPressed: () => Get.offNamed(RoutesNames.homePage)
        ),
        title: Text('Adquirir Créditos', style: ThemeColor.headingSmall),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Obx(() { 
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (controller.errorMessage.isNotEmpty) {
                  _showSnackbar(
                    context,
                    controller.errorMessage.value,
                    isError: true,
                  );
                  controller.clearMessages();
                }
                if (controller.successMessage.isNotEmpty) {
                  _showSnackbar(
                    context,
                    controller.successMessage.value,
                    isError: false,
                  );
                  controller.clearMessages();
                }
              });

              if (controller.isLoadingProducts.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: ThemeColor.primaryColor,
                  ),
                );
              }

              if (controller.products.isEmpty) {
                return _buildEmptyState(controller);
              }

              return _buildProductList(controller);
            }),
          ),
          _buildPlatformBadge(),
        ],
      ),
    );
  }
 
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeColor.paddingLarge,
        vertical: ThemeColor.paddingLarge,
      ),
      decoration: BoxDecoration(
        color: ThemeColor.primaryColor,
        boxShadow: [ThemeColor.darkShadow],
      ),
      child: Column(
        children: [
          const Icon(Icons.bolt_rounded, color: Colors.amber, size: 40),
          const SizedBox(height: 8),
          Text(
            'Potencia tu experiencia',
            style: ThemeColor.headingMedium.copyWith(
              color: ThemeColor.textLightColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Selecciona el paquete de créditos que más te convenga',
            style: ThemeColor.bodyMedium.copyWith(
              color: ThemeColor.textLightColor.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
 
  Widget _buildProductList(PurchaseController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(ThemeColor.paddingLarge),
      itemCount: controller.products.length,
      itemBuilder: (_, index) {
        final product = controller.products[index];
        return _buildProductCard(controller, product);
      },
    );
  }
 
  Widget _buildProductCard(
    PurchaseController controller,
    PurchaseEntity product,
  ) {
    return Obx(() {
      final isSelected =
          controller.selectedProductId.value == product.productId;
      final isPurchasing = controller.isPurchasing.value && isSelected;

      return GestureDetector(
        onTap: controller.isPurchasing.value
            ? null
            : () => controller.buyProduct(product),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: ThemeColor.paddingMedium),
          padding: const EdgeInsets.all(ThemeColor.paddingMedium),
          decoration: BoxDecoration(
            color: isSelected
                ? ThemeColor.primaryColor
                : ThemeColor.surfaceColor,
            borderRadius: ThemeColor.largeBorderRadius,
            border: Border.all(
              color: isSelected
                  ? ThemeColor.accentColor
                  : ThemeColor.dividerColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              isSelected ? ThemeColor.darkShadow : ThemeColor.lightShadow,
            ],
          ),
          child: Row(
            children: [ 
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.amber.withOpacity(0.2)
                      : ThemeColor.primaryColor.withOpacity(0.08),
                  borderRadius: ThemeColor.mediumBorderRadius,
                ),
                child: Center(
                  child: Text(
                    _creditEmoji(product.credits),
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(width: ThemeColor.paddingMedium),
 
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? product.productId,
                      style: ThemeColor.subtitleLarge.copyWith(
                        color: isSelected
                            ? ThemeColor.textLightColor
                            : ThemeColor.textPrimaryColor,
                      ),
                    ),
                    if (product.descripcion != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        product.descripcion!,
                        style: ThemeColor.bodySmall.copyWith(
                          color: isSelected
                              ? ThemeColor.textLightColor.withOpacity(0.75)
                              : ThemeColor.textSecondaryColor,
                        ),
                      ),
                    ],
                    if (product.credits != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${product.credits} créditos',
                            style: ThemeColor.caption.copyWith(
                              color: Colors.amber,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
 
              isPurchasing
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.amber,
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.amber
                            : ThemeColor.primaryColor,
                        borderRadius: ThemeColor.circularBorderRadius,
                      ),
                      child: Text(
                        product.price != null
                            ? '\$${product.price}'
                            : 'Comprar',
                        style: ThemeColor.buttonText.copyWith(
                          color: isSelected
                              ? ThemeColor.primaryColor
                              : ThemeColor.textLightColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      );
    });
  }
 
  Widget _buildEmptyState(PurchaseController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: ThemeColor.disabledColor,
          ),
          const SizedBox(height: ThemeColor.paddingMedium),
          Text(
            'Sin productos disponibles',
            style: ThemeColor.subtitleMedium.copyWith(
              color: ThemeColor.textSecondaryColor,
            ),
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
 
  Widget _buildPlatformBadge() {
    final isIOS = Platform.isIOS;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: ThemeColor.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isIOS ? Icons.apple : Icons.android,
            size: 16,
            color: ThemeColor.textSecondaryColor,
          ),
          const SizedBox(width: 6),
          Text(
            isIOS
                ? 'Pago procesado por App Store'
                : 'Pago procesado por Google Play',
            style: ThemeColor.caption,
          ),
        ],
      ),
    );
  }

  String _creditEmoji(num? credits) {
    final n = credits?.toInt() ?? 0;
    if (n >= 1000) return '💎';
    if (n >= 500) return '🔥';
    if (n >= 100) return '⭐';
    return '✨';
  }

  void _showSnackbar(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: ThemeColor.bodyMedium.copyWith(
            color: ThemeColor.textLightColor,
          ),
        ),
        backgroundColor: isError
            ? ThemeColor.errorColor
            : ThemeColor.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: ThemeColor.mediumBorderRadius,
        ),
        margin: const EdgeInsets.all(ThemeColor.paddingMedium),
      ),
    );
  }
}
