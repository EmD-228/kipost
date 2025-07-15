import 'package:flutter/material.dart';
import 'package:kipost/theme/theme.dart';

enum KipostButtonType {
  primary,
  secondary,
  outline,
  text,
  danger,
}

enum KipostButtonSize {
  small,
  medium,
  large,
}

class KipostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? suffixIcon;
  final KipostButtonType type;
  final KipostButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final Color? customColor;
  final Color? customTextColor;
  final EdgeInsetsGeometry? customPadding;
  final BorderRadius? customBorderRadius;

  const KipostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.suffixIcon,
    this.type = KipostButtonType.primary,
    this.size = KipostButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.customColor,
    this.customTextColor,
    this.customPadding,
    this.customBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null && !isLoading;
    
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getButtonHeight(),
      child: _buildButton(context, isDisabled),
    );
  }

  Widget _buildButton(BuildContext context, bool isDisabled) {
    switch (type) {
      case KipostButtonType.primary:
        return _buildPrimaryButton(context, isDisabled);
      case KipostButtonType.secondary:
        return _buildSecondaryButton(context, isDisabled);
      case KipostButtonType.outline:
        return _buildOutlineButton(context, isDisabled);
      case KipostButtonType.text:
        return _buildTextButton(context, isDisabled);
      case KipostButtonType.danger:
        return _buildDangerButton(context, isDisabled);
    }
  }

  Widget _buildPrimaryButton(BuildContext context, bool isDisabled) {
    final backgroundColor = customColor ?? AppColors.primary;
    final textColor = customTextColor ?? AppColors.onPrimary;
    
    return Container(
      decoration: BoxDecoration(
        gradient: isDisabled 
          ? null 
          : LinearGradient(
              colors: [
                backgroundColor,
                backgroundColor.withOpacity(0.8),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
        color: isDisabled ? AppColors.onSurface.withOpacity(0.12) : null,
        borderRadius: customBorderRadius ?? _getBorderRadius(),
        boxShadow: isDisabled 
          ? null 
          : [
              BoxShadow(
                color: backgroundColor.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: customBorderRadius ?? _getBorderRadius(),
          ),
          padding: customPadding ?? _getPadding(),
        ),
        child: _buildButtonContent(textColor, isDisabled),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, bool isDisabled) {
    final backgroundColor = customColor ?? AppColors.secondary;
    final textColor = customTextColor ?? AppColors.onSecondary;
    
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled 
          ? AppColors.onSurface.withOpacity(0.12) 
          : backgroundColor,
        foregroundColor: isDisabled 
          ? AppColors.onSurface.withOpacity(0.38) 
          : textColor,
        elevation: isDisabled ? 0 : AppDimensions.elevationSm,
        shape: RoundedRectangleBorder(
          borderRadius: customBorderRadius ?? _getBorderRadius(),
        ),
        padding: customPadding ?? _getPadding(),
      ),
      child: _buildButtonContent(textColor, isDisabled),
    );
  }

  Widget _buildOutlineButton(BuildContext context, bool isDisabled) {
    final borderColor = customColor ?? AppColors.primary;
    final textColor = customTextColor ?? AppColors.primary;
    
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: isDisabled 
          ? AppColors.onSurface.withOpacity(0.38) 
          : textColor,
        side: BorderSide(
          color: isDisabled 
            ? AppColors.onSurface.withOpacity(0.12) 
            : borderColor,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: customBorderRadius ?? _getBorderRadius(),
        ),
        padding: customPadding ?? _getPadding(),
      ),
      child: _buildButtonContent(textColor, isDisabled),
    );
  }

  Widget _buildTextButton(BuildContext context, bool isDisabled) {
    final textColor = customTextColor ?? AppColors.primary;
    
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: isDisabled 
          ? AppColors.onSurface.withOpacity(0.38) 
          : textColor,
        shape: RoundedRectangleBorder(
          borderRadius: customBorderRadius ?? _getBorderRadius(),
        ),
        padding: customPadding ?? _getPadding(),
      ),
      child: _buildButtonContent(textColor, isDisabled),
    );
  }

  Widget _buildDangerButton(BuildContext context, bool isDisabled) {
    final backgroundColor = customColor ?? AppColors.error;
    final textColor = customTextColor ?? AppColors.onError;
    
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled 
          ? AppColors.onSurface.withOpacity(0.12) 
          : backgroundColor,
        foregroundColor: isDisabled 
          ? AppColors.onSurface.withOpacity(0.38) 
          : textColor,
        elevation: isDisabled ? 0 : AppDimensions.elevationSm,
        shape: RoundedRectangleBorder(
          borderRadius: customBorderRadius ?? _getBorderRadius(),
        ),
        padding: customPadding ?? _getPadding(),
      ),
      child: _buildButtonContent(textColor, isDisabled),
    );
  }

  Widget _buildButtonContent(Color textColor, bool isDisabled) {
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: _getIconSize() - 4,
            height: _getIconSize() - 4,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDisabled 
                  ? AppColors.onSurface.withOpacity(0.38)
                  : textColor,
              ),
            ),
          ),
          SizedBox(width: AppDimensions.spacingSm),
          Text(
            label,
            style: _getTextStyle().copyWith(
              color: isDisabled 
                ? AppColors.onSurface.withOpacity(0.38)
                : textColor,
            ),
          ),
        ],
      );
    }

    final hasIcon = icon != null;
    final hasSuffixIcon = suffixIcon != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (hasIcon) ...[
          Icon(
            icon,
            size: _getIconSize(),
            color: isDisabled 
              ? AppColors.onSurface.withOpacity(0.38)
              : textColor,
          ),
          SizedBox(width: AppDimensions.spacingSm),
        ],
        Flexible(
          child: Text(
            label,
            style: _getTextStyle().copyWith(
              color: isDisabled 
                ? AppColors.onSurface.withOpacity(0.38)
                : textColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (hasSuffixIcon) ...[
          SizedBox(width: AppDimensions.spacingSm),
          Icon(
            suffixIcon,
            size: _getIconSize(),
            color: isDisabled 
              ? AppColors.onSurface.withOpacity(0.38)
              : textColor,
          ),
        ],
      ],
    );
  }

  double _getButtonHeight() {
    switch (size) {
      case KipostButtonSize.small:
        return AppDimensions.buttonHeightSm;
      case KipostButtonSize.medium:
        return AppDimensions.buttonHeightMd;
      case KipostButtonSize.large:
        return AppDimensions.buttonHeightLg;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case KipostButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingSm,
        );
      case KipostButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingLg,
          vertical: AppDimensions.spacingMd,
        );
      case KipostButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingXl,
          vertical: AppDimensions.spacingLg,
        );
    }
  }

  BorderRadius _getBorderRadius() {
    switch (size) {
      case KipostButtonSize.small:
        return AppDimensions.borderRadiusSm;
      case KipostButtonSize.medium:
        return AppDimensions.borderRadiusLg;
      case KipostButtonSize.large:
        return AppDimensions.borderRadiusXl;
    }
  }

  double _getIconSize() {
    switch (size) {
      case KipostButtonSize.small:
        return AppDimensions.iconSizeSm;
      case KipostButtonSize.medium:
        return AppDimensions.iconSizeMd;
      case KipostButtonSize.large:
        return AppDimensions.iconSizeLg;
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case KipostButtonSize.small:
        return const TextStyle(
          fontSize: AppDimensions.fontSizeSm,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        );
      case KipostButtonSize.medium:
        return const TextStyle(
          fontSize: AppDimensions.fontSizeLg,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        );
      case KipostButtonSize.large:
        return const TextStyle(
          fontSize: AppDimensions.fontSizeXl,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        );
    }
  }
}

