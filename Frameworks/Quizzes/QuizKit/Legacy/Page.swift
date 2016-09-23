//
//  Page.swift
//  Authentication
//
//  Created by Derrick Hathaway on 3/17/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation
import Result

struct Page<T> {
    let content: T
    let nextPage: Request<T>?
    var hasMorePages: Bool {
        return nextPage != nil
    }
    
    init(content: T, nextPage: Request<T>? = nil) {
        self.content = content
        self.nextPage = nextPage
    }
    
    typealias PaginatedResult = Result<Page<T>, NSError>
    
    func getNextPage(response: PaginatedResult->()) -> NSURLSessionDataTask? {
        if let nextPage = nextPage {
            return makeRequest(nextPage, completed: response)
        } else {
            // YOU SHOULDN'T EVER GET HERE.
            let error = NSError(domain: "com.instructure.authentication", code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("The Pages are gone!? Why are the pages always gone?", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "This shouldn't ever happen.")])
            response(Result(error: error))
            return nil
        }
    }
}


// MARK: parsing pagination links

func parseNextPageLinkHeader(headers: [NSObject: AnyObject]?) -> NSURL? {
    
    // Link headers look like this:
    // Link: <https://api.github.com/search/code?q=addClass+user%3Amozilla&page=2>; rel="next", <https://api.github.com/search/code?q=addClass+user%3Amozilla&page=34>; rel="last"
    
    if let linkValue = headers?["Link"] as? String {
        let links = linkValue.componentsSeparatedByString(",")
        
        for link in links {
            let scanner = NSScanner(string: link)
            
            // ignore everything up to and including the first <
            scanner.scanString("<", intoString: nil)
            
            // grab the URL
            var value: NSString?
            scanner.scanUpToString(">", intoString: &value)
            
            // ignore the trailing >; rel="
            scanner.scanString(">; rel=\"", intoString: nil)
            
            // now grab the key
            var key: NSString?
            scanner.scanUpToString("\"", intoString: &key)
            
            if key == "next" {
                if let value = value {
                    return NSURL(string: value as String)
                }
            }
        }
    }
    
    return nil
}

func parseNextPageFromJSONAPI(json: AnyObject?) -> NSURL? {
    let jsonObject = json as? NSDictionary
    let stringURL = jsonObject?.valueForKeyPath("meta.pagination.next") as? String
    
    return stringURL.flatMap {
        return NSURL(string: $0)
    }
}

