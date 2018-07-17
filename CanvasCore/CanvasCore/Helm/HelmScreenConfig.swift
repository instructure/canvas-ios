//
// Copyright (C) 2018-present Instructure, Inc.
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
