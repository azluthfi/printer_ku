part of printer_ku;

/// An implementation of [PrinterKuPlatform] that uses method channels.
class MethodChannelPrinterKu extends PrinterKuPlatform {
  /// The method channel used to interact with the native platform.

  static const String NAMESPACE = 'printer_ku';

  static const MethodChannel channel = MethodChannel('$NAMESPACE/methods');
  static const EventChannel stateChannel = EventChannel('$NAMESPACE/state');

  MethodChannelPrinterKu() {
    channel.setMethodCallHandler((MethodCall call) async {
      methodStreamController.add(call);
    });
  }

  @override
  Future<bool?> get isConnected async =>
      await channel.invokeMethod('isConnected');

  @override
  Stream<int> get state async* {
    yield await channel.invokeMethod('state').then((s) => s);

    yield* stateChannel.receiveBroadcastStream().map((s) => s);
  }

  @override
  Future getDevices() async {
    List<BluetoothDevice> listDevices = [];

    List<dynamic>? devicesMap =
        await channel.invokeMethod<List<dynamic>>('getDevices');
    if (devicesMap != null) {
      for (var deviceMap in devicesMap) {
        listDevices.add(
            BluetoothDevice.fromJson(Map<String, dynamic>.from(deviceMap)));
      }
    }
    scanResults.add(listDevices);
  }

  @override
  Future<dynamic> disconnect() => channel.invokeMethod('disconnect');

  @override
  Future<dynamic> connect(BluetoothDevice device) =>
      channel.invokeMethod('connect', device.toJson());

  @override
  Future<dynamic> test() => channel.invokeMethod('test');

  @override
  Future<dynamic> printLabel(Map<String, Object> commands) {
    channel.invokeMethod('printLabel', commands);
    return Future.value(true);
  }
}
