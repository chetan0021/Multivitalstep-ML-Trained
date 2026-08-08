/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class Assets {
  Assets._();

  static const AssetGenImage logo = AssetGenImage('assets/Logo.jpeg');
  static const AssetGenImage logo3 = AssetGenImage('assets/Logo3.png');
  static const AssetGenImage knucleLength =
      AssetGenImage('assets/knucleLength.png');
  static const AssetGenImage leftGreen = AssetGenImage('assets/leftGreen.png');
  static const AssetGenImage leftRed = AssetGenImage('assets/leftRed.png');
  static const AssetGenImage logo2 = AssetGenImage('assets/logo2.png');
  static const AssetGenImage pair = AssetGenImage('assets/pair.png');
  static const AssetGenImage palmLength =
      AssetGenImage('assets/palmLength.png');
  static const AssetGenImage palmWidth = AssetGenImage('assets/palmWidth.png');
  static const AssetGenImage rightGreen =
      AssetGenImage('assets/rightGreen.png');
  static const AssetGenImage rightRed = AssetGenImage('assets/rightRed.png');
  static const AssetGenImage stethoscope =
      AssetGenImage('assets/stethoscope.png');
  static const AssetGenImage test = AssetGenImage('assets/test.png');
  static const AssetGenImage thumbNailVideo =
      AssetGenImage('assets/thumbNailVideo.png');
  static const AssetGenImage thumbnail = AssetGenImage('assets/thumbnail.png');

  /// List of all assets
  static List<AssetGenImage> get values => [
        logo,
        logo3,
        knucleLength,
        leftGreen,
        leftRed,
        logo2,
        pair,
        palmLength,
        palmWidth,
        rightGreen,
        rightRed,
        stethoscope,
        test,
        thumbNailVideo,
        thumbnail
      ];
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
