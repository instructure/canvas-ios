//
//  NewUpload+Attachment.swift
//  Assignments
//
//  Created by Nathan Armstrong on 10/13/16.
//  Copyright © 2016 Instructure. All rights reserved.
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
