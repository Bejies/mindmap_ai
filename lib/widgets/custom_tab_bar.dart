import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tab item data structure for custom tab bar
class TabItem {
  final String label;
  final IconData? icon;
  final Widget? customIcon;
  final String? route;

  const TabItem({
    required this.label,
    this.icon,
    this.customIcon,
    this.route,
  });
}

/// Custom tab bar widget implementing Progressive Disclosure Toolbar pattern
/// with smooth transitions and contextual content organization
class CustomTabBar extends StatefulWidget implements PreferredSizeWidget {
  final List<TabItem> tabs;
  final int initialIndex;
  final Function(int)? onTap;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? indicatorColor;
  final double height;
  final bool isScrollable;
  final EdgeInsetsGeometry? padding;
  final TabController? controller;

  const CustomTabBar({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.onTap,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.indicatorColor,
    this.height = 48.0,
    this.isScrollable = false,
    this.padding,
    this.controller,
  });

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _CustomTabBarState extends State<CustomTabBar>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _indicatorAnimationController;
  late Animation<double> _indicatorAnimation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    _tabController = widget.controller ??
        TabController(
          length: widget.tabs.length,
          vsync: this,
          initialIndex: widget.initialIndex,
        );

    _indicatorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _indicatorAnimation = CurvedAnimation(
      parent: _indicatorAnimationController,
      curve: Curves.fastOutSlowIn,
    );

    _tabController.addListener(_handleTabChange);
    _indicatorAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    if (widget.controller == null) {
      _tabController.dispose();
    }
    _indicatorAnimationController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      final newIndex = _tabController.index;
      if (newIndex != _currentIndex) {
        HapticFeedback.lightImpact();
        setState(() {
          _currentIndex = newIndex;
        });

        // Navigate to route if specified
        final selectedTab = widget.tabs[newIndex];
        if (selectedTab.route != null) {
          Navigator.pushNamed(context, selectedTab.route!);
        }

        widget.onTap?.call(newIndex);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: widget.height,
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: widget.tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          return _buildTab(context, tab, index == _currentIndex, colorScheme);
        }).toList(),
        isScrollable: widget.isScrollable,
        labelColor: widget.selectedColor ?? colorScheme.primary,
        unselectedLabelColor:
            widget.unselectedColor ?? colorScheme.onSurfaceVariant,
        indicatorColor: widget.indicatorColor ?? colorScheme.primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        dividerColor: Colors.transparent,
        tabAlignment:
            widget.isScrollable ? TabAlignment.start : TabAlignment.fill,
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    TabItem tabItem,
    bool isSelected,
    ColorScheme colorScheme,
  ) {
    final selectedColor = widget.selectedColor ?? colorScheme.primary;
    final unselectedColor =
        widget.unselectedColor ?? colorScheme.onSurfaceVariant;

    return AnimatedBuilder(
      animation: _indicatorAnimation,
      builder: (context, child) {
        return Tab(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon (if provided)
                if (tabItem.icon != null || tabItem.customIcon != null) ...[
                  AnimatedScale(
                    scale: isSelected ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: tabItem.customIcon ??
                        Icon(
                          tabItem.icon,
                          size: 20,
                          color: isSelected ? selectedColor : unselectedColor,
                        ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Label with smooth transition
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    color: isSelected ? selectedColor : unselectedColor,
                    letterSpacing: 0.1,
                  ),
                  child: Text(
                    tabItem.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Specialized tab bar for mindmap content organization
class MindmapTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController? controller;
  final Function(int)? onTap;

  const MindmapTabBar({
    super.key,
    this.controller,
    this.onTap,
  });

  static const List<TabItem> _mindmapTabs = [
    TabItem(
      label: 'Overview',
      icon: Icons.dashboard_outlined,
    ),
    TabItem(
      label: 'Nodes',
      icon: Icons.account_tree_outlined,
    ),
    TabItem(
      label: 'Connections',
      icon: Icons.hub_outlined,
    ),
    TabItem(
      label: 'AI Insights',
      icon: Icons.psychology_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomTabBar(
      tabs: _mindmapTabs,
      controller: controller,
      onTap: onTap,
      isScrollable: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48.0);
}

/// Specialized tab bar for export and sharing options
class ExportTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController? controller;
  final Function(int)? onTap;

  const ExportTabBar({
    super.key,
    this.controller,
    this.onTap,
  });

  static const List<TabItem> _exportTabs = [
    TabItem(
      label: 'Formats',
      icon: Icons.file_download_outlined,
    ),
    TabItem(
      label: 'Share',
      icon: Icons.share_outlined,
    ),
    TabItem(
      label: 'Collaborate',
      icon: Icons.people_outline,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomTabBar(
      tabs: _exportTabs,
      controller: controller,
      onTap: onTap,
      isScrollable: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48.0);
}
