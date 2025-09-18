import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_fonts.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class Subscription extends StatefulWidget {
  const Subscription({super.key});

  @override
  State<Subscription> createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  /// 0 = Free, 1 = Premium
  int currentPlanIndex = 0;

  void selectPlan(int index) {
    setState(() {
      currentPlanIndex = index;
    });
  }

  int selectedPlanIndex = 1;

  final List<Map<String, String>> _premiumPlan = [
    {'title': 'Monthly', 'description': 'Billed monthly', 'price': '\$ 350.00'},
    {
      'title': 'Annually',
      'description': 'Billed annually',
      'price': '\$ 850.00',
    },
    {
      'title': 'Lifetime',
      'description': 'One time payment',
      'price': '\$ 1999.00',
    },
  ];
  final List<Map<String, String>> _standardPlan = [
    {'title': 'Monthly', 'description': 'Billed monthly', 'price': '\$ 7.7'},
    {'title': 'Annually', 'description': 'Billed annually', 'price': '\$ 75.5'},
  ];

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 55),
            Padding(
              padding: AppSizes.HORIZONTAL,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2),
                    height: 30,
                    width: 225,
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      border: Border.all(width: 1.0, color: kBorderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: List.generate(2, (index) {
                        final planNames = ['Premium', 'Standard'];
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => selectPlan(index),
                            child: Container(
                              height: Get.height,
                              decoration: BoxDecoration(
                                gradient:
                                    currentPlanIndex == index
                                        ? LinearGradient(
                                          colors: [
                                            Color(0xff12C0C0),
                                            Color(0xff009CCD),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        )
                                        : null,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: MyText(
                                  text: planNames[index],
                                  size: 12,
                                  weight: FontWeight.w500,
                                  color:
                                      currentPlanIndex == index
                                          ? kPrimaryColor
                                          : kGreyColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Image.asset(Assets.imagesCancel, height: 24),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                padding: AppSizes.VERTICAL,
                physics: BouncingScrollPhysics(),
                children: [
                  Padding(
                    padding: AppSizes.HORIZONTAL,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Image.asset(Assets.imagesCrown, height: 52),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            MyText(
                              text: 'Manifesto MD',
                              size: 30,
                              weight: FontWeight.w700,
                            ),
                            MyText(
                              text: ' PRO',
                              size: 30,
                              weight: FontWeight.w700,
                              color: kSecondaryColor,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        MyText(
                          text:
                              '100% ADs-Free experience with unlimited filters',
                          size: 12,
                          weight: FontWeight.w600,
                          color: kGreyColor,
                          paddingBottom: 16,
                        ),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(width: 1.0, color: kBorderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 70,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            color: kSecondaryColor,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Center(
                                            child: MyText(
                                              text: 'Features',
                                              weight: FontWeight.w600,
                                              color: kPrimaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: MyText(
                                      text: 'Standard',
                                      size: 12,
                                      textAlign: TextAlign.center,
                                      weight: FontWeight.w600,
                                      color: kSecondaryColor,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: MyText(
                                      text: 'Premium',
                                      size: 12,
                                      textAlign: TextAlign.center,
                                      weight: FontWeight.w600,
                                      color: kSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: Column(
                                      spacing: 20,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: List.generate(4, (index) {
                                        final features = [
                                          'All features',
                                          'Chat Group Creation',
                                          'Smart DDx',
                                          'Ads Free Version',
                                        ];
                                        return MyText(
                                          text: features[index],
                                          weight: FontWeight.w600,
                                        );
                                      }),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      spacing: 16,
                                      children: List.generate(4, (index) {
                                        return Image.asset(
                                          index < 3
                                              ? Assets.imagesCancelIcon
                                              : Assets.imagesCheckIcon,
                                          height: 24,
                                        );
                                      }),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      spacing: 16,
                                      children: List.generate(4, (index) {
                                        return Image.asset(
                                          Assets.imagesCheckIcon,
                                          height: 24,
                                        );
                                      }),
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
                  SizedBox(height: 24),
                  CarouselSlider(
                    carouselController: CarouselSliderController(),
                    options: CarouselOptions(
                      viewportFraction: 0.4,
                      enableInfiniteScroll: false,
                      autoPlay: false,
                      height: 150,
                      initialPage: 1,
                      enlargeCenterPage: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          selectedPlanIndex = index;
                        });
                      },
                    ),
                    items: List.generate(
                      currentPlanIndex == 0
                          ? _premiumPlan.length
                          : _standardPlan.length,
                      (index) {
                        return _Plan(
                          title:
                              currentPlanIndex == 0
                                  ? _premiumPlan[index]['title']!
                                  : _standardPlan[index]['title']!,
                          description:
                              currentPlanIndex == 0
                                  ? _premiumPlan[index]['description']!
                                  : _standardPlan[index]['description']!,
                          price:
                              currentPlanIndex == 0
                                  ? _premiumPlan[index]['price']!
                                  : _standardPlan[index]['price']!,
                          isSelected: selectedPlanIndex == index,
                          onTap: () {},
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: AppSizes.DEFAULT,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MyText(
                          paddingTop: 20,
                          text:
                              'Free premium for 3 days! After that, Rs 280.00/Week,\nCancel anytime before trial ends to avoid changes.',
                          size: 12,
                          lineHeight: 1.5,
                          color: kGreyColor,
                          paddingBottom: 12,
                          textAlign: TextAlign.center,
                        ),
                        MyButton(
                          radius: 16,
                          height: 56,
                          buttonText: '',
                          onTap: () {},
                          customChild: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: MyText(
                                    text: 'Subscribe Now',
                                    size: 16,
                                    weight: FontWeight.w600,
                                    color: kPrimaryColor,
                                  ),
                                ),
                                Image.asset(
                                  Assets.imagesArrowNextRounded,
                                  height: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontFamily: AppFonts.URBANIST,
                                color: kGreyColor,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Restore',
                                  style: TextStyle(
                                    fontSize: 10,
                                    decoration: TextDecoration.underline,
                                    color: kGreyColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(text: ' | '),
                                TextSpan(
                                  text: 'Terms of Use',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: kGreyColor,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(text: ' | '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: kGreyColor,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _Plan extends StatelessWidget {
  final String title;
  final String price;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _Plan({
    Key? key,
    required this.title,
    required this.description,
    required this.price,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? kBorderColor : kPrimaryColor,
        border: Border.all(
          width: isSelected ? 2.0 : 1.0,
          color: isSelected ? kSecondaryColor : kBorderColor,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? kSecondaryColor : Colors.transparent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Center(
              child: MyText(
                text: title.toUpperCase(),
                size: 16,
                color: isSelected ? kPrimaryColor : kTertiaryColor,
                textAlign: TextAlign.center,
                weight: FontWeight.w700,
              ),
            ),
          ),
          Spacer(),
          MyText(
            text: price,
            size: 20,
            color: isSelected ? kSecondaryColor : kTertiaryColor,
            textAlign: TextAlign.center,
            weight: FontWeight.w700,
          ),
          Spacer(),
          MyText(
            text:
                description == 'One time payment' ? 'Rs. 2500.00' : description,
            size: 10,
            decoration:
                description == 'One time payment'
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
            color: isSelected ? kTertiaryColor : kGreyColor,
            weight: FontWeight.w600,
            textAlign: TextAlign.center,
            paddingBottom: 12,
          ),
        ],
      ),
    );
  }
}
