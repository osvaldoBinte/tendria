import 'package:flutter/material.dart';
import 'package:tendria/common/theme/App_Theme.dart';
class NotificatioLoading extends StatefulWidget {
  const NotificatioLoading({Key? key}) : super(key: key);

  @override
  State<NotificatioLoading> createState() =>
      _NotificationLoadingState();
}

class _NotificationLoadingState extends State<NotificatioLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: false);

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: 5,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildNotificationItemSkeleton(
              hasImage: index % 3 == 0,
            );
          },
        );
      },
    );
  }

  Widget _buildShimmerBox({required Widget child}) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, _) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ThemeColor.loaddingwithOpacity1,
                ThemeColor.loaddingwithOpacity3,
                ThemeColor.loaddingwithOpacity1
              ],
              stops: [
                _shimmerAnimation.value - 1,
                _shimmerAnimation.value,
                _shimmerAnimation.value + 1,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }

  Widget _buildNotificationItemSkeleton({bool hasImage = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeColor.backgroundColorfondo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: ThemeColor.loaddingwithOpacity1,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerBox(
                        child: Container(
                          height: 14,
                          width: 120,
                          decoration: BoxDecoration(
                            color: ThemeColor.loadding,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                       
                      _buildShimmerBox(
                        child: Container(
                          height: 12,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: ThemeColor.loadding,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      _buildShimmerBox(
                        child: Container(
                          height: 12,
                          width: 200,
                          decoration: BoxDecoration(
                            color: ThemeColor.loadding,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      _buildShimmerBox(
                        child: Container(
                          height: 11,
                          width: 150,
                          decoration: BoxDecoration(
                            color: ThemeColor.loadding,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      
                      if (hasImage) ...[
                        const SizedBox(height: 12),
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: ThemeColor.loaddingwithOpacity1,
                            borderRadius: ThemeColor.smallBorderRadius,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 40,
                              color: ThemeColor.loaddingwithOpacity3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}