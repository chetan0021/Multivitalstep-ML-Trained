import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/ui/common/FAQs.dart';

import 'faq_viewmodel.dart';

class FaqView extends StackedView<FaqViewModel> {
  const FaqView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    FaqViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('FAQ'),
        ),
        body: Container(
          padding: const EdgeInsets.only(left: 25.0, right: 25.0),
          child: ListView.builder(
              itemBuilder: (context, index) {
                return Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text(
                      faqs[index].question,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          faqs[index].answer,
                          textAlign: TextAlign.start,
                        ),
                      )
                    ],
                  ),
                );
              },
              itemCount: faqs.length),
        ));
  }

  @override
  FaqViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      FaqViewModel();
}
