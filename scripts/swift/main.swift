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

let dependencies = [
  "jq": "brew install jq",
  "yarn": "brew install yarn",
]

for (dependency, installInstructions) in dependencies {
    if !cmd("/usr/bin/which", dependency).output(overwritingFile: "/dev/null").runBool() {
        FileHandle.standardError.write("""

        WARNING: dependency '\(dependency)' not detected, install with:
          \(installInstructions)


        """.data(using: .utf8)!)
    }
}

struct Scripts: ParsableCommand {
    static let configuration = CommandConfiguration(
      commandName: "./scripts/swift-run",
      subcommands: [
        BuildLink.self,
        DeleteExtraCheckmarxComments.self,
        ExportCoverage.self,
        SuggestLintFix.self,
        SummarizeTestResults.self,
      ]
    )
}

Scripts.main()
