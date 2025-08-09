import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class MindmapCardWidget extends StatelessWidget {
  final Map<String, dynamic> mindmap;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;
  final VoidCallback? onArchive;
  final VoidCallback? onRename;
  final VoidCallback? onMoveToFolder;
  final VoidCallback? onExport;

  const MindmapCardWidget({
    super.key,
    required this.mindmap,
    this.onTap,
    this.onShare,
    this.onDuplicate,
    this.onDelete,
    this.onArchive,
    this.onRename,
    this.onMoveToFolder,
    this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showContextMenu(context);
      },
      child: Dismissible(
        key: Key('mindmap_${mindmap["id"]}'),
        background: _buildSwipeBackground(context, isLeft: false),
        secondaryBackground: _buildSwipeBackground(context, isLeft: true),
        onDismissed: (direction) {
          if (direction == DismissDirection.startToEnd) {
            onShare?.call();
          } else if (direction == DismissDirection.endToStart) {
            onDelete?.call();
          }
        },
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            _showShareOptions(context);
            return false;
          } else if (direction == DismissDirection.endToStart) {
            return await _showDeleteConfirmation(context);
          }
          return false;
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail preview
              Container(
                height: 20.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Stack(
                  children: [
                    // Mindmap preview placeholder
                    Center(
                      child: CustomIconWidget(
                        iconName: 'account_tree',
                        color: colorScheme.primary,
                        size: 32,
                      ),
                    ),
                    // Collaboration status indicator
                    if (mindmap["isShared"] == true)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor(isLight),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CustomIconWidget(
                            iconName: 'people',
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    // Favorite indicator
                    if (mindmap["isFavorite"] == true)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: CustomIconWidget(
                          iconName: 'favorite',
                          color: AppTheme.warningColor(isLight),
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),

              // Content section
              Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      mindmap["title"] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 1.h),

                    // Last modified date
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'schedule',
                          color: colorScheme.onSurfaceVariant,
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Expanded(
                          child: Text(
                            _formatDate(mindmap["lastModified"] as DateTime),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 1.h),

                    // Node count and category
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'hub',
                              color: colorScheme.onSurfaceVariant,
                              size: 14,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '${mindmap["nodeCount"]} nodes',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            mindmap["category"] as String,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(BuildContext context, {required bool isLeft}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isLeft
            ? AppTheme.errorColor(
                Theme.of(context).brightness == Brightness.light)
            : AppTheme.successColor(
                Theme.of(context).brightness == Brightness.light),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: isLeft ? 'delete' : 'share',
                color: Colors.white,
                size: 24,
              ),
              SizedBox(height: 0.5.h),
              Text(
                isLeft ? 'Delete' : 'Share',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              mindmap["title"] as String,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),
            _buildContextMenuItem(context, 'edit', 'Rename', onRename),
            _buildContextMenuItem(
                context, 'folder', 'Move to Folder', onMoveToFolder),
            _buildContextMenuItem(context, 'file_download', 'Export', onExport),
            _buildContextMenuItem(
                context, 'content_copy', 'Duplicate', onDuplicate),
            _buildContextMenuItem(context, 'archive', 'Archive', onArchive),
            _buildContextMenuItem(context, 'delete', 'Delete', onDelete,
                isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildContextMenuItem(
    BuildContext context,
    String iconName,
    String label,
    VoidCallback? onTap, {
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color: isDestructive
            ? AppTheme.errorColor(isLight)
            : colorScheme.onSurface,
        size: 20,
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: isDestructive
              ? AppTheme.errorColor(isLight)
              : colorScheme.onSurface,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        HapticFeedback.lightImpact();
        onTap?.call();
      },
    );
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Share Options',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 2.h),
            _buildContextMenuItem(context, 'share', 'Share Link', onShare),
            _buildContextMenuItem(
                context, 'content_copy', 'Duplicate', onDuplicate),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Delete Mindmap',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Are you sure you want to delete "${mindmap["title"]}"? This action cannot be undone.',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor(
                      Theme.of(context).brightness == Brightness.light),
                ),
                child: Text('Delete'),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ) ??
        false;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}