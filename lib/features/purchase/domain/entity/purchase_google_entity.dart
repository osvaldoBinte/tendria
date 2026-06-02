class PurchaseGoogleEntity {
  final String productoId;
  final String purchaseToken;
  final String packageName;
  final String? couponcode;
  PurchaseGoogleEntity({
  required this.productoId,
  required this.packageName,
  required this.purchaseToken,
  this.couponcode,
  });
}