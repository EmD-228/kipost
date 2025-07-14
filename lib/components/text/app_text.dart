import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? color;
  final FontWeight fontWeight;
  final double? letterSpacing;
  final double? height;
  final TextDecoration textDecoration;
  final TextAlign textAlign;
  final int? maxLines;
  final FontStyle fontStyle;
  final List<Shadow>? shadows;

  const AppText(
    this.text, {
    super.key,
    this.fontSize = 14,
    this.color,
    this.fontWeight = FontWeight.w400,
    this.letterSpacing,
    this.textDecoration = TextDecoration.none,
    this.textAlign = TextAlign.start,
    this.height,
    this.maxLines,
    this.fontStyle = FontStyle.normal,
    this.shadows,
  });

  // Constructeurs nommés pour les cas d'usage courants
  const AppText.heading1(
    this.text, {
    super.key,
    this.color,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.shadows,
  }) : fontSize = 32,
       fontWeight = FontWeight.bold,
       letterSpacing = null,
       textDecoration = TextDecoration.none,
       height = 1.2,
       fontStyle = FontStyle.normal;

  const AppText.heading2(
    this.text, {
    super.key,
    this.color,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.shadows,
  }) : fontSize = 24,
       fontWeight = FontWeight.bold,
       letterSpacing = null,
       textDecoration = TextDecoration.none,
       height = 1.3,
       fontStyle = FontStyle.normal;

  const AppText.heading3(
    this.text, {
    super.key,
    this.color,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.shadows,
  }) : fontSize = 20,
       fontWeight = FontWeight.w600,
       letterSpacing = null,
       textDecoration = TextDecoration.none,
       height = 1.3,
       fontStyle = FontStyle.normal;

  const AppText.body(
    this.text, {
    super.key,
    this.color,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.shadows,
  }) : fontSize = 16,
       fontWeight = FontWeight.w400,
       letterSpacing = null,
       textDecoration = TextDecoration.none,
       height = 1.5,
       fontStyle = FontStyle.normal;

  const AppText.bodySmall(
    this.text, {
    super.key,
    this.color,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.shadows,
  }) : fontSize = 14,
       fontWeight = FontWeight.w400,
       letterSpacing = null,
       textDecoration = TextDecoration.none,
       height = 1.4,
       fontStyle = FontStyle.normal;

  const AppText.caption(
    this.text, {
    super.key,
    this.color,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.shadows,
  }) : fontSize = 12,
       fontWeight = FontWeight.w400,
       letterSpacing = 0.4,
       textDecoration = TextDecoration.none,
       height = 1.3,
       fontStyle = FontStyle.normal;

  const AppText.button(
    this.text, {
    super.key,
    this.color,
    this.textAlign = TextAlign.center,
    this.maxLines = 1,
    this.shadows,
  }) : fontSize = 16,
       fontWeight = FontWeight.w600,
       letterSpacing = 0.5,
       textDecoration = TextDecoration.none,
       height = 1.2,
       fontStyle = FontStyle.normal;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
      softWrap: true,
      style: GoogleFonts.lato(
        shadows: shadows,
        height: height,
        color: color ?? Theme.of(context).textTheme.bodyMedium?.color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        decoration: textDecoration,
        decorationColor: color ?? Theme.of(context).textTheme.bodyMedium?.color,
        decorationThickness: 2,
      ),
    );
  }
}

// Predefined text shadows for special effects
class AppTextShadows {
  static const List<Shadow> glow = [
    Shadow(
      color: Color(0xffa7eef8),
      offset: Offset(0, 4),
      blurRadius: 8,
    ),
  ];

  static const List<Shadow> subtle = [
    Shadow(
      color: Color(0x40000000),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static const List<Shadow> strong = [
    Shadow(
      color: Color(0x80000000),
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ];
}
