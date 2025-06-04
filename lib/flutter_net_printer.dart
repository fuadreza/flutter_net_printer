import 'dart:io';

import 'package:flutter_net_printer/model/network_device.dart';
import 'package:flutter_net_printer/src/network_manager.dart';

class FlutterNetPrinter {
  FlutterNetPrinter();

  /// The socket used for communication with the network printer.
  ///
  /// This is set when a connection to a printer is established and is `null` when not connected.
  Socket? _socket;

  /// Indicates whether the printer is currently connected.
  ///
  /// This is `true` when a connection is established and `false` otherwise.
  bool _isConnected = false;

  /// Discovers printers available on the network.
  ///
  /// This method scans the network for devices that are accessible on the specified port
  /// within the given timeout duration. It returns a stream of `List<NetworkDevice`
  /// containing the discovered printers.
  ///
  /// - [port]: The port number to scan for printers. Defaults to 9100.
  /// - [timeout]: The duration to wait for a response from devices. Defaults to 1 second.
  ///
  /// Returns a `Stream<List<NetworkDevice>>` containing the discovered printers.
  Stream<List<NetworkDevice>> discoverPrinters({
    int port = 9100,
    Duration timeout = const Duration(seconds: 1),
  }) {
    return NetworkManager.discoverPrinters(port: port, timeout: timeout);
  }

  /// Checks if a network device is available at the given [address] and [port] within the specified
  /// [timeout]. Returns a [NetworkDevice] if available, otherwise returns null.
  Future<NetworkDevice?> isDeviceAvailable(
    String address,
    int port,
    Duration timeout,
  ) {
    return NetworkManager.isDeviceAvailable(
      address: address,
      port: port,
      timeout: timeout,
    );
  }

  /// Attempts to connect to a printer at the specified [address] and [port].
  ///
  /// Optionally, a [timeout] can be provided (defaults to 10 seconds).
  ///
  /// Returns a [NetworkDevice] if the connection is successful, or `null` if the connection fails.
  /// Sets the internal connection state accordingly and destroys the socket on failure.
  Future<NetworkDevice?> connectToPrinter(
    String address,
    int port, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      _socket = await NetworkManager.connectToPrinter(
        address: address,
        port: port,
        timeout: timeout,
      );
      _isConnected = true;
      return NetworkDevice(address: address, port: port);
    } catch (e) {
      _isConnected = false;
      _socket?.destroy();
      return null;
    }
  }

  /// Disconnects from the currently connected printer.
  ///
  /// Closes the socket connection if it exists, sets the socket to null, and updates the
  /// connection state to not connected.
  Future<void> disconnect() async {
    if (_socket != null) {
      await _socket!.close();
      _socket = null;
      _isConnected = false;
    }
  }

  /// Sends raw bytes to the connected printer.
  ///
  /// This method checks if the socket is connected before attempting to send data.
  /// If the socket is not connected, the method returns immediately.
  /// Any errors during the send operation are caught and ignored.
  ///
  /// - [data]: The list of bytes to send to the printer.
  Future<void> printBytes({required List<int> data}) async {
    if (_socket == null || !_isConnected) {
      return;
    }
    try {
      _socket!.add(data);
      await _socket!.flush();
    } catch (e) {
      return;
    }
  }

  /// Sends data to a network device at the specified [address] and [port].
  ///
  /// This method uses the [NetworkManager] to send the provided [data] to the device,
  /// waiting up to [timeout] for the operation to complete.
  ///
  /// Returns a [Future] that completes when the data has been sent.
  Future<void> sendData(
    String address,
    int port,
    List<int> data,
    Duration timeout,
  ) {
    return NetworkManager.sendData(
      address: address,
      port: port,
      data: data,
      timeout: timeout,
    );
  }
}
