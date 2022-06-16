import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:printer_ku/printer_ku.dart';

// class MockPrinterKuPlatform
//     with MockPlatformInterfaceMixin
//     implements PrinterKuPlatform {
//
//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
//
//   @override
//   Future startScan() {
//     // TODO: implement startScan
//     throw UnimplementedError();
//   }
//
//
// }

void main() {
  final PrinterKuPlatform initialPlatform = PrinterKuPlatform.instance;

  test('$MethodChannelPrinterKu is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPrinterKu>());
  });

  // test('getPlatformVersion', () async {
  //   PrinterKu printerKuPlugin = PrinterKu();
  //   // MockPrinterKuPlatform fakePlatform = MockPrinterKuPlatform();
  //   // PrinterKuPlatform.instance = fakePlatform;
  //
  //   // expect(await printerKuPlugin.getPlatformVersion(), '42');
  // });
}
