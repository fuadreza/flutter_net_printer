# Flutter Net Printer

A Flutter plugin for discovering and printing to network printers. This plugin allows you to find printers on your local network, connect to them, and send raw printing commands.
You can generate ticket data using the [flutter_esc_pos_utils](https://pub.dev/packages/flutter_esc_pos_utils) package, which provides utilities for generating ESC/POS commands.

## Features

- Discover network printers on the local network
- Check printer availability
- Connect to network printers
- Send raw data for printing
- Cross-platform support (Android, iOS, macOS, Windows, Linux)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_net_printer: ^1.0.1
```

Then run:

```
flutter pub get
```

## Platform Setup

### Android

Add the following permissions to your `AndroidManifest.xml` file:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
```

For Android 10 (API level 29) and above, add the following to your manifest's `<application>` tag:

```xml
<application
    android:usesCleartextTraffic="true">
</application>
```

### iOS

Add the following to your `Info.plist` file:

```xml
<key>NSLocalNetworkUsageDescription</key>
<string>This app needs access to find and connect to printers on your local network</string>
<key>NSBonjourServices</key>
<array>
    <string>_ipp._tcp</string>
    <string>_pdl-datastream._tcp</string>
</array>
```

### macOS

Add the following to your `Info.plist` file:

```xml
<key>NSLocalNetworkUsageDescription</key>
<string>This app needs access to find and connect to printers on your local network</string>
<key>NSBonjourServices</key>
<array>
    <string>_ipp._tcp</string>
    <string>_pdl-datastream._tcp</string>
</array>
```

Also, add the network capability to your macOS app by updating your `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements` files:

```xml
<key>com.apple.security.network.client</key>
<true/>
<key>com.apple.security.network.server</key>
<true/>
```

### Windows and Linux

No special setup required beyond standard Flutter setup for these platforms.

## Usage

### Import the package

```dart
import 'package:flutter_net_printer/flutter_net_printer.dart';
import 'package:flutter_net_printer/model/network_device.dart';
```

### Initialize the printer

```dart
final printer = FlutterNetPrinter();
```

### Discover printers on the network

```dart
Stream<List<NetworkDevice>> printers = printer.discoverPrinters(
  port: 9100,
  timeout: Duration(seconds: 1),
);

printers.listen((devices) {
  for (var device in devices) {
    print('Printer found: ${device.address}:${device.port}');
  }
});
```

### Check if a printer is available

```dart
NetworkDevice? device = await printer.isDeviceAvailable(
  '192.168.1.100',
  9100,
  Duration(seconds: 1),
);

if (device != null) {
  print('Printer is available at ${device.address}:${device.port}');
} else {
  print('Printer is not available');
}
```

### Connect to a printer

```dart
NetworkDevice? connectedDevice = await printer.connectToPrinter(
  '192.168.1.100',
  9100,
  timeout: Duration(seconds: 5),
);

if (connectedDevice != null) {
  print('Connected to printer at ${connectedDevice.address}:${connectedDevice.port}');
} else {
  print('Failed to connect to printer');
}
```

### Print data

```dart
// Using ESC/POS commands with flutter_esc_pos_utils package
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';

final profile = PaperSize.mm80;
final generator = Generator(PaperSize.mm80);

List<int> bytes = [];
bytes += generator.text('Hello World!');
bytes += generator.cut();

await printer.printBytes(data: bytes);
```

### Disconnect from printer

```dart
await printer.disconnect();
print('Disconnected from printer');
```

### Send data directly (without connecting first)

```dart
try {
  await printer.sendData(
    '192.168.1.100',
    9100,
    [/* your byte data here */],
    Duration(seconds: 1),
  );
  print('Data sent successfully');
} catch (e) {
  print('Failed to send data: $e');
}
```

## Complete Example

See the complete example [here](https://pub.dev/packages/flutter_net_printer/example)

## Supported Printer Models

This plugin should be works with network printers that support raw socket printing. Tested on:

- Thermal printers Iware

Feel free to test with other models and report compatibility through Pull Requests or Issues.

## Limitations

- This plugin only works with network printers and does not support Bluetooth or USB printers
- Requires the printer to be on the same network as the device
- The plugin does not include ESC/POS command generation (use with `flutter_esc_pos_utils` for a complete solution)

## Troubleshooting

1. **Cannot find printers on the network**
   - Ensure the printer is powered on and connected to the same network
   - Verify that the correct permissions are added for your platform
   - Check if the printer has a static IP address

2. **Connection is refused**
   - Verify that port 9100 (or your specified port) is open on the printer
   - Check printer's network settings
   - Some networks may block raw socket connections

3. **Printing garbage or incorrect characters**
   - Ensure you're using the correct ESC/POS commands for your printer model
   - Check the printer's encoding settings

## Contributing

Contributions to the Flutter Net Printer plugin are welcome! If you'd like to contribute:

1. Fork the repository
2. Create a new branch for your feature (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests to ensure everything works as expected
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

Please make sure your code follows the project's style guidelines and includes appropriate tests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
