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


let bundle = NSBundle(identifier: "com.instructure.SoIconic")!

extension UIImage {
    public static func icon(icon: Icon, filled: Bool = false) -> UIImage {
        let name = icon.imageName(filled)
        guard let icon = UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: nil) else {
            fatalError("An image does not exist for the Icon/Filled/Size combination specified: \(name). Please add the varient to SoIconic.framework")
        }
        
        return icon
    }
}