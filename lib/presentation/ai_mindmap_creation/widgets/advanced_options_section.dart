import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

enum MindmapStyle { hierarchical, radial, flowchart }

class AdvancedOptionsSection extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final MindmapStyle selectedStyle;
  final Function(MindmapStyle) onStyleChanged;
  final double complexityLevel;
  final Function(double) onComplexityChanged;
  final String selectedColorScheme;
  final Function(String) onColorSchemeChanged;

  const AdvancedOptionsSection({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.selectedStyle,
    required this.onStyleChanged,
    required this.complexityLevel,
    required this.onComplexityChanged,
    required this.selectedColorScheme,
    required this.onColorSchemeChanged,
  });

  @override
  State<AdvancedOptionsSection> createState() => _AdvancedOptionsSectionState();
}

class _AdvancedOptionsSectionState extends State<AdvancedOptionsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  final List<String> _colorSchemes = [
    'Default',
    'Ocean Blue',
    'Forest Green',
    'Sunset Orange',
    'Purple Dream',
    'Monochrome',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (widget.isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AdvancedOptionsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onToggle();
            },
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'tune',
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Advanced Options',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: widget.isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: CustomIconWidget(
                      iconName: 'keyboard_arrow_down',
                      color: colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable Content
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _expandAnimation.value,
                  child: child,
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mindmap Style Selection
                  _buildSectionTitle('Mindmap Style'),
                  SizedBox(height: 1.h),
                  _buildStyleSelector(),

                  SizedBox(height: 3.h),

                  // Complexity Level
                  _buildSectionTitle('Complexity Level'),
                  SizedBox(height: 1.h),
                  _buildComplexitySlider(),

                  SizedBox(height: 3.h),

                  // Color Scheme
                  _buildSectionTitle('Color Scheme'),
                  SizedBox(height: 1.h),
                  _buildColorSchemeSelector(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
    );
  }

  Widget _buildStyleSelector() {
    return Row(
      children: MindmapStyle.values.map((style) {
        final isSelected = widget.selectedStyle == style;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onStyleChanged(style);
            },
            child: Container(
              margin: EdgeInsets.only(
                  right: style != MindmapStyle.values.last ? 2.w : 0),
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1)
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  CustomIconWidget(
                    iconName: _getStyleIcon(style),
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    _getStyleLabel(style),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 10.sp,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildComplexitySlider() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Simple',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              'Complex',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: colorScheme.primary,
            thumbColor: colorScheme.primary,
            overlayColor: colorScheme.primary.withValues(alpha: 0.2),
            inactiveTrackColor: colorScheme.primary.withValues(alpha: 0.3),
            trackHeight: 4,
          ),
          child: Slider(
            value: widget.complexityLevel,
            min: 1.0,
            max: 5.0,
            divisions: 4,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              widget.onComplexityChanged(value);
            },
          ),
        ),
        Text(
          'Level ${widget.complexityLevel.round()}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildColorSchemeSelector() {
    return SizedBox(
      height: 6.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _colorSchemes.length,
        itemBuilder: (context, index) {
          final scheme = _colorSchemes[index];
          final isSelected = widget.selectedColorScheme == scheme;

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onColorSchemeChanged(scheme);
            },
            child: Container(
              margin: EdgeInsets.only(right: 2.w),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Text(
                  scheme,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.w400,
                      ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getStyleIcon(MindmapStyle style) {
    switch (style) {
      case MindmapStyle.hierarchical:
        return 'account_tree';
      case MindmapStyle.radial:
        return 'hub';
      case MindmapStyle.flowchart:
        return 'timeline';
    }
  }

  String _getStyleLabel(MindmapStyle style) {
    switch (style) {
      case MindmapStyle.hierarchical:
        return 'Hierarchical';
      case MindmapStyle.radial:
        return 'Radial';
      case MindmapStyle.flowchart:
        return 'Flowchart';
    }
  }
}
