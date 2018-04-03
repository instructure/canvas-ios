//
//  HelmScreenConfig.swift
//  CanvasCore
//
//  Created by Layne Moseley on 1/24/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import Foundation

class HelmScreenConfig {
    let config: [String: Any]
    var moduleName: String?
    init(config: [String: Any]) {
        self.config = config
    }
    
    subscript(key: String) -> Any? {
        return self.config[key]
    }
    
    var navBarColor: UIColor? {
        guard let color = (self[PropKeys.navBarColor] ?? HelmManager.shared.defaultScreenConfiguration[self.moduleName ?? ""]?[PropKeys.navBarColor]) else { return nil }
        if let stringColor = color as? String, stringColor == "none" { return nil }
        return RCTConvert.uiColor(color)
    }
    
    var navBarTransparent: Bool {
        return self[PropKeys.navBarTransparent] as? Bool ?? false
    }
    
    var modal: Bool {
        return self[PropKeys.modal] as? Bool ?? false
    }
    
    var modalPresentationStyle: String? {
        return self[PropKeys.modalPresentationStyle] as? String
    }
    
    var drawUnderNavigationBar: Bool {
        return self[PropKeys.drawUnderNavBar] as? Bool ?? true
    }
    
    var drawUnderTabBar: Bool {
        return self[PropKeys.drawUnderTabBar] as? Bool ?? false
    }
}
