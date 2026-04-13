class PurchaseEntity {
  final int ordenId;
  final String productId;
  final String? name;
  final String? credits;
  final String ?descripcion;
  final String ?price;
  PurchaseEntity({
    required this.ordenId,
    required this.productId,
   this.name,
     this.credits,
     this.descripcion,
     this.price,
  });
}