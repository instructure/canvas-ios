//
//  WindowTraits.swift
//  CanvasCore
//
//  Created by Layne Moseley on 12/1/17.
//  Copyright © 2017 Instructure, Inc. All rights reserved.
//

import Foundation

public class WindowTraits: NSObject {
    public static func current() -> [String: String] {
        guard let traits = UIApplication.shared.keyWindow?.sizeClassInfoForJavascriptConsumption() else { return [:] }
        return traits
    }
}
