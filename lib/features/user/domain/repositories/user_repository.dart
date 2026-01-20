import 'package:tendria/features/user/domain/entities/get_user_entity.dart';

abstract class UserRepository {
    Future<GetUserEntity> fetchUser();

}