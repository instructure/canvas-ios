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
    
    

import Foundation

extension UIColor {
    public class func prettyErrorColor() -> UIColor {
        return UIColor(hue: 0, saturation: 0.75, brightness: 0.75, alpha: 1.0)
    }
    
    public class func prettyBlack() -> UIColor {
        return UIColor(white: 0.1, alpha: 1)
    }
    
    public class func prettyGray() -> UIColor {
        return UIColor(white: 0.6667, alpha: 1.0)
    }
    
    /// 92% (235/255)
    public class func prettyLightGray() -> UIColor {
        return UIColor(white: 0.92, alpha: 1.0)
    }
    
    public class func prettyOffWhite() -> UIColor {
        return UIColor(white: 0.98, alpha: 1.0)
    }
}
