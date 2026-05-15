import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/tutorial/startTutorial/start_tutorial_controller.dart';
import 'package:tendria/common/tutorial/startTutorial/start_tutorial_overlay.dart';
import 'package:tendria/common/tutorial/tutorialPerfil/profile_tutorial_controller.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/common/widgets/panic_button.dart';
import 'start_controller.dart';


class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  late final StartController controller;
  late final StartTutorialController tutorialCtrl;

  @override
  void initState() {
    super.initState();
    controller   = Get.put(StartController());
    tutorialCtrl =  Get.find<StartTutorialController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      tutorialCtrl.notifyPageReady();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() => ThemeColor.createMainScaffold(
          body: controller.currentPage,
          currentIndex: controller.selectedIndex.value,
          onNavigationTap: controller.changePage,
          iconPaths: controller.iconPaths,
          labels: controller.labels,
          backgroundColor: ThemeColor.backgroundColorfondo,
          bottomNavBackgroundColor: Colors.white, 
          navKeys: [
            tutorialCtrl.navProfileKey,
            tutorialCtrl.navRadarKey,
            tutorialCtrl.navMatchKey,
            tutorialCtrl.navChatKey,
          ],
          floatingActionButton: KeyedSubtree(
            key: tutorialCtrl.panicButtonKey,
            child: const PanicButton(),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        )),

        // Overlay encima de todo
        Obx(
          () => tutorialCtrl.isVisible.value
              ? const StartTutorialOverlay()
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}