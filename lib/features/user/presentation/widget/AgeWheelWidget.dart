// En preferences_page.dart, reemplaza _buildAgeWheel con esto:

import 'package:flutter/widgets.dart';
import 'package:tendria/common/theme/App_Theme.dart';

class AgeWheelWidget extends StatefulWidget {
  final int initialAge;
  final void Function(int) onChanged;

  const AgeWheelWidget({
    required this.initialAge,
    required this.onChanged,
  });

  @override
  State<AgeWheelWidget> createState() => _AgeWheelWidgetState();
}

class _AgeWheelWidgetState extends State<AgeWheelWidget> {
  late FixedExtentScrollController _scrollController;
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialAge;
    _scrollController = FixedExtentScrollController(
      initialItem: (widget.initialAge - 18).clamp(0, 62),
    );
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
        setState(() => _selected = 18 + index);
        widget.onChanged(18 + index);
      },
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: 63,
        builder: (context, index) {
          final isSelected = index == _selected - 18;
          return Container(
            height: 60,
            alignment: Alignment.center,
            child: Text(
              '${18 + index}',
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