import 'package:tendria/features/user/domain/entities/user_balance_entity.dart';
import 'package:tendria/features/user/domain/repositories/user_repository.dart';

class GetBalanceUsecase {
  final UserRepository userRepository;
  GetBalanceUsecase({required this.userRepository});
  Future<UserBalanceEntity> execute() async {
    return await userRepository.getuserbalance();
  }
}