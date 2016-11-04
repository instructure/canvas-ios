
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
    
    

import MobileCoreServices
import Result

extension NSItemProvider: Attachment {
    public func conforms(to uti: String) -> Bool {
        return hasItemConformingToTypeIdentifier(uti)
    }
    
    public func load(uti: String, completion: (Result<AnyObject, NSError>) -> Void) {
        let options = loadItemOptionsForTypeIdentifier(uti)
        loadItemForTypeIdentifier(uti, options: options) { item, error in
            completion(Result(item, failWith: error))
        }
    }

    func loadItemOptionsForTypeIdentifier(uti: String) -> [NSObject: AnyObject]? {
        switch uti {
        case String(kUTTypeImage):
            return [NSItemProviderPreferredImageSizeKey: NSValue(CGSize: CGSize(width: 400, height: 400))]
        default: return nil
        }
    }
}
