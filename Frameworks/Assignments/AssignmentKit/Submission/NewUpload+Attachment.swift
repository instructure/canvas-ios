
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
    
    

import FileKit
import MobileCoreServices

extension NewUpload {
    static func from(uti: String, item: AnyObject) -> NewUpload? {
        switch uti {
        case String(kUTTypeText):
            if let text = item as? String {
                return .Text(text)
            }
        case String(kUTTypeFileURL), String(kUTTypeURL):
            if let url = item as? NSURL {
                if url.fileURL {
                    return .FileUpload([.FileURL(url)])
                }
                return .URL(url)
            }
        case String(kUTTypeImage):
            if let image = item as? UIImage {
                return .FileUpload([.Photo(image)])
            }
        case String(kUTTypeMovie), String(kUTTypeAudio):
            if let data = item as? NSData {
                return .FileUpload([.Data(data)])
            }
        case String(kUTTypeItem):
            return from(String(kUTTypeText), item: item) ??
                from(String(kUTTypeFileURL), item: item) ??
                from(String(kUTTypeURL), item: item) ??
                from(String(kUTTypeImage), item: item) ??
                from(String(kUTTypeMovie), item: item) ??
                from(String(kUTTypeAudio), item: item) ??
                (item as? NSData).flatMap({ NewUpload.FileUpload([NewUploadFile.Data($0)]) })
        default: break
        }

        return nil
    }
}
