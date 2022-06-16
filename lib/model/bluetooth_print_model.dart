import 'package:json_annotation/json_annotation.dart';

part 'bluetooth_print_model.g.dart';

@JsonSerializable(includeIfNull: false)
class BluetoothDevice {
  BluetoothDevice();

  String? name;
  String? address;
  int? type = 0;
  bool? connected = false;

  factory BluetoothDevice.fromJson(Map<String, dynamic> json) =>
      _$BluetoothDeviceFromJson(json);
  Map<String, dynamic> toJson() => _$BluetoothDeviceToJson(this);
}

@JsonSerializable(includeIfNull: false)
class TscCommand {
  TscCommand(
      {this.type, //text,barcode,qrcode,image(base64 string)
      this.content,
      this.font = "0",
      this.size = 0,
      this.align = 0, // ALIGN_LEFT
      this.space = 0,
      this.weight = 0, //0,1
      this.width = 0, //0,1
      this.height = 0, //0,1
      this.underline = 0, //0,1
      this.linefeed = 0, //0,1
      this.xmultiplication = 0,
      this.ymultiplication = 0,
      this.x = 0,
      this.y = 0});

  static const String TYPE_TEXT = 'text';
  static const String TYPE_BLOCK = 'block';
  static const String TYPE_BOX = 'box';
  static const String TYPE_BAR = 'bar';
  static const String TYPE_BARCODE = 'barcode';
  static const String TYPE_QRCODE = 'qrcode';
  static const String TYPE_IMAGE = 'image';
  static const String TYPE_CUSTOM = 'custom';
  static const int ALIGN_LEFT = 1;
  static const int ALIGN_CENTER = 2;
  static const int ALIGN_RIGHT = 3;

  final String? type;
  final String? content;
  final String? font;
  final int? size;
  final int? align;
  final int? space;
  final int? weight;
  final int? width;
  final int? height;
  final int? underline;
  final int? linefeed;
  final int? xmultiplication;
  final int? ymultiplication;
  final int? x;
  final int? y;

  factory TscCommand.fromJson(Map<String, dynamic> json) =>
      _$TscCommandFromJson(json);
  Map<String, dynamic> toJson() => _$TscCommandToJson(this);
}
