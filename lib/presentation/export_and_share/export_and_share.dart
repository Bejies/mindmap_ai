import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/collaboration_card.dart';
import './widgets/export_format_card.dart';
import './widgets/export_progress_dialog.dart';
import './widgets/qr_code_widget.dart';
import './widgets/share_option_card.dart';

class ExportAndShare extends StatefulWidget {
  const ExportAndShare({super.key});

  @override
  State<ExportAndShare> createState() => _ExportAndShareState();
}

class _ExportAndShareState extends State<ExportAndShare>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFormat = 'PDF';
  String _selectedQuality = 'High';
  bool _includeMetadata = true;

  // Mock mindmap data
  final Map<String, dynamic> _currentMindmap = {
    "id": "mindmap_001",
    "title": "Project Planning Mindmap",
    "created": "2025-01-08T10:30:00Z",
    "nodes": [
      {
        "id": "root",
        "text": "Project Planning",
        "x": 400,
        "y": 300,
        "color": "#2563EB",
        "children": ["planning", "execution", "review"]
      },
      {
        "id": "planning",
        "text": "Planning Phase",
        "x": 200,
        "y": 200,
        "color": "#059669",
        "children": ["research", "timeline"]
      },
      {
        "id": "execution",
        "text": "Execution Phase",
        "x": 400,
        "y": 150,
        "color": "#D97706",
        "children": ["development", "testing"]
      },
      {
        "id": "review",
        "text": "Review Phase",
        "x": 600,
        "y": 200,
        "color": "#DC2626",
        "children": ["analysis", "feedback"]
      }
    ],
    "connections": [
      {"from": "root", "to": "planning"},
      {"from": "root", "to": "execution"},
      {"from": "root", "to": "review"}
    ]
  };

  final List<Map<String, dynamic>> _exportFormats = [
    {
      "title": "PDF Document",
      "description":
          "Vector-based format perfect for printing and professional sharing",
      "icon": "picture_as_pdf",
      "format": "PDF",
      "fileSize": "2.4 MB",
      "qualities": ["Standard", "High", "Print Quality"]
    },
    {
      "title": "PNG Image",
      "description":
          "High-resolution image format ideal for presentations and web",
      "icon": "image",
      "format": "PNG",
      "fileSize": "1.8 MB",
      "qualities": ["1x", "2x", "4x"]
    },
    {
      "title": "JSON Data",
      "description":
          "Raw data format for importing into other mindmap applications",
      "icon": "data_object",
      "format": "JSON",
      "fileSize": "156 KB",
      "qualities": ["Compact", "Formatted"]
    }
  ];

  final List<Map<String, dynamic>> _shareOptions = [
    {
      "title": "Native Share",
      "subtitle": "Share via installed apps on your device",
      "icon": "share",
      "action": "native_share"
    },
    {
      "title": "Email",
      "subtitle": "Send as attachment with customizable message",
      "icon": "email",
      "action": "email"
    },
    {
      "title": "Cloud Storage",
      "subtitle": "Upload to Google Drive, Dropbox, or iCloud",
      "icon": "cloud_upload",
      "action": "cloud"
    },
    {
      "title": "Social Media",
      "subtitle": "Share optimized version on social platforms",
      "icon": "share_outlined",
      "action": "social"
    }
  ];

  final List<Map<String, dynamic>> _collaborationOptions = [
    {
      "title": "View Only Link",
      "description": "Recipients can view but not edit the mindmap",
      "icon": "visibility",
      "accessLevel": "View Only",
      "hasExpiration": false
    },
    {
      "title": "Comment Access",
      "description": "Recipients can view and add comments to nodes",
      "icon": "comment",
      "accessLevel": "Comment",
      "hasExpiration": true
    },
    {
      "title": "Edit Permission",
      "description": "Recipients can view, comment, and edit the mindmap",
      "icon": "edit",
      "accessLevel": "Edit",
      "hasExpiration": true
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _exportMindmap() async {
    final selectedFormatData = _exportFormats.firstWhere(
      (format) => format['format'] == _selectedFormat,
    );

    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ExportProgressDialog(
        fileName:
            '${_currentMindmap['title']}.${_selectedFormat.toLowerCase()}',
        format: _selectedFormat,
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );

    // Simulate export process
    await Future.delayed(const Duration(seconds: 3));

    // Generate export content based on format
    String content = '';
    String fileName = '';

    switch (_selectedFormat) {
      case 'PDF':
        content = _generatePDFContent();
        fileName = '${_currentMindmap['title']}.pdf';
        break;
      case 'PNG':
        content = _generateImageContent();
        fileName = '${_currentMindmap['title']}.png';
        break;
      case 'JSON':
        content = _generateJSONContent();
        fileName = '${_currentMindmap['title']}.json';
        break;
    }

    // Download file
    await _downloadFile(content, fileName);

    // Close progress dialog
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mindmap exported successfully as $_selectedFormat'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              // Open file location or viewer
            },
          ),
        ),
      );
    }
  }

  Future<void> _downloadFile(String content, String fileName) async {
    try {
      if (kIsWeb) {
        // Web download
        final bytes = utf8.encode(content);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // Mobile download - in real implementation, use path_provider
        // For now, just show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File saved to Downloads folder'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _generatePDFContent() {
    // In real implementation, generate actual PDF content
    return '''%PDF-1.4
1 0 obj
<<
/Type /Catalog
/Pages 2 0 R
>>
endobj

2 0 obj
<<
/Type /Pages
/Kids [3 0 R]
/Count 1
>>
endobj

3 0 obj
<<
/Type /Page
/Parent 2 0 R
/MediaBox [0 0 612 792]
/Contents 4 0 R
>>
endobj

4 0 obj
<<
/Length 44
>>
stream
BT
/F1 12 Tf
100 700 Td
(${_currentMindmap['title']}) Tj
ET
endstream
endobj

xref
0 5
0000000000 65535 f 
0000000009 00000 n 
0000000058 00000 n 
0000000115 00000 n 
0000000206 00000 n 
trailer
<<
/Size 5
/Root 1 0 R
>>
startxref
300
%%EOF''';
  }

  String _generateImageContent() {
    // In real implementation, generate actual image data
    return 'PNG Image Data for ${_currentMindmap['title']}';
  }

  String _generateJSONContent() {
    final exportData = Map<String, dynamic>.from(_currentMindmap);
    if (_includeMetadata) {
      exportData['metadata'] = {
        'exportedAt': DateTime.now().toIso8601String(),
        'exportFormat': 'JSON',
        'quality': _selectedQuality,
        'version': '1.0.0'
      };
    }
    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  void _handleShareOption(String action) {
    HapticFeedback.lightImpact();

    switch (action) {
      case 'native_share':
        _showNativeShare();
        break;
      case 'email':
        _showEmailShare();
        break;
      case 'cloud':
        _showCloudUpload();
        break;
      case 'social':
        _showSocialShare();
        break;
    }
  }

  void _showNativeShare() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Mindmap',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 3.h),
            Text(
              'Choose how you want to share "${_currentMindmap['title']}"',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening system share sheet...'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text('Open Share Sheet'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmailShare() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Email Share'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Recipient Email',
                hintText: 'Enter email address',
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              decoration: InputDecoration(
                labelText: 'Subject',
                hintText: 'Mindmap: ${_currentMindmap['title']}',
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Message',
                hintText: 'Please find attached mindmap...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Email sent successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showCloudUpload() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Upload to Cloud',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 3.h),
            ShareOptionCard(
              title: 'Google Drive',
              subtitle: 'Upload to your Google Drive account',
              iconName: 'cloud',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Uploaded to Google Drive'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            ShareOptionCard(
              title: 'Dropbox',
              subtitle: 'Save to your Dropbox folder',
              iconName: 'cloud_queue',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Uploaded to Dropbox'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            if (!kIsWeb)
              ShareOptionCard(
                title: 'iCloud Drive',
                subtitle: 'Store in your iCloud Drive',
                iconName: 'cloud_done',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Uploaded to iCloud Drive'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showSocialShare() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Social Media Share',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 3.h),
            Text(
              'Share an optimized image of your mindmap',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialButton('Twitter', 'share', Colors.blue),
                _buildSocialButton('LinkedIn', 'business', Colors.blue[800]!),
                _buildSocialButton('Instagram', 'photo_camera', Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(String platform, String iconName, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Shared to $platform'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomIconWidget(
              iconName: iconName,
              color: color,
              size: 24,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            platform,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _handleCollaboration(Map<String, dynamic> option) {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Generate ${option['title']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(option['description']),
            SizedBox(height: 2.h),
            if (option['hasExpiration'])
              Row(
                children: [
                  Checkbox(
                    value: true,
                    onChanged: (value) {},
                  ),
                  Expanded(
                    child: Text(
                      'Set expiration date (7 days)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showGeneratedLink(option['accessLevel']);
            },
            child: Text('Generate Link'),
          ),
        ],
      ),
    );
  }

  void _showGeneratedLink(String accessLevel) {
    final link =
        'https://mindmapai.app/shared/${_currentMindmap['id']}?access=$accessLevel';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Link Generated',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 3.h),
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      link,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: link));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Link copied to clipboard'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: CustomIconWidget(
                      iconName: 'content_copy',
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            QRCodeWidget(
              data: link,
              title: 'QR Code Access',
              subtitle: 'Scan to open mindmap with $accessLevel access',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Export & Share'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios',
            color: colorScheme.onSurface,
            size: 20,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Export'),
            Tab(text: 'Share'),
            Tab(text: 'Collaborate'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExportTab(),
          _buildShareTab(),
          _buildCollaborateTab(),
        ],
      ),
    );
  }

  Widget _buildExportTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current mindmap info
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'psychology',
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentMindmap['title'],
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '${(_currentMindmap['nodes'] as List).length} nodes • Created Jan 8, 2025',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                                  .withValues(alpha: 0.8),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Format selection
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              'Export Format',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),

          SizedBox(height: 1.h),

          ..._exportFormats.map((format) => ExportFormatCard(
                title: format['title'],
                description: format['description'],
                iconName: format['icon'],
                fileSize: format['fileSize'],
                isSelected: _selectedFormat == format['format'],
                onTap: () {
                  setState(() {
                    _selectedFormat = format['format'];
                  });
                },
              )),

          SizedBox(height: 2.h),

          // Quality settings
          if (_selectedFormat != 'JSON') ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Quality Settings',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'tune',
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Quality Level',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: _exportFormats
                        .firstWhere(
                            (f) => f['format'] == _selectedFormat)['qualities']
                        .map<Widget>((quality) => Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedQuality = quality;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 1.w),
                                  padding: EdgeInsets.symmetric(vertical: 1.h),
                                  decoration: BoxDecoration(
                                    color: _selectedQuality == quality
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    quality,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: _selectedQuality == quality
                                              ? Colors.white
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],

          // Metadata toggle for JSON
          if (_selectedFormat == 'JSON') ...[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              child: CheckboxListTile(
                title: Text('Include Metadata'),
                subtitle: Text('Export timestamp, version, and format info'),
                value: _includeMetadata,
                onChanged: (value) {
                  setState(() {
                    _includeMetadata = value ?? true;
                  });
                },
              ),
            ),
          ],

          SizedBox(height: 4.h),

          // Export button
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _exportMindmap,
              icon: CustomIconWidget(
                iconName: 'file_download',
                color: Colors.white,
                size: 20,
              ),
              label: Text('Export as $_selectedFormat'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
              ),
            ),
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildShareTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              'Share Options',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          SizedBox(height: 1.h),
          ..._shareOptions.map((option) => ShareOptionCard(
                title: option['title'],
                subtitle: option['subtitle'],
                iconName: option['icon'],
                onTap: () => _handleShareOption(option['action']),
              )),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildCollaborateTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              'Collaboration Links',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          SizedBox(height: 1.h),
          ..._collaborationOptions.map((option) => CollaborationCard(
                title: option['title'],
                description: option['description'],
                iconName: option['icon'],
                accessLevel: option['accessLevel'],
                hasExpiration: option['hasExpiration'],
                onTap: () => _handleCollaboration(option),
              )),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
