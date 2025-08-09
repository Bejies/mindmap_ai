import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CreateMindmapModalWidget extends StatefulWidget {
  final Function(String, bool)? onCreateMindmap;

  const CreateMindmapModalWidget({
    super.key,
    this.onCreateMindmap,
  });

  @override
  State<CreateMindmapModalWidget> createState() =>
      _CreateMindmapModalWidgetState();
}

class _CreateMindmapModalWidgetState extends State<CreateMindmapModalWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  bool _isCreating = false;

  final List<Map<String, dynamic>> _templates = [
    {
      "id": 1,
      "title": "Project Planning",
      "description": "Organize tasks, timelines, and resources",
      "icon": "project_diagram",
      "category": "Business",
    },
    {
      "id": 2,
      "title": "Study Notes",
      "description": "Structure learning materials and concepts",
      "icon": "school",
      "category": "Education",
    },
    {
      "id": 3,
      "title": "Brainstorming",
      "description": "Generate and organize creative ideas",
      "icon": "lightbulb",
      "category": "Creative",
    },
    {
      "id": 4,
      "title": "Meeting Notes",
      "description": "Capture and organize meeting discussions",
      "icon": "meeting_room",
      "category": "Business",
    },
    {
      "id": 5,
      "title": "Goal Setting",
      "description": "Plan and track personal or professional goals",
      "icon": "flag",
      "category": "Personal",
    },
    {
      "id": 6,
      "title": "Decision Making",
      "description": "Analyze options and make informed choices",
      "icon": "psychology",
      "category": "Analysis",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _promptController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Create New Mindmap',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'AI Generate'),
                Tab(text: 'Templates'),
              ],
              labelStyle: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
              indicator: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              dividerColor: Colors.transparent,
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAIGenerateTab(context, colorScheme),
                _buildTemplatesTab(context, colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIGenerateTab(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),

          // AI Icon and Description
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'psychology',
                  color: colorScheme.tertiary,
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI-Powered Generation',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      'Describe your topic and let AI create a structured mindmap',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Title Input
          Text(
            'Mindmap Title',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          SizedBox(height: 1.h),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Enter mindmap title...',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'title',
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Prompt Input
          Text(
            'AI Prompt',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          SizedBox(height: 1.h),
          TextField(
            controller: _promptController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'Describe what you want to create a mindmap about...\n\nExample: "Create a mindmap for planning a mobile app development project including design, development, testing, and launch phases"',
              alignLabelWithHint: true,
            ),
          ),

          SizedBox(height: 2.h),

          // Example prompts
          Text(
            'Example Prompts',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: [
              _buildExampleChip(
                  context, 'Marketing strategy for new product launch'),
              _buildExampleChip(
                  context, 'Study plan for computer science degree'),
              _buildExampleChip(
                  context, 'Wedding planning checklist and timeline'),
            ],
          ),

          const Spacer(),

          // Create Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isCreating ? null : _handleAIGenerate,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isCreating
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Generating...',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'auto_awesome',
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Generate with AI',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesTab(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          Text(
            'Choose a Template',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Start with a pre-designed structure and customize as needed',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 3.w,
                mainAxisSpacing: 2.h,
                childAspectRatio: 0.85,
              ),
              itemCount: _templates.length,
              itemBuilder: (context, index) {
                final template = _templates[index];
                return _buildTemplateCard(context, template, colorScheme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    Map<String, dynamic> template,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: () => _handleTemplateSelect(template),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and Category
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: template["icon"] as String,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    template["category"] as String,
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Title
            Text(
              template["title"] as String,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 1.h),

            // Description
            Expanded(
              child: Text(
                template["description"] as String,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleChip(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        _promptController.text = text;
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  void _handleAIGenerate() async {
    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a prompt to generate mindmap'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    HapticFeedback.mediumImpact();

    // Simulate AI generation delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isCreating = false;
    });

    final title = _titleController.text.trim().isEmpty
        ? 'AI Generated Mindmap'
        : _titleController.text.trim();

    widget.onCreateMindmap?.call(title, true);
    Navigator.pop(context);
  }

  void _handleTemplateSelect(Map<String, dynamic> template) {
    HapticFeedback.lightImpact();
    widget.onCreateMindmap?.call(template["title"] as String, false);
    Navigator.pop(context);
  }
}