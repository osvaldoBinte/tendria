import 'package:tendria/features/user/domain/entities/update_location_entity.dart';
import 'package:tendria/features/user/domain/repositories/user_repository.dart';

class UpdateLocationUsecase {
  final UserRepository userRepository;

  UpdateLocationUsecase({ required this.userRepository});

  Future<void> execute(UpdateLocationEntity entity) async {
    return await userRepository.updateLocation(entity);
  }
}