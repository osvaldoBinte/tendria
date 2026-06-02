import 'package:tendria/features/user/domain/entities/update_location_entity.dart';
import 'package:tendria/features/user/domain/repositories/user_repository.dart';

class SearchCityUsecase {
  final UserRepository userRepository;

  SearchCityUsecase({ required this.userRepository});

  Future<List<UpdateLocationEntity>> execute(String city) async {
    return await userRepository.searchcity(city);
  }
}