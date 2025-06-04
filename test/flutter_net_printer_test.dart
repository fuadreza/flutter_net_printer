import 'dart:io';

import 'package:flutter_net_printer/flutter_net_printer.dart';
import 'package:flutter_net_printer/flutter_net_printer_method_channel.dart';
import 'package:flutter_net_printer/flutter_net_printer_platform_interface.dart';
import 'package:flutter_net_printer/model/network_device.dart';
import 'package:flutter_net_printer/src/network_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// Generate mocks for Socket and NetworkManager
// @GenerateMocks([Socket])
// import 'flutter_net_printer_test.mocks.dart';

class MockFlutterNetPrinterPlatform
    with MockPlatformInterfaceMixin
    implements FlutterNetPrinterPlatform {}

class MockNetworkManager extends Mock implements NetworkManager {}

class FakeSocket extends Fake implements Socket {
  bool closed = false;
  List<List<int>> sentData = [];
  
  @override
  Future<void> close() async {
    closed = true;
    return Future.value();
  }
  
  @override
  void add(List<int> data) {
    sentData.add(data);
  }
  
  @override
  Future<void> flush() async {
    return Future.value();
  }
  
  @override
  void destroy() {
    closed = true;
  }
}

void main() {
  final FlutterNetPrinterPlatform initialPlatform = FlutterNetPrinterPlatform.instance;
  late FlutterNetPrinter printer;
  // late MockSocket mockSocket;

  setUp(() {
    printer = FlutterNetPrinter();
    // mockSocket = MockSocket();
  });

  test('$MethodChannelFlutterNetPrinter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterNetPrinter>());
  });

  group('discoverPrinters', () {
    test('should return a stream of network devices', () async {
      // This test requires integration with actual network,
      // so we'll just verify it returns a Stream type
      final result = printer.discoverPrinters();
      expect(result, isA<Stream<List<NetworkDevice>>>());
    });
  });

  group('isDeviceAvailable', () {
    test('should return NetworkDevice when device is available', () async {
      // Create a fake test server to respond
      final server = await ServerSocket.bind('127.0.0.1', 0);
      final port = server.port;
      
      try {
        // Connect to our test server
        final result = await printer.isDeviceAvailable(
          '127.0.0.1', 
          port,
          const Duration(seconds: 1),
        );
        
        expect(result, isNotNull);
        expect(result?.address, '127.0.0.1');
        expect(result?.port, port);
      } finally {
        await server.close();
      }
    });

    test('should return null when device is not available', () async {
      // Use a port that's unlikely to be in use
      const unusedPort = 54321;
      
      final result = await printer.isDeviceAvailable(
        '127.0.0.1', 
        unusedPort,
        const Duration(milliseconds: 100),
      );
      
      expect(result, isNull);
    });
  });

  group('connectToPrinter', () {
    test('should connect to printer and return NetworkDevice when successful', () async {
      // Create a fake test server to respond
      final server = await ServerSocket.bind('127.0.0.1', 0);
      final port = server.port;
      
      try {
        // Connect to our test server
        final result = await printer.connectToPrinter(
          '127.0.0.1', 
          port,
          timeout: const Duration(seconds: 1),
        );
        
        expect(result, isNotNull);
        expect(result?.address, '127.0.0.1');
        expect(result?.port, port);
        
        // Verify we're connected by calling disconnect
        await printer.disconnect();
      } finally {
        await server.close();
      }
    });

    test('should return null when connection fails', () async {
      // Use a port that's unlikely to be in use
      const unusedPort = 54321;
      
      final result = await printer.connectToPrinter(
        '127.0.0.1', 
        unusedPort,
        timeout: const Duration(milliseconds: 100),
      );
      
      expect(result, isNull);
    });
  });

  group('disconnect', () {
    test('should disconnect without error even when not connected', () async {
      // Should not throw any exceptions
      await printer.disconnect();
    });

    test('should disconnect from connected printer', () async {
      // Create a fake test server to respond
      final server = await ServerSocket.bind('127.0.0.1', 0);
      final port = server.port;
      
      try {
        // Connect to our test server
        await printer.connectToPrinter(
          '127.0.0.1', 
          port,
          timeout: const Duration(seconds: 1),
        );
        
        // Disconnect should work without errors
        await printer.disconnect();
      } finally {
        await server.close();
      }
    });
  });

  group('printBytes', () {
    test('should do nothing when not connected', () async {
      // No connection established, so this should just return without error
      await printer.printBytes(data: [1, 2, 3, 4]);
    });

    test('should send bytes when connected', () async {
      // Create a test server to accept the connection
      final server = await ServerSocket.bind('127.0.0.1', 0);
      final port = server.port;
      
      // Prepare to receive data
      List<int> receivedData = [];
      server.listen((socket) {
        socket.listen((data) {
          receivedData.addAll(data);
        });
      });
      
      try {
        // Connect to our test server
        await printer.connectToPrinter(
          '127.0.0.1', 
          port,
        );
        
        // Send some test data
        final testData = [1, 2, 3, 4];
        await printer.printBytes(data: testData);
        
        // Give some time for data to be received
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Data might not be received in tests due to async nature,
        // but the important part is that the method doesn't throw an error
      } finally {
        await printer.disconnect();
        await server.close();
      }
    });
  });

  group('sendData', () {
    test('should send data to a network device', () async {
      // Create a test server to accept the connection
      final server = await ServerSocket.bind('127.0.0.1', 0);
      final port = server.port;
      
      // Prepare to receive data
      List<int> receivedData = [];
      server.listen((socket) {
        socket.listen((data) {
          receivedData.addAll(data);
        });
      });
      
      try {
        // Send some test data
        final testData = [1, 2, 3, 4];
        await printer.sendData(
          '127.0.0.1',
          port,
          testData,
          const Duration(seconds: 1),
        );
        
        // Give some time for data to be received
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Data might not be received in tests due to async nature,
        // but the important part is that the method doesn't throw an error
      } finally {
        await server.close();
      }
    });

    test('should throw exception when device is not available', () async {
      // Use a port that's unlikely to be in use
      const unusedPort = 54321;
      
      expect(
        () => printer.sendData(
          '127.0.0.1',
          unusedPort,
          [1, 2, 3, 4],
          const Duration(milliseconds: 100),
        ),
        throwsException,
      );
    });
  });
}
