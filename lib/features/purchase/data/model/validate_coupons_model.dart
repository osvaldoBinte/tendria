import 'package:tendria/features/purchase/domain/entity/validate_coupons_entity.dart';

class ValidateCouponsModel extends ValidateCouponsEntity {
  ValidateCouponsModel({required super.isValid, required super.description, required super.bonusPoints});
  

  factory ValidateCouponsModel.fromJson(Map<String, dynamic> json) {
    return ValidateCouponsModel(
      isValid: json['valido'] as bool,
      description: json['descripcion'] as String,
      bonusPoints: json['bonificacion'] as int,
    );
  }
}