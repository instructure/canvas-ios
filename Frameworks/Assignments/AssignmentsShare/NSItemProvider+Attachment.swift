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
    public func conforms(toUTI uti: String) -> Bool {
        return hasItemConformingToTypeIdentifier(uti)
    }
    
    public func load(uti: String, completion: @escaping (Result<Any, NSError>) -> Void) {
        let options = loadItemOptionsForTypeIdentifier(uti)
        loadItem(forTypeIdentifier: uti, options: options) { object, error in
            completion(Result(object, failWith: error as NSError))
        }
    }

    func loadItemOptionsForTypeIdentifier(_ uti: String) -> [AnyHashable: Any]? {
        switch uti {
        case String(kUTTypeImage):
            return [NSItemProviderPreferredImageSizeKey: NSValue(cgSize: CGSize(width: 400, height: 400))]
        default: return nil
        }
    }
}
