//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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

