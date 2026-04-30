import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
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

  final RxBool isLoadingProducts = false.obs;
  final RxBool isPurchasing = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;
  final RxList<PurchaseEntity> products = <PurchaseEntity>[].obs;
  final RxString selectedProductId = ''.obs;

  // productId → { 'price': '$100', 'currency': 'MXN' }
  // currency viene directo del SDK de Apple/Google, nunca del locale del dispositivo
  final RxMap<String, Map<String, String>> storePrices =
      <String, Map<String, String>>{}.obs;

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
    super.onClose();
  }

  // ─────────────────────────────────────────────
  // INIT IAP
  // ─────────────────────────────────────────────

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
        errorMessage.value = 'Error en el proceso de compra';
        showErrorSnackbar('Error en el proceso de compra');
      },
    );

    print('✅ IAP inicializado y stream escuchando');
  }

  // ─────────────────────────────────────────────
  // CARGAR PRODUCTOS
  // ─────────────────────────────────────────────

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
      errorMessage.value = 'Error al cargar los productos';
      showErrorSnackbar('Error al cargar los productos');
    } finally {
      isLoadingProducts.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // FETCH PRECIOS DE TIENDA
  // ─────────────────────────────────────────────

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

        // Obtener el currencyCode real desde el SDK, NO del locale del dispositivo
        if (Platform.isIOS && detail is AppStoreProductDetails) {
          currency =
              detail.skProduct.priceLocale.currencyCode ?? '';
          print(
              '🍎 iOS currencyCode [${detail.id}]: $currency | priceLocale: ${detail.skProduct.priceLocale.currencyCode}');
        } else if (Platform.isAndroid &&
            detail is GooglePlayProductDetails) {
          currency = detail
                  .productDetails
                  .oneTimePurchaseOfferDetails
                  ?.priceCurrencyCode ??
              '';
          print(
              '🤖 Android currencyCode [${detail.id}]: $currency');
        }

        prices[detail.id] = {
          'price': detail.price,     // ej: "$100"
          'currency': currency,      // ej: "MXN"
        };

        print(
            '💰 [${detail.id}] price: ${detail.price} | currency: $currency');
      }

      storePrices.assignAll(prices);
      print(
          '✅ Precios de tienda cargados: ${prices.length}/${productList.length}');
    } catch (e) {
      print('🔥 Excepción al consultar precios de tienda: $e');
      // No lanzar — la UI usará product.price como fallback
    }
  }

  // ─────────────────────────────────────────────
  // DISPLAY PRICE
  // ─────────────────────────────────────────────

  /// Devuelve el precio formateado para mostrar en la UI.
  ///
  /// Prioridad:
  ///   1. Precio real de la tienda con currency del SDK → "$100 MXN"
  ///   2. Fallback: precio del backend sin currency → "$100"
  ///   3. Sin precio → "—"
  String displayPrice(PurchaseEntity product) {
    final data = storePrices[product.productId];
    print('🏷️ displayPrice [${product.productId}] → data: $data');

    if (data != null) {
      final price = data['price'] ?? '';
      final currency = data['currency'] ?? '';

      if (price.isNotEmpty) {
        // Si el precio ya incluye el código (ej: "MX$100.00"), devolver tal cual
        // Si no, agregar el código al final: "$100 MXN"
        final result = currency.isNotEmpty && !price.contains(currency)
            ? '$price $currency'
            : price;
        print('   ✅ Precio final: $result');
        return result;
      }
    }

    // Fallback: precio del backend
    if (product.price != null) {
      final fallback = '\$${product.price}';
      print('   ⚠️ Usando fallback backend: $fallback');
      return fallback;
    }

    print('   ❌ Sin precio disponible');
    return '—';
  }

  // ─────────────────────────────────────────────
  // COMPRAR PRODUCTO
  // ─────────────────────────────────────────────

  Future<void> buyProduct(PurchaseEntity product) async {
    print('💳 buyProduct llamado: ${product.productId}');

    if (!_iapAvailable) {
      print('⚠️ IAP no disponible');
      errorMessage.value = 'Compras no disponibles en este dispositivo';
      showErrorSnackbar('Compras no disponibles en este dispositivo');
      return;
    }

    if (isPurchasing.value) {
      print('⚠️ Ya hay una compra en progreso');
      showInfoSnackbar('Ya hay una compra en progreso');
      return;
    }

    try {
      isPurchasing.value = true;
      errorMessage.value = '';
      successMessage.value = '';
      selectedProductId.value = product.productId;

      final Set<String> ids = {product.productId};
      print('🔍 Consultando producto en tienda: $ids');

      final ProductDetailsResponse response =
          await _iap.queryProductDetails(ids);

      print(
          '📊 Productos encontrados: ${response.productDetails.length}');
      print('❓ IDs no encontrados: ${response.notFoundIDs}');

      if (response.error != null) {
        print('❌ Error en queryProductDetails: ${response.error}');
        errorMessage.value = 'Producto no encontrado en la tienda';
        showErrorSnackbar('Producto no encontrado en la tienda');
        isPurchasing.value = false;
        return;
      }

      if (response.productDetails.isEmpty) {
        print('❌ Lista de productos vacía');
        errorMessage.value = 'Producto no encontrado en la tienda';
        showErrorSnackbar('Producto no encontrado en la tienda');
        isPurchasing.value = false;
        return;
      }

      final productDetails = response.productDetails.first;
      print(
          '✅ Producto listo: ${productDetails.id} | Precio: ${productDetails.price}');

      final purchaseParam = PurchaseParam(productDetails: productDetails);
      await _iap.buyConsumable(purchaseParam: purchaseParam);
      print('⏳ buyConsumable ejecutado, esperando stream...');
    } catch (e) {
      print('🔥 Exception en buyProduct: $e');
      isPurchasing.value = false;
      errorMessage.value = 'Error al iniciar la compra';
      showErrorSnackbar('Error al iniciar la compra');
    }
  }

  // ─────────────────────────────────────────────
  // STREAM DE COMPRAS
  // ─────────────────────────────────────────────

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    print('🔔 _onPurchaseUpdate con ${purchases.length} compra(s)');

    for (final purchase in purchases) {
      print(
          '📋 ProductID: ${purchase.productID} | Status: ${purchase.status}');

      switch (purchase.status) {
        case PurchaseStatus.pending:
          print('⏳ Compra pendiente...');
          showInfoSnackbar('Procesando compra...');
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          print('✅ purchased/restored → _verifyAndDeliver');
          await _verifyAndDeliver(purchase);
          break;

        case PurchaseStatus.error:
          print('❌ Error: ${purchase.error?.message}');
          isPurchasing.value = false;
          selectedProductId.value = '';
          errorMessage.value =
              purchase.error?.message ?? 'Error en la compra';
          showErrorSnackbar(
              purchase.error?.message ?? 'Error en la compra');
          break;

        case PurchaseStatus.canceled:
          print('🚫 Compra cancelada');
          isPurchasing.value = false;
          selectedProductId.value = '';
          showInfoSnackbar('Compra cancelada');
          break;
      }

      if (purchase.pendingCompletePurchase) {
        print('🔄 Completando compra: ${purchase.productID}');
        await _iap.completePurchase(purchase);
        print('✅ completePurchase ejecutado');
      }
    }
  }

  // ─────────────────────────────────────────────
  // VERIFICAR Y ENTREGAR
  // ─────────────────────────────────────────────

  Future<void> _verifyAndDeliver(PurchaseDetails purchase) async {
    print(
        '🔍 _verifyAndDeliver | iOS: ${Platform.isIOS} | Android: ${Platform.isAndroid}');

    try {
      if (Platform.isAndroid) {
        if (purchase is! GooglePlayPurchaseDetails) {
          errorMessage.value = 'Error interno al procesar la compra';
          showErrorSnackbar('Error interno al procesar la compra');
          return;
        }
        await purchaseGoogleUsecase.call(
          PurchaseGoogleEntity(
            productoId: purchase.productID,
            purchaseToken:
                purchase.billingClientPurchase.purchaseToken,
            packageName:
                purchase.billingClientPurchase.packageName,
          ),
        );
      } else if (Platform.isIOS) {
        if (purchase is! AppStorePurchaseDetails) {
          errorMessage.value = 'Error interno al procesar la compra';
          showErrorSnackbar('Error interno al procesar la compra');
          return;
        }
        final receiptData =
            purchase.verificationData.localVerificationData;
        await purchaseAppleUsecase.call(
          PurchaseAppleEntity(
            productoId: purchase.productID,
            receiptData: receiptData,
          ),
        );
      }

      successMessage.value = '¡Compra completada exitosamente!';
      showSuccessSnackbar('¡Compra completada exitosamente!');
      print('🎉 Compra completada');
    } catch (e, stackTrace) {
      print('🔥 Error en _verifyAndDeliver: $e\n$stackTrace');
      errorMessage.value =
          'Error al verificar la compra con el servidor';
      showErrorSnackbar(
          'Error al verificar la compra con el servidor');
    } finally {
      isPurchasing.value = false;
      selectedProductId.value = '';
    }
  }

  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }
}

// ─────────────────────────────────────────────
// DELEGATE iOS
// ─────────────────────────────────────────────

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