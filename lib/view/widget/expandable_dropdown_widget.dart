import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_fonts.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class ExpandableDropdown extends StatefulWidget {
  const ExpandableDropdown({
    required this.title,
    required this.prefixIcon,
    required this.selectedValue,
    required this.items,
    required this.onSelect,
  });
  final String title;
  final String prefixIcon;
  final String selectedValue;
  final List<String> items;
  final void Function(String value) onSelect;

  @override
  State<ExpandableDropdown> createState() => _ExpandableDropdownState();
}

class _ExpandableDropdownState extends State<ExpandableDropdown> {
  late ExpandableController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ExpandableController(initialExpanded: false);
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Image.asset(widget.prefixIcon, height: 24),
              Expanded(
                child: MyText(
                  paddingLeft: 8,
                  text: widget.title,
                  size: 12,
                  color: kTertiaryColor,
                  weight: FontWeight.w600,
                ),
              ),

              // GestureDetector(
              //   onTap: (){},
              //   child: Image.asset(labelSuffix ?? '', height: 20),
              // ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 18),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(width: 1.0, color: kBorderColor),
          ),
          child: ExpandableNotifier(
            controller: _controller,
            child: ScrollOnExpand(
              child: ExpandablePanel(
                controller: _controller,
                theme: ExpandableThemeData(
                  tapHeaderToExpand: true,
                  hasIcon: false,
                ),
                header: Container(
                  child: Row(
                    children: [
                      Expanded(
                        child: MyText(
                          text: widget.selectedValue,
                          size: 14,
                          weight: FontWeight.w600,
                        ),
                      ),
                      RotatedBox(
                        quarterTurns: _controller.expanded ? 2 : 0,
                        child: Image.asset(Assets.imagesDropdown, height: 18),
                      ),
                    ],
                  ),
                ),
                collapsed: SizedBox(),
                expanded: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 12),
                      height: 1,
                      color: kBorderColor,
                    ),
                    ListView.separated(
                      padding: AppSizes.ZERO,
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: widget.items.length,
                      itemBuilder: (context, index) {
                        return MyText(
                          text: widget.items[index],
                          weight: FontWeight.w600,
                          size: 14,
                          onTap:
                              widget.items[index] == widget.selectedValue
                                  ? null
                                  : () {
                                    widget.onSelect(widget.items[index]);
                                    _controller.toggle();
                                  },
                          color:
                              widget.items[index] == widget.selectedValue
                                  ? kSecondaryColor
                                  : kTertiaryColor,
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Container(
                          height: 1,
                          color: kBorderColor,
                          margin: EdgeInsets.symmetric(vertical: 12),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ExpandableDropdown2 extends StatefulWidget {
  const ExpandableDropdown2({
    required this.title,
    required this.selectedValue,
    required this.items,
    required this.onSelect,
  });
  final String title;
  final String selectedValue;
  final List<String> items;
  final void Function(String value) onSelect;

  @override
  State<ExpandableDropdown2> createState() => _ExpandableDropdown2State();
}

class _ExpandableDropdown2State extends State<ExpandableDropdown2> {
  late ExpandableController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ExpandableController(initialExpanded: false);
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1.0, color: kBorderColor),
      ),
      child: ExpandableNotifier(
        controller: _controller,
        child: ScrollOnExpand(
          child: ExpandablePanel(
            controller: _controller,
            theme: ExpandableThemeData(tapHeaderToExpand: true, hasIcon: false),
            header: Container(
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: '${widget.title} '),
                          TextSpan(
                            text: '(${widget.selectedValue})',
                            style: TextStyle(color: kSecondaryColor),
                          ),
                        ],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: kTertiaryColor,
                          fontFamily: AppFonts.URBANIST,
                        ),
                      ),
                    ),
                  ),
                  RotatedBox(
                    quarterTurns: _controller.expanded ? 2 : 0,
                    child: Image.asset(Assets.imagesDropdown, height: 18),
                  ),
                ],
              ),
            ),
            collapsed: SizedBox(),
            expanded: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 12),
                  height: 1,
                  color: kBorderColor,
                ),
                ListView.separated(
                  padding: AppSizes.ZERO,
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    return MyText(
                      text: widget.items[index],
                      weight: FontWeight.w600,
                      size: 14,
                      onTap:
                          widget.items[index] == widget.selectedValue
                              ? null
                              : () {
                                widget.onSelect(widget.items[index]);
                                _controller.toggle();
                              },
                      color:
                          widget.items[index] == widget.selectedValue
                              ? kSecondaryColor
                              : kTertiaryColor,
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Container(
                      height: 1,
                      color: kBorderColor,
                      margin: EdgeInsets.symmetric(vertical: 12),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
