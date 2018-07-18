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
    public func replaceHREFsWithAPISafeURLs() {
        self.evaluateJavaScript(webPostProcessingLinkJavascript, completionHandler: nil)
    }
}

extension UIWebView {
    public func replaceHREFsWithAPISafeURLs() {
        self.stringByEvaluatingJavaScript(from: webPostProcessingLinkJavascript)
    }
}
