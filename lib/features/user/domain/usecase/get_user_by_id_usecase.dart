import 'package:tendria/features/user/domain/entities/get_user_entity.dart';
import 'package:tendria/features/user/domain/repositories/user_repository.dart';

class GetUserByIdUsecase {
  final UserRepository userRepository;

  GetUserByIdUsecase({required this.userRepository});

  Future<GetUserEntity> execute(int iduser) async {
    return await userRepository.getuserbyid(iduser);
  } 
}