import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
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
 
  Future<void> _initIAP() async {
    _iapAvailable = await _iap.isAvailable();
    if (!_iapAvailable) {
      errorMessage.value = 'Las compras no están disponibles en este dispositivo';
      return;
    }
 
    if (Platform.isIOS) {
      final iosPlatformAddition = _iap
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }
 
    _purchaseSubscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _purchaseSubscription?.cancel(),
      onError: (e) {
        isPurchasing.value = false;
        errorMessage.value = 'Error en el proceso de compra';
      },
    );
  }
 
  Future<void> loadProducts() async {
    try {
      isLoadingProducts.value = true;
      errorMessage.value = '';
      final result = await getPurchasesUsecase.call();
      products.assignAll(result);
    } catch (e) {
      errorMessage.value = 'Error al cargar los productos';
    } finally {
      isLoadingProducts.value = false;
    }
  }
 
  Future<void> buyProduct(PurchaseEntity product) async {
    if (!_iapAvailable) {
      errorMessage.value = 'Compras no disponibles';
      return;
    }
    if (isPurchasing.value) return;

    try {
      isPurchasing.value = true;
      errorMessage.value = '';
      selectedProductId.value = product.productId;
 
      final Set<String> ids = {product.productId};
      final ProductDetailsResponse response = await _iap.queryProductDetails(ids);

      if (response.error != null || response.productDetails.isEmpty) {
        errorMessage.value = 'Producto no encontrado en la tienda';
        isPurchasing.value = false;
        return;
      }

      final productDetails = response.productDetails.first;
      final purchaseParam = PurchaseParam(productDetails: productDetails);
      await _iap.buyConsumable(purchaseParam: purchaseParam);
  
    } catch (e) {
      isPurchasing.value = false;
      errorMessage.value = 'Error al iniciar la compra';
    }
  }
 
  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending: 
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verifyAndDeliver(purchase);
          break;

        case PurchaseStatus.error:
          isPurchasing.value = false;
          selectedProductId.value = '';
          errorMessage.value = purchase.error?.message ?? 'Error en la compra';
          break;

        case PurchaseStatus.canceled:
          isPurchasing.value = false;
          selectedProductId.value = '';
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
        final androidDetails =
            purchase as GooglePlayPurchaseDetails;
        await purchaseGoogleUsecase.call(
          PurchaseGoogleEntity(
            productoId: purchase.productID,
            purchaseToken: androidDetails.billingClientPurchase.purchaseToken,
            packageName: androidDetails.billingClientPurchase.packageName,
          ),
        );
      } else if (Platform.isIOS) {
        final skPaymentTransaction =
            (purchase as AppStorePurchaseDetails).skPaymentTransaction;
        final receiptData =
            skPaymentTransaction.originalTransaction?.transactionIdentifier ??
            skPaymentTransaction.transactionIdentifier ??
            '';
        await purchaseAppleUsecase.call(
          PurchaseAppleEntity(
            productoId: purchase.productID,
            receiptData: receiptData,
          ),
        );
      }

      successMessage.value = '¡Compra completada exitosamente!';
    } catch (e) {
      errorMessage.value = 'Error al verificar la compra con el servidor';
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
 
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) => true;

  @override
  bool shouldShowPriceConsent() => false;
}