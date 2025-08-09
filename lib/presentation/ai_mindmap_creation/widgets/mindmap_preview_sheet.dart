
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

enum MindmapStyle {
  hierarchical,
  radial,
  flowchart,
  organic,
}

class MindmapPreviewSheet extends StatefulWidget {
  final String generatedContent;
  final VoidCallback onAccept;
  final VoidCallback onRegenerate;
  final VoidCallback onEdit;
  final VoidCallback onClose;

  const MindmapPreviewSheet({
    super.key,
    required this.generatedContent,
    required this.onAccept,
    required this.onRegenerate,
    required this.onEdit,
    required this.onClose,
  });

  @override
  State<MindmapPreviewSheet> createState() => _MindmapPreviewSheetState();
}

class _MindmapPreviewSheetState extends State<MindmapPreviewSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _generateMindmapStructure(String content) {
    // Generate a dynamic mindmap structure based on user input
    final contentLower = content.toLowerCase();

    if (contentLower.contains('business') ||
        contentLower.contains('startup') ||
        contentLower.contains('company')) {
      return {
        'central_topic': _extractMainTopic(content, 'Business Plan'),
        'branches': [
          {
            'title': 'Market Analysis',
            'color': Colors.blue,
            'items': ['Target Audience', 'Competition', 'Market Size', 'Trends']
          },
          {
            'title': 'Financial Planning',
            'color': Colors.green,
            'items': ['Revenue Model', 'Funding', 'Expenses', 'Projections']
          },
          {
            'title': 'Marketing Strategy',
            'color': Colors.orange,
            'items': ['Brand Identity', 'Channels', 'Campaign Ideas', 'Metrics']
          },
          {
            'title': 'Operations',
            'color': Colors.purple,
            'items': ['Workflow', 'Team Structure', 'Tools', 'Processes']
          },
        ]
      };
    } else if (contentLower.contains('study') ||
        contentLower.contains('learn') ||
        contentLower.contains('education')) {
      return {
        'central_topic': _extractMainTopic(content, 'Learning Plan'),
        'branches': [
          {
            'title': 'Core Concepts',
            'color': Colors.blue,
            'items': [
              'Fundamentals',
              'Key Theories',
              'Principles',
              'Definitions'
            ]
          },
          {
            'title': 'Practice',
            'color': Colors.green,
            'items': ['Exercises', 'Projects', 'Case Studies', 'Applications']
          },
          {
            'title': 'Resources',
            'color': Colors.orange,
            'items': ['Books', 'Online Courses', 'Videos', 'Tools']
          },
          {
            'title': 'Assessment',
            'color': Colors.red,
            'items': ['Quizzes', 'Tests', 'Milestones', 'Review']
          },
        ]
      };
    } else if (contentLower.contains('travel') ||
        contentLower.contains('trip') ||
        contentLower.contains('vacation')) {
      return {
        'central_topic': _extractMainTopic(content, 'Travel Plan'),
        'branches': [
          {
            'title': 'Destinations',
            'color': Colors.blue,
            'items': ['Main Cities', 'Attractions', 'Hidden Gems', 'Day Trips']
          },
          {
            'title': 'Logistics',
            'color': Colors.green,
            'items': [
              'Transportation',
              'Accommodation',
              'Itinerary',
              'Documents'
            ]
          },
          {
            'title': 'Budget',
            'color': Colors.orange,
            'items': ['Flights', 'Hotels', 'Food', 'Activities']
          },
          {
            'title': 'Preparation',
            'color': Colors.purple,
            'items': ['Packing', 'Research', 'Bookings', 'Insurance']
          },
        ]
      };
    } else if (contentLower.contains('project') ||
        contentLower.contains('plan') ||
        contentLower.contains('organize')) {
      return {
        'central_topic': _extractMainTopic(content, 'Project Plan'),
        'branches': [
          {
            'title': 'Planning',
            'color': Colors.blue,
            'items': ['Goals', 'Timeline', 'Requirements', 'Scope']
          },
          {
            'title': 'Execution',
            'color': Colors.green,
            'items': ['Tasks', 'Milestones', 'Resources', 'Team']
          },
          {
            'title': 'Monitoring',
            'color': Colors.orange,
            'items': ['Progress', 'Quality', 'Risks', 'Issues']
          },
          {
            'title': 'Completion',
            'color': Colors.purple,
            'items': ['Delivery', 'Testing', 'Documentation', 'Review']
          },
        ]
      };
    } else {
      // Generic mindmap structure for any topic
      return {
        'central_topic': _extractMainTopic(content, 'Main Topic'),
        'branches': [
          {
            'title': 'Key Elements',
            'color': Colors.blue,
            'items': ['Element 1', 'Element 2', 'Element 3', 'Element 4']
          },
          {
            'title': 'Action Items',
            'color': Colors.green,
            'items': ['Action 1', 'Action 2', 'Action 3', 'Action 4']
          },
          {
            'title': 'Resources',
            'color': Colors.orange,
            'items': ['Resource 1', 'Resource 2', 'Resource 3', 'Resource 4']
          },
          {
            'title': 'Goals',
            'color': Colors.purple,
            'items': ['Goal 1', 'Goal 2', 'Goal 3', 'Goal 4']
          },
        ]
      };
    }
  }

  String _extractMainTopic(String content, String fallback) {
    // Extract the main topic from user input
    final words = content.split(' ');
    if (words.length >= 3) {
      return words.take(3).join(' ').replaceAll(RegExp(r'[^\w\s]'), '');
    }
    return content.length > 30 ? '${content.substring(0, 30)}...' : content;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mindmapData = _generateMindmapStructure(widget.generatedContent);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              height: 85.h,
              margin: EdgeInsets.only(top: 8.h),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle and Header
                  _buildHeader(theme, colorScheme),

                  // Preview Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 2.h),
                          _buildMindmapPreview(theme, colorScheme, mindmapData),
                          SizedBox(height: 4.h),
                        ],
                      ),
                    ),
                  ),

                  // Action Buttons
                  _buildActionButtons(theme, colorScheme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        children: [
          // Handle
          Container(
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          SizedBox(height: 2.h),

          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    'Mindmap Preview',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  widget.onClose();
                },
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMindmapPreview(ThemeData theme, ColorScheme colorScheme,
      Map<String, dynamic> mindmapData) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Central Topic
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.8)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              mindmapData['central_topic'],
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: 3.h),

          // Branches
          Wrap(
            spacing: 3.w,
            runSpacing: 2.h,
            alignment: WrapAlignment.center,
            children: (mindmapData['branches'] as List<Map<String, dynamic>>)
                .map((branch) {
              return _buildBranchPreview(theme, colorScheme, branch);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchPreview(
      ThemeData theme, ColorScheme colorScheme, Map<String, dynamic> branch) {
    final branchColor = branch['color'] as Color;
    return Container(
      width: 40.w,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: branchColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: branchColor.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branch Title
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: branchColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              branch['title'],
              style: theme.textTheme.labelLarge?.copyWith(
                color: branchColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(height: 1.h),

          // Branch Items
          ...(branch['items'] as List<String>).take(3).map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: 0.5.h),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: branchColor.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          if ((branch['items'] as List<String>).length > 3)
            Text(
              '...and more',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Regenerate Button
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  widget.onRegenerate();
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.outline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'refresh',
                      color: colorScheme.onSurface,
                      size: 18,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Regenerate',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: 3.w),

            // Accept Button
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  widget.onAccept();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'check_circle',
                      color: colorScheme.onPrimary,
                      size: 18,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Accept & Save',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
