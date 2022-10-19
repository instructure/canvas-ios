//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Core
import XCTest

class ConversationParticipantNamesTests: CoreTestCase {

    func testNames() {
        let bob = makeParticipant(name: "Bob")
        let alice = makeParticipant(name: "Alice")
        let ray = makeParticipant(name: "Ray")
        let trudy = makeParticipant(name: "Trudy")
        let jay = makeParticipant(name: "Jay")
        let leeloo = makeParticipant(name: "Leeloo")
        let jim = makeParticipant(name: "Jim")
        let nina = makeParticipant(name: "Nina")
        let allNames = [bob, alice, ray, trudy, jay, leeloo, jim, nina]

        XCTAssertEqual(Array(allNames.prefix(0)).names, "")
        XCTAssertEqual(Array(allNames.prefix(1)).names, "Bob")
        XCTAssertEqual(Array(allNames.prefix(2)).names, "Bob, Alice")
        XCTAssertEqual(Array(allNames.prefix(3)).names, "Bob, Alice, Ray")
        XCTAssertEqual(Array(allNames.prefix(4)).names, "Bob, Alice, Ray, Trudy")
        XCTAssertEqual(Array(allNames.prefix(5)).names, "Bob, Alice, Ray, Trudy, Jay")
        XCTAssertEqual(Array(allNames.prefix(6)).names, "Bob, Alice, Ray, Trudy, Jay, Leeloo")
        XCTAssertEqual(Array(allNames.prefix(7)).names, "Bob, Alice, Ray, Trudy, Jay + 2 more")
        XCTAssertEqual(Array(allNames.prefix(8)).names, "Bob, Alice, Ray, Trudy, Jay + 3 more")
    }

    private func makeParticipant(name: String) -> ConversationParticipant {
        let p = ConversationParticipant(context: databaseClient)
        p.name = name
        return p
    }
}
