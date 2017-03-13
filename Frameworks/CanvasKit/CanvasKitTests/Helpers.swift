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

class Helpers: NSObject {
    
    class func loadJSONFixture(fixtureName: String) -> AnyObject? {
        
        
        var bundle = NSBundle(forClass: Helpers.self)
        var filePath = bundle.pathForResource(fixtureName, ofType: "json")
        println("filePath: \(filePath)")
        
        var data = NSData(contentsOfFile: filePath!)
        
        println("data = \(NSString(data: data!, encoding:NSUTF8StringEncoding))")
        var result: AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
        
        println("result = \(result)")
        
        return result
    }
    
}