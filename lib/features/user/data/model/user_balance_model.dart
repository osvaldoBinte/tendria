import 'package:tendria/features/user/domain/entities/user_balance_entity.dart';

class UserBalanceModel extends UserBalanceEntity {
  UserBalanceModel({required super.balance, required super.costChat});

  factory UserBalanceModel.fromJson(Map<String, dynamic> json) {
    return UserBalanceModel(
      balance: json['saldo']?.toDouble() ?? 0.0,
      costChat: json['costoChat']?.toDouble() ?? 0.0,
    );
  }
}