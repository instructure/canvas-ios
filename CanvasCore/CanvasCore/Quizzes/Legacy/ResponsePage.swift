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

struct ResponsePage<T> {
    let content: T
    let nextPage: Request<T>?
    var hasMorePages: Bool {
        return nextPage != nil
    }
    
    init(content: T, nextPage: Request<T>? = nil) {
        self.content = content
        self.nextPage = nextPage
    }
    
    typealias PaginatedResult = Result<ResponsePage<T>, NSError>
    
    func getNextPage(_ response: @escaping (PaginatedResult)->()) -> URLSessionDataTask? {
        if let nextPage = nextPage {
            return makeRequest(nextPage, completed: response)
        } else {
            // YOU SHOULDN'T EVER GET HERE.
            let error = NSError(domain: "com.instructure.authentication", code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("The Pages are gone!? Why are the pages always gone?", tableName: "Localizable", bundle: .core, value: "", comment: "This shouldn't ever happen.")])
            response(Result(error: error))
            return nil
        }
    }
}

func parseNextPageFromJSONAPI(_ json: Any?) -> URL? {
    let jsonObject = json as? NSDictionary
    let stringURL = jsonObject?.value(forKeyPath: "meta.pagination.next") as? String
    
    return stringURL.flatMap {
        return URL(string: $0)
    }
}

