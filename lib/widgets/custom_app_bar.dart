import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom app bar widget implementing Intelligent Minimalism design
/// with contextual actions and smooth transitions for mindmapping application
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation = 0,
    this.backgroundColor,
    this.foregroundColor,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: foregroundColor ?? colorScheme.onSurface,
          letterSpacing: 0.15,
        ),
      ),
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading ??
          (automaticallyImplyLeading && Navigator.canPop(context)
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: foregroundColor ?? colorScheme.onSurface,
                  ),
                  onPressed: onBackPressed ??
                      () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                  tooltip: 'Back',
                )
              : null),
      actions: actions ?? _buildDefaultActions(context, isLight),
      bottom: bottom,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
        statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
      ),
    );
  }

  List<Widget> _buildDefaultActions(BuildContext context, bool isLight) {
    final colorScheme = Theme.of(context).colorScheme;

    return [
      // Search action for mindmap library
      IconButton(
        icon: Icon(
          Icons.search_rounded,
          color: colorScheme.onSurface,
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          _showSearchDialog(context);
        },
        tooltip: 'Search mindmaps',
      ),

      // More options menu
      PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert_rounded,
          color: colorScheme.onSurface,
        ),
        onSelected: (value) {
          HapticFeedback.lightImpact();
          _handleMenuAction(context, value);
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'settings',
            child: Row(
              children: [
                Icon(Icons.settings_rounded, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Settings',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'help',
            child: Row(
              children: [
                Icon(Icons.help_outline_rounded, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Help & Support',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'about',
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 20),
                const SizedBox(width: 12),
                Text(
                  'About',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 8,
      ),
      const SizedBox(width: 8),
    ];
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Search Mindmaps',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter search terms...',
            prefixIcon: Icon(Icons.search_rounded),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onSubmitted: (value) {
            Navigator.pop(context);
            // Implement search functionality
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement search functionality
            },
            child: Text('Search'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'settings':
        // Navigate to settings or show settings dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Settings feature coming soon'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 'help':
        // Navigate to help section
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Help & Support feature coming soon'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 'about':
        // Show about dialog
        _showAboutDialog(context);
        break;
    }
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'MindMap AI',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.psychology_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            'An intelligent mindmapping application that transforms complex information visualization into natural gesture-based interactions with AI assistance.',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}
