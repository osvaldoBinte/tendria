import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:tendria/common/settings/language_controller.dart';
import 'package:tendria/common/widgets/alert/snackbar_helper.dart';
import 'package:tendria/features/purchase/domain/entity/purchase_apple_entity.dart';
import 'package:tendria/features/purchase/domain/entity/purchase_entity.dart';
import 'package:tendria/features/purchase/domain/entity/purchase_google_entity.dart';
import 'package:tendria/features/purchase/domain/usecase/get_purchases_usecase.dart';
import 'package:tendria/features/purchase/domain/usecase/purchase_apple_usecase.dart';
import 'package:tendria/features/purchase/domain/usecase/purchase_google_usecase.dart';

class PurchaseController extends GetxController {
  final PurchaseAppleUsecase purchaseAppleUsecase;
  final PurchaseGoogleUsecase purchaseGoogleUsecase;
  final GetPurchasesUsecase getPurchasesUsecase;

  PurchaseController({
    required this.getPurchasesUsecase,
    required this.purchaseAppleUsecase,
    required this.purchaseGoogleUsecase,
  });
 
  LanguageController get _l => Get.find<LanguageController>();
 
  final RxBool isLoadingProducts = false.obs;
  final RxBool isPurchasing = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;
  final RxList<PurchaseEntity> products = <PurchaseEntity>[].obs;
  final RxString selectedProductId = ''.obs;
  final RxMap<String, Map<String, String>> storePrices =
      <String, Map<String, String>>{}.obs;
 
  final RxString couponCode = ''.obs;
  final TextEditingController couponController = TextEditingController();
 
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  bool _iapAvailable = false;
 
  @override
  void onInit() {
    super.onInit();
    _initIAP();
    loadProducts();
  }

  @override
  void onClose() {
    _purchaseSubscription?.cancel();
    couponController.dispose();
    super.onClose();
  }
 
