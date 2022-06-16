package com.example.printer_ku;

import android.app.Activity;
import android.app.Application;
import android.app.Service;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothManager;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.IBinder;
import android.util.Base64;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import net.posprinter.posprinterface.IMyBinder;
import net.posprinter.posprinterface.ProcessData;
import net.posprinter.posprinterface.UiExecute;
import net.posprinter.service.PosprinterService;
import net.posprinter.utils.BitmapToByteData;
import net.posprinter.utils.DataForSendToPrinterPos80;
import net.posprinter.utils.DataForSendToPrinterTSC;

import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

/**
 * PrinterKuPlugin
 */
public class PrinterKuPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler {
    private static final String TAG = PrinterKuPlugin.class.getSimpleName();
    private static final int ENABLE_BLUETOOTH = 7314;

    private static final String NAMESPACE = "printer_ku";

    private Object initializationLock = new Object();
    private Context context;

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private EventChannel stateChannel;
    private BluetoothManager mBluetoothManager;
    private BluetoothAdapter mBluetoothAdapter;

    private FlutterPluginBinding pluginBinding;
    private ActivityPluginBinding activityBinding;
    private Activity activity;

    //IMyBinder interface，All methods that can be invoked to connect and send data are encapsulated within this interface
    public static IMyBinder binder;

    public static boolean ISCONNECT;


