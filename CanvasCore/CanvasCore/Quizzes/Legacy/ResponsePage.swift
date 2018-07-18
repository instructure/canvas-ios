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

