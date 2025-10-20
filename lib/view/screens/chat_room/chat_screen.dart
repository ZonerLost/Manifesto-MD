import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_fonts.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/main.dart';
import 'package:manifesto_md/view/screens/chat_room/group_details.dart';
import 'package:manifesto_md/view/widget/common_image_view_widget.dart';
import 'package:manifesto_md/view/widget/custom_check_box_widget.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}   

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  // Group messages by date for day-to-day chat separation
  final Map<String, List<Map<String, dynamic>>> messagesByDate = {
    "Yesterday": [
      {
        "text":
            "Before LP, check CT brain to rule out any mass effect. Don’t forget fundoscopy.",
        "isMe": false,
        "name": "Dr. John",
        "time": "09:05 AM",
      },
      {
        "text":
            "Agree. Also start empirical IV antibiotics — ceftriaxone + vancomycin + acyclovir. Don’t wait for LP.",
        "isMe": true,
        "name": "You",
        "time": "09:07 AM",
      },
    ],
    "Today": [
      {
        "text":
            "Morning team, I just admitted a 65-year-old male with shortness of breath and bilateral leg swelling. BP is 150/90, HR 88. ECG is normal. What should I consider next?",
        "isMe": false,
        "name": "Dr. Alex Perry",
        "time": "10:15 AM",
      },
      {
        "text":
            "Sounds like possible congestive heart failure. Did you check BNP and get a chest X-ray?",
        "isMe": false,
        "name": "Dr. Smith",
        "time": "10:17 AM",
      },
    ],
  };

  // Helper to flatten messages for backward compatibility
  List<Map<String, dynamic>> get messages {
    final List<Map<String, dynamic>> all = [];
    messagesByDate.forEach((date, msgs) => all.addAll(msgs));
    return all;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.bottomSheet(_ChatRoomConsent(), isScrollControlled: true);
      _scrollToBottom();
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      final now = TimeOfDay.now().format(context);
      // Add to 'Today' group, or create if not present
      final todayKey = "Today";
      if (!messagesByDate.containsKey(todayKey)) {
        messagesByDate[todayKey] = [];
      }
      messagesByDate[todayKey]!.add({
        "text": text,
        "isMe": true,
        "name": "You",
        "time": now,
      });
    });
    _textController.clear();
    _scrollToBottom();
    _generateRandomReply();
  }

  void _generateRandomReply() async {
    final List<String> replies = [
      "That's interesting! Tell me more.",
      "Can you explain further?",
      "I agree with you.",
      "Let's discuss this in detail.",
      "Thanks for sharing!",
      "Could you clarify that?",
      "I'm not sure I understand.",
      "Absolutely!",
      "That's a good point.",
      "I'll look into it.",
    ];
    await Future.delayed(
      Duration(
        milliseconds:
            900 +
            (2000 *
                    (0.2 +
                        0.6 *
                            (DateTime.now().millisecondsSinceEpoch % 1000) /
                            1000))
                .toInt(),
      ),
    );
    final reply = (replies..shuffle()).first;
    setState(() {
      final now = TimeOfDay.now().format(context);
      final todayKey = "Today";
      if (!messagesByDate.containsKey(todayKey)) {
        messagesByDate[todayKey] = [];
      }
      messagesByDate[todayKey]!.add({
        "text": reply,
        "isMe": false,
        "name": "Dr. John",
        "time": now,
      });
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0, // For reverse: true, scroll to top
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
                    // text:
                    //     name.isNotEmpty
                    //         ? name
                    //             .trim()
                    //             .split(' ')
                    //             .map((e) => e.isNotEmpty ? e[0] : '')
                    //             .take(2)
                    //             .join()
                    //             .toUpperCase()
                    //         : '',
                    text: 'IM',
                    size: 16,
                    color: kTertiaryColor,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text: 'Internal Medicine',
                      size: 14,
                      color: kTertiaryColor,
                      weight: FontWeight.w600,
                    ),
                    MyText(
                      paddingTop: 6,
                      text: 'Smith, John, Alex, Perry, Alina, Carry Mo..',
                      size: 10,
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                      color: kGreyColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: GestureDetector(
                onTap: () {
                  Get.bottomSheet(_Options(), isScrollControlled: true);
                },
                child: Image.asset(Assets.imagesMore, height: 24),
              ),
            ),
            SizedBox(width: 20),
          ],
          shape: Border(bottom: BorderSide(width: 1.0, color: kBorderColor)),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                controller: _scrollController,
                padding: AppSizes.DEFAULT,
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: messagesByDate.length,
                itemBuilder: (context, dateIndex) {
                  // Reverse the date keys so 'Today' is always at the bottom with reverse:true
                  final reversedDateKeys =
                      messagesByDate.keys.toList().reversed.toList();
                  final dateKey = reversedDateKeys[dateIndex];
                  final chatList = messagesByDate[dateKey]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: MyText(
                              text: dateKey,
                              size: 10,
                              color: kGreyColor,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      // Messages for this date (normal order)
                      ListView.builder(
                        itemCount: chatList.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, msgIndex) {
                          final msg = chatList[msgIndex];
                          return Align(
                            alignment:
                                msg['isMe']
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                            child:
                                msg['isMe']
                                    ? RightBubble(
                                      text: msg['text'] ?? '',
                                      time: msg['time'] ?? '',
                                    )
                                    : LeftBubble(
                                      text: msg['text'] ?? '',
                                      name: msg['name'] ?? '',
                                    ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
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
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          controller: _textController,
                          onFieldSubmitted: (_) => _sendMessage(),
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
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 0,
                            ),
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
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Image.asset(Assets.imagesSend, height: 34),
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

class LeftBubble extends StatelessWidget {
  final String text;
  final String name;
  const LeftBubble({required this.text, required this.name, Key? key})
    : super(key: key);

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
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
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
  const RightBubble({required this.text, required this.time, Key? key})
    : super(key: key);

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
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
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
            padding: const EdgeInsets.only(right: 8, top: 0),
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
  final List<String> _options = [
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        image: DecorationImage(
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
                        // Group Media
                        break;
                      case 2:
                        // Search
                        break;
                      case 3:
                        // Report
                        break;
                      case 4:
                        // Exit Group
                        break;
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      border: Border.all(color: kBorderColor, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: MyText(
                      text: _options[i],
                      size: 14,
                      color:
                          i == _options.length - 1 ? kRedColor : kTertiaryColor,
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
  final List<Map<String, String>> _options = [
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
    return Container(
      margin: AppSizes.DEFAULT,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        image: DecorationImage(
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
                    style: TextStyle(
                      fontSize: 12,
                      color: kTertiaryColor,
                      fontFamily: AppFonts.URBANIST,
                    ),
                    children: [
                      TextSpan(
                        text: '- ',
                        style: TextStyle(color: kSecondaryColor),
                      ),
                      TextSpan(
                        text: _options[i]['targetText'],
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: ' - ${_options[i]['normalText']}'),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),
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
          SizedBox(height: 20),
          MyButton(
            height: 44,
            buttonText: 'Continue',
            onTap: () {
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
