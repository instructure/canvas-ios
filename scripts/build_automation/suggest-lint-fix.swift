#!/usr/bin/swift sh
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

// Reply to a PR with a lint fix
//
// Note, swift-sh should be installed to resolve dependencies
//   brew install mxcl/made/swift-sh
//
// To edit this file in xcode:
//   swift sh edit suggest-lint-fix.swift

import Foundation
import swsh // @cobbal == 0.2.0
import GitDiffSwift // @cobbal == master

ExternalCommand.verbose = true

let repoOwner = "instructure"
let repoName = "canvas-ios"
let repo = "\(repoOwner)/\(repoName)"

let env = ProcessInfo.processInfo.environment

func envError(_ name: String) -> Never {
    print("environment variable \(name) must be set")
    exit(1)
}

enum Github {
    static var token: String {
        if let token = env["DANGER_GITHUB_API_TOKEN"] {
            return token
        }
        if let token = env["GITHUB_ACCESS_TOKEN"] {
            return token
        }
        envError("DANGER_GITHUB_API_TOKEN")
    }

    struct Comment: Codable {
        let body: String
        let commit_id: String
        let path: String

        let start_line: Int
        let line: Int // last line

        let start_side: String = "LEFT"
        let side: String = "RIGHT"
    }

    static func postComment(prID: String, comment: Comment) throws {
        try cmd(
            "curl", "-sf", "https://api.github.com/repos/\(repo)/pulls/\(prID)/comments",
            "-X", "POST",
            "-H", "Content-Type: application/json; charset=utf-8",
            "-H", "Accept: application/vnd.github.comfort-fade-preview+json",
            "-H", "Authorization: Bearer \(token)",

            "--data-binary", "@-"
        ).inputJSON(from: comment).run()
    }
}

var snapshotHash = try! cmd("git", "stash", "create").runString() // may be an empty string if nothing to stash
if snapshotHash.isEmpty {
    snapshotHash = "HEAD"
}
_ = try! cmd("./scripts/runSwiftLint.sh", "fix").runString(joinErr: true)

// don't read gitconfig, it might mess with diff format
let gitEnv = ["GIT_CONFIG_NOGLOBAL": "1", "HOME": "", "XDG_CONFIG_HOME": ""]
let diffText = try! cmd("git", "diff", "-U1", snapshotHash, addEnv: gitEnv).runString()

// undo fixes
try! cmd("git", "checkout", snapshotHash, "--", ".").run()

print(diffText)
let diffs = DiffParser(input: diffText).parseDiffedFiles()

let commit = try! cmd("git", "rev-parse", "HEAD").runString()

for diff in diffs {
    for hunk in diff.hunks {
        print(diff.previousFilePath, hunk.oldLineStart, hunk.oldLineSpan)
        let suggestion = (hunk.changes.compactMap { $0.type == "deletion" ? nil : "    \($0.text)" }).joined(separator: "\n")
        let comment = Github.Comment(
          body: """
            ```suggestion
            \(suggestion)
            ```
            """,
          commit_id: commit,
          path: diff.previousFilePath,
          start_line: hunk.oldLineStart,
          line: hunk.oldLineStart + hunk.oldLineSpan - 1
        )
        print(comment)
        try! cmd("jq").inputJSON(from: comment).run()
        let prID = env["BITRISE_PULL_REQUEST"]
        guard prID?.isEmpty == false else { envError("BITRISE_PULL_REQUEST") }
        try! Github.postComment(prID: prID!, comment: comment)
    }
}