  Future<void> _initIAP() async {
    print('🚀 Inicializando IAP...');
    _iapAvailable = await _iap.isAvailable();
    print('📦 IAP disponible: $_iapAvailable');

    if (!_iapAvailable) {
      print('⚠️ IAP no disponible, se usarán precios del backend');
      return;
    }

    if (Platform.isIOS) {
      print('🍎 Configurando delegate de iOS...');
      final iosPlatformAddition =
          _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    _purchaseSubscription = _iap.purchaseStream.listen(
      (purchases) {
        print('📡 Stream recibió ${purchases.length} evento(s)');
        _onPurchaseUpdate(purchases);
      },
      onDone: () {
        print('🔚 Stream cerrado');
        _purchaseSubscription?.cancel();
      },
      onError: (e) {
        print('💥 Error en stream: $e');
        isPurchasing.value = false;
        errorMessage.value = _l.t('purchase_stream_error');
        showErrorSnackbar(_l.t('purchase_stream_error'));
      },
    );

    print('✅ IAP inicializado y stream escuchando');
  }
 
  Future<void> loadProducts() async {
    try {
      print('🛒 Cargando productos del backend...');
      isLoadingProducts.value = true;
      errorMessage.value = '';

      final result = await getPurchasesUsecase.call();
      products.assignAll(result);
      print('✅ Productos del backend: ${result.length}');

      await _fetchStorePrices(result);
    } catch (e) {
      print('❌ Error al cargar productos: $e');
      errorMessage.value = _l.t('purchase_load_error');
      showErrorSnackbar(_l.t('purchase_load_error'));
    } finally {
      isLoadingProducts.value = false;
    }
  }
 
  Future<void> _fetchStorePrices(List<PurchaseEntity> productList) async {
    if (!_iapAvailable || productList.isEmpty) {
      print('⚠️ IAP no disponible: se usarán precios del backend');
      return;
    }

    try {
      final ids = productList.map((p) => p.productId).toSet();
      print('🔍 Consultando precios en tienda para: $ids');

      final ProductDetailsResponse response =
          await _iap.queryProductDetails(ids);

      if (response.error != null) {
        print('❌ Error al consultar precios: ${response.error}');
        return;
      }

      if (response.notFoundIDs.isNotEmpty) {
        print('⚠️ IDs no encontrados en tienda: ${response.notFoundIDs}');
      }

      final Map<String, Map<String, String>> prices = {};

      for (final detail in response.productDetails) {
        String currency = '';

        if (Platform.isIOS && detail is AppStoreProductDetails) {
          currency = detail.skProduct.priceLocale.currencyCode ?? '';
        } else if (Platform.isAndroid && detail is GooglePlayProductDetails) {
          currency = detail.productDetails.oneTimePurchaseOfferDetails
                  ?.priceCurrencyCode ??
              '';
        }

        prices[detail.id] = {
          'price': detail.price,
          'currency': currency,
        };

        print('💰 [${detail.id}] price: ${detail.price} | currency: $currency');
      }

      storePrices.assignAll(prices);
      print(
          '✅ Precios de tienda cargados: ${prices.length}/${productList.length}');
    } catch (e) {
      print('🔥 Excepción al consultar precios de tienda: $e');
    }
  }
 
  String displayPrice(PurchaseEntity product) {
    final data = storePrices[product.productId];

    if (data != null) {
      final price = data['price'] ?? '';
      final currency = data['currency'] ?? '';

      if (price.isNotEmpty) {
        final result = currency.isNotEmpty && !price.contains(currency)
            ? '$price $currency'
            : price;
        return result;
      }
    }

    if (product.price != null) return '\$${product.price}';
    return '—';
  }
 
  Future<void> buyProduct(PurchaseEntity product) async {
    print('💳 buyProduct llamado: ${product.productId}');

    if (!_iapAvailable) {
      errorMessage.value = _l.t('purchase_no_device');
      showErrorSnackbar(_l.t('purchase_no_device'));
      return;
    }

    if (isPurchasing.value) {
      showInfoSnackbar(_l.t('purchase_in_progress'));
      return;
    }

    try {
      isPurchasing.value = true;
      errorMessage.value = '';
      successMessage.value = '';
      selectedProductId.value = product.productId;

      final Set<String> ids = {product.productId};
      final ProductDetailsResponse response =
          await _iap.queryProductDetails(ids);

      if (response.error != null || response.productDetails.isEmpty) {
        errorMessage.value = _l.t('purchase_product_not_found');
        showErrorSnackbar(_l.t('purchase_product_not_found'));
        isPurchasing.value = false;
        return;
      }

      final productDetails = response.productDetails.first;
      final purchaseParam = PurchaseParam(productDetails: productDetails);
      await _iap.buyConsumable(purchaseParam: purchaseParam);
      print('⏳ buyConsumable ejecutado, esperando stream...');
    } catch (e) {
      print('🔥 Exception en buyProduct: $e');
      isPurchasing.value = false;
      errorMessage.value = _l.t('purchase_error');
      showErrorSnackbar(_l.t('purchase_error'));
    }
  }
 
  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      print(
          '📋 ProductID: ${purchase.productID} | Status: ${purchase.status}');

      switch (purchase.status) {
        case PurchaseStatus.pending:
          showInfoSnackbar(_l.t('purchase_processing'));
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verifyAndDeliver(purchase);
          break;

        case PurchaseStatus.error:
          isPurchasing.value = false;
          selectedProductId.value = '';
          errorMessage.value =
              purchase.error?.message ?? _l.t('purchase_error');
          showErrorSnackbar(
              purchase.error?.message ?? _l.t('purchase_error'));
          break;

        case PurchaseStatus.canceled:
          isPurchasing.value = false;
          selectedProductId.value = '';
          showInfoSnackbar(_l.t('purchase_canceled'));
          break;
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }
 
  Future<void> _verifyAndDeliver(PurchaseDetails purchase) async {
    try {
      if (Platform.isAndroid) {
        if (purchase is! GooglePlayPurchaseDetails) {
          errorMessage.value = _l.t('purchase_internal_error');
          showErrorSnackbar(_l.t('purchase_internal_error'));
          return;
        }
        await purchaseGoogleUsecase.call(
          PurchaseGoogleEntity(
            productoId: purchase.productID,
            purchaseToken: purchase.billingClientPurchase.purchaseToken,
            packageName: purchase.billingClientPurchase.packageName,
            couponcode: couponCode.value.trim().isNotEmpty
                ? couponCode.value.trim()
                : null,
          ),
        );
      } else if (Platform.isIOS) {
        if (purchase is! AppStorePurchaseDetails) {
          errorMessage.value = _l.t('purchase_internal_error');
          showErrorSnackbar(_l.t('purchase_internal_error'));
          return;
        }

        final skPaymentTransaction = purchase.skPaymentTransaction;
        final transactionId = skPaymentTransaction.transactionIdentifier;
        final originalTransactionId =
            skPaymentTransaction.originalTransaction?.transactionIdentifier;
        final receiptData = originalTransactionId ?? transactionId ?? '';

        await purchaseAppleUsecase.call(
          PurchaseAppleEntity(
            productoId: purchase.productID,
            receiptData: receiptData,
          ),
        );
      }

      successMessage.value = _l.t('purchase_success');
      showSuccessSnackbar(_l.t('purchase_success'));
      print('🎉 Compra completada');
    } catch (e, stackTrace) {
      print('🔥 Error en _verifyAndDeliver: $e\n$stackTrace');
      errorMessage.value = _l.t('purchase_verify_error');
      showErrorSnackbar('${errorMessage.value}: $e');
    } finally {
      isPurchasing.value = false;
      selectedProductId.value = '';
    }
  }

  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  void clearCoupon() {
    couponController.clear();
    couponCode.value = '';
  }
}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) =>
      true;

  @override
  bool shouldShowPriceConsent() => false;
}