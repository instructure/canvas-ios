
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
import TooLegit

extension Session {
    public func logFilePath() -> NSURL? {
        let files = try! NSFileManager.defaultManager().contentsOfDirectoryAtURL(logDirectoryURL, includingPropertiesForKeys: [NSURLContentModificationDateKey], options: .SkipsHiddenFiles).sort({ file1URL, file2URL -> Bool in
            do {
                var file1URLModifiedDate: AnyObject?
                try file1URL.getResourceValue(&file1URLModifiedDate, forKey: NSURLContentModificationDateKey)

                var file2URLModifiedDate: AnyObject?
                try file2URL.getResourceValue(&file2URLModifiedDate, forKey: NSURLContentModificationDateKey)

                if let date1 = file1URLModifiedDate as? NSDate, date2 = file2URLModifiedDate as? NSDate {
                    return date1.compare(date2) == .OrderedAscending
                }
            } catch {
                return false
            }
            return false
        })

        return files.first
    }
}