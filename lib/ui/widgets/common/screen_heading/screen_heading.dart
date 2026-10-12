import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'screen_heading_model.dart';

class ScreenHeading extends StackedView<ScreenHeadingModel> {
  const ScreenHeading({super.key});

  @override
  Widget builder(
    BuildContext context,
    ScreenHeadingModel viewModel,
    Widget? child,
  ) {
    return const SizedBox.shrink();
  }

  @override
  ScreenHeadingModel viewModelBuilder(
    BuildContext context,
  ) =>
      ScreenHeadingModel();
}
