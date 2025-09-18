import 'package:flutter/material.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class References extends StatelessWidget {
  const References({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(title: 'References'),
        body: ListView(
          shrinkWrap: true,
          padding: AppSizes.DEFAULT,
          physics: BouncingScrollPhysics(),
          children: [
            MyText(text: 'Guidelines:', size: 16, weight: FontWeight.w600),
            MyText(
              paddingTop: 8,
              paddingBottom: 16,
              text:
                  '- National Institute for Health and Care Excellence (NICE). (2019). Pneumonia in adults: diagnosis and management. NICE Clinical Guideline [CG191].',
              size: 12,
              color: kGreyColor,
            ),
            MyText(
              paddingTop: 8,
              paddingBottom: 16,
              text:
                  '- World Health Organization (WHO). (2020). Global report on pneumonia. WHO Publications.',
              size: 12,
              color: kGreyColor,
            ),
            MyText(text: 'Research Papers:', size: 16, weight: FontWeight.w600),
            MyText(
              paddingTop: 8,
              paddingBottom: 16,
              text:
                  '- Lim, W. S., van der Eerden, M. M., Laing, R., Boersma, W. G., Karalus, N., Town, G. I., ... & Woodhead, M. A. (2003). Defining community acquired pneumonia severity on presentation to hospital: an international derivation and validation study. Thorax, 58(5), 377–382.',
              size: 12,
              color: kGreyColor,
            ),
            MyText(
              paddingTop: 8,
              paddingBottom: 16,
              text:
                  '- Fine, M. J., Auble, T. E., Yealy, D. M., Hanusa, B. H., Weissfeld, L. A., Singer, D. E., ... & Kapoor, W. N. (1997). A prediction rule to identify low-risk patients with community-acquired pneumonia. New England Journal of Medicine, 336(4), 243–250.',
              size: 12,
              color: kGreyColor,
            ),
            MyText(text: 'Textbooks:', size: 16, weight: FontWeight.w600),
            MyText(
              paddingTop: 8,
              paddingBottom: 16,
              text:
                  '- Mandell, L. A., & Niederman, M. S. (2015). Community-acquired pneumonia. In: Kasper D, Fauci A, Hauser S, Longo D, Jameson J, Loscalzo J. (Eds.), Harrison\'s Principles of Internal Medicine (19th ed.). McGraw-Hill.',
              size: 12,
              color: kGreyColor,
            ),
            MyText(
              text: 'Online Resources:',
              size: 16,
              weight: FontWeight.w600,
            ),
            MyText(
              paddingTop: 8,
              paddingBottom: 16,
              text:
                  '- UpToDate. (2022). Clinical assessment of community-acquired pneumonia. Wolters Kluwer.',
              size: 12,
              color: kGreyColor,
            ),
            MyText(
              paddingTop: 8,
              paddingBottom: 16,
              text:
                  '- Centers for Disease Control and Prevention (CDC). (2021). Pneumonia (community-acquired): Diagnosis and management. CDC.gov.',
              size: 12,
              color: kGreyColor,
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: AppSizes.DEFAULT,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MyText(
                text: 'Disclaimer:',
                size: 14,
                weight: FontWeight.w600,
                color: kSecondaryColor,
                paddingBottom: 6,
              ),
              MyText(
                text:
                    'The scientific content and the total ManifestoMD will be updated on a regular basis every six months to maximize your benefits.',
                size: 11,
                weight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                lineHeight: 1.5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
