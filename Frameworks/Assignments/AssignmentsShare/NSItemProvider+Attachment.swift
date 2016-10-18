//
//  NSItemProvider+Attachment.swift
//  Assignments
//
//  Created by Nathan Armstrong on 10/13/16.
//  Copyright © 2016 Instructure. All rights reserved.
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
