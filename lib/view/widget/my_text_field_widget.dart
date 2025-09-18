import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyTextField extends StatelessWidget {
  MyTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.labelText,
    this.onChanged,
    this.isObSecure = false,
    this.marginBottom = 18.0,
    this.maxLines = 1,
    this.labelSize,
    this.prefix,
    this.suffix,
    this.isReadOnly = false,
    this.fillColor = kPrimaryColor,
    this.onTap,
    this.textInputType,
    this.textInputAction,
    this.validator,
    this.autofocus = false,
    this.enabled = true,
    this.focusNode,
    this.initialValue,
    this.labelPrefix,
    this.labelSuffix,
    this.onLabelSuffixTap,
  }) : super(key: key);

  final String? labelText, labelPrefix, labelSuffix, hintText, initialValue;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool isObSecure, isReadOnly, autofocus, enabled;
  final double? marginBottom;
  final int? maxLines;
  final Color? fillColor;
  final double? labelSize;
  final Widget? prefix, suffix;
  final VoidCallback? onTap;
  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final VoidCallback? onLabelSuffixTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: marginBottom!),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (labelText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  if (labelPrefix != null)
                    Image.asset(labelPrefix ?? '', height: 24),
                  Expanded(
                    child: MyText(
                      paddingLeft: labelPrefix != null ? 8 : 0,
                      text: labelText ?? '',
                      size: labelSize ?? 12,
                      color: kTertiaryColor,
                      weight: FontWeight.w600,
                    ),
                  ),
                  if (labelSuffix != null)
                    GestureDetector(
                      onTap: onLabelSuffixTap,
                      child: Image.asset(labelSuffix ?? '', height: 20),
                    ),
                ],
              ),
            ),
          TextFormField(
            autofocus: autofocus,
            enabled: enabled,
            focusNode: focusNode,
            initialValue: initialValue,
            keyboardType: textInputType,
            validator: validator,
            onTap: onTap,
            textAlignVertical:
                prefix != null || suffix != null
                    ? TextAlignVertical.center
                    : null,
            cursorColor: kQuaternaryColor,
            maxLines: maxLines,
            readOnly: isReadOnly,
            controller: controller,
            onChanged: onChanged,
            textInputAction: TextInputAction.next,
            obscureText: isObSecure,
            obscuringCharacter: '*',
            style: TextStyle(
              fontSize: 14,
              color: kTertiaryColor,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: fillColor,
              prefixIcon: prefix,
              suffixIcon: suffix,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: maxLines! > 1 ? 15 : 0,
              ),
              hintText: hintText,
              hintStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kHintColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: kBorderColor, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: kBorderColor, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: kSecondaryColor, width: 1),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: kBorderColor, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class PhoneField extends StatefulWidget {
  PhoneField({
    Key? key,
    this.controller,
    this.onChanged,
    this.marginBottom = 16.0,
  }) : super(key: key);

  TextEditingController? controller;
  ValueChanged<String>? onChanged;
  double? marginBottom;

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> {
  String countryFlag = '🇺🇸';
  String countryCode = '1';
  bool isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyText(
            text: 'Phone Number',
            size: 12,
            color: kTertiaryColor,
            paddingBottom: 6,
            weight: FontWeight.bold,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TextFormField(
              cursorColor: kQuaternaryColor,
              controller: widget.controller,
              onChanged: widget.onChanged,
              textInputAction: TextInputAction.next,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: kTertiaryColor,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: kBorderColor,
                prefixIcon: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      child: Row(
                        children: [
                          SizedBox(width: 15),
                          MyText(
                            paddingLeft: 10,
                            paddingRight: 10,
                            onTap: () {
                              showCountryPicker(
                                context: context,
                                countryListTheme: CountryListThemeData(
                                  flagSize: 25,
                                  backgroundColor: kPrimaryColor,
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                    color: kTertiaryColor,
                                    // fontFamily: AppFonts.URBANIST,
                                  ),
                                  bottomSheetHeight: 500,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                  searchTextStyle: TextStyle(
                                    fontSize: 14,
                                    color: kTertiaryColor,
                                    fontWeight: FontWeight.w500,
                                    // fontFamily: AppFonts.URBANIST,
                                  ),
                                  inputDecoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                    fillColor: kBorderColor,
                                    filled: true,
                                    hintText: 'Search',
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      color: kQuaternaryColor,
                                      // fontFamily: AppFonts.i,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: kBorderColor,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: kBorderColor,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: kBorderColor,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                onSelect: (Country country) {
                                  setState(() {
                                    countryFlag = country.flagEmoji;
                                    countryCode = country.countryCode;
                                  });
                                },
                              );
                            },
                            text: ' +${countryCode}',
                            size: 14,
                            weight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
                hintText: '000 000 0000',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: kHintColor,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: kBorderColor, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: kBorderColor, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                errorBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
