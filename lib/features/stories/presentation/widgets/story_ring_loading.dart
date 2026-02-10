import 'package:flutter/material.dart';
import 'package:tendria/common/theme/App_Theme.dart';

class StoryRingLoading extends StatefulWidget {
  final double size;
  final bool multiple; 

  const StoryRingLoading({
    Key? key,
    this.size = 80,
    this.multiple = false,
  }) : super(key: key);
  @override
  State<StoryRingLoading> createState() => _StoryRingLoadingState();
}

class _StoryRingLoadingState extends State<StoryRingLoading>
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
  
  Widget build(BuildContext context) {
  return widget.multiple
      ? SizedBox(
          height: widget.size + 20,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildRing(), // 👈 usamos la función del ring
              );
            },
          ),
        )
      : _buildRing(); // 👈 solo uno
}
Widget _buildRing() {
  return AnimatedBuilder(
    animation: _shimmerAnimation,
    builder: (context, child) {
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
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: ThemeColor.loadding,
              width: 3,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ThemeColor.loadding,
              ),
            ),
          ),
        ),
      );
    },
  );
}

}