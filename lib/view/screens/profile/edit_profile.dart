import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_country_list.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/controllers/profile_controller.dart';
import 'package:manifesto_md/main.dart';
import 'package:manifesto_md/models/auth_model.dart';
import 'package:manifesto_md/models/professional_details_model.dart';
import 'package:manifesto_md/view/widget/common_image_view_widget.dart';
import 'package:manifesto_md/view/widget/common_shimmer_widget.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/custom_drop_down_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_field_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class EditProfile extends StatefulWidget {
  EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final ProfileController profileController = Get.find();

  final nameTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final specialityTextController = TextEditingController();

  String? selectedCountryName;
  String? selectedExpLevel;

  final listProfessional = const [
    'Medical Student',
    'Internship Doctor',
    'Resident',
    'General Practitioner',
    'Specialist / Consultant',
  ];


  late Worker _profDetailsWorker;
  late Worker _profileWorker;

  String? _matchOption(String? value, List<String> options) {
    if (value == null) return null;
    final v = value.trim().toLowerCase();
    for (final opt in options) {
      if (opt.toLowerCase().trim() == v) return opt;
    }
    for (final opt in options) {
      final o = opt.toLowerCase();
      if (o.startsWith(v) || o.contains(v)) return opt;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    
    nameTextController.text = profileController.profile.value?.name ?? "";
    emailTextController.text = profileController.profile.value?.email ?? "";
    specialityTextController.text =
        profileController.professionalDetails.value?.speciality ?? "";

    selectedExpLevel = _matchOption(
          profileController.professionalDetails.value?.professionalLevel,
          listProfessional,
        ) ??
        listProfessional.first;

    selectedCountryName = _matchOption(
          profileController.profile.value?.country,
          countryList,
        ) ??
        countryList.first;

    _profDetailsWorker =
        ever<ProfessionalDetailsModel?>(profileController.professionalDetails,
            (details) {
      if (!mounted) return;
      final m = _matchOption(details?.professionalLevel, listProfessional);
      if (m != null && m != selectedExpLevel) {
        setState(() => selectedExpLevel = m);
      }
    });

    _profileWorker = ever<AuthModel?>(profileController.profile, (p) {
      if (!mounted) return;
      final m = _matchOption(p?.country, countryList);
      if (m != null && m != selectedCountryName) {
        setState(() => selectedCountryName = m);
      }
    });
  }

  @override
  void dispose() {
    // 🔹 dispose controllers
    nameTextController.dispose();
    emailTextController.dispose();
    specialityTextController.dispose();

    _profDetailsWorker.dispose();
    _profileWorker.dispose();

    super.dispose();
  }



  void _showImageSourceSheet() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }
 Future<void> _pickImage(ImageSource source) async {
    Get.back();
    await profileController.pickAndUploadProfileImage(source: source);
  }
  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(title: 'Edit Profile'),
        body: ListView(
          shrinkWrap: true,
          padding: AppSizes.DEFAULT,
          physics: const BouncingScrollPhysics(),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 MyText(
                  text: 'Your Basic\nDetails',
                  size: 24,
                  weight: FontWeight.w600,
                ),
                Stack(
                  children: [
                    // You can swap dummyImg with profileController.imageUrl.value if you want
                     Obx(() {
                      final url = profileController.imageUrl.value.isNotEmpty
                          ? profileController.imageUrl.value
                          : dummyImg;
                      return CommonImageView(
                        height: 80,
                        width: 80,
                        url: url,
                        fit: BoxFit.cover,
                        radius: 100,
                      );
                    }),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: (){
                          _showImageSourceSheet();
                          print("object");
                        },
                        child: Obx(() {
                          if (profileController.isLoading.value) {
                            return const CommonShimmer(
                              height: 28,
                              width: 28,
                              radius: 28,
                            );
                          }
                          return Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              // color: kSecondaryColor,
                              shape: BoxShape.circle,
                              // border: Border.all(color: kPrimaryColor, width: 1),
                            ),
                            child: Image.asset(
                              Assets.imagesChangeProfileImage,
                              height: 32,
                            ),
                          );
                        }),
                      ),
                    ),
                   
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            MyTextField(
              labelText: 'Name',
              controller: nameTextController,
              hintText: profileController.profile.value?.name ?? "",
              labelPrefix: Assets.imagesName,
            ),
            MyTextField(
              labelText: 'Email',
              hintText: "Enter your email",
              isReadOnly: true,
              labelPrefix: Assets.imagesEmail,
              controller: emailTextController,
            ),
            CustomDropDown(
              labelPrefix: Assets.imagesCountryIcon,
              labelText: 'Country',
              hint: 'Select Country',
              items: countryList,
              selectedValue: selectedCountryName,
              onChanged: (value) {
                setState(() => selectedCountryName = value);
              },
            ),
            MyTextField(
              labelText: 'Medical Specialty',
              hintText: 'Internal Medicine',
              controller: specialityTextController,
              labelPrefix: Assets.imagesMedicalSpecial,
            ),
            CustomDropDown(
              labelPrefix: Assets.imagesProfessinalLevelIcon,
              labelText: 'Professional Level',
              hint: 'General Practitioner',
              items: listProfessional,
              selectedValue: selectedExpLevel,
              onChanged: (value) {
                setState(() {
                  selectedExpLevel = value;
                });
              },
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: AppSizes.DEFAULT,
            child: Obx(
              () => MyButton(
                isLoading: profileController.isLoading.value,
                buttonText: 'Done',
                onTap: () async {
                  // No setState here after await → safe with Get.back() in controller
                  await profileController.updateProfile(
                    profileController.docId.value,
                    nameTextController.text,
                    selectedCountryName!,
                    specialityTextController.text,
                    selectedExpLevel!,
                  );
                  // Navigation is handled inside controller (Get.back()) as you wanted
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
