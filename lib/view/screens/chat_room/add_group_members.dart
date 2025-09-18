import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/main.dart';
import 'package:manifesto_md/view/widget/common_image_view_widget.dart';
import 'package:manifesto_md/view/widget/custom_check_box_widget.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/custom_search_bar_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class AddGroupMembers extends StatefulWidget {
  const AddGroupMembers({super.key});

  @override
  State<AddGroupMembers> createState() => _AddGroupMembersState();
}

class _AddGroupMembersState extends State<AddGroupMembers> {
  final List<Map<String, String>> chatGroups = [
    {'name': 'Alex S', 'email': 'AS@gmail.com', 'imageUrl': dummyImg},
    {'name': 'Danish Mehmood', 'email': 'DM@gmail.com', 'imageUrl': dummyImg},
    {'name': 'Sara Khan', 'email': 'sara.khan@email.com', 'imageUrl': dummyImg},
    {'name': 'John Doe', 'email': 'john.doe@email.com', 'imageUrl': dummyImg},
    {
      'name': 'Emily Clark',
      'email': 'emily.clark@email.com',
      'imageUrl': dummyImg,
    },
    {
      'name': 'Michael Lee',
      'email': 'michael.lee@email.com',
      'imageUrl': dummyImg,
    },
    {
      'name': 'Priya Patel',
      'email': 'priya.patel@email.com',
      'imageUrl': dummyImg,
    },
    {
      'name': 'Carlos Rivera',
      'email': 'carlos.rivera@email.com',
      'imageUrl': dummyImg,
    },
    {'name': 'Fatima Zahra', 'email': 'fatima.zahra@email.com', 'imageUrl': ''},
    {'name': 'Tom Smith', 'email': 'tom.smith@email.com', 'imageUrl': ''},
  ];
  final Set<int> selectedIndexes = {};
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Filter chatGroups based on searchQuery
    final List<Map<String, String>> filteredGroups =
        searchQuery.isEmpty
            ? chatGroups
            : chatGroups
                .where(
                  (member) =>
                      (member['name'] ?? '').toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ) ||
                      (member['email'] ?? '').toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ),
                )
                .toList();

    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton:
            selectedIndexes.isNotEmpty
                ? Padding(
                  padding: const EdgeInsets.only(right: 5, bottom: 15),
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Image.asset(Assets.imagesDone, height: 48),
                  ),
                )
                : null,

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
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
          title: Column(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MyText(
                text: 'New Group',
                size: 14,
                color: kTertiaryColor,
                weight: FontWeight.w600,
              ),
              MyText(text: 'Add Members', size: 12, color: kTertiaryColor),
            ],
          ),
        ),
        body: ListView(
          shrinkWrap: true,
          padding: AppSizes.VERTICAL,
          physics: BouncingScrollPhysics(),
          children: [
            Padding(
              padding: AppSizes.HORIZONTAL,
              child: CustomSearchBar(
                hintText: 'Search Name or Email',
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    searchQuery = val;
                  });
                },
              ),
            ),
            if (selectedIndexes.isNotEmpty) ...[
              SizedBox(height: 16),
              SizedBox(
                height: 65,
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: AppSizes.HORIZONTAL,
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedIndexes.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(width: 10);
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.bottomCenter,
                          children: [
                            if (chatGroups[selectedIndexes.elementAt(
                                      index,
                                    )]['imageUrl'] !=
                                    null &&
                                chatGroups[selectedIndexes.elementAt(
                                      index,
                                    )]['imageUrl']!
                                    .isNotEmpty)
                              CommonImageView(
                                height: 40,
                                width: 40,
                                radius: 100,
                                url:
                                    chatGroups[selectedIndexes.elementAt(
                                      index,
                                    )]['imageUrl'] ??
                                    '',
                                fit: BoxFit.cover,
                              )
                            else
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: kBorderColor,
                                ),
                                child: Center(
                                  child: MyText(
                                    text:
                                        chatGroups[selectedIndexes.elementAt(
                                                  index,
                                                )]['name'] !=
                                                null
                                            ? chatGroups[selectedIndexes
                                                    .elementAt(index)]['name']!
                                                .trim()
                                                .split(' ')
                                                .where((e) => e.isNotEmpty)
                                                .map((e) => e.substring(0, 1))
                                                .take(2)
                                                .join()
                                                .toUpperCase()
                                            : '',
                                    size: 16,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                              ),

                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndexes.remove(
                                      selectedIndexes.elementAt(index),
                                    );
                                  });
                                },
                                child: Image.asset(
                                  Assets.imagesCancelIcon,
                                  height: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        MyText(
                          paddingTop: 6,
                          text:
                              (() {
                                final name =
                                    chatGroups[selectedIndexes.elementAt(
                                      index,
                                    )]['name'] ??
                                    '';
                                final parts = name.trim().split(' ');
                                return parts.isNotEmpty ? parts.first : name;
                              })(),
                          size: 12,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          textOverflow: TextOverflow.ellipsis,
                          weight: FontWeight.w500,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Container(
                height: 1,
                color: kBorderColor,
                margin: EdgeInsets.symmetric(vertical: 16),
              ),
            ],

            MyText(
              paddingLeft: 20,
              paddingTop: selectedIndexes.isNotEmpty ? 0 : 16,
              paddingBottom: 12,
              text: 'All SymptoSmart MD Contacts',
              size: 14,
              weight: FontWeight.w600,
            ),
            ListView.separated(
              itemCount: filteredGroups.length,
              padding: AppSizes.HORIZONTAL,
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 16);
              },
              itemBuilder: (BuildContext context, int filteredIndex) {
                // Find the original index in chatGroups for selection tracking
                final originalIndex = chatGroups.indexOf(
                  filteredGroups[filteredIndex],
                );
                return _MemberTile(
                  name: filteredGroups[filteredIndex]['name'] ?? '',
                  email: filteredGroups[filteredIndex]['email'] ?? '',
                  imageUrl: filteredGroups[filteredIndex]['imageUrl'] ?? '',
                  isSelected: selectedIndexes.contains(originalIndex),
                  onTap: () {
                    setState(() {
                      if (selectedIndexes.contains(originalIndex)) {
                        selectedIndexes.remove(originalIndex);
                      } else {
                        selectedIndexes.add(originalIndex);
                      }
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final String name;
  final String email;
  final String imageUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const _MemberTile({
    Key? key,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          if (imageUrl.isNotEmpty)
            CommonImageView(
              height: 48,
              width: 48,
              url: imageUrl,
              radius: 100,
              fit: BoxFit.cover,
            )
          else
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kBorderColor,
              ),
              child: Center(
                child: MyText(
                  text:
                      name.isNotEmpty
                          ? name
                              .trim()
                              .split(' ')
                              .map((e) => e.isNotEmpty ? e[0] : '')
                              .take(2)
                              .join()
                              .toUpperCase()
                          : '',
                  size: 16,
                  weight: FontWeight.w600,
                ),
              ),
            ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(text: name, size: 14, weight: FontWeight.w600),
                MyText(
                  paddingTop: 6,
                  text: email,
                  size: 12,
                  maxLines: 1,
                  textOverflow: TextOverflow.ellipsis,
                  color: kGreyColor,
                ),
              ],
            ),
          ),
          CustomCheckBox(
            radius: 100,
            borderWidth: 1.0,
            isActive: isSelected,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}
