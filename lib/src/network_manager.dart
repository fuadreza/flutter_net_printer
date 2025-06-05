import 'dart:async';
import 'dart:io';

import 'package:flutter_net_printer/model/network_device.dart';
import 'package:network_info_plus/network_info_plus.dart';

class NetworkManager {
  const NetworkManager();

  static Future<void> discoverPrinters({
    required StreamController<List<NetworkDevice>> controller,
    int port = 9100,
    Duration timeout = const Duration(seconds: 1),
    required bool Function() shouldCancel,
  }) async {
    try {
      if (port < 1 || port > 65535) {
        throw ArgumentError('Port must be between 1 and 65535');
      }

      final devices = <NetworkDevice>[];
      final info = NetworkInfo();
      final ip = await info.getWifiIP();
      final mask = await info.getWifiSubmask();

      if (ip == null || mask == null) {
        controller.close();
        throw Exception('Could not get IP address or subnet mask');
      }

      List<int> ipParts = ip.split('.').map(int.parse).toList();
      List<int> maskParts = mask.split('.').map(int.parse).toList();

      int ipInt =
          (ipParts[0] << 24) |
          (ipParts[1] << 16) |
          (ipParts[2] << 8) |
          ipParts[3];
      int maskInt =
          (maskParts[0] << 24) |
          (maskParts[1] << 16) |
          (maskParts[2] << 8) |
          maskParts[3];

      int network = ipInt & maskInt;
      int broadcast = network | (~maskInt & 0xFFFFFFFF);

      for (var i = network + 1; i < broadcast; i++) {
        if (shouldCancel()) {
          break;
        }

        final address =
            '${(i >> 24) & 0xFF}.${(i >> 16) & 0xFF}.${(i >> 8) & 0xFF}.${i & 0xFF}';

        try {
          final socket = await Socket.connect(
            address,
            port,
            timeout: timeout,
            sourceAddress: InternetAddress.anyIPv4,
          );

          if (shouldCancel()) {
            socket.destroy();
            break;
          }

          devices.add(NetworkDevice(address: address, port: port));
          print('Found device at $address:$port');
          socket.destroy();
          if (!shouldCancel()) {
            controller.add(List<NetworkDevice>.from(devices));
          }
        } catch (e) {
          if (!(e is SocketException)) {
            continue;
          }
          print(
            'Error connecting to $address:$port- Code: ${e.osError?.errorCode} - $e',
          );
          continue;
        }
      }
    } catch (e) {
      if (!shouldCancel()) {
        controller.addError(e);
      }
    } finally {
      if (!controller.isClosed) {
        controller.close();
      }
    }
  }

  static Future<NetworkDevice?> isDeviceAvailable({
    required String address,
    int port = 9100,
    Duration timeout = const Duration(seconds: 1),
  }) async {
    if (port < 1 || port > 65535) {
      throw ArgumentError('Port must be between 1 and 65535');
    }

    try {
      final socket = await Socket.connect(
        address,
        port,
        timeout: timeout,
        sourceAddress: InternetAddress.anyIPv4,
      );
      socket.destroy();
      return NetworkDevice(address: address, port: port);
    } catch (e) {
      if (e is SocketException) {
        return null;
      }
      return null;
    }
  }

  static Future<Socket> connectToPrinter({
    required String address,
    int port = 9100,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (port < 1 || port > 65535) {
      throw ArgumentError('Port must be between 1 and 65535');
    }

    try {
      final socket = await Socket.connect(
        address,
        port,
        timeout: timeout,
        sourceAddress: InternetAddress.anyIPv4,
      );
      return socket;
    } catch (e) {
      if (e is SocketException) {
        throw Exception(
          'Failed to connect to $address:$port - ${e.osError?.message}',
        );
      }
      throw Exception('Failed to connect to $address:$port - $e');
    }
  }

  static Future<void> sendData({
    required String address,
    int port = 9100,
    required List<int> data,
    Duration timeout = const Duration(seconds: 1),
  }) async {
    if (port < 1 || port > 65535) {
      throw ArgumentError('Port must be between 1 and 65535');
    }

    try {
      final socket = await Socket.connect(
        address,
        port,
        timeout: timeout,
        sourceAddress: InternetAddress.anyIPv4,
      );
      socket.add(data);
      await socket.flush();
      socket.destroy();
    } catch (e) {
      if (e is SocketException) {
        throw Exception(
          'Failed to send data to $address:$port - ${e.osError?.message}',
        );
      }
      throw Exception('Failed to send data to $address:$port - $e');
    }
  }
}
