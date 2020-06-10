//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import UIKit
import Core

extension CanvasWebView {
    static var htmlTemplateURL: URL {
        return Bundle.core.url(forResource: "CanvasWebView", withExtension: "html")!
    }

    func htmlString(title: String? = nil, body: String) -> String {
        let htmlTitle = title
            .map { "<h1 id=\"title\">\($0)</h1>" }
            ?? ""

        let buttonBack = Core.Brand.shared.buttonPrimaryBackground.ensureContrast(against: .named(.backgroundLightest))
        let buttonFore = Core.Brand.shared.buttonPrimaryText.ensureContrast(against: buttonBack)
        let link = Core.Brand.shared.linkColor.ensureContrast(against: .named(.backgroundLightest))

        var template = try! String(contentsOf: Self.htmlTemplateURL, encoding: .utf8)
        template = template.replacingOccurrences(of: "{$TITLE$}", with: htmlTitle)
        template = template.replacingOccurrences(of: "{$PAGE_BODY$}", with: body)
        template = template.replacingOccurrences(of: "{$PRIMARY_BUTTON_BACKGROUND$}", with: buttonBack.hexString)
        template = template.replacingOccurrences(of: "{$PRIMARY_BUTTON_TEXT$}", with: buttonFore.hexString)
        template = template.replacingOccurrences(of: "{$LINK_COLOR$}", with: link.hexString)
        template = template.replacingOccurrences(of: "{$TEXT_COLOR$}", with: UIColor.named(.textDarkest).hexString)
        template = template.replacingOccurrences(of: "{$FONT_SIZE$}", with: "\(UIFont.scaledNamedFont(.regular16).pointSize)")
        template = template.replacingOccurrences(of: "{$BACKGROUND_COLOR$}", with: UIColor.named(.backgroundLightest).hexString)
        template = template.replacingOccurrences(of: "{$LTI_LAUNCH_TEXT$}", with: NSLocalizedString("Launch External Tool", comment: ""))
        template = template.replacingOccurrences(of: "{$CONTENT_DIRECTION$}", with: UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? "rtl" : "ltr")

        let jquery = (body.contains("$(") || body.contains("$."))
            ? "<script defer src=\"https://code.jquery.com/jquery-1.9.1.min.js\"></script>"
            : ""
        template = template.replacingOccurrences(of: "{$JQUERY$}", with: jquery)
        
        return template
    }
}
