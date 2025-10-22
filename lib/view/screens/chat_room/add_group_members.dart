import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/widget/common_image_view_widget.dart';
import 'package:manifesto_md/view/widget/custom_check_box_widget.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/custom_search_bar_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';
import 'package:manifesto_md/controllers/create_group_controller.dart'; // keep your path

class AddGroupMembers extends StatefulWidget {
  const AddGroupMembers({super.key});

  @override
  State<AddGroupMembers> createState() => _AddGroupMembersState();
}

class _AddGroupMembersState extends State<AddGroupMembers> {
  late final CreateGroupController c;
  final TextEditingController _searchController = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
   
    c = Get.isRegistered<CreateGroupController>()
        ? Get.find<CreateGroupController>()
        : Get.put(CreateGroupController());

   
    _scrollCtrl.addListener(() {
      final max = _scrollCtrl.position.maxScrollExtent;
      if (_scrollCtrl.position.pixels > max - 280) {
        c.loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- helpers to normalize user fields ---
  String _name(Map<String, dynamic> u) =>
      (u['name'] ?? u['name'] ?? '').toString();
  String _email(Map<String, dynamic> u) =>
      (u['email'] ?? '').toString();
  String _photo(Map<String, dynamic> u) =>
      (u['photoURL'] ?? u['imageUrl'] ?? '').toString();

  String _initials(Map<String, dynamic> u) {
    final n = _name(u).trim();
    if (n.isEmpty) return '';
    final parts = n.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    final letters = parts.take(2).map((e) => e[0]).join();
    return letters.toUpperCase();
    }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: Obx(() => c.selected.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(right: 5, bottom: 15),
                child: GestureDetector(
                  onTap: () async {
                  String resp = await c.submit();
                  if(resp.isNotEmpty){
                    Get.back();
                    Get.back();
                   
                  }
                  },
                  child:c.isSubmitting.value  ? Center(child: CircularProgressIndicator.adaptive(),) : Image.asset(Assets.imagesDone, height: 48),
                ),
              )
            : const SizedBox.shrink()),
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
        body: Obx(() {
          // Build filtered list reactively
          final query = c.query.value.trim().toLowerCase();
          final all = c.users; // RxList<Map>
          final filtered = query.isEmpty
              ? all
              : all.where((u) {
                  final n = _name(u).toLowerCase();
                  final e = _email(u).toLowerCase();
                  return n.contains(query) || e.contains(query);
                }).toList();

          // Create a quick lookup to render selected chips
          final byId = {for (final u in all) u['id'] as String: u};

          return ListView(
            controller: _scrollCtrl,
            shrinkWrap: true,
            padding: AppSizes.VERTICAL,
            physics: const BouncingScrollPhysics(),
            children: [
              // Search
              Padding( 
                padding: AppSizes.HORIZONTAL,
                child: CustomSearchBar(
                  hintText: 'Search Name or Email',
                  controller: _searchController,
                  onChanged: (val) => c.query.value = val,
                ),
              ),

              // Selected chips
              if (c.selected.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 65,
                  child: ListView.separated(
                    padding: AppSizes.HORIZONTAL,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: c.selected.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      final uid = c.selected.elementAt(i);
                      final u = byId[uid];
                      final img = u != null ? _photo(u) : '';
                      final initials = u != null ? _initials(u) : '';
                      final firstName = u != null
                          ? (_name(u).split(' ').firstOrNull ?? _name(u))
                          : uid;

                      return Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.bottomCenter,
                            children: [
                              if (img.isNotEmpty)
                                CommonImageView(
                                  height: 40,
                                  width: 40,
                                  radius: 100,
                                  url: img,
                                  fit: BoxFit.cover,
                                )
                              else
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration:  BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: kBorderColor,
                                  ),
                                  child: Center(
                                    child: MyText(
                                      text: initials,
                                      size: 16,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: () => c.selected.remove(uid),
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
                            text: firstName,
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
                  margin: const EdgeInsets.symmetric(vertical: 16),
                ),
              ],

              SizedBox(height: 10,),

               MyText(
                paddingLeft: 20,
                paddingBottom: 12,
                text: 'All SymptoSmart MD Contacts',
                size: 14,
                weight: FontWeight.w600,
              ),

              // Users list
              ListView.separated(
                itemCount: filtered.length + ((c.hasMore.value && c.isLoadingPage.value) ? 1 : 0),
                padding: AppSizes.HORIZONTAL,
              physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) {
                  // loader row at end
                  if (i >= filtered.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  final u = filtered[i];
                  final uid = u['id'] as String;
                  final img = _photo(u);
                  final nm = _name(u);
                  final em = _email(u);
                  final checked = c.selected.contains(uid);

                  return _MemberTile(
                    name: nm,
                    email: em,
                    imageUrl: img,
                    isSelected: checked,
                    onTap: () => checked ? c.selected.remove(uid) : c.selected.add(uid),
                  );
                },
              ),
            ],
          );
        }),
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
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.isSelected,
    required this.onTap,
  });

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
              decoration:  BoxDecoration(
                shape: BoxShape.circle,
                color: kBorderColor,
              ),
              child: Center(
                child: MyText(
                  text: name.isNotEmpty
                      ? name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).map((e) => e[0]).take(2).join().toUpperCase()
                      : '',
                  size: 16,
                  weight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 12),
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

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
