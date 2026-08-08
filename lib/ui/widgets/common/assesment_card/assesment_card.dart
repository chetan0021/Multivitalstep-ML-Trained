import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'assesment_card_model.dart';

class AssesmentCard extends StackedView<AssesmentCardModel> {
  const AssesmentCard({super.key});

  @override
  Widget builder(
    BuildContext context,
    AssesmentCardModel viewModel,
    Widget? child,
  ) {
    return const SizedBox.shrink();
  }

  @override
  AssesmentCardModel viewModelBuilder(
    BuildContext context,
  ) =>
      AssesmentCardModel();
}
