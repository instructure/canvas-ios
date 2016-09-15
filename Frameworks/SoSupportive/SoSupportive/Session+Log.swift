//
//  Session+Log.swift
//  SoSupportive
//
//  Created by Brandon Pluim on 7/7/16.
//  Copyright © 2016 Instructure. All rights reserved.
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