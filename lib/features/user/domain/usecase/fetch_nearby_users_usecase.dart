import 'package:tendria/features/user/domain/entities/get_user_entity.dart';
import 'package:tendria/features/user/domain/repositories/user_repository.dart';

class FetchNearbyUsersUsecase {
  final UserRepository userRepository;

  FetchNearbyUsersUsecase({required this.userRepository});

  Future<List<GetUserEntity>> execute(int pageNumber,int pageSize,) async {
    return await userRepository.fetchNearbyUsers(pageNumber,pageSize);
  }
}