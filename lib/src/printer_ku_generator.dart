part of printer_ku;

class PrinterKuGenerator {
  double sizeWidth; // mm
  double sizeHeight; // mm
  double gapHeight; // mm

  List<TscCommand> commands = [];

  /// The [sizeWidth] and [sizeHeight] paper size by mm.
  ///
  /// The [gapHeight] paper gap height by mm.
  /// ---
  /// **Notes**
  /// * 200 DPI : 1mm = 8 dots
  /// * 300 DPI : 1mm = 12 dots
  PrinterKuGenerator({
    this.sizeWidth = 60,
    this.sizeHeight = 75,
    this.gapHeight = 0,
  });

  /// [x] and [y] Specify cordinate (in dots)
  ///
  /// [font] 0 - 8
  void addText(String content,
      {required int x,
      required int y,
      String font = "0",
      int xmultiplication = 1,
      int ymultiplication = 1}) {
    commands.add(TscCommand(
        type: TscCommand.TYPE_TEXT,
        content: content,
        x: x,
        y: y,
        font: font,
        xmultiplication: xmultiplication,
        ymultiplication: ymultiplication));
  }

  /// [x] and [y] Specify cordinate (in dots)
  ///
  /// [width] and [width] size for the paragraph (in dots)
  ///
  /// [font] 0 - 8
  void addBlock(String content,
      {required int x,
      required int y,
      required int width,
      required int height,
      String font = "0",
      int xmultiplication = 1,
      int ymultiplication = 1,
      int space = 0,
      int align = TscCommand.ALIGN_LEFT}) {
    commands.add(TscCommand(
      type: TscCommand.TYPE_BLOCK,
      content: content,
      x: x,
      y: y,
      width: width,
      height: height,
      font: font,
      xmultiplication: xmultiplication,
      ymultiplication: ymultiplication,
      space: space,
      align: align,
    ));
  }

  /// [x] and [y] Specify cordinate (in dots)
  ///
  /// [xEnd] and [yEnd] Specify end cordinate (in dots)
  void addBox(
      {required int x,
      required int y,
      required int xEnd,
      required int yEnd,
      int thickness = 1}) {
    commands.add(TscCommand(
        type: TscCommand.TYPE_BOX,
        x: x,
        y: y,
        width: xEnd,
        height: yEnd,
        weight: thickness));
  }

  /// [x] and [y] Specify cordinate (in dots)
  ///
  /// [width] and [width] size for the bar (in dots)
  void addBar(
      {required int x,
      required int y,
      required int width,
      required int height}) {
    commands.add(TscCommand(
        type: TscCommand.TYPE_BAR, x: x, y: y, width: width, height: height));
  }

  /// [x] and [y] Specify cordinate (in dots)
  void addImage({required int x, required int y, required String base64Image}) {
    commands.add(TscCommand(
        type: TscCommand.TYPE_IMAGE, x: x, y: y, content: base64Image));
  }

  /// [x] and [y] Specify cordinate (in dots)
  ///
  /// [cellWidth] 1 - 10
  void addQrCode(String content,
      {required int x, required int y, required int cellWidth}) {
    commands.add(TscCommand(
        type: TscCommand.TYPE_QRCODE,
        x: x,
        y: y,
        width: cellWidth,
        content: content));
  }

  /// [x] and [y] Specify cordinate (in dots)
  ///
  /// [humanReadable] human readable (0: Not readable, 1: aligns to left, 2: aligns to center, 3: aligns to right)
  void addBarcode(String content,
      {required int x, required int y, required int height, int humanReadable = 0, String codeType = "128", int narrow = 1, int wide = 1}) {
    commands.add(TscCommand(
        type: TscCommand.TYPE_QRCODE,
        x: x,
        y: y,
        font: codeType,
        height: height,
        align: humanReadable,
        space: narrow,
        width: wide,
        content: content));
  }

  void addCustom(String content) {
    commands.add(TscCommand(
        type: TscCommand.TYPE_CUSTOM,
        content: content));
  }

  Map<String, Object> printCommands() {
    Map<String, dynamic> config = {};
    config['width'] = sizeWidth; // mm
    config['height'] = sizeHeight; // mm
    config['gap'] = gapHeight; // mm

    Map<String, Object> args = {};

    args['config'] = config;
    args['data'] = commands.map((m) {
      return m.toJson();
    }).toList();

    return args;
  }
}
