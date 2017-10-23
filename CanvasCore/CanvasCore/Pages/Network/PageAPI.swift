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



let pagesPathSuffix = "/pages"

open class PageAPI {
    
    open class func getPages(_ session: Session, contextID: ContextID) throws -> URLRequest {
        return try session.GET(contextID.apiPath + pagesPathSuffix)
    }
    
    open class func getPage(_ session: Session, contextID: ContextID, url: String) throws -> URLRequest {
        return try session.GET(contextID.apiPath + pagesPathSuffix + "/" + url)
    }

    open class func getFrontPage(_ session: Session, contextID: ContextID) throws -> URLRequest {
        return try session.GET(contextID.apiPath + "/front_page")
    }
    
}
