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

extension UIWebView {
    @objc func scalePageToFit() {
        let docWidth = Int(self.stringByEvaluatingJavaScript(from: "$(document).width()") ?? String(describing: UIScreen.main.bounds.size.width))
        
        if docWidth == nil || docWidth == 0 {
            return
        }
        
        let scale = self.bounds.size.width / CGFloat(docWidth!)
        
        // fix scale
        stringByEvaluatingJavaScript(from: String(format:
            "metaElement = document.querySelector('meta[name=viewport]');" +
            "if (metaElement == null) { metaElement = document.createElement('meta'); }" +
            "metaElement.name = \"viewport\";" +
            "metaElement.content = \"minimum-scale=%.2f, initial-scale=%.2f, maximum-scale=1.0, user-scalable=yes\";" +
            "var head = document.getElementsByTagName('head')[0];" +
            "head.appendChild(metaElement);", scale, scale))
    }
}
