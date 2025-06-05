class NetworkDevice {
  final String? name;
  final String address;
  final int port;

  NetworkDevice({this.name, required this.address, required this.port});

  @override
  String toString() {
    return 'NetworkDevice{name: $name, address: $address, port: $port}';
  }
}
