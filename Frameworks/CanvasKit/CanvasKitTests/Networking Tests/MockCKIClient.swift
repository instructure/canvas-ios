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

class MockCKIClient: CKIClient {
    enum Method {
        case Fetch, Create, Delete
    }
    
    var capturedPath: NSString? = nil
    var capturedParameters: [NSObject : AnyObject]? = nil
    var capturedModelClass: AnyClass? = nil
    var capturedContext: CKIContext? = nil
    var capturedMethod: Method? = nil
    
    override func fetchResponseAtPath(path: String!, parameters: [NSObject : AnyObject]!, modelClass: AnyClass!, context: CKIContext!) -> RACSignal! {
        capturedPath = path
        capturedParameters = parameters
        capturedModelClass = modelClass
        capturedContext = context
        capturedMethod = .Fetch
        
        return RACSignal.empty()
    }
    
    override func createModelAtPath(path: String!, parameters: [NSObject : AnyObject]!, modelClass: AnyClass!, context: CKIContext!) -> RACSignal! {
        capturedPath = path
        capturedParameters = parameters
        capturedModelClass = modelClass
        capturedContext = context
        capturedMethod = .Create
        
        return RACSignal.empty()
    }
    
    override func deleteObjectAtPath(path: String!, modelClass: AnyClass!, parameters: [NSObject : AnyObject]!, context: CKIContext!) -> RACSignal! {
        capturedPath = path
        capturedParameters = parameters
        capturedModelClass = modelClass
        capturedContext = context
        capturedMethod = .Delete
        
        return RACSignal.empty()
    }
    
    
    
}