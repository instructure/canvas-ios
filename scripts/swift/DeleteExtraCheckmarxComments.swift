//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import swsh
import ArgumentParser

struct DeleteExtraCheckmarxComments: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "delete-cx",
        abstract: """
            Remove all but last comment left by github user "instructure-cx" from a pull request
            """
    )

    @Argument()
    var prNumber: Int

    func run() throws {
        let annoyingComments = Array(try Github.listCheckmarxCommentIds(forPrNumber: prNumber).dropLast(1))
        try Github.deleteComments(withIds: annoyingComments)
        print("Done!")
    }
}
