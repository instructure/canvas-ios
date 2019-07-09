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

//
//  UIWebView+PostProcessing.swift
//  WhizzyWig
//
//  Created by Nathan Lambson on 2/12/16.
//
//

import UIKit
import WebKit

let webPostProcessingLinkJavascript = "var links = document.getElementsByTagName('a'); for (var i = 0; i < links.length; i++){ if(links[i].getAttribute('data-api-endpoint')){ links[i].setAttribute('href',links[i].getAttribute('data-api-endpoint'));}}"

extension WKWebView {
    @objc public func replaceHREFsWithAPISafeURLs() {
        self.evaluateJavaScript(webPostProcessingLinkJavascript, completionHandler: nil)
    }
}

extension UIWebView {
    @objc public func replaceHREFsWithAPISafeURLs() {
        self.stringByEvaluatingJavaScript(from: webPostProcessingLinkJavascript)
    }
}
