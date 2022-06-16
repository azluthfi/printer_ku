// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bluetooth_print_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BluetoothDevice _$BluetoothDeviceFromJson(Map<String, dynamic> json) =>
    BluetoothDevice()
      ..name = json['name'] as String?
      ..address = json['address'] as String?
      ..type = json['type'] as int?
      ..connected = json['connected'] as bool?;

Map<String, dynamic> _$BluetoothDeviceToJson(BluetoothDevice instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  writeNotNull('address', instance.address);
  writeNotNull('type', instance.type);
  writeNotNull('connected', instance.connected);
  return val;
}

TscCommand _$TscCommandFromJson(Map<String, dynamic> json) => TscCommand(
      type: json['type'] as String?,
      content: json['content'] as String?,
      font: json['font'] as String? ?? "0",
      size: json['size'] as int? ?? 0,
      align: json['align'] as int? ?? 0,
      space: json['space'] as int? ?? 0,
      weight: json['weight'] as int? ?? 0,
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
      underline: json['underline'] as int? ?? 0,
      linefeed: json['linefeed'] as int? ?? 0,
      xmultiplication: json['xmultiplication'] as int? ?? 0,
      ymultiplication: json['ymultiplication'] as int? ?? 0,
      x: json['x'] as int? ?? 0,
      y: json['y'] as int? ?? 0,
    );

Map<String, dynamic> _$TscCommandToJson(TscCommand instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('type', instance.type);
  writeNotNull('content', instance.content);
  writeNotNull('font', instance.font);
  writeNotNull('size', instance.size);
  writeNotNull('align', instance.align);
  writeNotNull('space', instance.space);
  writeNotNull('weight', instance.weight);
  writeNotNull('width', instance.width);
  writeNotNull('height', instance.height);
  writeNotNull('underline', instance.underline);
  writeNotNull('linefeed', instance.linefeed);
  writeNotNull('xmultiplication', instance.xmultiplication);
  writeNotNull('ymultiplication', instance.ymultiplication);
  writeNotNull('x', instance.x);
  writeNotNull('y', instance.y);
  return val;
}
