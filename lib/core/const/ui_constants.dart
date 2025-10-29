/// UI Design Constants
/// Contains all UI-related measurements, sizes, and visual constants

import 'package:flutter/material.dart';

class UIConstants {
  // Border Radius Values
  static const double radiusTiny = 4.0;
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 10.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  static const double radiusXXLarge = 20.0;
  static const double radiusXXXLarge = 25.0;

  // Border Radius Objects
  static const BorderRadius borderRadiusTiny = BorderRadius.all(Radius.circular(radiusTiny));
  static const BorderRadius borderRadiusSmall = BorderRadius.all(Radius.circular(radiusSmall));
  static const BorderRadius borderRadiusMedium = BorderRadius.all(Radius.circular(radiusMedium));
  static const BorderRadius borderRadiusLarge = BorderRadius.all(Radius.circular(radiusLarge));
  static const BorderRadius borderRadiusXLarge = BorderRadius.all(Radius.circular(radiusXLarge));
  static const BorderRadius borderRadiusXXLarge = BorderRadius.all(Radius.circular(radiusXXLarge));
  static const BorderRadius borderRadiusXXXLarge = BorderRadius.all(Radius.circular(radiusXXXLarge));

  // Font Sizes
  static const double fontSizeMicro = 12.0;
  static const double fontSizeSmall = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeXXLarge = 24.0;
  static const double fontSizeXXXLarge = 28.0;

  // Spacing Values
  static const double spacingMicro = 2.0;
  static const double spacingMini = 4.0;
  static const double spacingTiny = 8.0;
  static const double spacingSmall = 12.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 20.0;
  static const double spacingXLarge = 24.0;
  static const double spacingXXLarge = 32.0;
  static const double spacingXXXLarge = 40.0;
  static const double spacingXXXXLarge = 60.0;

  // SizedBox Widgets for consistent spacing
  static const Widget sizedBoxMicro = SizedBox(height: spacingMicro, width: spacingMicro);
  static const Widget sizedBoxMini = SizedBox(height: spacingMini, width: spacingMini);
  static const Widget sizedBoxTiny = SizedBox(height: spacingTiny, width: spacingTiny);
  static const Widget sizedBoxSmall = SizedBox(height: spacingSmall, width: spacingSmall);
  static const Widget sizedBoxMedium = SizedBox(height: spacingMedium, width: spacingMedium);
  static const Widget sizedBoxLarge = SizedBox(height: spacingLarge, width: spacingLarge);
  static const Widget sizedBoxXLarge = SizedBox(height: spacingXLarge, width: spacingXLarge);
  static const Widget sizedBoxXXLarge = SizedBox(height: spacingXXLarge, width: spacingXXLarge);
  static const Widget sizedBoxXXXLarge = SizedBox(height: spacingXXXLarge, width: spacingXXXLarge);
  static const Widget sizedBoxXXXXLarge = SizedBox(height: spacingXXXXLarge, width: spacingXXXXLarge);

  // Vertical Spacing Widgets
  static const Widget verticalSpaceMicro = SizedBox(height: spacingMicro);
  static const Widget verticalSpaceMini = SizedBox(height: spacingMini);
  static const Widget verticalSpaceTiny = SizedBox(height: spacingTiny);
  static const Widget verticalSpaceSmall = SizedBox(height: spacingSmall);
  static const Widget verticalSpaceMedium = SizedBox(height: spacingMedium);
  static const Widget verticalSpaceLarge = SizedBox(height: spacingLarge);
  static const Widget verticalSpaceXLarge = SizedBox(height: spacingXLarge);
  static const Widget verticalSpaceXXLarge = SizedBox(height: spacingXXLarge);
  static const Widget verticalSpaceXXXLarge = SizedBox(height: spacingXXXLarge);
  static const Widget verticalSpaceXXXXLarge = SizedBox(height: spacingXXXXLarge);

  // Horizontal Spacing Widgets
  static const Widget horizontalSpaceMicro = SizedBox(width: spacingMicro);
  static const Widget horizontalSpaceMini = SizedBox(width: spacingMini);
  static const Widget horizontalSpaceTiny = SizedBox(width: spacingTiny);
  static const Widget horizontalSpaceSmall = SizedBox(width: spacingSmall);
  static const Widget horizontalSpaceMedium = SizedBox(width: spacingMedium);
  static const Widget horizontalSpaceLarge = SizedBox(width: spacingLarge);
  static const Widget horizontalSpaceXLarge = SizedBox(width: spacingXLarge);
  static const Widget horizontalSpaceXXLarge = SizedBox(width: spacingXXLarge);
  static const Widget horizontalSpaceXXXLarge = SizedBox(width: spacingXXXLarge);
  static const Widget horizontalSpaceXXXXLarge = SizedBox(width: spacingXXXXLarge);

  // EdgeInsets Objects
  static const EdgeInsets paddingMicro = EdgeInsets.all(spacingMicro);
  static const EdgeInsets paddingMini = EdgeInsets.all(spacingMini);
  static const EdgeInsets paddingTiny = EdgeInsets.all(spacingTiny);
  static const EdgeInsets paddingSmall = EdgeInsets.all(spacingSmall);
  static const EdgeInsets paddingMedium = EdgeInsets.all(spacingMedium);
  static const EdgeInsets paddingLarge = EdgeInsets.all(spacingLarge);
  static const EdgeInsets paddingXLarge = EdgeInsets.all(spacingXLarge);
  static const EdgeInsets paddingXXLarge = EdgeInsets.all(spacingXXLarge);

  // Symmetric Padding
  static const EdgeInsets paddingHorizontalSmall = EdgeInsets.symmetric(horizontal: spacingSmall);
  static const EdgeInsets paddingHorizontalMedium = EdgeInsets.symmetric(horizontal: spacingMedium);
  static const EdgeInsets paddingHorizontalLarge = EdgeInsets.symmetric(horizontal: spacingLarge);
  static const EdgeInsets paddingHorizontalXLarge = EdgeInsets.symmetric(horizontal: spacingXLarge);

  static const EdgeInsets paddingVerticalTiny = EdgeInsets.symmetric(vertical: spacingTiny);
  static const EdgeInsets paddingVerticalSmall = EdgeInsets.symmetric(vertical: spacingSmall);
  static const EdgeInsets paddingVerticalMedium = EdgeInsets.symmetric(vertical: spacingMedium);
  static const EdgeInsets paddingVerticalLarge = EdgeInsets.symmetric(vertical: spacingLarge);
  static const EdgeInsets paddingVerticalXLarge = EdgeInsets.symmetric(vertical: spacingXLarge);

  // Card Dimensions
  static const double cardElevation = 2.0;
  static const double cardPressedElevation = 4.0;
  static const double cardBorderWidth = 1.0;

  // Button Dimensions
  static const double buttonHeight = 48.0;
  static const double buttonHeightLarge = 56.0;
  static const double buttonHeightSmall = 36.0;
  static const double buttonBorderRadius = radiusLarge;

  // Icon Sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;
  static const double iconSizeXLarge = 32.0;

  // Line Height
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightLoose = 1.6;

  // Shadow
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.1),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.15),
      blurRadius: 6,
      offset: Offset(0, 4),
    ),
  ];
}