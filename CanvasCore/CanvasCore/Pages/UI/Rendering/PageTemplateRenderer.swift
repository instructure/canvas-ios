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
import UIKit

private func format(_ width: CGFloat) -> String {
    return "\(Int(width))"
}


public class PageTemplateRenderer: NSObject {
    
    fileprivate override init() { }
    
    static var templateUrl: URL {
        return Bundle(for: Page.self).url(forResource: "PageTemplate", withExtension: "html")!
    }

    static func htmlStringForPage(_ page: Page, viewportWidth: CGFloat) -> String {
        return htmlString(title: page.title, body: page.body ?? "", viewportWidth: viewportWidth)
    }
    
    public class func htmlString(title: String? = nil, body: String, viewportWidth: CGFloat) -> String {
        let htmlTitle = title
            .map { "<h1 id=\"title\">\($0)</h1>" }
            ?? ""

        var template = try! String(contentsOf: templateUrl, encoding: String.Encoding.utf8)
        template = template.replacingOccurrences(of: "{$CONTENT_WIDTH$}", with: format(viewportWidth))
        template = template.replacingOccurrences(of: "{$TITLE$}", with: htmlTitle)
        template = template.replacingOccurrences(of: "{$PAGE_BODY$}", with: body)
        template = template.replacingOccurrences(of: "{$PRIMARY_BUTTON_COLOR$}", with: Brand.current.primaryButtonColor.hex)
        template = template.replacingOccurrences(of: "{$LTI_LAUNCH_TEXT$}", with: NSLocalizedString("Launch External Tool", comment: ""))

        let jquery = (body.contains("$(") || body.contains("$."))
            ? "<script defer src=\"https://code.jquery.com/jquery-1.9.1.min.js\"></script>"
            : ""
        template = template.replacingOccurrences(of: "{$JQUERY$}", with: jquery)
        
        return template
    }
    
}
