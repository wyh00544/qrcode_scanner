import Flutter
import UIKit

private enum PluginKey: String {
    case scan
    case scanPhoto = "scan_photo"
    case scanPath = "scan_path"
    case scanBytes = "scan_bytes"
    case generateBarcode = "generate_barcode"
}

public class SwiftQrscanPlugin: NSObject, FlutterPlugin {
    private let helper = LBXScanPhotoHelper()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "qr_scan", binaryMessenger: registrar.messenger())
        let instance = SwiftQrscanPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let value = PluginKey(rawValue: call.method) else {
            return
        }

        switch value {
        case .scan:
            guard let resultController = UIViewController.current else {
                return
            }

            LBXScanViewController.show(
                from: resultController,
                lineImage: BundleHelper.imageNamed("qrcode_scan_light_blue.png"),
                success: { (results) in
                result(results.strScanned)
            })
        case .scanPath:
            guard let dic = call.arguments as? [String: Any],
                let path = dic["path"] as? String,
                let data = try? NSData(contentsOfFile: path) as Data,
                let image = UIImage(data: data) else {
                    return
            }
            guard let results = helper.recognizeQRImage(image: image) else {
                result(nil)
                return
            }

            result(results.strScanned)
        case .scanBytes:
            guard let dic = call.arguments as? [String: Any],
                let bytes = dic["bytes"] as? FlutterStandardTypedData,
                let image = UIImage(data: bytes.data) else {
                    result(nil)
                    return
            }

            guard let results = helper.recognizeQRImage(image: image) else {
                result(nil)
                return
            }

            result(results.strScanned)

        case .scanPhoto:
            helper.scanDidSuccess = { (results) in
                result(results.strScanned)
            }

            helper.scanDidFalse = {
                result(nil)
            }

            helper.openPhotoAlbum()
        case .generateBarcode:
            guard let dic = call.arguments as? [String: Any] else { return }
            result(FlutterStandardTypedData(bytes:
                QrCodeGenerator.qrcode(codeString:
                    (dic["code"] as? String) ?? "") ?? Data()
            ))
        }

    }
}
