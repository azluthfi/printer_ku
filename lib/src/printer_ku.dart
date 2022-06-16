part of printer_ku;

class PrinterKu {
  final PrinterKuPlatform _printerKuPlatform = PrinterKuPlatform.instance;

  static const int CONNECTED = 1;
  static const int DISCONNECTED = 0;

  /// Gets the current state of the Bluetooth module
  Stream<int> get state async* {
    yield* _printerKuPlatform.state;
  }

  BehaviorSubject<bool> get isScanning => _printerKuPlatform.isScanning;

  Future getDevices() => _printerKuPlatform.getDevices();

  BehaviorSubject<List<BluetoothDevice>> get scanResults =>
      _printerKuPlatform.scanResults;

  Future<bool?> get isConnected async => _printerKuPlatform.isConnected;

  Future<dynamic> disconnect() => _printerKuPlatform.disconnect();

  Future<dynamic> connect(BluetoothDevice device) =>
      _printerKuPlatform.connect(device);

  Future<dynamic> test() => _printerKuPlatform.test();

  Future<dynamic> printLabel(Map<String, Object> commands) =>
      _printerKuPlatform.printLabel(commands);
}
