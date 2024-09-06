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
import ArgumentParser
import swsh
import GitDiffSwift

struct SuggestLintFix: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Reply to a PR with a lint fix"
    )

    func inDir<R>(_ path: String, body: () throws -> R) rethrows -> R {
        let originalPath = FileManager.default.currentDirectoryPath
        FileManager.default.changeCurrentDirectoryPath(path)
        defer { FileManager.default.changeCurrentDirectoryPath(originalPath) }
        return try body()
    }

    @Argument()
    var prNumber: Int

    func run() throws {
        var snapshotHash = try cmd("git", "stash", "create").runString() // may be an empty string if nothing to stash
        if snapshotHash.isEmpty {
            snapshotHash = "HEAD"
        }

        _ = try cmd("./scripts/runSwiftLint.sh", "fix").combineError.runString()

        // don't read gitconfig, it might mess with diff format
        let gitEnv = ["GIT_CONFIG_NOGLOBAL": "1", "HOME": "", "XDG_CONFIG_HOME": ""]
        let diffText = try cmd("git", "diff", "-U0", snapshotHash, addEnv: gitEnv).runString()
        // undo fixes
        try cmd("git", "checkout", snapshotHash, "--", ".").run()

        print(diffText)

        let diffs = DiffParser(input: diffText).parseDiffedFiles()

        let commit = try cmd("git", "rev-parse", "HEAD").runString()

        var threads: [Github.DraftPullRequestReviewThread] = []
        for diff in diffs {
            for hunk in diff.hunks {
                print(diff.previousFilePath, hunk.oldLineStart, hunk.oldLineSpan)
                var lines = [Int: String]()
                for change in hunk.changes {
                    print("  ", change.type, change.oldLine, change.text)
                    switch change.type {
                    case "deletion":
                        lines[change.oldLine] = ""
                    case "addition":
                        let targetLine = hunk.oldLineStart + (change.newLine - hunk.newLineStart)
                        lines[targetLine] = "\(lines[targetLine] ?? "")\(change.text)\n"
                    default: fatalError()
                    }
                }
                for (line, suggestion) in lines.sorted(by: { $0.key < $1.key }) {
                    threads.append(Github.DraftPullRequestReviewThread(
                                     body: """
                                       ```suggestion
                                       \(suggestion)```
                                       """,
                                     path: diff.previousFilePath,
                                     line: line
                                   ))
                }
            }
        }

        let prID = try Github.findPullRequestId(prNumber: prNumber)

        let review = Github.AddPullRequestReviewInput(
          threads: threads,
          commitOID: commit,
          event: .comment,
          pullRequestId: prID,
          body: "fix lint"
        )
        try cmd("jq").inputJSON(from: review).run()
        try Github.postReview(review)
    }
}
