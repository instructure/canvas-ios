//
//  Session+ModulesTab.swift
//  CanvasCore
//
//  Created by Derrick Hathaway on 11/28/17.
//  Copyright © 2017 Instructure, Inc. All rights reserved.
//

import Foundation

@objc
public class ContentAccess: NSObject {
    public enum Access {
        case granted
        case denied(String)
    }
    public let access: Access
    
    public init(_ access: Access) {
        self.access = access
    }
    
    @objc
    public var accessDeniedMessage: String? {
        guard case let .denied(reason) = access else {
            return nil
        }
        return reason
    }
}

extension Session {
    @objc
    public func accessForContent(with url: URL) -> ContentAccess {
        guard let context = ContextID(url: url) else {
            return ContentAccess(.granted)
        }

        // default to granting access since we'v never restricted access in past
        guard let enrollmentRoles = enrollmentsDataSource[context]?.roles else {
            return ContentAccess(.granted)
        }
        
        if enrollmentRoles.contains(.Teacher)
            || enrollmentRoles.contains(.TA)
            || enrollmentRoles.contains(.Designer) {
            return ContentAccess(.granted)
        }

        let pageAccessDenied = NSLocalizedString(
            "That page has been disabled for this course",
            tableName: "Localizable",
            bundle: .core,
            value: "",
            comment: "")
        
        let enrollment = enrollmentsDataSource[context]
        
        if url.path.contains("/modules") && url.absoluteString.range(of: enrollment!.defaultViewPath) == nil {
            guard let tab = (try? Tab.modulesTab(for: context, in: self)).flatMap({ $0 }), !tab.hidden else {
                return ContentAccess(.denied(pageAccessDenied))
            }
        }
        
        return ContentAccess(.granted)
    }
}
