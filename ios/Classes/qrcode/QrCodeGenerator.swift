//
//  QrCodeGenerator.swift
//  qrscan
//
//  Created by Di on 2019/10/24.
//

import UIKit
import CoreImage

class QrCodeGenerator {
    static func qrcode(codeString: String) -> Data? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator"),
            let qrcodeData = codeString.data(using: .utf8, allowLossyConversion: true) else {
            return nil
        }

        filter.setDefaults()

        filter.setValue(qrcodeData, forKey: "inputMessage")

        guard let outputImage = filter.outputImage else { return nil }

        return createNonInterpolatedImage(image: outputImage)?.pngData()
    }

    static private func createNonInterpolatedImage(image: CIImage, size: CGFloat = 400) -> UIImage? {
        let extent = image.extent.integral

        let scale = min(size / extent.width, size / extent.height)

        let width = Int(extent.width * scale)
        let height = Int(extent.height * scale)

        let colorSpaceRef = CGColorSpaceCreateDeviceGray()

        let bitmap = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
                               space: colorSpaceRef,
                               bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue).rawValue)

        let context = CIContext(options: nil)
        guard let bitmapImage = context.createCGImage(image, from: extent) else {
            return nil
        }

        bitmap?.interpolationQuality = .none
        bitmap?.scaleBy(x: scale, y: scale)

        bitmap?.draw(bitmapImage, in: extent)

        guard let image = bitmap?.makeImage() else { return nil }

        return UIImage(cgImage: image)
    }
}
