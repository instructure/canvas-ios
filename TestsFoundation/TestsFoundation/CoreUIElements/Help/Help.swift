//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Foundation
import XCTest

public enum Help {
    public static var searchTheCanvasGuides: Element {
        return app.find(id: "helpItems").rawElement.findAll(type: .button)[0]
    }

    public static var askYourInstructor: Element {
        return app.find(id: "helpItems").rawElement.findAll(type: .button)[1]
    }

    public static var reportAProblem: Element {
        return app.find(id: "helpItems").rawElement.findAll(type: .button)[2]
    }

    public static var submitAFeatureIdea: Element {
        return app.find(id: "helpItems").rawElement.findAll(type: .button)[3]
    }

    public static var covid19: Element {
        return app.find(id: "helpItems").rawElement.findAll(type: .button)[4]
    }
}
