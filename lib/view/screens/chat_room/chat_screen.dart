import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_fonts.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/controllers/chat_controller.dart';
import 'package:manifesto_md/controllers/profile_controller.dart';
import 'package:manifesto_md/models/chat_message_model.dart';
import 'package:manifesto_md/view/screens/chat_room/support_screens/file_viewer_screen.dart';
import 'package:manifesto_md/view/screens/chat_room/support_screens/image_viewer_screen.dart';
import 'package:manifesto_md/view/screens/chat_room/support_screens/video_player_screen.dart';
import 'package:manifesto_md/view/widget/common_image_view_widget.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';
import 'package:manifesto_md/view/widget/options_sheet.dart';

class ChatScreen extends StatefulWidget {
  final String groupId;
  final String? groupName;

  const ChatScreen({Key? key, required this.groupId, this.groupName})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final ChatController c;
  final ProfileController profileController = Get.find();

  // local reply + pending attachments tray
  Map<String, dynamic>? _replyingTo;
  final List<Map<String, dynamic>> _pendingAttachments = [];

  @override
  void initState() {
    super.initState();
    c = Get.put(ChatController(widget.groupId), tag: widget.groupId);

    _textController.addListener(() {
      c.input.text = _textController.text;
      c.input.selection = _textController.selection;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    ever<List<ChatMessage>>(c.messages, (_) => _scrollToBottom());
  }

  @override
  void dispose() {
    if (Get.isRegistered<ChatController>(tag: widget.groupId)) {
      Get.delete<ChatController>(tag: widget.groupId);
    }
    _textController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // -------------------- UI helpers --------------------
  String _fmtTime(DateTime? dt) {
    if (dt == null) return '';
    final t = TimeOfDay.fromDateTime(dt);
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final mm = t.minute.toString().padLeft(2, '0');
    return '$h:$mm ${t.period == DayPeriod.am ? 'AM' : 'PM'}';
  }

  String _dayLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(d.year, d.month, d.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('EEEE, MMM d, yyyy').format(d);
  }

  Map<String, List<ChatMessage>> _groupByDay(List<ChatMessage> items) {
    final map = <String, List<ChatMessage>>{};
    for (final m in items) {
      final dt = m.sentAt?.toDate() ?? DateTime.now();
      final key = _dayLabel(dt);
      (map[key] ??= []).add(m);
    }
    return map;
  }

  IconData _fileIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
        return Icons.folder_zip;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _fmtSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suf = ['B', 'KB', 'MB', 'GB'];
    final i = (log(bytes) / log(1024)).floor().clamp(0, suf.length - 1);
    final v = bytes / pow(1024, i);
    return '${v.toStringAsFixed(1)} ${suf[i]}';
  }

  // -------------------- Search functionality --------------------
  void _toggleSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search messages...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchController.clear();
                      c.clearSearch();
                      Navigator.pop(ctx);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  c.setSearchQuery(value);
                },
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (c.isSearching.value && c.filteredMessages.isEmpty) {
                  return const Text('No messages found');
                }
                return Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: c.filteredMessages.length,
                    itemBuilder: (context, index) {
                      final message = c.filteredMessages[index];
                      return ListTile(
                        title: Text(message.message),
                        subtitle: Text('By: ${message.userName}'),
                        trailing: Text(_fmtTime(message.sentAt?.toDate())),
                        onTap: () {
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------- media pickers --------------------
  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Colors.blueAccent),
              title: const Text('Camera (Photo / Video)'),
              onTap: () async {
                Navigator.pop(ctx);
                final type = await showModalBottomSheet<String>(
                  context: context,
                  builder: (ctx2) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.camera_alt),
                          title: const Text('Take Photo'),
                          onTap: () => Navigator.pop(ctx2, 'photo'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.videocam),
                          title: const Text('Record Video'),
                          onTap: () => Navigator.pop(ctx2, 'video'),
                        ),
                      ],
                    ),
                  ),
                );
                if (type == null) return;
                final isVideo = type == 'video';
                final url = await c.pickAndUploadMedia(
                    isVideo: isVideo, source: ImageSource.camera);
                if (url != null) {
                  if (isVideo) {
                    await c.sendVideo(url);
                  } else {
                    await c.sendImage(url);
                  }
                  _scrollToBottom();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Gallery (Photo / Video)'),
              onTap: () async {
                Navigator.pop(ctx);
                final type = await showModalBottomSheet<String>(
                  context: context,
                  builder: (ctx2) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.photo),
                          title: const Text('Pick Photo'),
                          onTap: () => Navigator.pop(ctx2, 'photo'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.videocam),
                          title: const Text('Pick Video'),
                          onTap: () => Navigator.pop(ctx2, 'video'),
                        ),
                      ],
                    ),
                  ),
                );
                if (type == null) return;
                final isVideo = type == 'video';
                final url = await c.pickAndUploadMedia(
                    isVideo: isVideo, source: ImageSource.gallery);
                if (url != null) {
                  if (isVideo) {
                    await c.sendVideo(url);
                  } else {
                    await c.sendImage(url);
                  }
                  _scrollToBottom();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file, color: Colors.orange),
              title: const Text('Files'),
              onTap: () async {
                Navigator.pop(ctx);
                final files = await c.pickFiles();
                if (files == null || files.isEmpty) return;
                for (final f in files) {
                  final url = await c.uploadFileAttachment(f);
                  if (url != null) {
                    _pendingAttachments.add({
                      'name': f.name,
                      'url': url,
                      'size': f.size,
                      'ext': f.extension ?? '',
                    });
                  }
                }
                if (_pendingAttachments.isNotEmpty) {
                  setState(() {});
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- message bubble --------------------
  Widget _buildMessage(ChatMessage m) {
    final isMe = m.userId == c.userId;
    final bg = isMe ? kSecondaryColor : kPrimaryColor;
    final textColor = isMe ? kPrimaryColor : kTertiaryColor;

    // reply preview
    Widget? replyWidget;
    if (m.replyTo != null) {
      final reply = m.replyTo!;
      final replyText = reply['message'] ?? '';
      final replyUser = reply['userName'] ?? 'User';
      final replyType = reply['type'] ?? 'text';
      replyWidget = Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: kPrimaryColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kBorderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              replyUser,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: textColor.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              replyType == 'text' ? replyText : '[$replyType]',
              style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.8)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    // reactions
    final reactions = m.reactions ?? {};
    final hasReactions = reactions.isNotEmpty;

    // message content
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (replyWidget != null) replyWidget,
        if (m.message.isNotEmpty)
          MyText(
            text: m.message,
            color: textColor,
            size: 14,
            weight: FontWeight.w500,
          ),
        if (m.type == 'image' && m.mediaUrl != null)
          GestureDetector(
            onTap: () {
              Get.to(() => ImageViewerScreen(url: m.mediaUrl!));
            },
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CommonImageView(
                  url: m.mediaUrl!,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        if (m.type == 'video' && m.mediaUrl != null)
          GestureDetector(
            onTap: () {
              Get.to(() => VideoPlayerScreen(url: m.mediaUrl!));
            },
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CommonImageView(
                      url: Assets.imagesComingSoon,
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 50),
                  ),
                ],
              ),
            ),
          ),
        if (m.type == 'file' || m.type == 'files')
          ...(m.attachments ?? []).map((att) {
            final name = att['name'] ?? 'file';
            final url = att['url'] ?? '';
            final size = att['size'] ?? 0;
            final ext = att['ext'] ?? '';
            return GestureDetector(
              onTap: () {
                Get.to(() => FileViewerScreen(
                  fileName: name,
                  url: url,
                  ext: ext,
                ));
              },
              child: Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kBorderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_fileIcon(ext), size: 24, color: kSecondaryColor),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 12,
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _fmtSize(size),
                          style: TextStyle(
                            fontSize: 10,
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        if (hasReactions)
          Wrap(
            spacing: 4,
            children: reactions.entries.map((e) {
              final emoji = e.key;
              final users = List<String>.from(e.value ?? []);
              final isReactedByMe = users.contains(c.userId);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isReactedByMe
                      ? kPrimaryColor
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorderColor),
                ),
                child: Text(
                  '$emoji ${users.length}',
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }).toList(),
          ),
      ],
    );

    // timestamp + status
    final timeWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _fmtTime(m.sentAt?.toDate()),
          style: TextStyle(
            fontSize: 10,
            color: kGreyColor,
          ),
        ),
        if (isMe) ...[
          const SizedBox(width: 4),
          Icon(
            (m.readBy?.length ?? 0) > 1 ? Icons.done_all : Icons.done,
            size: 12,
            color: kGreyColor,
          ),
        ],
      ],
    );

    return GestureDetector(
      onLongPress: () {
        _showMessageOptions(m, isMe);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              // WhatsApp-style sender avatar for others' messages
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CommonImageView(
                  height: 32,
                  width: 32,
                  radius: 16,
                  url: m.photoUrl,
                  userName: m.userName,
                  isAvatar: true,
                ),
              ),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // Show username for others' messages (WhatsApp style)
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4, left: 8),
                      child: MyText(
                        text: m.userName ?? 'User',
                        size: 12,
                        color: kSecondaryColor,
                        weight: FontWeight.w600,
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 16),
                      ),
                    ),
                    child: content,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 4,
                      left: isMe ? 0 : 8,
                      right: isMe ? 8 : 0,
                    ),
                    child: timeWidget,
                  ),
                ],
              ),
            ),
            if (isMe) ...[
              // My avatar on the right side
              const SizedBox(width: 8),
              CommonImageView(
                height: 32,
                width: 32,
                radius: 16,
                url: m.photoUrl,
                userName: m.userName,
                isAvatar: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showMessageOptions(ChatMessage m, bool isMe) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMe)
              ListTile(
                leading: const Icon(Icons.reply),
                title: const Text('Reply'),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _replyingTo = {
                      'messageId': m.id,
                      'message': m.message,
                      'userName': m.userName,
                      'type': m.type,
                    };
                  });
                },
              ),
            ListTile(
              leading: const Icon(Icons.emoji_emotions_outlined),
              title: const Text('Add Reaction'),
              onTap: () {
                Navigator.pop(ctx);
                _showReactionPicker(m);
              },
            ),
            if (isMe)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Message'),
                onTap: () {
                  Navigator.pop(ctx);
                  c.deleteMessage(m.id);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showReactionPicker(ChatMessage m) {
    final emojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: emojis.map((e) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  c.addReaction(m.id, e);
                },
                child: Text(e, style: const TextStyle(fontSize: 30)),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // -------------------- typing indicator --------------------
  Widget _buildTypingIndicator() {
    return Obx(() {
      if (c.typingUsers.isEmpty) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            const SizedBox(width: 8),
            MyText(
              text: '${c.typingUsers.join(', ')} ${c.typingUsers.length == 1 ? 'is' : 'are'} typing...',
              size: 12,
              color: kGreyColor,
            ),
          ],
        ),
      );
    });
  }

  // -------------------- pending attachments tray --------------------
  Widget _buildAttachmentsTray() {
    if (_pendingAttachments.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        border: Border(top: BorderSide(color: kBorderColor)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _pendingAttachments.length,
        itemBuilder: (ctx, i) {
          final att = _pendingAttachments[i];
          return Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kBorderColor),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_fileIcon(att['ext']), size: 24, color: kSecondaryColor),
                    const SizedBox(height: 4),
                    MyText(
                      text: att['name'],
                      size: 10,
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _pendingAttachments.removeAt(i);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // -------------------- reply preview --------------------
  Widget _buildReplyPreview() {
    if (_replyingTo == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        border: Border(top: BorderSide(color: kBorderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  text: 'Replying to ${_replyingTo!['userName']}',
                  size: 12,
                  weight: FontWeight.w600,
                ),
                MyText(
                  text: _replyingTo!['message'],
                  size: 12,
                  color: kGreyColor,
                  maxLines: 1,
                  textOverflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() => _replyingTo = null);
            },
            child: const Icon(Icons.close, size: 18, color: kGreyColor),
          ),
        ],
      ),
    );
  }

  // -------------------- build --------------------
  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          titleSpacing: -5,
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Image.asset(Assets.imagesArrowBack, height: 24),
              ),
            ],
          ),
          title: Row(
            children: [
              // Group avatar
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kBorderColor,
                ),
                child: Center(
                  child: MyText(
                    text: widget.groupName != null && widget.groupName!.isNotEmpty
                        ? widget.groupName!
                        .trim()
                        .split(' ')
                        .map((e) => e.isNotEmpty ? e[0] : '')
                        .take(2)
                        .join()
                        .toUpperCase()
                        : 'G',
                    size: 16,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text: widget.groupName ?? "Group",
                      size: 14,
                      color: kTertiaryColor,
                      weight: FontWeight.w600,
                    ),
                    Obx(() {
                      final members = c.members;
                      if (members.isEmpty) {
                        return MyText(
                          text: 'No members',
                          size: 10,
                          color: kGreyColor,
                        );
                      }

                      // Show typing indicator if someone is typing
                      if (c.typingUsers.isNotEmpty) {
                        return MyText(
                          text: '${c.typingUsers.join(', ')} ${c.typingUsers.length == 1 ? 'is' : 'are'} typing...',
                          size: 10,
                          color: kGreyColor,
                        );
                      }

                      // Show member count
                      return MyText(
                        text: '${members.length} members',
                        size: 10,
                        color: kGreyColor,
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: GestureDetector(
                onTap: _toggleSearch,
                child: const Icon(Icons.search, color: kTertiaryColor, size: 24),
              ),
            ),
            const SizedBox(width: 10),
            Center(
              child: GestureDetector(
                onTap: () => Get.bottomSheet(const OptionsSheet(), isScrollControlled: true),
                child: Image.asset(Assets.imagesMore, height: 24),
              ),
            ),
            const SizedBox(width: 20),
          ],
          shape: Border(bottom: BorderSide(width: 1.0, color: kBorderColor)),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Obx(() {
                final items = c.isSearching.value ? c.filteredMessages : c.messages;
                if (items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: AppSizes.DEFAULT,
                      child: MyText(
                        text: '',
                        size: 12,
                        color: kGreyColor,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final grouped = _groupByDay(items);
                final dayKeys = grouped.keys.toList();

                // FIXED: Show messages in natural order (latest at bottom) - WhatsApp style
                return ListView.builder(
                  controller: _scrollController,
                  padding: AppSizes.DEFAULT,
                  physics: const BouncingScrollPhysics(),
                  itemCount: dayKeys.length,
                  itemBuilder: (_, dateIdx) {
                    final dayKey = dayKeys[dateIdx]; // Use normal order
                    final chatList = grouped[dayKey]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(color: kBorderColor),
                              ),
                              child: MyText(text: dayKey, size: 10, color: kGreyColor),
                            ),
                          ),
                        ),
                        // Messages for this day in chronological order
                        ...chatList.map(_buildMessage).toList(),
                      ],
                    );
                  },
                );
              }),
            ),

            // Typing indicator
            _buildTypingIndicator(),

            // pending attachments tray
            if (_pendingAttachments.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: kPrimaryColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        MyText(text: 'Attachments', size: 12, color: kGreyColor, weight: FontWeight.w600),
                        const Spacer(),
                        GestureDetector(
                          onTap: () async {
                            final ready = _pendingAttachments.any((a) => a['url'] != null);
                            if (!ready) return;
                            final bundle = _pendingAttachments
                                .where((a) => a['url'] != null)
                                .map((a) => {
                              'name': a['name'],
                              'url': a['url'],
                              'size': a['size'],
                              'type': a['ext'],
                            })
                                .toList();
                            await c.sendAttachmentBundle(
                              atts: bundle,
                              text: _textController.text,
                            );
                            setState(() {
                              _pendingAttachments.clear();
                              _textController.clear(); // Clear text field
                            });
                          },
                          child: MyText(
                            text: 'Send',
                            size: 12,
                            color: kSecondaryColor,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._pendingAttachments.asMap().entries.map((e) {
                      final i = e.key;
                      final a = e.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: kBorderColor),
                        ),
                        child: Row(
                          children: [
                            Icon(_fileIcon(a['ext']), color: kSecondaryColor, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    text: a['name'],
                                    size: 12,
                                    color: kTertiaryColor,
                                    weight: FontWeight.w500,
                                  ),
                                  const SizedBox(height: 2),
                                  MyText(
                                    text: _fmtSize((a['size'] ?? 0) as int),
                                    size: 10,
                                    color: kGreyColor,
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _pendingAttachments.removeAt(i)),
                              child: const Icon(Icons.close, size: 16, color: kGreyColor),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],

            // reply banner
            if (_replyingTo != null) ...[
              Container(
                color: kPrimaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: MyText(
                        text: 'Replying to ${_replyingTo!['userName']}: ${_replyingTo!['message']}',
                        size: 12,
                        color: kGreyColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() => _replyingTo = null);
                      },
                      child: const Icon(Icons.close, size: 18, color: kGreyColor),
                    ),
                  ],
                ),
              ),
            ],

            // input row
            Padding(
              padding: AppSizes.DEFAULT,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _showMediaPicker,
                    child: Image.asset(Assets.imagesImage, height: 34),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: kBorderColor, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _textController,
                          textAlignVertical: TextAlignVertical.center,
                          onChanged: (v) => c.onTypingChanged(v.trim().isNotEmpty),
                          onFieldSubmitted: (_) async {
                            if (_textController.text.trim().isNotEmpty) {
                              await c.send(profileController.profile.value?.name ?? '');
                              _textController.clear(); // Clear immediately after send
                            }
                          },
                          decoration: InputDecoration(
                            prefixIcon: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(Assets.imagesEmoji, height: 34),
                              ],
                            ),
                            hintText: 'Type Message',
                            hintStyle: TextStyle(
                              color: kGreyColor,
                              fontSize: 14,
                              fontFamily: AppFonts.URBANIST,
                              fontWeight: FontWeight.w500,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                          ),
                          style: TextStyle(
                            color: kTertiaryColor,
                            fontSize: 14,
                            fontFamily: AppFonts.URBANIST,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () async {
                      if (_textController.text.trim().isNotEmpty) {
                        await c.send(profileController.profile.value?.name ?? '');
                        _textController.clear(); // Clear immediately after send
                      }
                    },
                    child: Obx(() => Opacity(
                      opacity: c.isSending.value ? 0.6 : 1,
                      child: Image.asset(Assets.imagesSend, height: 34),
                    )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}