import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
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
  // INIT
  // ─────────────────────────────────────────────

  Future<void> _initIAP() async {
    print('🚀 Inicializando IAP...');
    _iapAvailable = await _iap.isAvailable();
    print('📦 IAP disponible: $_iapAvailable');

    if (!_iapAvailable) {
      errorMessage.value = 'Las compras no están disponibles en este dispositivo';
      showErrorSnackbar('Las compras no están disponibles en este dispositivo');
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
      print('🛒 Cargando productos...');
      isLoadingProducts.value = true;
      errorMessage.value = '';
      final result = await getPurchasesUsecase.call();
      products.assignAll(result);
      print('✅ Productos cargados: ${result.length}');
      for (final p in result) {
        print('   → ${p.productId}');
      }
    } catch (e) {
      print('❌ Error al cargar productos: $e');
      errorMessage.value = 'Error al cargar los productos';
      showErrorSnackbar('Error al cargar los productos');
    } finally {
      isLoadingProducts.value = false;
    }
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

      print('📊 Productos encontrados: ${response.productDetails.length}');
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
      print('✅ Producto listo: ${productDetails.id} | Precio: ${productDetails.price}');

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
      print('📋 ProductID: ${purchase.productID} | Status: ${purchase.status} | Type: ${purchase.runtimeType}');

      switch (purchase.status) {
        case PurchaseStatus.pending:
          print('⏳ Compra pendiente...');
          showInfoSnackbar('Procesando compra...');
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          print('✅ Estado purchased/restored → llamando _verifyAndDeliver');
          await _verifyAndDeliver(purchase);
          break;

        case PurchaseStatus.error:
          print('❌ Error: ${purchase.error?.message} | Code: ${purchase.error?.code}');
          isPurchasing.value = false;
          selectedProductId.value = '';
          errorMessage.value = purchase.error?.message ?? 'Error en la compra';
          showErrorSnackbar(purchase.error?.message ?? 'Error en la compra');
          break;

        case PurchaseStatus.canceled:
          print('🚫 Compra cancelada');
          isPurchasing.value = false;
          selectedProductId.value = '';
          showInfoSnackbar('Compra cancelada');
          break;
      }

      if (purchase.pendingCompletePurchase) {
        print('🔄 Completando compra pendiente: ${purchase.productID}');
        await _iap.completePurchase(purchase);
        print('✅ completePurchase ejecutado');
      }
    }
  }

  // ─────────────────────────────────────────────
  // VERIFICAR Y ENTREGAR
  // ─────────────────────────────────────────────

  Future<void> _verifyAndDeliver(PurchaseDetails purchase) async {
    print('🔍 _verifyAndDeliver | iOS: ${Platform.isIOS} | Android: ${Platform.isAndroid}');
    print('🔍 Purchase runtimeType: ${purchase.runtimeType}');

    try {
      if (Platform.isAndroid) {
        print('🤖 Verificando compra Android...');

        if (purchase is! GooglePlayPurchaseDetails) {
          print('❌ NO es GooglePlayPurchaseDetails: ${purchase.runtimeType}');
          errorMessage.value = 'Error interno al procesar la compra';
          showErrorSnackbar('Error interno al procesar la compra');
          return;
        }

        print('📦 purchaseToken: ${purchase.billingClientPurchase.purchaseToken}');
        print('📦 packageName: ${purchase.billingClientPurchase.packageName}');

        await purchaseGoogleUsecase.call(
          PurchaseGoogleEntity(
            productoId: purchase.productID,
            purchaseToken: purchase.billingClientPurchase.purchaseToken,
            packageName: purchase.billingClientPurchase.packageName,
          ),
        );
        print('✅ purchaseGoogleUsecase ejecutado');
      } else if (Platform.isIOS) {
        print('🍎 Verificando compra iOS...');

        if (purchase is! AppStorePurchaseDetails) {
          print('❌ NO es AppStorePurchaseDetails: ${purchase.runtimeType}');
          errorMessage.value = 'Error interno al procesar la compra';
          showErrorSnackbar('Error interno al procesar la compra');
          return;
        }

        final skPaymentTransaction = purchase.skPaymentTransaction;
        final transactionId = skPaymentTransaction.transactionIdentifier;
        final originalTransactionId =
            skPaymentTransaction.originalTransaction?.transactionIdentifier;

        print('📝 transactionIdentifier: $transactionId');
        print('📝 originalTransactionIdentifier: $originalTransactionId');

        final receiptData = originalTransactionId ?? transactionId ?? '';
        print('🎫 receiptData a enviar: $receiptData');

        await purchaseAppleUsecase.call(
          PurchaseAppleEntity(
            productoId: purchase.productID,
            receiptData: receiptData,
          ),
        );
        print('✅ purchaseAppleUsecase ejecutado');
      }

      successMessage.value = '¡Compra completada exitosamente!';
      showSuccessSnackbar('¡Compra completada exitosamente!');
      print('🎉 Compra completada');
    } catch (e, stackTrace) {
      print('🔥 Error en _verifyAndDeliver: $e');
      print('📚 StackTrace: $stackTrace');
      errorMessage.value = 'Error al verificar la compra con el servidor';
      showErrorSnackbar('Error al verificar la compra con el servidor');
    } finally {
      isPurchasing.value = false;
      selectedProductId.value = '';
      print('🏁 _verifyAndDeliver finalizado');
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