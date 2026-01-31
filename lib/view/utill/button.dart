import 'package:converter/view/utill/app_padding.dart';
import 'package:converter/view/utill/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? borderColor;
  final Color? textColor;
  final Color? backgroundColor;
  final double? height;
  final double? width;
  final double? borderRadius;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;
  final bool showIndicator;
  final String? svgAsset;
  final Color? svgColor;
  final double? iconHeight;
  final double? iconWidth;
  final MainAxisAlignment? mainAxisAlignment;
  final MainAxisSize? mainAxisSize;
  final TextStyle? textStyle; // <-- NEW PARAMETER

  const AppButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.borderColor,
    this.textColor,
    this.backgroundColor,
    this.height,
    this.width,
    this.borderRadius,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.showIndicator = false,
    this.svgAsset,
    this.svgColor,
    this.iconHeight,
    this.iconWidth,
    this.mainAxisAlignment,
    this.mainAxisSize,
    this.textStyle, // <-- ADDED IN CONSTRUCTOR
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color effectiveBorderColor = borderColor ?? AppColors.mediumPurple;
    final Color effectiveTextColor = textColor ?? AppColors.black;
    final Color effectiveBgColor = backgroundColor ?? AppColors.black.withOpacity(0.10);
    final double effectiveHeight = height ?? 45;
    final double effectiveWidth = width ?? double.infinity;
    final double effectiveRadius = borderRadius ?? 8;
    final double effectiveFontSize = fontSize ?? 14;
    final FontWeight effectiveFontWeight = fontWeight ?? FontWeight.w400;
    final EdgeInsetsGeometry effectivePadding = padding ?? AppPaddings.h16v8;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: effectiveHeight,
        width: effectiveWidth,
        alignment: Alignment.center,
        padding: effectivePadding,
        decoration: BoxDecoration(
          color: effectiveBgColor,
          border: Border.all(color: effectiveBorderColor),
          borderRadius: BorderRadius.circular(effectiveRadius),
        ),
        child: Row(
          mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
          mainAxisSize: mainAxisSize ?? MainAxisSize.min,
          children: [
            if (svgAsset != null) ...[
              SvgPicture.asset(
                svgAsset!,
                height: iconHeight ?? 18,
                width: iconWidth ?? 18,
                color: svgColor,
              ),
              if (text.trim().isNotEmpty) const SizedBox(width: 6),
            ],
            if (text.trim().isNotEmpty)
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle ??
                      TextStyle(
                        color: effectiveTextColor,
                        fontSize: effectiveFontSize,
                        fontWeight: effectiveFontWeight,
                        fontFamily: 'Poppins',
                      ),
                ),
              ),
            if (showIndicator) ...[
              const SizedBox(width: 6),
              Container(
                height: 7,
                width: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.green,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

//
//
// A document converter is a tool/software that converts one file format into another.
// There are many types, but they are usually grouped by what they convert.
//
// 1️⃣ Text / Document Converters
//
// Used for office & text files
//
// Common types
//
// DOC ↔ DOCX
//
// DOCX → PDF
//
// PDF → DOCX
//
// TXT → PDF
//
// RTF → DOCX
//
// ODT ↔ DOCX
//
// HTML → PDF / DOCX
//
// Markdown → PDF / HTML
//
// Examples
//
// Word to PDF
//
// PDF to Word
//
// Word to HTML
//
// 2️⃣ PDF Converters
//
// Specially for PDF files
//
// Types
//
// PDF → Word
//
// PDF → Excel
//
// PDF → PowerPoint
//
// PDF → Image (JPG / PNG)
//
// Image → PDF
//
// PDF → Text
//
// PDF → PDF/A (archival)
//
// 3️⃣ Image Converters
//
// Convert image formats
//
// Types
//
// JPG ↔ PNG
//
// PNG → WebP
//
// HEIC → JPG
//
// BMP → PNG
//
// TIFF → JPG
//
// SVG ↔ PNG/JPG
//
// 4️⃣ Spreadsheet Converters
//
// For Excel & data files
//
// Types
//
// XLS ↔ XLSX
//
// Excel → PDF
//
// CSV ↔ Excel
//
// CSV → JSON
//
// JSON → Excel
//
// XML → CSV
//
// 5️⃣ Presentation Converters
//
// For slide files
//
// Types
//
// PPT ↔ PPTX
//
// PPTX → PDF
//
// PDF → PPTX
//
// Google Slides → PPTX
//
// 6️⃣ Audio Converters
//
// Convert sound files
//
// Types
//
// MP3 ↔ WAV
//
// AAC → MP3
//
// M4A → MP3
//
// FLAC → MP3
//
// OGG → MP3
//
// 7️⃣ Video Converters
//
// Convert video formats
//
// Types
//
// MP4 ↔ MKV
//
// AVI → MP4
//
// MOV → MP4
//
// WMV → MP4
//
// Video → Audio (MP4 → MP3)
//
// 8️⃣ E-book Converters
//
// For digital books
//
// Types
//
// EPUB ↔ PDF
//
// MOBI → EPUB
//
// AZW → PDF
//
// DOCX → EPUB