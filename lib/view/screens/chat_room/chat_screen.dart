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
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0, // reverse:true
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
    // (kept your style)
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
              leading: const Icon(Icons.attach_file, color: Colors.deepPurple),
              title: const Text('Attach Files'),
              onTap: () async {
                Navigator.pop(ctx);
                await _pickAndSendFiles();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndSendFiles() async {
    final files = await c.pickFiles();
    if (files == null || files.isEmpty) return;

    setState(() {
      _pendingAttachments.clear();
      for (final f in files) {
        _pendingAttachments.add({
          'name': f.name,
          'size': f.size,
          'extension': (f.extension ?? 'file').toLowerCase(),
          'uploading': true,
          'url': null,
          '_raw': f,
        });
      }
    });

    for (int i = 0; i < files.length; i++) {
      final f = files[i];
      final url = await c.uploadFileAttachment(f);
      setState(() {
        _pendingAttachments[i]['uploading'] = false;
        _pendingAttachments[i]['url'] = url;
      });
    }

    final allOk = _pendingAttachments.every((a) => a['url'] != null);
    if (allOk) {
      final bundle = _pendingAttachments
          .map((a) => {
        'name': a['name'],
        'url': a['url'],
        'size': a['size'],
        'type': a['extension'],
      })
          .toList();
      await c.sendAttachmentBundle(atts: bundle, text: _textController.text);
      setState(() => _pendingAttachments.clear());
      _textController.clear();
      _scrollToBottom();
    }
  }

  // -------------------- message actions --------------------
  void _showMessageOptions(ChatMessage m) {
    final isMe = m.userId == c.userId;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                setState(() {
                  _replyingTo = {
                    'messageId': m.id,
                    'message': m.message,
                    'sender': m.userName ?? 'User',
                    'userId': m.userId,
                  };
                });
                c.setReplyTo(_replyingTo);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_emotions_outlined),
              title: const Text('Add Reaction'),
              onTap: () {
                Navigator.pop(ctx);
                _showEmojiPicker(m);
              },
            ),
            if (isMe)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Message'),
                onTap: () async {
                  await c.deleteMessage(m.id);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showEmojiPicker(ChatMessage m) {
    final emojis = ['😊', '👍', '❤️', '😂', '😢'];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          spacing: 8,
          children: emojis
              .map((e) => GestureDetector(
            onTap: () async {
              final myReacted =
              (m.reactions?[e] as List<dynamic>? ?? []).contains(c.userId);
              if (myReacted) {
                await c.removeReaction(m.id, e);
              } else {
                await c.addReaction(m.id, e);
              }
              Navigator.pop(ctx);
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(e, style: const TextStyle(fontSize: 24)),
            ),
          ))
              .toList(),
        ),
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
              Container(
                height: 38,
                width: 38,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
                child: Center(
                  child: MyText(
                    text: 'IM',
                    size: 16,
                    color: kTertiaryColor,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Obx(() {
                  final typers = c.typingUsers;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        text: widget.groupName ?? '',
                        size: 14,
                        color: kTertiaryColor,
                        weight: FontWeight.w600,
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: typers.isEmpty ? 0 : 16,
                        child: MyText(
                          text: typers.isEmpty
                              ? ''
                              : '${typers.join(', ')} ${typers.length > 1 ? 'are' : 'is'} typing…',
                          size: 10,
                          color: kGreyColor,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
          actions: [
            Center(
              child: GestureDetector(
                onTap: () => Get.bottomSheet(const OptionsSheet(), isScrollControlled: true),
                child: Image.asset(Assets.imagesMore, height: 24),
              ),
            ),
            const SizedBox(width: 20),
          ],
          shape: const Border(bottom: BorderSide(width: 1.0, color: Colors.blue)),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Obx(() {
                final items = c.messages;
                if (items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: AppSizes.DEFAULT,
                      child: MyText(
                        text: 'No messages yet',
                        size: 12,
                        color: kGreyColor,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                final grouped = _groupByDay(items);
                final dayKeys = grouped.keys.toList();
                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: AppSizes.DEFAULT,
                  physics: const BouncingScrollPhysics(),
                  itemCount: dayKeys.length,
                  itemBuilder: (_, dateIdx) {
                    final dayKey = dayKeys[dayKeys.length - 1 - dateIdx];
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
                        ListView.builder(
                          itemCount: chatList.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (_, i) {
                            final m = chatList[i];
                            final me = profileController.profile.value?.uid;
                            final isMe = (m.userId == me);

                            return GestureDetector(
                              onLongPress: () => _showMessageOptions(m),
                              child: _MessageBubble(
                                message: m,
                                isMe: isMe,
                                fmtTime: _fmtTime,
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              }),
            ),

            // pending attachments tray
            if (_pendingAttachments.isNotEmpty)
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
                            final ready = _pendingAttachments.any((a) => !a['uploading'] && a['url'] != null);
                            if (!ready) return;
                            final bundle = _pendingAttachments
                                .where((a) => a['url'] != null)
                                .map((a) => {
                              'name': a['name'],
                              'url': a['url'],
                              'size': a['size'],
                              'type': a['extension'],
                            })
                                .toList();
                            await c.sendAttachmentBundle(
                              atts: bundle,
                              text: _textController.text,
                            );
                            setState(() => _pendingAttachments.clear());
                            _textController.clear();
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
                            Icon(_fileIcon(a['extension']),
                                color: a['uploading'] ? kGreyColor : kSecondaryColor, size: 20),
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
                                    text: a['uploading'] ? 'Uploading…' : _fmtSize((a['size'] ?? 0) as int),
                                    size: 10,
                                    color: kGreyColor,
                                  ),
                                ],
                              ),
                            ),
                            if (a['uploading'])
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            else
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

            // reply banner
            if (_replyingTo != null)
              Container(
                color: kPrimaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: MyText(
                        text: 'Replying to ${_replyingTo!['sender']}: ${_replyingTo!['message']}',
                        size: 12,
                        color: kGreyColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() => _replyingTo = null);
                        c.setReplyTo(null);
                      },
                      child: const Icon(Icons.close, size: 18, color: kGreyColor),
                    ),
                  ],
                ),
              ),

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
                            await c.send(profileController.profile.value?.name ?? '');
                            _textController.clear();
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
                      await c.send(profileController.profile.value?.name ?? '');
                      _textController.clear();
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

// Renders all message types, keeps your bubble aesthetics
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.fmtTime,
  });

  final ChatMessage message;
  final bool isMe;
  final String Function(DateTime?) fmtTime;

  bool get _isImage => message.type == 'image' && (message.mediaUrl ?? '').isNotEmpty;
  bool get _isVideo => message.type == 'video' && (message.mediaUrl ?? '').isNotEmpty;
  bool get _hasAtts => (message.attachments?.isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    final sent = message.sentAt?.toDate();
    final time = fmtTime(sent);
    final bubbleColor = isMe ? kSecondaryColor : kPrimaryColor;
    final textColor = isMe ? kPrimaryColor : kTertiaryColor;

    Widget body;

    // reply preview
    final reply = message.replyTo;
    final replyWidget = (reply != null)
        ? Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorderColor),
      ),
      child: MyText(
        text: 'Replying to ${reply['sender']}: ${reply['message']}',
        size: 12,
        color: kGreyColor,
      ),
    )
        : const SizedBox.shrink();

    final media = [
      if (_isImage)
        GestureDetector(
          onTap: () => Get.to(() => ImageViewerScreen(url: message.mediaUrl!, heroTag: 'img_${message.id}')),
          child: Hero(
            tag: 'img_${message.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                message.mediaUrl!,
                width: 220,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      if (_isVideo)
        GestureDetector(
          onTap: () => Get.to(() => VideoPlayerScreen(url: message.mediaUrl!)),
          child: Container(
            width: 220,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.play_circle_filled, size: 40, color: Colors.black54),
          ),
        ),
      if (_hasAtts)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: message.attachments!
              .map((a) => _AttachmentTile(att: Map<String, dynamic>.from(a)))
              .toList(),
        ),
    ];

    final textBlock = (message.message.isNotEmpty)
        ? MyText(text: message.message, size: 12, color: textColor, weight: FontWeight.w500)
        : const SizedBox.shrink();

    final reacts = message.reactions ?? {};
    final reactionRow = reacts.isEmpty
        ? const SizedBox.shrink()
        : Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 4,
        children: reacts.entries
            .map((e) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBorderColor),
          ),
          child: Text('${e.key} ${(e.value as List).length}'),
        ))
            .toList(),
      ),
    );

    body = Container(
      margin: EdgeInsets.fromLTRB(isMe ? 38 : 0, 8, isMe ? 0 : 38, 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(isMe ? 0 : 16),
          topLeft: Radius.circular(isMe ? 16 : 0),
          bottomLeft: const Radius.circular(16),
          bottomRight: const Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe && (message.userName?.isNotEmpty ?? false))
            MyText(
              paddingBottom: 4,
              text: message.userName!,
              size: 12,
              color: kSecondaryColor,
              weight: FontWeight.w500,
            ),
          if (replyWidget is! SizedBox) replyWidget,
          ...media,
          if (media.isNotEmpty && message.message.isNotEmpty) const SizedBox(height: 6),
          textBlock,
          reactionRow,
        ],
      ),
    );

    // footer (time + ticks + avatars like your style)
    final footer = Padding(
      padding: EdgeInsets.fromLTRB(isMe ? 38 : 0, 2, isMe ? 0 : 38, 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            CommonImageView(
              height: 20,
              width: 20,
              radius: 100,
              url: message.photoUrl ?? '',
              fit: BoxFit.cover,
            ),
          if (!isMe) const SizedBox(width: 4),
          MyText(text: time, size: 10, color: kGreyColor),
          const SizedBox(width: 6),
          Icon(
            Icons.done_all,
            size: 16,
            color: _allRead(message) ? kSecondaryColor : kGreyColor,
          ),
          if (isMe) const SizedBox(width: 4),
          if (isMe)
            CommonImageView(
              height: 20,
              width: 20,
              radius: 100,
              url: message.photoUrl ?? '',
              fit: BoxFit.cover,
            ),
        ],
      ),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(children: [body, footer]),
    );
  }

  bool _allRead(ChatMessage m) {
    final readBy = m.readBy ?? const [];
    // Treat "everyone read" = all group members present in readBy
    // If you prefer strict: compare with controller.members length + 1 (owner)
    return readBy.isNotEmpty; // simple visual; refine if you keep members length in context
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({required this.att});
  final Map<String, dynamic> att;

  bool get _isImageExt =>
      ['jpg','jpeg','png','gif','webp','bmp','heic','heif'].contains((att['type'] ?? '').toString().toLowerCase());
  bool get _isVideoExt =>
      ['mp4','mov','m4v','webm','avi','mkv','3gp'].contains((att['type'] ?? '').toString().toLowerCase());
  bool get _isPdf => (att['type'] ?? '') == 'pdf';

  @override
  Widget build(BuildContext context) {
    final name = (att['name'] ?? 'file').toString();
    final url = (att['url'] ?? '').toString();
    final size = (att['size'] ?? 0) is int ? (att['size'] as int) : 0;
    final ext = (att['type'] ?? 'file').toString();
    return GestureDetector(
      onTap: () {
        if (_isImageExt) {
          Get.to(() => ImageViewerScreen(url: url));
        } else if (_isVideoExt) {
          Get.to(() => VideoPlayerScreen(url: url));
        } else if (_isPdf) {
          Get.to(() => FileViewerScreen(url: url, fileName: name, ext: ext));
        } else {
          Get.to(() => FileViewerScreen(url: url, fileName: name, ext: ext));
        }
      },
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kBorderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kSecondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.insert_drive_file, color: kSecondaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(text: name, size: 12, color: kTertiaryColor, weight: FontWeight.w600),
                  const SizedBox(height: 4),
                  MyText(text: _fmtSize(size), size: 10, color: kGreyColor),
                ],
              ),
            ),
            const Icon(Icons.open_in_new, size: 18, color: kSecondaryColor),
          ],
        ),
      ),
    );
  }

  String _fmtSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suf = ['B', 'KB', 'MB', 'GB'];
    final i = (log(bytes) / log(1024)).floor();
    final v = bytes / pow(1024, i);
    return '${v.toStringAsFixed(1)} ${suf[i]}';
  }
}
