//
//  PageAPI.swift
//  Pages
//
//  Created by Joseph Davison on 5/13/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import TooLegit
import SoLazy

let pagesPathSuffix = "/pages"

public class PageAPI {
    
    public class func getPages(session: Session, contextID: ContextID) throws -> NSURLRequest {
        return try session.GET(contextID.apiPath + pagesPathSuffix)
    }
    
    public class func getPage(session: Session, contextID: ContextID, url: String) throws -> NSURLRequest {
        return try session.GET(contextID.apiPath + pagesPathSuffix + "/" + url)
    }

    public class func getFrontPage(session: Session, contextID: ContextID) throws -> NSURLRequest {
        return try session.GET(contextID.apiPath + "/front_page")
    }
    
}