    //bindService connection
    ServiceConnection conn = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName componentName, IBinder iBinder) {
            //Bind successfully
            binder = (IMyBinder) iBinder;
            io.flutter.Log.d("binder", "connected");
        }

        @Override
        public void onServiceDisconnected(ComponentName componentName) {
            io.flutter.Log.d("disbinder", "disconnected");
        }
    };

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        pluginBinding = flutterPluginBinding;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (mBluetoothAdapter == null && !"isAvailable".equals(call.method)) {
            result.error("bluetooth_unavailable", "the device does not have bluetooth", null);
            return;
        }
        final Map<String, Object> args = call.arguments();
        switch (call.method) {
            case "state":
                state(result);
                break;
            case "isConnected":
                result.success(ISCONNECT);
                break;
            case "getDevices":
                setBluetooth(result);
                break;
            case "connect":
                connect(result, args);
                break;
            case "disconnect":
                result.success(disconnect());
                break;
            case "printLabel":
                printLabel(result, args);
                break;
            case "test":
                test();
                result.success(null);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        pluginBinding = null;
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        activityBinding = binding;
        setup(
                pluginBinding.getBinaryMessenger(),
                (Application) pluginBinding.getApplicationContext(),
                activityBinding.getActivity(),
                null,
                activityBinding);
    }

    @Override public void onDetachedFromActivityForConfigChanges() {

    }

    @Override public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override public void onDetachedFromActivity() {
        tearDown();
    }

    private void setup(
            final BinaryMessenger messenger,
            final Application application,
            final Activity activity,
            final PluginRegistry.Registrar registrar,
            final ActivityPluginBinding activityBinding) {
        synchronized (initializationLock) {
            Log.i(TAG, "setup");
            this.activity = activity;
            this.context = application;
            channel = new MethodChannel(messenger, NAMESPACE + "/methods");
            channel.setMethodCallHandler(this);
            stateChannel = new EventChannel(messenger, NAMESPACE + "/state");
            stateChannel.setStreamHandler(stateHandler);
            mBluetoothManager = (BluetoothManager) application.getSystemService(Context.BLUETOOTH_SERVICE);
            mBluetoothAdapter = mBluetoothManager.getAdapter();
            pluginBinding.getApplicationContext().bindService(
                    new Intent(application, PosprinterService.class),
                    conn,
                    Service.BIND_AUTO_CREATE
            );
        }
    }

    private void tearDown() {
        Log.i(TAG, "teardown");
        binder.disconnectCurrentPort(new UiExecute() {
            @Override
            public void onsucess() {

            }

            @Override
            public void onfailed() {

            }
        });
        activity.unbindService(conn);
        context = null;
        activityBinding = null;
        channel.setMethodCallHandler(null);
        channel = null;
        stateChannel.setStreamHandler(null);
        stateChannel = null;
        mBluetoothAdapter = null;
        mBluetoothManager = null;
    }

    private void state(Result result) {
        try {
            switch (mBluetoothAdapter.getState()) {
                case BluetoothAdapter.STATE_OFF:
                    result.success(BluetoothAdapter.STATE_OFF);
                    break;
                case BluetoothAdapter.STATE_ON:
                    result.success(BluetoothAdapter.STATE_ON);
                    break;
                case BluetoothAdapter.STATE_TURNING_OFF:
                    result.success(BluetoothAdapter.STATE_TURNING_OFF);
                    break;
                case BluetoothAdapter.STATE_TURNING_ON:
                    result.success(BluetoothAdapter.STATE_TURNING_ON);
                    break;
                default:
                    result.success(0);
                    break;
            }
        } catch (SecurityException e) {
            result.error("invalid_argument", "argument 'address' not found", null);
        }

    }

    private final EventChannel.StreamHandler stateHandler = new EventChannel.StreamHandler() {
        private EventChannel.EventSink sink;

        private final BroadcastReceiver mReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                final String action = intent.getAction();
                Log.d(TAG, "stateStreamHandler, current action: " + action);

                if (BluetoothAdapter.ACTION_STATE_CHANGED.equals(action)) {
                    sink.success(intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, -1));
                } else if (BluetoothDevice.ACTION_ACL_CONNECTED.equals(action)) {
                    sink.success(1);
                } else if (BluetoothDevice.ACTION_ACL_DISCONNECTED.equals(action)) {
                    sink.success(0);
                }
            }
        };

        @Override
        public void onListen(Object o, EventChannel.EventSink eventSink) {
            sink = eventSink;
            IntentFilter filter = new IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED);
            filter.addAction(BluetoothAdapter.ACTION_CONNECTION_STATE_CHANGED);
            filter.addAction(BluetoothDevice.ACTION_ACL_CONNECTED);
            filter.addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED);
            context.registerReceiver(mReceiver, filter);
        }

        @Override
        public void onCancel(Object o) {
            sink = null;
            context.unregisterReceiver(mReceiver);
        }
    };

    private void connect(Result result, Map<String, Object> args) {
        if (args.containsKey("address")) {
            String address = (String) args.get("address");

            binder.connectBtPort(address, new UiExecute() {
                @Override
                public void onsucess() {
                    ISCONNECT = true;
                    io.flutter.Log.d(TAG, "connect ISCONNECT = " + ISCONNECT);
                    binder.write(DataForSendToPrinterPos80.openOrCloseAutoReturnPrintState(0x1f), new UiExecute() {
                        @Override
                        public void onsucess() {
                            binder.acceptdatafromprinter(new UiExecute() {
                                @Override
                                public void onsucess() {

                                }

                                @Override
                                public void onfailed() {
                                    ISCONNECT = false;
                                    io.flutter.Log.d(TAG, "connect onfailed(2) ISCONNECT = " + ISCONNECT);
                                }
                            });
                        }

                        @Override
                        public void onfailed() {

                        }
                    });


                }

                @Override
                public void onfailed() {
                    ISCONNECT = false;
                    io.flutter.Log.d(TAG, "connect onfailed(1) ISCONNECT = " + ISCONNECT);
                }
            });

            result.success(true);
        } else {
            result.error("invalid_argument", "argument 'address' not found", null);
        }
    }

    private boolean disconnect() {
        if (ISCONNECT) {
            binder.disconnectCurrentPort(new UiExecute() {
                @Override
                public void onsucess() {
                    ISCONNECT = false;
                }

                @Override
                public void onfailed() {
                }
            });
        }
        return true;
    }

    private void test() {
        binder.writeDataByYouself(new UiExecute() {
            @Override
            public void onsucess() {
                io.flutter.Log.d(TAG, "successed");
            }

            @Override
            public void onfailed() {
                io.flutter.Log.d(TAG, "failed");

            }
        }, new ProcessData() {
            @Override
            public List<byte[]> processDataBeforeSend() {
                List<byte[]> list = new ArrayList<byte[]>();
                list.add(DataForSendToPrinterTSC.selfTest());
                list.add(DataForSendToPrinterTSC.print(1));
                return list;
            }
        });
    }

    public void setBluetooth(Result result) {
        mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

        if (!mBluetoothAdapter.isEnabled()) {
            //open bluetooth
            io.flutter.Log.d(TAG, "bluetoth not enabled");
            Intent intent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            activity.startActivityForResult(intent, ENABLE_BLUETOOTH);
            result.success(null);
        } else {
            io.flutter.Log.d(TAG, "bluetoth enabled");
            showblueboothlist(result);
        }
    }

    private void showblueboothlist(Result result) {
        if (!mBluetoothAdapter.isDiscovering()) {
            mBluetoothAdapter.startDiscovery();
        }
        Set<BluetoothDevice> device = mBluetoothAdapter.getBondedDevices();

        List<Map<String, Object>> devices = new ArrayList<>();
        if (device.size() > 0) {
            //already
            for (BluetoothDevice btd : device) {
                final Map<String, Object> ret = new HashMap<>();
                ret.put("address", btd.getAddress());
                ret.put("name", btd.getName());
                ret.put("type", btd.getType());
                devices.add(ret);
            }
        }
        result.success(devices);
        io.flutter.Log.d(TAG, "showblueboothlist() enddd");
    }

    private void printLabel(Result result, Map<String, Object> args) {

        if (args.containsKey("config") && args.containsKey("data")) {
            final Map<String, Object> config = (Map<String, Object>) args.get("config");
            final List<Map<String, Object>> listData = (List<Map<String, Object>>) args.get("data");
            if (listData == null) {
                result.error("please add data", "", null);
            } else {
                binder.writeDataByYouself(new UiExecute() {
                    @Override
                    public void onsucess() {
                        Log.i(TAG, "print ok !");
                    }

                    @Override
                    public void onfailed() {
                        Log.e(TAG, "print not ok !");
                    }
                }, new ProcessData() {
                    @Override
                    public List<byte[]> processDataBeforeSend() {
                        double sizeWidth = (double) (config.get("width") == null ? 60 : config.get("width")); // 单位：mm
                        double sizeHeight = (double) (config.get("height") == null ? 75 : config.get("height")); // 单位：mm
                        double gap = (double) (config.get("gap") == null ? 0 : config.get("gap")); // 单位：mm

                        ArrayList<byte[]> list = new ArrayList<byte[]>();
                        //default is gbk,if you don't set the charset
                        DataForSendToPrinterTSC.setCharsetName("gbk");
                        byte[] data = DataForSendToPrinterTSC.sizeBymm(sizeWidth, sizeHeight); // 800 x 1200 dot
                        list.add(data);
                        //set the gap
                        list.add(DataForSendToPrinterTSC.gapBymm(gap, 0));
                        // clear the cache
                        list.add(DataForSendToPrinterTSC.cls());
                        for (Map<String, Object> m : listData) {
                            String type = (String) m.get("type");
                            String content = (String) m.get("content");
                            int x = (int) (m.get("x") == null ? 0 : m.get("x")); //dpi: 1mm约为8个点
                            int y = (int) (m.get("y") == null ? 0 : m.get("y"));
                            int width = (int) (m.get("width") == null ? 0 : m.get("width")); //dpi: 1mm约为8个点
                            int height = (int) (m.get("height") == null ? 0 : m.get("height"));
                            int space = (int) (m.get("space") == null ? 0 : m.get("space"));
                            int align = (int) (m.get("align") == null ? 0 : m.get("align"));
                            int weight = (int) (m.get("weight") == null ? 0 : m.get("weight"));
                            int xmultiplication = (int) (m.get("xmultiplication") == null ? 1 : m.get("xmultiplication"));
                            int ymultiplication = (int) (m.get("ymultiplication") == null ? 1 : m.get("ymultiplication"));
                            String font = (String) (m.get("font") == null ? "0" : m.get("font"));

                            if ("text".equals(type)) {
                                list.add(DataForSendToPrinterTSC.text(x, y, font, 0, xmultiplication, ymultiplication, content));
                            } else if ("block".equals(type)) {
                                list.add(DataForSendToPrinterTSC.block(x, y, width, height, font, 0, xmultiplication, ymultiplication, space, align, content));
                            } else if ("box".equals(type)) {
                                list.add(DataForSendToPrinterTSC.box(x, y, width, height, weight));
                            } else if ("bar".equals(type)) {
                                list.add(DataForSendToPrinterTSC.bar(x, y, width, height));
                            } else if ("qrcode".equals(type)) {
                                list.add(DataForSendToPrinterTSC.qrCode(x, y, "L", width, "A", 0, content));
                            } else if ("barcode".equals(type)) {
                                if(font == null || font.equals("0")){ // code in barcode
                                    font = "128";
                                }
                                list.add(DataForSendToPrinterTSC.barCode(x, y, font, height, align, 0, space, width,content));
                            } else if ("image".equals(type)) {
                                byte[] bytes = Base64.decode(content, Base64.DEFAULT);
                                Bitmap bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
                                list.add(DataForSendToPrinterTSC.bitmap(x, y, 0, bitmap, BitmapToByteData.BmpType.Dithering));
                            }else if ("custom".equals(type)) {
                                list.add(strTobytes(content, null));
                            }
                        }


                        list.add(DataForSendToPrinterTSC.print(1));
                        return list;
                    }
                });
            }
        } else {
            result.error("please add config or data", "", null);
        }

    }

    private byte[] strTobytes(String str, @Nullable String charsetName) {
        byte[] b = null;
        byte[] data = null;

        try {
            b = str.getBytes("utf-8");
            if (charsetName == null | charsetName == "") {
                charsetName = "gbk";
            }
            data = (new String(b, "utf-8")).getBytes(charsetName);
        } catch (UnsupportedEncodingException var4) {
            var4.printStackTrace();
        }

        return data;
    }
}
