import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:vital_step/Model/Device.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/app/app.router.dart';
import 'package:vital_step/ui/common/app_colors.dart';
import 'package:vital_step/ui/common/ui_helpers.dart';
import 'package:vital_step/ui/views/device/device_view.form.dart';

import 'device_viewmodel.dart';

@FormView(
  fields: [
    FormTextField(name: 'deviceName'),
    FormTextField(name: 'deviceCode'),
  ],
)
class DeviceView extends StackedView<DeviceViewModel> with $DeviceView {
  DeviceView({Key? key, required this.showExistingDevices}) : super(key: key);
  final bool showExistingDevices;

  @override
  Widget builder(
    BuildContext context,
    DeviceViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: kcBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Device Pairing',
          style: TextStyle(color: kcDarkGreyColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: kcDarkGreyColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── CONNECTED DEVICES SECTION ──
            _buildSectionTitle('Connected Devices'),
            verticalSpaceSmall,
            _buildConnectedDevicesSection(context, viewModel),

            verticalSpaceMedium,
            const Divider(),
            verticalSpaceMedium,

            // ── ADD NEW DEVICE SECTION ──
            _buildSectionTitle('Add New Device'),
            verticalSpaceMedium,
            if (viewModel.scannedDeviceCode != null) ...[
              _buildScannedCodeCard(viewModel),
              verticalSpaceMedium,
              _buildInputCard(
                controller: deviceNameController,
                label: 'Device Name',
                hint: 'e.g. My Left Hand Sensor',
                icon: Icons.edit,
              ),
              verticalSpaceMedium,
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: viewModel.isBusy
                      ? null
                      : () async {
                          await viewModel
                              .saveScannedDevice(deviceNameController.text);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kcPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                  ),
                  child: viewModel.isBusy
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Add Device',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              verticalSpaceSmall,
              Center(
                child: TextButton(
                  onPressed: viewModel.clearScannedCode,
                  child: const Text('Scan Again',
                      style: TextStyle(color: kcMediumGrey)),
                ),
              ),
            ] else ...[
              _buildScanButton(context, viewModel),
            ],
            verticalSpaceMedium,
            const Center(
              child: Text(
                'You can add devices later from settings',
                textAlign: TextAlign.center,
                style: TextStyle(color: kcMediumGrey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main connected devices section ──
  Widget _buildConnectedDevicesSection(
      BuildContext context, DeviceViewModel viewModel) {
    return FutureBuilder<List<Device>?>(
      future: viewModel.devicesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final devices = viewModel.devices ?? snapshot.data ?? [];

        if (devices.isEmpty) return _buildEmptyState();

        // ── Device already selected: show Done card + Change Device button ──
        if (viewModel.hasSelectedDevice) {
          final selected = viewModel.selectedDevice!;
          final idx =
              devices.indexWhere((d) => d.deviceCode == selected.deviceCode);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDoneCard(selected, idx >= 0 ? idx : 0),
              verticalSpaceSmall,
              // Change Device → opens bottom sheet
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _openDevicePickerSheet(context, viewModel, devices),
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Change Device'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kcPrimaryColor,
                    side: BorderSide(
                        color: kcPrimaryColor.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        // ── No device selected yet ──
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Continue without device
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  locator<NavigationService>().navigateTo(Routes.startupView);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Continue with VitalStep',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            verticalSpaceMedium,
            const Text(
              'Or select a device below:',
              style: TextStyle(color: kcMediumGrey, fontSize: 13),
            ),
            verticalSpaceSmall,
            // Inline device list for first-time selection
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: devices.length,
              separatorBuilder: (_, __) => verticalSpaceSmall,
              itemBuilder: (context, index) => _buildSelectableDeviceCard(
                context,
                devices[index],
                index,
                viewModel,
                devices,
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Opens a bottom sheet for picking a device ──
  void _openDevicePickerSheet(
    BuildContext context,
    DeviceViewModel viewModel,
    List<Device> devices,
  ) {
    // Track the temp selection inside the sheet
    Device? tempSelected = viewModel.selectedDevice;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select a Device',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kcDarkGreyColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Device list
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: devices.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      final device = devices[index];
                      final isSelected =
                          tempSelected?.deviceCode == device.deviceCode;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setSheetState(() => tempSelected = device);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? kcPrimaryColor.withValues(alpha: 0.06)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? kcPrimaryColor
                                  : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Radio circle
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? kcPrimaryColor
                                        : kcMediumGrey,
                                    width: 2,
                                  ),
                                  color: isSelected
                                      ? kcPrimaryColor
                                      : Colors.transparent,
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check,
                                        color: Colors.white, size: 14)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              // Number badge
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      kcPrimaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                      color: kcPrimaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Device info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      device.deviceName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: kcDarkGreyColor),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Code: ${device.deviceCode}',
                                      style: const TextStyle(
                                          color: kcMediumGrey, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Done button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: tempSelected == null
                          ? null
                          : () async {
                              HapticFeedback.mediumImpact();
                              Navigator.pop(ctx); // close sheet first
                              await viewModel.selectDevice(tempSelected!);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kcPrimaryColor,
                        disabledBackgroundColor:
                            kcMediumGrey.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Selectable card used in the inline list (first-time selection) ──
  Widget _buildSelectableDeviceCard(
    BuildContext context,
    Device device,
    int index,
    DeviceViewModel viewModel,
    List<Device> devices,
  ) {
    return GestureDetector(
      onTap: () => _openDevicePickerSheet(context, viewModel, devices),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Empty radio
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kcMediumGrey, width: 2),
              ),
            ),
            horizontalSpaceMedium,
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kcPrimaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                    color: kcPrimaryColor, fontWeight: FontWeight.bold),
              ),
            ),
            horizontalSpaceMedium,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.deviceName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: kcDarkGreyColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                  verticalSpaceTiny,
                  Text(
                    'Code: ${device.deviceCode}',
                    style: const TextStyle(color: kcMediumGrey, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: kcMediumGrey),
          ],
        ),
      ),
    );
  }

  // ── Done card shown after device is confirmed ──
  Widget _buildDoneCard(Device device, int index) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: kcSuccessColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: kcSuccessColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: kcSuccessColor.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kcSuccessColor,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 18),
          ),
          horizontalSpaceMedium,
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kcSuccessColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                  color: kcSuccessColor, fontWeight: FontWeight.bold),
            ),
          ),
          horizontalSpaceMedium,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.deviceName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: kcDarkGreyColor),
                  overflow: TextOverflow.ellipsis,
                ),
                verticalSpaceTiny,
                Text(
                  'Code: ${device.deviceCode}',
                  style: const TextStyle(color: kcMediumGrey, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: kcSuccessColor, size: 22),
              SizedBox(height: 2),
              Text(
                'Done',
                style: TextStyle(
                    color: kcSuccessColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton(BuildContext context, DeviceViewModel viewModel) {
    return GestureDetector(
      onTap: () => _openScanner(context, viewModel),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: kcPrimaryColor.withValues(alpha: 0.3),
              width: 2,
              style: BorderStyle.solid),
          boxShadow: [
            BoxShadow(
              color: kcPrimaryColor.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kcPrimaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.qr_code_scanner_rounded,
                  color: kcPrimaryColor, size: 48),
            ),
            verticalSpaceSmall,
            const Text(
              'Scan Device QR Code',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kcDarkGreyColor),
            ),
            verticalSpaceTiny,
            const Text(
              'Tap to open camera and scan the QR code on your device',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: kcMediumGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannedCodeCard(DeviceViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kcSuccessColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kcSuccessColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: kcSuccessColor, size: 28),
          horizontalSpaceSmall,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Device Code Scanned',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kcSuccessColor,
                        fontSize: 14)),
                verticalSpaceTiny,
                Text(
                  viewModel.scannedDeviceCode!,
                  style: const TextStyle(
                      color: kcDarkGreyColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openScanner(BuildContext context, DeviceViewModel viewModel) {
    final MobileScannerController scannerController = MobileScannerController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Scan QR Code',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      scannerController.dispose();
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: scannerController,
                      onDetect: (capture) {
                        final barcode = capture.barcodes.firstOrNull;
                        if (barcode?.rawValue != null) {
                          final code = barcode!.rawValue!;
                          scannerController.dispose();
                          Navigator.pop(ctx);
                          viewModel.onQrScanned(code);
                        }
                      },
                    ),
                    Center(
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          border: Border.all(color: kcPrimaryColor, width: 3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: Text(
                        'Align the QR code within the frame',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: kcDarkGreyColor),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.devices_other, color: kcMediumGrey),
          SizedBox(width: 8),
          Text('No devices paired yet',
              style: TextStyle(color: kcMediumGrey)),
        ],
      ),
    );
  }

  Widget _buildInputCard({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          icon: Icon(icon, color: kcMediumGrey),
          labelText: label,
          hintText: hint,
          border: InputBorder.none,
          labelStyle: const TextStyle(color: kcMediumGrey),
        ),
      ),
    );
  }

  @override
  DeviceViewModel viewModelBuilder(BuildContext context) => DeviceViewModel();

  @override
  void onViewModelReady(DeviceViewModel viewModel) {
    syncFormWithViewModel(viewModel);
    viewModel.devicesFuture = viewModel.init();
  }
}
