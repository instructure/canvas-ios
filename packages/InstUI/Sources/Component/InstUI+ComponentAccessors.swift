//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import SwiftUI

extension InstUI {
    public enum Component {}
}

extension Color {
    public enum iui {} // Namespace for the component layer
}

extension Font.Weight {
    public enum iui {} // Namespace for the component layer
}

extension String {
    public enum iui {} // Namespace for the component layer
}

extension Double {
    public enum iui {} // Namespace for the component layer
}

extension CGFloat {
    public enum iui {} // Namespace for the component layer
}

// Called from generated component accessor extensions — module-level scope keeps `InstUI`
// unambiguous even though each Swift type has a shadowing `Color.InstUI` / `CGFloat.InstUI` etc.
func _iuiComponents() -> InstUI.Theme.Components { InstUI.Theme.default.components }
