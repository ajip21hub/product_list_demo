/// Grid Layout Constants
/// Contains all grid-related configuration for product lists and other grid layouts

class GridConstants {
  // Product Grid Configuration
  static const int productGridCrossAxisCount = 2;
  static const double productGridChildAspectRatio = 0.7;
  static const double productGridCrossAxisSpacing = 12.0;
  static const double productGridMainAxisSpacing = 12.0;
  static const double productGridPadding = 12.0;

  // Grid Layout Variants
  static const int compactGridCrossAxisCount = 3;
  static const double compactGridChildAspectRatio = 0.8;
  static const double compactGridSpacing = 8.0;

  static const int spaciousGridCrossAxisCount = 2;
  static const double spaciousGridChildAspectRatio = 0.6;
  static const double spaciousGridSpacing = 16.0;

  // Category Grid Configuration
  static const int categoryGridCrossAxisCount = 2;
  static const double categoryGridChildAspectRatio = 1.2;
  static const double categoryGridSpacing = 12.0;

  // Responsive Breakpoints
  static const double smallScreenBreakpoint = 600.0;
  static const double mediumScreenBreakpoint = 900.0;
  static const double largeScreenBreakpoint = 1200.0;

  // Tablet Configuration
  static const int tabletGridCrossAxisCount = 3;
  static const double tabletGridChildAspectRatio = 0.8;
  static const double tabletGridSpacing = 16.0;

  // Desktop Configuration
  static const int desktopGridCrossAxisCount = 4;
  static const double desktopGridChildAspectRatio = 0.9;
  static const double desktopGridSpacing = 20.0;

  // Card Dimensions
  static const double cardMinHeight = 200.0;
  static const double cardMaxHeight = 300.0;
  static const double cardImageHeightRatio = 0.6; // 60% of card height

  // Animation
  static const Duration gridAnimationDuration = Duration(milliseconds: 300);
  static const Duration staggeredAnimationDelay = Duration(milliseconds: 50);
}