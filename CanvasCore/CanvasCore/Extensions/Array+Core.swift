//
//  Array+Core.swift
//  CanvasCore
//
//  Created by Garrett Richards on 3/29/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import Foundation

extension Array where Element == String {
    func pathTo(lastComponent: String) -> String? {
        var result: NSString = ""
        if let index = index(of: lastComponent) {
            for(i , element) in self.enumerated() {
                if(i <= index) {
                    result = result.appendingPathComponent(element) as NSString
                }
                else { return result as String }
            }
        }
        return nil
    }
}
