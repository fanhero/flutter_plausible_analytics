import 'dart:io';

Future<String> getHostIP() async {
  for (var interface in await NetworkInterface.list()) {
    for (var addr in interface.addresses) {
      if (addr.type == InternetAddressType.IPv4 &&
          !addr.isLinkLocal &&
          !addr.isLoopback) {
        return addr.address;
      }
    }
  }
  throw Exception('Unable to get host IP address');
}
