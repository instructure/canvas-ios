//
//  UIWebView+PostProcessing.swift
//  WhizzyWig
//
//  Created by Nathan Lambson on 2/12/16.
//
//

import Foundation

extension UIWebView {
    public func replaceHREFsWithAPISafeURLs() {
        self.stringByEvaluatingJavaScriptFromString("var links = document.getElementsByTagName('a'); for (var i = 0; i < links.length; i++){ if(links[i].getAttribute('data-api-endpoint')){ links[i].setAttribute('href',links[i].getAttribute('data-api-endpoint'));}}")
    }
}