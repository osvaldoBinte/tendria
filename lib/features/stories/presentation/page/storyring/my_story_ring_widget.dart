import 'package:flutter/material.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/stories/presentation/page/create_story_screen.dart';
import 'package:tendria/features/stories/presentation/page/story_controller.dart';
import 'package:tendria/features/stories/presentation/page/story_modal_widget.dart';
import 'package:tendria/features/stories/presentation/widgets/story_ring_loading.dart';
import 'package:get/get.dart';
import 'package:tendria/features/user/presentation/controller/profile_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyStoryRingWidget extends StatefulWidget {
  final double size;

  const MyStoryRingWidget({
    Key? key,
    this.size = 80,
  }) : super(key: key);

  @override
  State<MyStoryRingWidget> createState() => _MyStoryRingWidgetState();
}

class _MyStoryRingWidgetState extends State<MyStoryRingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
     
    final ProfileController userController = Get.find<ProfileController>();
    _showProfilePhotoDialog(userController);
  }

  void _onLongPressCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _showProfilePhotoDialog(ProfileController userController) {
    if (Get.context == null) return;

    showGeneralDialog(
      context: Get.context!,
      barrierDismissible: true,
      barrierLabel: 'Cerrar',
      barrierColor: Colors.black.withOpacity(0.9),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [ 
                Center(
                  child: Hero(
                    tag: 'profile_photo',
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        color: ThemeColor.backgroundColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: ThemeColor.radarScanner.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Obx(() {
                          final photoUrl = userController.profilePhotoUrl;
                          final isUploading = userController.isUploadingProfilePhoto.value;

                          if (isUploading) {
                            return Container(
                              color: ThemeColor.backgroundColor,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: ThemeColor.tertiaryColor,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Subiendo foto...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          if (photoUrl.isNotEmpty) {
                            return CachedNetworkImage(
                              imageUrl: photoUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: ThemeColor.backgroundColor,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: ThemeColor.tertiaryColor,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: ThemeColor.backgroundColor,
                                child: Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 120,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Container(
                              color: ThemeColor.backgroundColor,
                              child: Center(
                                child: Icon(
                                  Icons.person,
                                  size: 120,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          }
                        }),
                      ),
                    ),
                  ),
                ),
 
                Positioned(
                  top: 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Obx(() => Text(
                          userController.userName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        )),
                  ),
                ),

                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        userController.showProfilePhotoOptions();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeColor.tertiaryColor,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeColor.tertiaryColor.withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Cambiar foto de perfil',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final StoryController storyController = Get.find<StoryController>();
    final ProfileController userController = Get.find<ProfileController>();

    return Container(
  margin: const EdgeInsets.only(right: 12),      child: Obx(() {
        if (storyController.isLoadingMyStory.value) {
          return StoryRingLoading(size: widget.size);
        }

        final userPhoto = userController.profilePhotoUrl;
        final isUploadingProfilePhoto = userController.isUploadingProfilePhoto.value;

        if (storyController.hasMyStory.value &&
            storyController.myStories.isNotEmpty) {
          return _buildMyStoryRing(
            context,
            storyController,
            userPhoto,
            isUploadingProfilePhoto,
          );
        }

        return _buildAddStoryButton(
          context,
          userPhoto,
          isUploadingProfilePhoto,
        );
      }),
    );
  }

  Widget _buildMyStoryRing(
    BuildContext context,
    StoryController storyController,
    String? userPhoto,
    bool isUploading,
  ) {
    final bool allViewed =
        storyController.myStories.every((story) => story.yaVista);

    return GestureDetector(
      onTap: () {
        showStoryModal(context, userIndex: -1, isMyStory: true);
      },
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      onLongPressCancel: _onLongPressCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              children: [
                Hero(
                  tag: 'profile_photo',
                  child: ThemeColor.createStoryRing(
                    child: _buildProfileImage(userPhoto, isUploading),
                    hasStory: true,
                    isViewed: allViewed,
                    size: widget.size,
                  ),
                ),

                if (_isPressed)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.zoom_in,
                          color: Colors.white.withOpacity(0.8),
                          size: widget.size * 0.4,
                        ),
                      ),
                    ),
                  ),

                if (!_isPressed)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () {
                        Get.to(() => const CreateStoryScreen());
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: ThemeColor.tertiaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [ThemeColor.lightShadow],
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),

                if (storyController.myStories.length > 1 && !_isPressed)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: ThemeColor.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Center(
                        child: Text(
                          '${storyController.myStories.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddStoryButton(
    BuildContext context,
    String? userPhoto,
    bool isUploading,
  ) {
    return GestureDetector(
      onTap: () {
        Get.to(() => const CreateStoryScreen());
      },
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      onLongPressCancel: _onLongPressCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              children: [
                Hero(
                  tag: 'profile_photo',
                  child: ThemeColor.createStoryRing(
                    child: _buildProfileImage(userPhoto, isUploading),
                    hasStory: false,
                    size: widget.size,
                  ),
                ),

                if (_isPressed)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.zoom_in,
                          color: Colors.white.withOpacity(0.8),
                          size: widget.size * 0.4,
                        ),
                      ),
                    ),
                  ),

                if (!_isPressed)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: ThemeColor.tertiaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [ThemeColor.lightShadow],
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

 Widget _buildProfileImage(String? imageUrl, bool isUploading) {
  if (isUploading) {
    return Container(
      color: ThemeColor.backgroundColor,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: ThemeColor.tertiaryColor,
        ),
      ),
    );
  }

  if (imageUrl != null && imageUrl.isNotEmpty) {
    final cacheKey = Uri.tryParse(imageUrl)?.path ?? imageUrl; 

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        cacheKey: cacheKey, 
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
        fadeInDuration: Duration.zero,     
        fadeOutDuration: Duration.zero,   
        placeholder: (context, url) => Container(
          color: ThemeColor.backgroundColor,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: ThemeColor.tertiaryColor,
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildFallbackIcon(),
      ),
    );
  } else {
    return _buildFallbackIcon();
  }
}
  Widget _buildFallbackIcon() {
    return Container(
      color: ThemeColor.backgroundColor,
      child: const Center(
        child: Icon(
          Icons.person,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }
}