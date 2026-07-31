import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/page/sendGiftPage/gift_sent_success.dart';

class GiftOption {
  final String name;
  final int price;
  final String imageUrl;
  final bool locked;
  final String? tag; // ej. 'ELITE'

  GiftOption({
    required this.name,
    required this.price,
    required this.imageUrl,
    this.locked = false,
    this.tag,
  });
}

class SendGiftController extends GetxController {
  final List<GiftOption> gifts = [
    GiftOption(
      name: 'Rosa',
      price: 10,
      imageUrl: 'https://images.unsplash.com/photo-1518895949257-7621c3c786d7',
    ),
    GiftOption(
      name: 'Champagne',
      price: 50,
      imageUrl: 'https://images.unsplash.com/photo-1594736797933-d0e501ba2fe6',
    ),
    GiftOption(
      name: 'Corona VIP',
      price: 300,
      imageUrl: 'https://images.unsplash.com/photo-1621607512214-68297480165e',
      tag: 'ELITE',
    ),
    GiftOption(
      name: 'Diamante',
      price: 500,
      imageUrl: 'https://images.unsplash.com/photo-1615655406736-b37c4fabf923',
      locked: true,
    ),
  ];

  final RxInt selectedIndex = 2.obs;
  final RxInt currentBalance = 320.obs;

  void selectGift(int index) {
    if (gifts[index].locked) return;
    selectedIndex.value = index;
  }

  GiftOption get selectedGift => gifts[selectedIndex.value];

  final RxBool showSuccess = false.obs;
  GiftOption? sentGift;
  int sentBalanceAfter = 0;

  void sendGift() {
    final gift = selectedGift;

    if (gift.price > currentBalance.value) {
      return;
    }

    currentBalance.value -= gift.price;

    sentGift = gift;
    sentBalanceAfter = currentBalance.value;
    showSuccess.value = true;
  }

  void closeSuccessOverlay() {
    showSuccess.value = false;
  }
}

class SendGiftPage extends StatelessWidget {
  const SendGiftPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SendGiftController());

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFF0E0D10),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 18),
                _buildBalanceCard(controller),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Obx(() {
                      final selected = controller.selectedIndex.value;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.gifts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                        itemBuilder: (context, index) {
                          final gift = controller.gifts[index];
                          final isSelected = index == selected && !gift.locked;

                          return _GiftCard(
                            gift: gift,
                            isSelected: isSelected,
                            onTap: gift.locked
                                ? null
                                : () => controller.selectGift(index),
                          );
                        },
                      );
                    }),
                  ),
                ),
                _buildDivider(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: controller.sendGift,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      decoration: BoxDecoration(
                        color: ThemeColor.primaryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.send_rounded,
                            color: Colors.black,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ENVIAR REGALO',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Al enviar confirmas la transacción de créditos.',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        Obx(() {
          if (!controller.showSuccess.value || controller.sentGift == null) {
            return const SizedBox.shrink();
          }
          return giftSentSuccess(
            giftName: controller.sentGift!.name,
            giftValue: controller.sentGift!.price,
            newBalance: controller.sentBalanceAfter,
          );
        }),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Enviar Regalo',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              color: ThemeColor.primaryColor,
            ),
          ),
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(
              Icons.close_rounded,
              color: Colors.white70,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(SendGiftController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ThemeColor.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                size: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tu Saldo',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.attach_money_rounded,
                    size: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 6),
                Obx(
                  () => Text(
                    '${controller.currentBalance.value}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 40),
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Icon(
            Icons.diamond_outlined,
            color: ThemeColor.primaryColor,
            size: 16,
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 40),
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ],
    );
  }
}

class _GiftCard extends StatelessWidget {
  final GiftOption gift;
  final bool isSelected;
  final VoidCallback? onTap;

  const _GiftCard({
    required this.gift,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? ThemeColor.primaryColor
                    : Colors.white.withOpacity(0.08),
                width: isSelected ? 1.6 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: ThemeColor.primaryColor.withOpacity(0.35),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                    border: Border.all(
                      color: gift.locked
                          ? Colors.white24
                          : ThemeColor.primaryColor.withOpacity(0.4),
                    ),
                  ),
                  child: ClipOval(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Opacity(
                          opacity: gift.locked ? 0.25 : 1,
                          child: Image.network(
                            gift.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.white10,
                              child: Icon(
                                Icons.card_giftcard_rounded,
                                color: Colors.white38,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                        if (gift.locked)
                          Center(
                            child: Icon(
                              Icons.lock_rounded,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  gift.name,
                  style: TextStyle(
                    color: gift.locked ? Colors.white38 : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: gift.locked
                            ? Colors.white24
                            : ThemeColor.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.attach_money_rounded,
                        size: 11,
                        color: gift.locked ? Colors.white38 : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${gift.price}',
                      style: TextStyle(
                        color: gift.locked ? Colors.white38 : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (gift.tag != null)
            Positioned(
              top: -1,
              left: -1,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: ThemeColor.primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  gift.tag!,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
