import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/advanced_options_section.dart' as advanced;
import './widgets/mindmap_preview_sheet.dart';
import './widgets/prompt_template_chip.dart';
import './widgets/voice_input_button.dart';

class AiMindmapCreation extends StatefulWidget {
  const AiMindmapCreation({super.key});

  @override
  State<AiMindmapCreation> createState() => _AiMindmapCreationState();
}

class _AiMindmapCreationState extends State<AiMindmapCreation>
    with TickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();
  final FocusNode _promptFocusNode = FocusNode();

  bool _isGenerating = false;
  bool _isAdvancedExpanded = false;
  String _selectedTemplate = '';
  advanced.MindmapStyle _selectedStyle = advanced.MindmapStyle.hierarchical;
  double _complexityLevel = 3.0;
  String _selectedColorScheme = 'Default';

  late AnimationController _generateButtonController;
  late Animation<double> _generateButtonAnimation;

  // Recent prompts for quick reuse
  final List<String> _recentPrompts = [
    'Create a study plan for machine learning',
    'Organize my home renovation project',
    'Plan a fitness routine for beginners',
    'Develop a content strategy for social media',
  ];

  // Template data
  final List<Map<String, dynamic>> _promptTemplates = [
    {
      'label': 'Business Planning',
      'icon': Icons.business_outlined,
      'prompt':
          'Create a comprehensive business plan for [your business idea] including market analysis, financial projections, marketing strategy, and operational structure.',
    },
    {
      'label': 'Study Notes',
      'icon': Icons.school_outlined,
      'prompt':
          'Organize study materials for [subject/topic] with key concepts, important dates, formulas, and practice questions structured for effective learning.',
    },
    {
      'label': 'Travel Planning',
      'icon': Icons.travel_explore_outlined,
      'prompt':
          'Plan a comprehensive trip to [destination] including itinerary, budget, accommodations, activities, and travel logistics.',
    },
    {
      'label': 'Project Management',
      'icon': Icons.assignment_outlined,
      'prompt':
          'Structure a project plan for [project name] including timeline, milestones, resource allocation, team responsibilities, and risk management.',
    },
    {
      'label': 'Creative Ideas',
      'icon': Icons.lightbulb_outlined,
      'prompt':
          'Generate creative ideas for [project/campaign] exploring different approaches, themes, target audiences, and innovative solutions.',
    },
    {
      'label': 'Learning Path',
      'icon': Icons.trending_up_outlined,
      'prompt':
          'Create a structured learning path for [skill/topic] with progressive milestones, resources, practice exercises, and assessment checkpoints.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _generateButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _generateButtonAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _generateButtonController,
      curve: Curves.easeInOut,
    ));

    _promptController.addListener(_onPromptChanged);
  }

  @override
  void dispose() {
    _promptController.dispose();
    _promptFocusNode.dispose();
    _generateButtonController.dispose();
    super.dispose();
  }

  void _onPromptChanged() {
    setState(() {});
  }

  bool get _canGenerate => _promptController.text.trim().length >= 10;

  void _onTemplateSelected(String template, String prompt) {
    setState(() {
      _selectedTemplate = template;
      _promptController.text = prompt;
    });
    HapticFeedback.lightImpact();
  }

  void _onVoiceTranscription(String transcription) {
    setState(() {
      _promptController.text = transcription;
    });
    _promptFocusNode.unfocus();
  }

  Future<void> _generateMindmap() async {
    if (!_canGenerate || _isGenerating) return;

    HapticFeedback.mediumImpact();
    _generateButtonController.forward().then((_) {
      _generateButtonController.reverse();
    });

    setState(() {
      _isGenerating = true;
    });

    _promptFocusNode.unfocus();

    // Add to recent prompts
    final prompt = _promptController.text.trim();
    if (!_recentPrompts.contains(prompt)) {
      _recentPrompts.insert(0, prompt);
      if (_recentPrompts.length > 5) {
        _recentPrompts.removeLast();
      }
    }

    // Simulate AI processing
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isGenerating = false;
    });

    // Show preview sheet
    _showPreviewSheet();
  }

  void _showPreviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MindmapPreviewSheet(
        generatedContent: _promptController.text,
        onAccept: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/mindmap-library');
          _showSuccessMessage('Mindmap created successfully!');
        },
        onRegenerate: () {
          Navigator.pop(context);
          _generateMindmap();
        },
        onEdit: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/mindmap-library');
        },
        onClose: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios',
            color: colorScheme.onSurface,
            size: 20,
          ),
        ),
        title: Text(
          'AI Mindmap Creation',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_canGenerate && !_isGenerating)
            TextButton(
              onPressed: _generateMindmap,
              child: Text(
                'Generate',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),

                  // Main Input Section
                  _buildInputSection(),

                  SizedBox(height: 3.h),

                  // Template Chips
                  _buildTemplateSection(),

                  SizedBox(height: 3.h),

                  // Recent Prompts
                  if (_recentPrompts.isNotEmpty) _buildRecentPromptsSection(),

                  SizedBox(height: 3.h),

                  // Advanced Options
                  advanced.AdvancedOptionsSection(
                    isExpanded: _isAdvancedExpanded,
                    onToggle: () {
                      setState(() {
                        _isAdvancedExpanded = !_isAdvancedExpanded;
                      });
                    },
                    selectedStyle: _selectedStyle,
                    onStyleChanged: (style) {
                      setState(() {
                        _selectedStyle = style;
                      });
                    },
                    complexityLevel: _complexityLevel,
                    onComplexityChanged: (level) {
                      setState(() {
                        _complexityLevel = level;
                      });
                    },
                    selectedColorScheme: _selectedColorScheme,
                    onColorSchemeChanged: (scheme) {
                      setState(() {
                        _selectedColorScheme = scheme;
                      });
                    },
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          // Generate Button
          _buildGenerateButton(),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _promptFocusNode.hasFocus
              ? colorScheme.primary
              : colorScheme.outline.withValues(alpha: 0.3),
          width: _promptFocusNode.hasFocus ? 2 : 1,
        ),
        boxShadow: _promptFocusNode.hasFocus
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input Header
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 1.h),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'psychology',
                  color: colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Describe any topic you want to visualize: "Learn Python programming", "Plan my wedding", "Organize team goals"...',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Text Input with Voice Button
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    focusNode: _promptFocusNode,
                    maxLines: 6,
                    minLines: 4,
                    decoration: InputDecoration(
                      hintText:
                          'Describe any topic you want to visualize: "Learn Python programming", "Plan my wedding", "Organize team goals"...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      height: 1.4,
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _promptFocusNode.unfocus(),
                  ),
                ),
                SizedBox(width: 3.w),
                VoiceInputButton(
                  onTranscriptionComplete: _onVoiceTranscription,
                ),
              ],
            ),
          ),

          // Character Counter
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _promptController.text.length < 10
                      ? 'Minimum 10 characters required'
                      : 'Ready to generate',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _promptController.text.length < 10
                        ? colorScheme.error
                        : colorScheme.primary,
                  ),
                ),
                Text(
                  '${_promptController.text.length}/500',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          child: Text(
            'Quick Templates',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: 1.h),
        SizedBox(
          height: 6.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 1.w),
            itemCount: _promptTemplates.length,
            itemBuilder: (context, index) {
              final template = _promptTemplates[index];
              return PromptTemplateChip(
                label: template['label'] as String,
                icon: template['icon'] as IconData,
                isSelected: _selectedTemplate == template['label'],
                onTap: () => _onTemplateSelected(
                  template['label'] as String,
                  template['prompt'] as String,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentPromptsSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          child: Text(
            'Recent Prompts',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: 1.h),
        ...(_recentPrompts.take(3).map((prompt) => Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 1.h),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _promptController.text = prompt;
                  });
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'history',
                        color: colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          prompt,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      CustomIconWidget(
                        iconName: 'arrow_forward_ios',
                        color: colorScheme.onSurfaceVariant,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ))),
      ],
    );
  }

  Widget _buildGenerateButton() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
        child: AnimatedBuilder(
          animation: _generateButtonAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _generateButtonAnimation.value,
              child: SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed:
                      _canGenerate && !_isGenerating ? _generateMindmap : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canGenerate
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.12),
                    foregroundColor: _canGenerate
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface.withValues(alpha: 0.38),
                    elevation: _canGenerate ? 2 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isGenerating
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.onPrimary,
                                ),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              'Generating Mindmap...',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colorScheme.onPrimary,
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
                              color: _canGenerate
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface
                                      .withValues(alpha: 0.38),
                              size: 20,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Generate Mindmap',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: _canGenerate
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface
                                        .withValues(alpha: 0.38),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}