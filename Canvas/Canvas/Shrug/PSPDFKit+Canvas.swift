//
//  PSPDFKit+Canvas.swift
//  Canvas
//
//  Created by Derrick Hathaway on 5/26/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import PSPDFKit
import Secrets

extension PSPDFKit {
    static func license() {
        
        if let key = Secrets.fetch(.CanvasPSPDFKit) {
           setLicenseKey(key)
        }
    }
}
