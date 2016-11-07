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
import SoLazy

public class PageTemplateRenderer: NSObject {
    
    private override init() { }
    
    static var templateUrl: NSURL {
        return NSBundle(forClass: Page.self).URLForResource("PageTemplate", withExtension: "html")!
    }

    static func htmlStringForPage(page: Page) -> String {
        return htmlString(title: page.title, body: page.body ?? "")
    }
    
    public class func htmlString(title title: String, body: String) -> String {
        var template = try! String(contentsOfURL: templateUrl, encoding: NSUTF8StringEncoding)
        template = template.stringByReplacingOccurrencesOfString("{$TITLE$}", withString: title)
        template = template.stringByReplacingOccurrencesOfString("{$PAGE_BODY$}", withString: body)
        
        return template
    }
    
}