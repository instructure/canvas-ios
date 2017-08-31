//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

struct Brand {
    var navBgColor = UIColor.red
    var navButtonColor = UIColor.red
    var navTextColor = UIColor.red
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
            
            if let hex = payload["ic-brand-global-nav-menu-item__text-color"] as? String, let color = UIColor.colorFromHexString(hex) {
                navTextColor = color
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
