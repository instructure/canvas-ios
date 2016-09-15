//
//  UploadAction.swift
//  File
//
//  Created by Derrick Hathaway on 12/2/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import Foundation
//import MediaKit
import SoLazy

private let FileKitBundle = NSBundle(forClass: UploadBuilder.classForCoder())

extension UIImage {
    static func FileKitImageNamed(name: String) -> UIImage {
        guard let image = UIImage(named: name, inBundle: FileKitBundle, compatibleWithTraitCollection: nil) else { ❨╯°□°❩╯⌢"Cannot load image named \(name) from FileKit.framework" }
        
        return image
    }
}

protocol UploadActionDelegate: class {
    func actionCancelled()
    func chooseUpload(newUpload: NewUpload)
}

protocol UploadAction {
    var title: String { get }
    var icon: UIImage { get }

    func initiate()
}
