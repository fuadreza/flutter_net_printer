import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_net_printer/flutter_net_printer.dart';
import 'package:flutter_net_printer/model/network_device.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _controllerAddress = TextEditingController();
  final TextEditingController _controllerPort = TextEditingController();

  final _flutterNetPrinterPlugin = FlutterNetPrinter();
  Stream<List<NetworkDevice>>? _printerStream;
  StreamSubscription<List<NetworkDevice>>? _printerSubscription;
  NetworkDevice? connectedPrinter;

  @override
  void initState() {
    super.initState();
    _discoverPrinters();
  }

  Future<void> _discoverPrinters() async {
    try {
      // Cancel any existing subscription before starting a new discovery
      _printerSubscription?.cancel();
      _printerSubscription = null;
      // Clear any existing stream
      _printerStream = null;
      // Start discovering printers on the default port (9100)
      _printerStream = _flutterNetPrinterPlugin.discoverPrinters(
        port: 9100,
        timeout: Duration(milliseconds: 200),
      );
    } catch (e) {
      // Handle any errors that occur during discovery
    }
  }

  void _cancelDiscovery() {
    // Cancel the current discovery subscription if it exists
    _printerSubscription?.cancel();
    _printerSubscription = null;
    // Optionally, you can show a message to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Discovery cancelled')),
    );
  }

  void _isDeviceAvailable(BuildContext context) async {
    final address =
        _controllerAddress.text.isNotEmpty ? _controllerAddress.text : '';
    final port =
        _controllerPort.text.isNotEmpty
            ? int.tryParse(_controllerPort.text) ?? 9100
            : 9100;

    if (address.isEmpty) {
      return;
    }

    final device = await _flutterNetPrinterPlugin.isDeviceAvailable(
      address,
      port,
      Duration(seconds: 10),
    );
    if (device != null) {
      // Device is available, you can proceed with printing
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Device is available: ${device.address}:${device.port}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // Device is not available, handle accordingly
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Device is not available: $address:$port'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _connectPrinter() async {
    final address =
        _controllerAddress.text.isNotEmpty ? _controllerAddress.text : '';
    final port =
        _controllerPort.text.isNotEmpty
            ? int.tryParse(_controllerPort.text) ?? 9100
            : 9100;

    if (address.isEmpty) {
      return;
    }

    connectedPrinter = await _flutterNetPrinterPlugin.connectToPrinter(
      address,
      port,
    );

    setState(() {});
  }

  void _printTestFromConnected() async {
    final bytes = await _generateTicket();

    _flutterNetPrinterPlugin
        .printBytes(data: bytes)
        .then((_) {
          // Handle successful printing
        })
        .catchError((error) {
          // Handle any errors that occur during printing
        });
  }

  void _printTestFromInputAddress() async {
    final address =
        _controllerAddress.text.isNotEmpty ? _controllerAddress.text : '';
    final port =
        _controllerPort.text.isNotEmpty
            ? int.tryParse(_controllerPort.text) ?? 9100
            : 9100;

    if (address.isEmpty) {
      return;
    }

    final bytes = await _generateTicket();

    _flutterNetPrinterPlugin
        .sendData(address, port, bytes, Duration(seconds: 10))
        .then((_) {
          // Handle successful sending of data
        })
        .catchError((error) {
          // Handle any errors that occur during sending
        });
  }

  Future<List<int>> _generateTicket() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    bytes += generator.text(
      'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ',
    );
    bytes += generator.text(
      'Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
      styles: const PosStyles(codeTable: 'CP1252'),
    );
    bytes += generator.text(
      'Special 2: blåbærgrød',
      styles: const PosStyles(codeTable: 'CP1252'),
    );

    bytes += generator.text('Bold text', styles: const PosStyles(bold: true));
    bytes += generator.text(
      'Reverse text',
      styles: const PosStyles(reverse: true),
    );
    bytes += generator.text(
      'Underlined text',
      styles: const PosStyles(underline: true),
      linesAfter: 1,
    );
    bytes += generator.text(
      'Align left',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'Align center',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'Align right',
      styles: const PosStyles(align: PosAlign.right),
      linesAfter: 1,
    );
    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }

  @override
  void dispose() {
    _printerSubscription?.cancel();
    _printerSubscription = null;
    _controllerAddress.dispose();
    _controllerPort.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Container(
          margin: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<NetworkDevice>>(
                  stream: _printerStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No printers found'));
                    } else {
                      final devices = snapshot.data!;
                      return ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          final device = devices[index];
                          return ListTile(
                            title: Text(device.name ?? 'Unknown Printer'),
                            subtitle: Text('${device.address}:${device.port}'),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
              // Show text field for IP address and port
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controllerAddress,
                      decoration: InputDecoration(
                        labelText: 'IP Address',
                        hintText: 'Enter printer IP address',
                      ),
                      onChanged: (value) {
                        // Handle IP address input
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controllerPort,
                      decoration: InputDecoration(
                        labelText: 'Port',
                        hintText: 'Enter printer port',
                      ),
                      onChanged: (value) {
                        // Handle port input
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (connectedPrinter != null) ...[
                Text(
                  'Connected to: ${connectedPrinter!.address}:${connectedPrinter!.port}',
                  style: TextStyle(color: Colors.green),
                ),
                SizedBox(height: 8),
              ],
              // Connect button
              ElevatedButton(
                onPressed: () {
                  _connectPrinter();
                },
                child: const Text('Connect Printer'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _printTestFromConnected();
                },
                child: const Text('Print From Connected Printer'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _printTestFromInputAddress();
                },
                child: const Text('Print From Input Address'),
              ),
              SizedBox(height: 16),
              // Button device availability check
              Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      _isDeviceAvailable(context);
                    },
                    child: const Text('Check Device Availability'),
                  );
                },
              ),
              SizedBox(height: 16),
              Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      _cancelDiscovery();
                    },
                    child: const Text('Cancel Discovery'),
                  );
                },
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
