//
//  UITextField+ReturnKeyUpdate.swift
//  Parent
//
//  Created by Ben Kraus on 6/8/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit

extension UITextField {
    func updateReturnKey(toType type: UIReturnKeyType) {
        self.returnKeyType = type
        if self.isFirstResponder() {
            self.resignFirstResponder()
            self.becomeFirstResponder()
        }
    }
}
