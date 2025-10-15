import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/config/extensions/media_query_extensions.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/controllers/auth_controller.dart';
import 'package:manifesto_md/controllers/profile_controller.dart';
import 'package:manifesto_md/main.dart';
import 'package:manifesto_md/view/screens/profile/app_language.dart';
import 'package:manifesto_md/view/screens/profile/app_theme.dart';
import 'package:manifesto_md/view/screens/profile/edit_profile.dart';
import 'package:manifesto_md/view/screens/profile/notification_settings.dart';
import 'package:manifesto_md/view/screens/profile/privacy_settings.dart';
import 'package:manifesto_md/view/screens/profile/references.dart';
import 'package:manifesto_md/view/screens/subscription/subscription.dart';
import 'package:manifesto_md/view/widget/common_image_view_widget.dart';
import 'package:manifesto_md/view/widget/common_shimmer_widget.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

    final ProfileController profileController = Get.find();
    final AuthController authController = Get.find();

  @override
  void initState() {
    super.initState();
      profileController.fetchProfile();
  }
  
  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(title: 'Settings'),
        body: ListView(
          shrinkWrap: true,
          padding: AppSizes.DEFAULT,
          physics: BouncingScrollPhysics(),
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    CommonImageView(
                      height: 60,
                      width: 60,
                      url: dummyImg,
                      fit: BoxFit.cover,
                      radius: 100,
                    ),
                   Obx(() => Positioned(
                      bottom: 0,
                      right: 0,
                      child: profileController.isLoading.value ? CommonShimmer(height: 60, width: 60, radius: 60,) :  Image.asset(
                        Assets.imagesChangeProfileImage,
                        height: 22,
                      ),
                    ),
                   )
                  ],
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    
                    children: [
                    Obx( () => profileController.isLoading.value ? CommonShimmer(
                      height: 10, width: context.screenWidth,
                    )  :  MyText(
                        text: profileController.profile.value?.name ?? "",
                        size: 16,
                        weight: FontWeight.w700,
                      )),
                      SizedBox(height: 4,),
                    Obx( () => profileController.isLoading.value ? CommonShimmer(
                      height: 10, width: context.screenWidth,
                    )  :  MyText(
                        paddingTop: 6,
                        text:  profileController.profile.value?.email ?? "",
                        size: 12,
                        weight: FontWeight.w500,
                        color: kGreyColor,
                      )),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
               Obx( () => MyText(
                  onTap: () {
                    Get.to(() => EditProfile());
                  },
                  text: profileController.profileCompletion.value == 100 ? 'Edit Profile' : 'Complete Your Profile. ',
                  size: 10,
                  weight: FontWeight.w600,
                  color: kSecondaryColor,
                  decoration: TextDecoration.underline,
                )),
                Expanded(
                  child: MyText(
                    text: 'Add your specialty to improve content relevance! ',
                    size: 10,
                    weight: FontWeight.w500,
                    color: kGreyColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
          Obx( () => profileController.isLoading.value ? CommonShimmer(
                      height: 10, width: context.screenWidth,
                    )  :  LinearPercentIndicator(
              lineHeight: 6.0,
              percent: profileController.profileCompletion.value,
              padding: EdgeInsets.zero,
              backgroundColor: kSecondaryColor.withValues(alpha: 0.12),
              progressColor: kSecondaryColor,
              barRadius: Radius.circular(8),
              animation: true,
              trailing: MyText(
                paddingLeft: 6,
                text: '${(profileController.profileCompletion.value * 100).toStringAsFixed(0)}%',
                size: 12,
                weight: FontWeight.w500,
                color: kGreyColor,
              ),
              animationDuration: 800,
            )),
            Container(
              height: 1,
              color: kBorderColor,
              margin: EdgeInsets.symmetric(vertical: 16),
            ),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage(Assets.imagesProBg)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Image.asset(Assets.imagesCrown, height: 38),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MyText(
                          text: 'Manifesto MD PRO',
                          size: 16,
                          weight: FontWeight.w700,
                          color: kPrimaryColor,
                        ),
                        MyText(
                          paddingTop: 8,
                          text:
                              'Upgrade to pro and get access of premium features',
                          size: 10,
                          color: kPrimaryColor,
                          weight: FontWeight.w700,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => Subscription());
                    },
                    child: Container(
                      width: 72,
                      height: 30,
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      alignment: Alignment.center,
                      child: MyText(
                        text: 'Continue',
                        size: 12,
                        weight: FontWeight.bold,
                        color: kSecondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            MyText(text: 'General', weight: FontWeight.w600, paddingBottom: 8),
            _ProfileTile(
              onTap: () {
                Get.bottomSheet(AppLanguage(), isScrollControlled: true);
              },
              image: Assets.imagesAppLanguage,
              title: 'App Language',
              subtitle: 'Customize to your regional languages.',
            ),
            _ProfileTile(
              onTap: () {
                Get.bottomSheet(_RateUs(), isScrollControlled: true);
              },
              image: Assets.imagesRateUs,
              title: 'Rate Us',
              subtitle: 'Rate our app on play store.',
            ),
            _ProfileTile(
              onTap: () {
                Get.bottomSheet(AppTheme(), isScrollControlled: true);
              },
              image: Assets.imagesAppTheme,
              title: 'App Theme',
              subtitle: 'Light Theme',
            ),
            _ProfileTile(
              image: Assets.imagesReferenceIcon,
              title: 'References',
              subtitle: 'View medical sources & research',
              onTap: () {
                Get.to(() => References());
              },
            ),
            MyText(
              text: 'Customize',
              weight: FontWeight.w600,
              paddingBottom: 8,
            ),
            _ProfileTile(
              onTap: () {
                Get.to(() => NotificationSettings());
              },
              image: Assets.imagesNotificationSettings,
              title: 'Notification Settings',
              subtitle: 'Content Updates, Chat Messages, Clinical Alerts',
            ),
            _ProfileTile(
              image: Assets.imagesPersonalContent,
              title: 'Personal Content',
              subtitle: 'Favorite List, Chat Rooms ',
            ),
            _ProfileTile(
              onTap: () {
                Get.to(() => PrivacySettings());
              },
              image: Assets.imagesPrivacySettings,
              title: 'Privacy Settings',
              subtitle: 'Show online status',
            ),
            MyText(text: 'Others', weight: FontWeight.w600, paddingBottom: 8),
            _ProfileTile(
              image: Assets.imagesShareTheApp,
              title: 'Share the App',
              subtitle: 'Tell your friends about SymptoSmart MD App',
            ),
            _ProfileTile(
              onTap: () {
                Get.bottomSheet(_DeleteAccount(
                  
                   title: 'Logout!',
                  subtitle:  'Are you sure you want to logout?' ,
                  btnText: "Logout",
                  icon:  Assets.imageLogout,
                  ontap: () {
                    authController.logOut();
                  },
                ), isScrollControlled: true);
              },
              image: Assets.imageLogout,
              title: 'Logout',
              subtitle: 'Logout Your Account',
              
              isRed: false,
            ),
            _ProfileTile(
              onTap: () {
                Get.bottomSheet(_DeleteAccount(
                  title: 'Delete Account!',
                  subtitle:  'Are you sure you want to delete your account?' ,
                  btnText: "Delete",
                  icon:  Assets.imagesDeleteAccountIcon,
                  ontap: (){
                    
                  },
                ), isScrollControlled: true);
              },
              image: Assets.imagesDeleteAccount,
              title: 'Delete Account',
              subtitle: 'Signout from your account',
              isRed: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final bool isRed;
  final VoidCallback? onTap;

  const _ProfileTile({
    required this.image,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isRed = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isRed ? kRedColor.withValues(alpha: 0.05) : kBorderColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            width: 1,
            color:
                isRed
                    ? kRedColor.withValues(alpha: 0.12)
                    : kBorderColor.withValues(alpha: .05),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.asset(image, height: 32)),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MyText(text: title, weight: FontWeight.w600),
                  MyText(
                    paddingTop: 4,
                    text: subtitle,
                    size: 10,
                    color: kGreyColor,
                    weight: FontWeight.w500,
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

class _DeleteAccount extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final String btnText; 
  final Function()? ontap;
  const _DeleteAccount({required this.title, required this.subtitle, 
  required this.btnText, required this.ontap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: AppSizes.DEFAULT,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MyText(
                text: title ,
                size: 18,
                weight: FontWeight.w700,
                paddingBottom: 8,
              ),
              MyText(
                text: subtitle,
                paddingBottom: 20,
              ),
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: MyBorderButton(
                      buttonText: 'Cancel',
                      onTap: () {
                        Get.back();
                      },
                    ),
                  ),
                  Expanded(
                    child: MyButton(
                      bgColor: kRedColor,
                      buttonText:  btnText ,
                      onTap: ontap ?? (){},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Positioned(
          top: -16,
          right: 32,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
            
            child: Image.asset(icon, height: 65)),
        ),
      ],
    );
  }
}

class _RateUs extends StatefulWidget {
  @override
  State<_RateUs> createState() => _RateUsState();
}

class _RateUsState extends State<_RateUs> {
  final List<String> imageAssets = [
    Assets.imagesOneStar,
    Assets.imagesTwoStar,
    Assets.imagesThreeStar,
    Assets.imagesFourStar,
    Assets.imagesFiveStar,
  ];
  int selectedRating = 0;
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: AppSizes.DEFAULT,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MyText(
                text: 'Rate Our App',
                size: 20,
                color: kSecondaryColor,
                weight: FontWeight.w700,
                paddingBottom: 8,
              ),
              MyText(
                size: 12,
                text:
                    'We work super hard to make application better for you, and would love to know',
                paddingBottom: 20,
                lineHeight: 1.5,
                color: kGreyColor.withValues(alpha: 0.7),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: RatingBar.builder(
                      initialRating: 1,
                      minRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemSize: 35,
                      glow: false,
                      updateOnDrag: false,
                      unratedColor: Color(0xff999999),
                      itemPadding: EdgeInsets.symmetric(horizontal: 5.0),
                      itemBuilder:
                          (context, _) =>
                              Image.asset(Assets.imagesStarFiled, height: 35),
                      onRatingUpdate: (rating) {
                        setState(() {
                          selectedRating = rating.toInt().clamp(1, 5) - 1;
                        });
                      },
                    ),
                  ),
                  Center(
                    child: MyText(
                      paddingTop: 50,
                      text: 'Our best we can get',
                      size: 12,
                      color: kGreyColor.withValues(alpha: 0.7),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    right: 44,
                    child: Image.asset(Assets.imagesRoundedArrow, height: 70),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: MyBorderButton(
                      buttonText: 'May Be, later!',
                      onTap: () {
                        Get.back();
                      },
                    ),
                  ),
                  Expanded(
                    child: MyButton(
                      buttonText: 'Thanks',
                      onTap: () {
                        Get.back();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Positioned(
          top: -30,
          right: 32,
          child: Image.asset(imageAssets[selectedRating], height: 90),
        ),
      ],
    );
  }
}
