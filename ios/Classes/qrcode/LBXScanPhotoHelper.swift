//
//  LBXScanPhotoHelper.swift
//  qrscan
//
//  Created by Di on 2019/10/24.
//

import Foundation

class LBXScanPhotoHelper: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var scanDidSuccess: ((LBXScanResult)->Void)?
    var scanDidFalse: (()->Void)?

    func openPhotoAlbum()
    {
        LBXPermissions.authorizePhotoWith { [weak self] (granted) in

            let picker = UIImagePickerController()

            picker.sourceType = UIImagePickerController.SourceType.photoLibrary

            picker.delegate = self;

            picker.allowsEditing = true

            UIViewController.current?.present(picker, animated: true, completion: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)

        var image:UIImage? = info[.editedImage] as? UIImage

        if (image == nil )
        {
            image = info[.originalImage] as? UIImage
        }

        if let image = image, let result = recognizeQRImage(image: image)
        {
            scanDidSuccess?(result)
            return
        }

        showMsg(title: nil, message: "未找到二维码或条形码")

        scanDidFalse?()
    }

    func recognizeQRImage(image: UIImage) -> LBXScanResult? {
        return LBXScanWrapper.recognizeQRImage(image: image).first
    }

    func showMsg(title:String?,message:String?)
    {
        let alertController = UIAlertController(title: nil, message:message, preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction(title: "确定", style: UIAlertAction.Style.default) { (alertAction) in}

        alertController.addAction(alertAction)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(500), execute: {
            UIViewController.current?.present(alertController, animated: true, completion: nil)
        })
    }
}
