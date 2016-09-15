//
//  PageTemplateRenderer.swift
//  Pages
//
//  Created by Joseph Davison on 5/20/16.
//  Copyright © 2016 Instructure. All rights reserved.
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