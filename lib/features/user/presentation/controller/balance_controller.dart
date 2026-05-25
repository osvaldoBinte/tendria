import 'package:get/get.dart';
import 'package:tendria/features/user/domain/entities/user_balance_entity.dart';
import 'package:tendria/features/user/domain/usecase/get_balance_usecase.dart';

class BalanceController extends GetxController {
  final GetBalanceUsecase getBalanceUsecase;
  BalanceController({required this.getBalanceUsecase});

  final Rx<UserBalanceEntity?> balance = Rx<UserBalanceEntity?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBalance();
  }

  Future<void> fetchBalance() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await getBalanceUsecase.execute();
      balance.value = result;
    } catch (e) {
      errorMessage.value = 'Error al obtener el balance: $e';
    } finally {
      isLoading.value = false;
    }
  }

  double get currentBalance => balance.value?.balance ?? 0.0;
  double get chatCost => balance.value?.costChat ?? 0.0;
  bool get hasBalance => balance.value != null;
}