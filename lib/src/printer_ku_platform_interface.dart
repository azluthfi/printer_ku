part of printer_ku;

abstract class PrinterKuPlatform extends PlatformInterface {
  /// Constructs a PrinterKuPlatform.
  PrinterKuPlatform() : super(token: _token);

  static final Object _token = Object();

  static PrinterKuPlatform _instance = MethodChannelPrinterKu();

  /// The default instance of [PrinterKuPlatform] to use.
  ///
  /// Defaults to [MethodChannelPrinterKu].
  static PrinterKuPlatform get instance => _instance;

  final BehaviorSubject<List<BluetoothDevice>> scanResults =
      BehaviorSubject.seeded([]);

  final BehaviorSubject<bool> isScanning = BehaviorSubject.seeded(false);
  final PublishSubject stopScanPill = PublishSubject();

  Stream<MethodCall> get methodStream => methodStreamController.stream;
  final StreamController<MethodCall> methodStreamController =
      StreamController.broadcast();

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PrinterKuPlatform] when
  /// they register themselves.
  static set instance(PrinterKuPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future getDevices() async {
    throw UnimplementedError('getDevices() has not been implemented.');
  }

  Stream<int> get state async* {
    throw UnimplementedError('state has not been implemented.');
  }

  Future<bool?> get isConnected async {
    throw UnimplementedError('isConnected has not been implemented.');
  }

  Future<dynamic> disconnect() {
    throw UnimplementedError('disconnect() has not been implemented.');
  }

  Future<dynamic> connect(BluetoothDevice device) {
    throw UnimplementedError('connect() has not been implemented.');
  }

  Future<dynamic> test() {
    throw UnimplementedError('test() has not been implemented.');
  }

  Future<dynamic> printLabel(Map<String, Object> commands) {
    throw UnimplementedError('printLabel() has not been implemented.');
  }
}
