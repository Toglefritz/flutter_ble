import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ble/flutter_ble.dart';
import 'package:flutter_ble/models/ble_device.dart';

import 'package:flutter_ble_example/screens/scan/scan_route.dart';
import 'package:flutter_ble_example/screens/scan/scan_view.dart';

import '../scan_configuration/scan_configuration_route.dart';

/// A controller for the [ScanRoute] that manages the state and owns all business logic.
class ScanController extends State<ScanRoute> {
  /// A [FlutterBle] instance used for Bluetooth operations conducted by this route.
  final FlutterBle _ble = FlutterBle();

  /// A [StreamSubscription] for the Bluetooth scanning process.
  StreamSubscription<BleDevice>? _scanStream;

  /// A list of [BleDevice]s discovered by the Bluetooth scan.
  List<BleDevice> discoveredDevices = [];

  @override
  void initState() {
    _startBluetoothScan();

    super.initState();
  }

  /// Starts a scan for nearby Bluetooth devices and adds a listener to the stream of devices detected by the scan.
  ///
  /// The scan is handled by the *flutter_ble* plugin. Regardless of operating system, the scan works by providing a
  /// callback function (in this case [_onDeviceDetected]) that is called whenever a device is detected by the scan.
  /// The [startScan] stream delivers an instance of [BleDevice] to the callback which contains information about
  /// the Bluetooth device.
  ///
  /// The
  void _startBluetoothScan() {
    _scanStream = _ble
        .startScan(filters: widget.filters, settings: widget.settings)
        .listen((device) => _onDeviceDetected(device));
  }

  /// A callback used each time a new device is discovered by the Bluetooth scan.
  void _onDeviceDetected(BleDevice device) {
    debugPrint('Discovered BLE device: ${device.name}');

    // Add the newly discovered device to the list only if it not already in the list
    if (discoveredDevices.where((discoveredDevice) => discoveredDevice.address == device.address).isEmpty) {
      setState(() {
        discoveredDevices.add(device);
      });
    }
  }

  /// Handles taps on the "filter" button in the [AppBar].
  ///
  /// When this button is pressed, the app navigates to the [ScanConfigurationRoute], which allows for the
  /// [ScanFilter]s and [ScanSetting]s to be set up.
  void onFiltersPressed() {
    Navigator.pushReplacement<void, void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const ScanConfigurationRoute(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ScanView(this);

  @override
  void dispose() {
    _scanStream?.cancel();

    super.dispose();
  }
}