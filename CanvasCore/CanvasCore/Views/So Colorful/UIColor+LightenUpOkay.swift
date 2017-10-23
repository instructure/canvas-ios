//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

//
//  UIColor+LightenUpOkay.swift
//
//
//  Created by Derrick Hathaway on 9/24/15.
//
//

import UIKit

extension UIColor {
    public func lighterShade() -> UIColor {
        var a: CGFloat = 0.0
        var b: CGFloat = 0.0
        var c: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        if getHue(&a, saturation: &b, brightness: &c, alpha: &alpha) {
            return UIColor(hue: a, saturation: 0.2, brightness: 1.0, alpha: 1.0)
        }
        
        if getRed(&a, green: &b, blue: &c, alpha: &alpha) {
            let scale = 1.0 / max(a, max(b, c))
            return UIColor(red: scale * a, green: scale * b, blue: scale * c, alpha: 1.0)
        }
        
        return UIColor.prettyLightGray()
    }
}
