//
//  UIWebView+Quizzes.swift
//  Quizzes
//
//  Created by Ben Kraus on 5/1/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation

extension UIWebView {
    func scalePageToFit() {
        let docWidth = Int(self.stringByEvaluatingJavaScriptFromString("$(document).width()") ?? String(UIScreen.mainScreen().bounds.size.width))
        
        if docWidth == nil || docWidth == 0 {
            return
        }
        
        let scale = self.bounds.size.width / CGFloat(docWidth!)
        
        // fix scale
        stringByEvaluatingJavaScriptFromString(String(format:
            "metaElement = document.querySelector('meta[name=viewport]');" +
            "if (metaElement == null) { metaElement = document.createElement('meta'); }" +
            "metaElement.name = \"viewport\";" +
            "metaElement.content = \"minimum-scale=%.2f, initial-scale=%.2f, maximum-scale=1.0, user-scalable=yes\";" +
            "var head = document.getElementsByTagName('head')[0];" +
            "head.appendChild(metaElement);", scale, scale))
    }
}