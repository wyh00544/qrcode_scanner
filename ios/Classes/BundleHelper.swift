//
//  BundleHelper.swift
//  qrscan
//
//  Created by Di on 2019/10/24.
//

import Foundation

class BundleHelper {
    static var bundle: Bundle {
        var bundle = Bundle(for: BundleHelper.self)

        if let resource = bundle.resourcePath, let resourceBundle = Bundle(path: resource + "/qrscan.bundle") {
            bundle = resourceBundle
        }

        return bundle
    }

    static func imageNamed(_ name: String) -> UIImage? {
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
}
