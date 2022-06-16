import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printer_ku/model/bluetooth_print_model.dart';
import 'package:printer_ku/printer_ku.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _printerKuPlugin = PrinterKu();

  bool _connected = false;
  BluetoothDevice? _device;
  String tips = 'no device connect';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initBluetooth() async {
    _printerKuPlugin.getDevices();

    bool isConnected = await _printerKuPlugin.isConnected ?? false;

    _printerKuPlugin.state.listen((state) {
      print('cur device status: $state');

      switch (state) {
        case PrinterKu.CONNECTED:
          setState(() {
            _connected = true;
            tips = 'connect success';
          });
          break;
        case PrinterKu.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = 'disconnect success';
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    if (isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('PrinterKu example app'),
        ),
        body: RefreshIndicator(
          onRefresh: () => _printerKuPlugin.getDevices(),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: Text(tips),
                    ),
                  ],
                ),
                const Divider(),
                StreamBuilder<List<BluetoothDevice>>(
                    stream: _printerKuPlugin.scanResults,
                    initialData: const [],
                    builder: (c, snapshot) {
                      return Column(
                        children: snapshot.data!
                            .map((d) => ListTile(
                                  title: Text(d.name ?? ''),
                                  subtitle: Text(d.address ?? ''),
                                  onTap: () async {
                                    setState(() {
                                      _device = d;
                                    });
                                  },
                                  trailing: _device != null &&
                                          _device?.address == d.address
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.green,
                                        )
                                      : null,
                                ))
                            .toList(),
                      );
                    }),
                const Divider(),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          OutlinedButton(
                            onPressed: _connected
                                ? null
                                : () async {
                                    if (_device != null &&
                                        _device?.address != null) {
                                      await _printerKuPlugin.connect(_device!);
                                    } else {
                                      setState(() {
                                        tips = 'please select device';
                                      });
                                    }
                                  },
                            child: const Text('connect'),
                          ),
                          const SizedBox(width: 10.0),
                          OutlinedButton(
                            onPressed: _connected
                                ? () async {
                                    await _printerKuPlugin.disconnect();
                                  }
                                : null,
                            child: const Text('disconnect'),
                          ),
                        ],
                      ),
                      OutlinedButton(
                        onPressed: _connected ? () => _printLabel() : null,
                        child: const Text('print label'),
                      ),
                      OutlinedButton(
                        child: const Text('print selftest'),
                        onPressed: () async {
                          await _printerKuPlugin.test();
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.refresh),
          onPressed: () => _printerKuPlugin.getDevices(),
        ),
      ),
    );
  }

  Future<void> _printLabel() async {
    PrinterKuGenerator generator =
        PrinterKuGenerator(sizeWidth: 100, sizeHeight: 152, gapHeight: 2);
    generator.addBar(x: 0, y: 200, width: 800, height: 4);
    generator.addBar(x: 200, y: 0, width: 4, height: 200);

    ByteData data = await rootBundle.load("assets/logo_waste.jpg");
    List<int> imageBytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    String base64Image = base64Encode(imageBytes);
    generator.addImage(x: 10, y: 10, base64Image: base64Image);

    generator.addBlock("LIMBAH MEDIS",
        x: 220,
        y: 50,
        width: 560,
        height: 40,
        font: "0",
        align: TscCommand.ALIGN_CENTER,
        xmultiplication: 14,
        ymultiplication: 14);
    generator.addBlock("BOJONG NANGKA",
        x: 220,
        y: 100,
        width: 560,
        height: 100,
        font: "0",
        align: TscCommand.ALIGN_CENTER,
        xmultiplication: 14,
        ymultiplication: 14);

    generator.addQrCode("123/456/7890", x: 208, y: 240, cellWidth: 18);
    generator.addBlock("123/456/7890",
        x: 20,
        y: 640,
        width: 760,
        height: 40,
        font: "4.EFT",
        align: TscCommand.ALIGN_CENTER);

    generator.addText("Tanggal Timbulan", x: 80, y: 710, font: "3.EFT");
    generator.addText(": 03 Jun 2022", x: 360, y: 710, font: "3.EFT");
    generator.addText("Jenis Limbah", x: 80, y: 750, font: "3.EFT");
    generator.addText(": Medis", x: 360, y: 750, font: "3.EFT");
    generator.addText("Tipe Limbah", x: 80, y: 790, font: "3.EFT");
    generator.addText(": Limbah Covid-19", x: 360, y: 790, font: "3.EFT");
    generator.addText("Detail Limbah", x: 80, y: 830, font: "3.EFT");
    generator.addText(": Limbah Covid-19", x: 360, y: 830, font: "3.EFT");

    generator.addBlock(
        "Apabila menemukan kantong ini diluar tempat yang seharusnya, harap hubungi : 0000000000",
        x: 120,
        y: 950,
        width: 560,
        height: 250,
        font: "0",
        space: 10,
        align: TscCommand.ALIGN_CENTER,
        xmultiplication: 12,
        ymultiplication: 12);

    await _printerKuPlugin.printLabel(generator.printCommands());
  }
}