// Widget factory methods pour une utilisation plus simple
extension KipostButtonFactory on KipostButton {
  /// Bouton principal avec gradient
  static Widget primary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    IconData? suffixIcon,
    KipostButtonSize size = KipostButtonSize.medium,
    bool isLoading = false,
    bool isFullWidth = false,
  }) {
    return KipostButton(
      key: key,
      label: label,
      onPressed: onPressed,
      icon: icon,
      suffixIcon: suffixIcon,
      type: KipostButtonType.primary,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }

  /// Bouton secondaire
  static Widget secondary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    IconData? suffixIcon,
    KipostButtonSize size = KipostButtonSize.medium,
    bool isLoading = false,
    bool isFullWidth = false,
  }) {
    return KipostButton(
      key: key,
      label: label,
      onPressed: onPressed,
      icon: icon,
      suffixIcon: suffixIcon,
      type: KipostButtonType.secondary,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }

  /// Bouton outline
  static Widget outline({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    IconData? suffixIcon,
    KipostButtonSize size = KipostButtonSize.medium,
    bool isLoading = false,
    bool isFullWidth = false,
  }) {
    return KipostButton(
      key: key,
      label: label,
      onPressed: onPressed,
      icon: icon,
      suffixIcon: suffixIcon,
      type: KipostButtonType.outline,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }

  /// Bouton texte
  static Widget text({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    IconData? suffixIcon,
    KipostButtonSize size = KipostButtonSize.medium,
    bool isLoading = false,
  }) {
    return KipostButton(
      key: key,
      label: label,
      onPressed: onPressed,
      icon: icon,
      suffixIcon: suffixIcon,
      type: KipostButtonType.text,
      size: size,
      isLoading: isLoading,
    );
  }

  /// Bouton danger
  static Widget danger({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    IconData? suffixIcon,
    KipostButtonSize size = KipostButtonSize.medium,
    bool isLoading = false,
    bool isFullWidth = false,
  }) {
    return KipostButton(
      key: key,
      label: label,
      onPressed: onPressed,
      icon: icon,
      suffixIcon: suffixIcon,
      type: KipostButtonType.danger,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }
}
