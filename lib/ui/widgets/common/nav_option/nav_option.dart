import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vital_step/app/app.router.dart';

import 'nav_option_model.dart';

class NavOption extends StackedView<NavOptionModel> {
  const NavOption(this.heading, this.icon, {super.key, this.data = const {}});
  final Map<String, dynamic>? data;
  final String heading;
  final IconData icon;

  @override
  Widget builder(
    BuildContext context,
    NavOptionModel viewModel,
    Widget? child,
  ) {
    List<Widget> detailsRows = [];

    for (var k in data!.keys) {
      if (["device", "id", "createdAt", "accounts", "assessment", "password"]
          .contains(k)) {
      } else if (k == "height") {
        detailsRows.add(DetailsRow(heading: k, value: "${data![k] ?? ""} cm"));
      } else if (k == "weight") {
        detailsRows.add(DetailsRow(heading: k, value: "${data![k] ?? ""} kg"));
      } else if (heading == "Devices") {
        detailsRows.add(DetailsRow(
          heading: k,
          value: "${data![k] ?? ""} kg",
          devices: true,
        ));
      } else {
        detailsRows
            .add(DetailsRow(heading: k, value: (data![k] ?? "").toString()));
      }
    }
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ExpansionTile(
            leading: Icon(icon),
            title: Text(heading),
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            children: detailsRows),
      ),
    );
  }

  @override
  NavOptionModel viewModelBuilder(
    BuildContext context,
  ) =>
      NavOptionModel();
}

class DetailsRow extends StatelessWidget {
  const DetailsRow(
      {super.key, required this.heading, required this.value, this.devices});

  final bool? devices;
  final String heading;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 2, 25, 2),
      child: InkWell(
        onTap: () async {
          if (heading == "Email") {
            final Uri emailLaunchUri = Uri(
              scheme: 'mailto',
              path: 'App_support@SP4ameya.com',
              query: 'subject=Support Request&body=Hello, I need help with...',
            );

            if (await canLaunch(emailLaunchUri.toString())) {
              await launch(emailLaunchUri.toString());
            } else {
              Fluttertoast.showToast(msg: "Could not launch email");
            }
          } else if (heading == "Phone Number") {
            const url = "tel:+91 99163 87717";
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              Fluttertoast.showToast(msg: "Could not launch phone");
            }
          } else if (devices == true) {
            NavigationService().navigateToDeviceView(showExistingDevices: true);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.grey[100],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Row(
              children: [
                Expanded(child: Text(heading)),
                Expanded(
                    child: Text(
                  value,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
