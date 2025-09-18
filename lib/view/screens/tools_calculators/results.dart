import 'package:flutter/material.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class Results extends StatefulWidget {
  const Results({super.key});

  @override
  State<Results> createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  int _stage = 0;
  final List<Map<String, String>> _stages = [
    {
      'score': '01',
      'status': 'Low Risk',
      'desc': 'Outpatient treatment recommended. Routine follow-up advised.',
    },
    {
      'score': '02',
      'status': 'Moderate Risk',
      'desc':
          'Increase frequency of monitoring and follow-up visits. Consider additional diagnostic tests or preventive measures. Provide patient education on risk factors.',
    },
    {
      'score': '03',
      'status': 'High Risk',
      'desc':
          'Immediate and comprehensive evaluation required. Initiate necessary interventions promptly. Refer to specialist if needed. Ensure continuous monitoring and follow-up.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animateStages();
  }

  void _animateStages() async {
    for (int i = 0; i < _stages.length; i++) {
      setState(() {
        _stage = i;
      });
      await Future.delayed(Duration(seconds: 3));
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _stages[_stage];
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(title: 'CURB-65-Calculation & Result'),
        body: ListView(
          shrinkWrap: true,
          padding: AppSizes.DEFAULT,
          physics: BouncingScrollPhysics(),
          children: [
            _ScoreCard(
              title: 'CURB-65',
              score: current['score']!,
              status: current['status']!,
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kPrimaryColor,
                border: Border.all(color: kBorderColor, width: 1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Image.asset(Assets.imagesInformation, height: 16),
                      Expanded(
                        child: MyText(
                          paddingLeft: 8,
                          text: 'What this means',
                          size: 16,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  MyText(
                    paddingTop: 8,
                    text: current['status']!,
                    size: 12,
                    color:
                        current['status'] == 'Moderate Risk'
                            ? kOrangeColor
                            : current['status'] == 'High Risk'
                            ? kRedColor
                            : kSecondaryColor,
                    weight: FontWeight.w600,
                  ),
                  MyText(
                    paddingTop: 8,
                    text: current['desc']!,
                    size: 12,
                    lineHeight: 1.5,
                    color: kGreyColor,
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

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.title,
    required this.score,
    required this.status,
  });
  final String title;
  final String score;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 12, 12, 4),
      decoration: BoxDecoration(
        color:
            status == 'Moderate Risk'
                ? kOrangeColor.withValues(alpha: 0.12)
                : status == 'High Risk'
                ? kRedColor.withValues(alpha: 0.12)
                : kBorderColor,
        border: Border.all(
          color:
              status == 'Moderate Risk'
                  ? kOrangeColor.withValues(alpha: 0.12)
                  : status == 'High Risk'
                  ? kRedColor.withValues(alpha: 0.12)
                  : kBorderColor,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyText(
            text: title,
            size: 16,
            weight: FontWeight.w600,
            paddingBottom: 12,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText(
                text: score,
                size: 60,
                color:
                    status == 'Moderate Risk'
                        ? kOrangeColor
                        : status == 'High Risk'
                        ? kRedColor
                        : kSecondaryColor,
                weight: FontWeight.w600,
              ),
              Container(
                margin: EdgeInsets.only(bottom: 8),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      status == 'Moderate Risk'
                          ? kOrangeColor.withValues(alpha: 0.12)
                          : status == 'High Risk'
                          ? kRedColor.withValues(alpha: 0.12)
                          : kBorderColor,
                  border: Border.all(
                    color:
                        status == 'Moderate Risk'
                            ? kOrangeColor.withValues(alpha: 0.12)
                            : status == 'High Risk'
                            ? kRedColor.withValues(alpha: 0.12)
                            : kBorderColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: MyText(
                  text: status,
                  size: 10,
                  weight: FontWeight.w600,
                  color:
                      status == 'Moderate Risk'
                          ? kOrangeColor
                          : status == 'High Risk'
                          ? kRedColor
                          : kSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
