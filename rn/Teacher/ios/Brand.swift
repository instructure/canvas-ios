//
//  Brand.swift
//  Teacher
//
//  Created by Garrett Richards on 5/8/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import Foundation

struct Brand {
    var navBgColor = UIColor.red
    var navButtonColor = UIColor.red
    var primaryButtonColor = UIColor.red
    var primaryButtonTextColor = UIColor.red
    var primaryBrandColor = UIColor.red
    var fontColorDark = UIColor.red
    var headerImageURL: String = ""
    
    init(webPayload: [String: Any]?) {
        if let payload = webPayload {
            if let hex = payload["ic-brand-global-nav-bgd"] as? String, let color = UIColor.colorFromHexString(hex) {
                navBgColor = color
            }
            
            if let hex = payload["ic-brand-global-nav-ic-icon-svg-fill"] as? String, let color = UIColor.colorFromHexString(hex) {
                navButtonColor = color
            }
            if let hex = payload["ic-brand-button--primary-bgd"] as? String, let color = UIColor.colorFromHexString(hex) {
                primaryButtonColor = color
            }
            
            if let hex = payload["ic-brand-button--primary-text"] as? String, let color = UIColor.colorFromHexString(hex) {
                primaryButtonTextColor = color
            }
            
            if let hex = payload["ic-brand-primary"] as? String, let color = UIColor.colorFromHexString(hex) {
                primaryBrandColor = color
            }
            
            if let hex = payload["ic-brand-font-color-dark"] as? String, let color = UIColor.colorFromHexString(hex) {
                fontColorDark = color
            }
            
            if let imagePath = payload["ic-brand-header-image"] as? String {
                headerImageURL = imagePath
            }
        }
    }
    
    init() {}
}
