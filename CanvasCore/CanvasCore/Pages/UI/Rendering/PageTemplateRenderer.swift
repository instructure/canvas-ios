//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
