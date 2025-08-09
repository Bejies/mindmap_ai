import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/category_filter_chip_widget.dart';
import './widgets/create_mindmap_modal_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/mindmap_card_widget.dart';
import './widgets/search_bar_widget.dart';

class MindmapLibrary extends StatefulWidget {
  const MindmapLibrary({super.key});

  @override
  State<MindmapLibrary> createState() => _MindmapLibraryState();
}

class _MindmapLibraryState extends State<MindmapLibrary>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _selectedCategory = 'Recent';
  String _searchQuery = '';
  bool _isRefreshing = false;
  bool _isSearchExpanded = false;

  final List<String> _categories = [
    'Recent',
    'Favorites',
    'Shared',
    'Templates',
  ];

  final Map<String, String> _categoryIcons = {
    'Recent': 'schedule',
    'Favorites': 'favorite',
    'Shared': 'people',
    'Templates': 'template_add',
  };

  final List<Map<String, dynamic>> _mindmaps = [
    {
      "id": 1,
      "title": "Mobile App Development Project",
      "lastModified": DateTime.now().subtract(const Duration(hours: 2)),
      "nodeCount": 24,
      "category": "Business",
      "isShared": true,
      "isFavorite": false,
      "isTemplate": false,
    },
    {
      "id": 2,
      "title": "Computer Science Study Plan",
      "lastModified": DateTime.now().subtract(const Duration(days: 1)),
      "nodeCount": 18,
      "category": "Education",
      "isShared": false,
      "isFavorite": true,
      "isTemplate": false,
    },
    {
      "id": 3,
      "title": "Marketing Strategy Q4 2024",
      "lastModified": DateTime.now().subtract(const Duration(days: 3)),
      "nodeCount": 32,
      "category": "Business",
      "isShared": true,
      "isFavorite": true,
      "isTemplate": false,
    },
    {
      "id": 4,
      "title": "Wedding Planning Checklist",
      "lastModified": DateTime.now().subtract(const Duration(days: 5)),
      "nodeCount": 45,
      "category": "Personal",
      "isShared": false,
      "isFavorite": false,
      "isTemplate": false,
    },
    {
      "id": 5,
      "title": "Project Management Template",
      "lastModified": DateTime.now().subtract(const Duration(days: 7)),
      "nodeCount": 16,
      "category": "Templates",
      "isShared": false,
      "isFavorite": false,
      "isTemplate": true,
    },
    {
      "id": 6,
      "title": "AI Research Topics",
      "lastModified": DateTime.now().subtract(const Duration(days: 10)),
      "nodeCount": 28,
      "category": "Research",
      "isShared": true,
      "isFavorite": false,
      "isTemplate": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Handle scroll events for potential infinite loading
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'MindMap Library',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _handleSync,
            icon: CustomIconWidget(
              iconName: 'sync',
              color: colorScheme.onSurface,
              size: 24,
            ),
            tooltip: 'Sync with cloud',
          ),
          IconButton(
            onPressed: _handleSettings,
            icon: CustomIconWidget(
              iconName: 'settings',
              color: colorScheme.onSurface,
              size: 24,
            ),
            tooltip: 'Settings',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Library'),
            Tab(text: 'Create'),
            Tab(text: 'Profile'),
          ],
          labelStyle: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          dividerColor: Colors.transparent,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLibraryTab(context, colorScheme),
          _buildCreateTab(context, colorScheme),
          _buildProfileTab(context, colorScheme),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _showCreateMindmapModal,
              child: CustomIconWidget(
                iconName: 'add',
                color: Colors.white,
                size: 24,
              ),
              tooltip: 'Create new mindmap',
            )
          : null,
    );
  }

  Widget _buildLibraryTab(BuildContext context, ColorScheme colorScheme) {
    final filteredMindmaps = _getFilteredMindmaps();

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: Column(
        children: [
          // Search Bar
          SearchBarWidget(
            controller: _searchController,
            hintText: 'Search mindmaps and content...',
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            onClear: () {
              setState(() {
                _searchQuery = '';
              });
            },
          ),

          // Category Filter Chips
          Container(
            height: 6.h,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final count = _getCategoryCount(category);
                return CategoryFilterChipWidget(
                  label: category,
                  count: count,
                  isSelected: _selectedCategory == category,
                  iconName: _categoryIcons[category]!,
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                    HapticFeedback.lightImpact();
                  },
                );
              },
            ),
          ),

          // Content
          Expanded(
            child: filteredMindmaps.isEmpty
                ? EmptyStateWidget(
                    onCreateMindmap: _showCreateMindmapModal,
                    onBrowseTemplates: () {
                      setState(() {
                        _selectedCategory = 'Templates';
                      });
                    },
                  )
                : _buildMindmapGrid(context, filteredMindmaps, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildMindmapGrid(
    BuildContext context,
    List<Map<String, dynamic>> mindmaps,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: GridView.builder(
        controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(),
          crossAxisSpacing: 2.w,
          mainAxisSpacing: 1.h,
          childAspectRatio: 0.75,
        ),
        itemCount: mindmaps.length,
        itemBuilder: (context, index) {
          final mindmap = mindmaps[index];
          return MindmapCardWidget(
            mindmap: mindmap,
            onTap: () => _handleMindmapTap(mindmap),
            onShare: () => _handleShare(mindmap),
            onDuplicate: () => _handleDuplicate(mindmap),
            onDelete: () => _handleDelete(mindmap),
            onArchive: () => _handleArchive(mindmap),
            onRename: () => _handleRename(mindmap),
            onMoveToFolder: () => _handleMoveToFolder(mindmap),
            onExport: () => _handleExport(mindmap),
          );
        },
      ),
    );
  }

  Widget _buildCreateTab(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'psychology',
              color: colorScheme.primary,
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              'Create Tab',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'AI mindmap creation features will be available here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/ai-mindmap-creation'),
              child: Text('Go to AI Creation'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'person',
              color: colorScheme.primary,
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              'Profile Tab',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'User profile and settings will be available here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  int _getCrossAxisCount() {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      return 3; // Tablet
    }
    return 2; // Phone
  }

  List<Map<String, dynamic>> _getFilteredMindmaps() {
    List<Map<String, dynamic>> filtered = _mindmaps;

    // Filter by category
    if (_selectedCategory != 'Recent') {
      filtered = filtered.where((mindmap) {
        switch (_selectedCategory) {
          case 'Favorites':
            return mindmap["isFavorite"] == true;
          case 'Shared':
            return mindmap["isShared"] == true;
          case 'Templates':
            return mindmap["isTemplate"] == true;
          default:
            return true;
        }
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((mindmap) {
        final title = (mindmap["title"] as String).toLowerCase();
        final category = (mindmap["category"] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return title.contains(query) || category.contains(query);
      }).toList();
    }

    // Sort by last modified for Recent
    if (_selectedCategory == 'Recent') {
      filtered.sort((a, b) => (b["lastModified"] as DateTime)
          .compareTo(a["lastModified"] as DateTime));
    }

    return filtered;
  }

  int _getCategoryCount(String category) {
    switch (category) {
      case 'Recent':
        return _mindmaps.length;
      case 'Favorites':
        return _mindmaps.where((m) => m["isFavorite"] == true).length;
      case 'Shared':
        return _mindmaps.where((m) => m["isShared"] == true).length;
      case 'Templates':
        return _mindmaps.where((m) => m["isTemplate"] == true).length;
      default:
        return 0;
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    HapticFeedback.mediumImpact();

    // Simulate cloud sync
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mindmaps synced successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCreateMindmapModal() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateMindmapModalWidget(
        onCreateMindmap: (title, isAI) {
          _handleCreateMindmap(title, isAI);
        },
      ),
    );
  }

  void _handleCreateMindmap(String title, bool isAI) {
    HapticFeedback.lightImpact();

    if (isAI) {
      Navigator.pushNamed(context, '/ai-mindmap-creation');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Creating mindmap: $title'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleMindmapTap(Map<String, dynamic> mindmap) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening: ${mindmap["title"]}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleShare(Map<String, dynamic> mindmap) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/export-and-share');
  }

  void _handleDuplicate(Map<String, dynamic> mindmap) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Duplicated: ${mindmap["title"]}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleDelete(Map<String, dynamic> mindmap) {
    HapticFeedback.mediumImpact();
    setState(() {
      _mindmaps.removeWhere((m) => m["id"] == mindmap["id"]);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted: ${mindmap["title"]}'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _mindmaps.add(mindmap);
            });
          },
        ),
      ),
    );
  }

  void _handleArchive(Map<String, dynamic> mindmap) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Archived: ${mindmap["title"]}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleRename(Map<String, dynamic> mindmap) {
    HapticFeedback.lightImpact();
    _showRenameDialog(mindmap);
  }

  void _handleMoveToFolder(Map<String, dynamic> mindmap) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Move to folder: ${mindmap["title"]}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleExport(Map<String, dynamic> mindmap) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/export-and-share');
  }

  void _handleSync() {
    HapticFeedback.lightImpact();
    _handleRefresh();
  }

  void _handleSettings() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Settings feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showRenameDialog(Map<String, dynamic> mindmap) {
    final TextEditingController renameController = TextEditingController();
    renameController.text = mindmap["title"] as String;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Rename Mindmap',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: renameController,
          decoration: InputDecoration(
            labelText: 'New name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (renameController.text.trim().isNotEmpty) {
                setState(() {
                  mindmap["title"] = renameController.text.trim();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Renamed to: ${renameController.text.trim()}'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text('Rename'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}