import 'package:flutter/widgets.dart';
import 'package:tendria/common/theme/App_Theme.dart';

class DistanceWheelWidget extends StatefulWidget {
  final double initialDistance;
  final void Function(double) onChanged;

  const DistanceWheelWidget({
    required this.initialDistance,
    required this.onChanged,
  });

  @override
  State<DistanceWheelWidget> createState() => _DistanceWheelWidgetState();
}

class _DistanceWheelWidgetState extends State<DistanceWheelWidget> {
  late FixedExtentScrollController _scrollController;
  late int _selected;

  int _indexForDistance(double d) {
    if (d < 1) return ((d * 10).round() - 1).clamp(0, 8);
    return (9 + (d.toInt() - 1)).clamp(0, 1008);
  }

  String _labelForIndex(int index) {
    if (index < 9) return '${(index + 1) * 100} m';
    final km = index - 9 + 1;
    return km >= 1000 ? 'Máximo' : '$km km';
  }

  double _kmForIndex(int index) {
    if (index < 9) return ((index + 1) * 100) / 1000.0;
    return (index - 9 + 1).toDouble();
  }

  @override
  void initState() {
    super.initState();
    _selected = _indexForDistance(widget.initialDistance);
    _scrollController = FixedExtentScrollController(initialItem: _selected);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      controller: _scrollController,
      itemExtent: 60,
      diameterRatio: 1.5,
      perspective: 0.003,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: (index) {
        setState(() => _selected = index);
        widget.onChanged(_kmForIndex(index));
      },
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: 1009,
        builder: (context, index) {
          final isSelected = index == _selected;
          return Container(
            height: 60,
            alignment: Alignment.center,
            child: Text(
              _labelForIndex(index),
              style: ThemeColor.bodyLarge.copyWith(
                color: isSelected
                    ? ThemeColor.textDarkColor
                    : ThemeColor.textSecondaryColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: isSelected ? 20 : 16,
              ),
            ),
          );
        },
      ),
    );
  }
}
