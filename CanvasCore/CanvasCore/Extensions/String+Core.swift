//
//  StringExtensions.swift
//  CanvasCore
//
//  Created by Garrett Richards on 3/7/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import Foundation

extension String {
    func populatePathWithParams(_ params: PageViewEventDictionary?) -> String? {
        guard let url = URL(string: self), params?.count ?? 0 > 0 else {
            return nil
        }
        var components = url.pathComponents
        let componentsCopy = components

        for (index, c) in componentsCopy.enumerated() {
            if c.hasPrefix(":") || c.hasPrefix("*"), let replacementVal = params?[String(c.dropFirst())] {
                components[index] = replacementVal.description
            }
        }
        return NSString.path(withComponents: components) as String
    }
    
    func pruneApiVersionFromPath() -> String {
        let regex = "\\/{0,1}api\\/v\\d+"
        guard let range = self.range(of: regex, options: .regularExpression, range: nil, locale: nil) else {
            return self
        }
        let prefix = String(self[self.startIndex..<range.lowerBound]) ?? ""
        let suffix = String(self[range.upperBound..<self.endIndex]) ?? ""
        return prefix + suffix
    }
}
