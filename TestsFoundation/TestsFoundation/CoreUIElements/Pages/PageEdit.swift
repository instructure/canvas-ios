//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public enum PageEdit: String, RawRepresentable, RawElementWrapper {
    case done = "pages.edit.doneButton"
    case title = "pages.edit.titleInput"
    case published = "pages.edit.published.row"
    case frontPage = "pages.edit.front_page.row"
    case canEdit = "pages.edit.editing_roles.row"
}
