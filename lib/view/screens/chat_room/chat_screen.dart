import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_fonts.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/controllers/chat_controller.dart';
import 'package:manifesto_md/controllers/profile_controller.dart';
import 'package:manifesto_md/main.dart';
import 'package:manifesto_md/models/chat_message_model.dart';
import 'package:manifesto_md/view/screens/chat_room/group_details.dart';
import 'package:manifesto_md/view/widget/common_image_view_widget.dart';
import 'package:manifesto_md/view/widget/custom_check_box_widget.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class ChatScreen extends StatefulWidget {
  final String groupId;
  final String? groupName;

  const ChatScreen({
    Key? key,
    required this.groupId,
    this.groupName,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // keep your local text + scroll controllers (UI unchanged)
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final ChatController c;
final ProfileController profileController = Get.find();


  @override
  void initState() {
    super.initState();
    // one controller per groupId; tag isolates instances
    c = Get.put(ChatController(widget.groupId), tag: widget.groupId);

    // keep local input in sync with controller input (UI unchanged)
    _textController.addListener(() {
      c.input.text = _textController.text;
      c.input.selection = _textController.selection;
    });

    
    // autoscroll to latest
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
          0.0, // reverse: true → latest is at top position 0
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ---- helpers: time + day labels (pure formatting, no UI change) -----------
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
    return '${that.year}-${that.month.toString().padLeft(2, '0')}-${that.day.toString().padLeft(2, '0')}';
  }

  Map<String, List<ChatMessage>> _groupByDay(List<ChatMessage> items) {
    final map = <String, List<ChatMessage>>{};
    for (final m in items) {
      final dt = m.createdAt; // ensure model exposes DateTime
      final key = _dayLabel(dt ?? DateTime.now());
      (map[key] ??= []).add(m);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          titleSpacing: -5.0,
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kBorderColor,
                ),
                child: Center(
                  child: MyText(
                    text: 'IM', // keeping your UI as-is
                    size: 16,
                    color: kTertiaryColor,
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
                      text: widget.groupName ??"" , // unchanged title UI
                      size: 14,
                      color: kTertiaryColor,
                      weight: FontWeight.w600,
                    ),
                   Obx( () => Row(
  children: [
    // Show only first 4 members
    ...c.members.take(4).map((e) => Padding(
          padding: const EdgeInsets.only(right: 4),
          child: MyText(
            paddingTop: 6,
            text: e.email!,
            size: 10,
            maxLines: 1,
            textOverflow: TextOverflow.ellipsis,
            color: kGreyColor,
          ),
        )),

    if (c.members.length > 4)
      MyText(
        paddingTop: 6,
        text: '+${c.members.length - 4} more',
        size: 10,
        color: kGreyColor,
      ),
  ],
)
  ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: GestureDetector(
                onTap: () => Get.bottomSheet(const _Options(), isScrollControlled: true),
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
            // ---------------- MESSAGES (live) ----------------
            Expanded(
              child: Obx(() {
                final items = c.messages; // ascending by createdAt from service
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

                // group by day for your existing day headers
                final grouped = _groupByDay(items);
                final dayKeys = grouped.keys.toList(); // insertion order follows iteration
                // we want latest at bottom visually with reverse:true, so keep as-is and
                // let reverse:true flip it (we’ll iterate reversed inside the builder)
                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: AppSizes.DEFAULT,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: dayKeys.length,
                  itemBuilder: (context, dateIndex) {
                    // because reverse:true, pull from the end
                    final dayKey = dayKeys[dayKeys.length - 1 - dateIndex];
                    final chatList = grouped[dayKey]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: MyText(
                                text: dayKey,
                                size: 10,
                                color: kGreyColor,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        // messages of the day in natural order
                        ListView.builder(
                          itemCount: chatList.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, msgIndex) {
                            final m = chatList[msgIndex];
                            final isMe = m.senderId == profileController.profile.value!.uid;
                            print(isMe);
                            print(m.senderId);
                            print(c.userId);

                            return Align(
                              alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
                              child: isMe
                                  ? RightBubble(
                                      text: m.text,
                                      time: _fmtTime(m.createdAt),
                                    )
                                  : LeftBubble(
                                      text: m.text,
                                      name: m.senderName ?? 'User',
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

            // ---------------- INPUT ROW (unchanged UI, wired to controller) ---
            Padding(
              padding: AppSizes.DEFAULT,
              child: Row(
                spacing: 6,
                children: [
                  Image.asset(Assets.imagesImage, height: 34),
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
                              color: Colors.black.withValues(alpha: .05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          controller: _textController, // keep your field
                          onChanged: (v) => c.onTypingChanged(v.trim().isNotEmpty),
                          onFieldSubmitted: (_) {

                            c.send(profileController.profile.value?.name ?? "");
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
                            hintStyle:  TextStyle(
                              color: kGreyColor,
                              fontSize: 14,
                              fontFamily: AppFonts.URBANIST,
                              fontWeight: FontWeight.w500,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 0,
                            ),
                          ),
                          style:  TextStyle(
                            color: kTertiaryColor,
                            fontSize: 14,
                            fontFamily: AppFonts.URBANIST,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: ()async{
                      await c.send(profileController.profile.value?.name ?? "");
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

// ------------------ bubbles + bottom sheets (unchanged UI) -------------------

class LeftBubble extends StatelessWidget {
  final String text;
  final String name;
  const LeftBubble({required this.text, required this.name, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 38, 8),
      child: Row(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           CommonImageView(
            height: 30,
            width: 30,
            radius: 100,
            url: dummyImg,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      topLeft: Radius.circular(0),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        paddingBottom: 4,
                        text: name,
                        size: 12,
                        color: kSecondaryColor,
                        weight: FontWeight.w500,
                      ),
                      MyText(
                        text: text,
                        size: 12,
                        color: kTertiaryColor,
                        weight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RightBubble extends StatelessWidget {
  final String text;
  final String time;
  const RightBubble({required this.text, required this.time, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(38, 8, 0, 8),
      child: Row(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: kSecondaryColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(0),
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: MyText(
                    text: text,
                    size: 12,
                    color: kPrimaryColor,
                    weight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
           Padding(
            padding: EdgeInsets.only(right: 8, top: 0),
            child: CommonImageView(
              height: 30,
              width: 30,
              radius: 100,
              url: dummyImg,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

class _Options extends StatelessWidget {
  const _Options();

  final List<String> _options = const [
    'Group Info',
    'Group Media',
    'Search',
    'Report',
    'Exit Group',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSizes.DEFAULT,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage(Assets.imagesMainBg),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyText(
            text: 'Options',
            size: 18,
            weight: FontWeight.w700,
            paddingBottom: 16,
          ),
          Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < _options.length; i++)
                GestureDetector(
                  onTap: () {
                    switch (i) {
                      case 0:
                        Get.to(() => GroupDetails());
                        break;
                      case 1:
                        break;
                      case 2:
                        break;
                      case 3:
                        break;
                      case 4:
                        break;
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      border: Border.all(color: kBorderColor, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: MyText(
                      text: _options[i],
                      size: 14,
                      color: i == _options.length - 1 ? kRedColor : kTertiaryColor,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatRoomConsent extends StatelessWidget {
  const _ChatRoomConsent();

  final List<Map<String, String>> _options = const [
    {
      "targetText": "Professional Use Only",
      "normalText":
          "This chat is strictly for professional and educational purposes. Social conversations or personal discussions are not allowed.",
    },
    {
      "targetText": "Respectful Communication",
      "normalText":
          "Always communicate with respect. Racism, harassment, offensive language, or disrespect towards others will not be tolerated.",
    },
    {
      "targetText": "No Inappropriate Content",
      "normalText":
          "Do not share or promote any political, cultural, religious, or offensive opinions or materials.",
    },
    {
      "targetText": "Copyright Compliance",
      "normalText":
          "Do not share or distribute copyrighted materials without proper rights or permissions.",
    },
    {
      "targetText": "Secure Sharing",
      "normalText":
          "Only share documents or photos that are relevant, safe, and appropriate for professional use.",
    },
    {
      "targetText": "Enforcement",
      "normalText":
          "Any violation of these rules may result in immediate and permanent suspension from the chat room.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container
    (
      margin: AppSizes.DEFAULT,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage(Assets.imagesMainBg),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: Image.asset(Assets.imagesHandle, height: 6)),
          MyText(
            paddingTop: 16,
            text: 'Chat Room Consent',
            size: 16,
            weight: FontWeight.w600,
            paddingBottom: 10,
          ),
          MyText(
            text: 'By joining this chat room, you agree to the following:',
            size: 12,
            color: kGreyColor,
            paddingBottom: 16,
          ),
          Column(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < _options.length; i++)
                RichText(
                  text: TextSpan(
                    style:  TextStyle(
                      fontSize: 12,
                      color: kTertiaryColor,
                      fontFamily: AppFonts.URBANIST,
                    ),
                    children: [
                      const TextSpan(
                        text: '- ',
                        style: TextStyle(color: kSecondaryColor),
                      ),
                      TextSpan(
                        text: _options[i]['targetText'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: ' - ${_options[i]['normalText']}'),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomCheckBox(isActive: true, onTap: () {}),
              Expanded(
                child: MyText(
                  paddingLeft: 10,
                  lineHeight: 1.5,
                  text:
                      'By clicking “I Agree”, you confirm that you have read, understood, and agree to follow these guidelines.',
                  size: 12,
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          MyButton(
            height: 44,
            buttonText: 'Continue',
            onTap: Get.back,
          ),
        ],
      ),
    );
  }
}
