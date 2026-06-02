import 'package:tendria/features/user/domain/entities/update_location_entity.dart';
import 'package:tendria/features/user/domain/repositories/user_repository.dart';

class UpdateCityUsecase {
  final UserRepository userRepository;
  UpdateCityUsecase({required this.userRepository});
  Future<void> execute(UpdateLocationEntity entity) async {
    return await userRepository.updateCity(entity);
  }
}