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

    struct GraphQLRequest<C: Codable>: Codable {
        let query: String
        let variables: [String: C]
    }

    struct AddPullRequestReviewInput: Codable {
        var threads: [DraftPullRequestReviewThread] = []
        let commitOID: String
        let event: PullRequestReviewEvent
        let pullRequestId: String // global id, not the PR number
        let body: String
    }

    enum PullRequestReviewEvent: String, Codable {
        case approve = "APPROVE"
        case comment = "COMMENT"
        case dismiss = "DISMISS"
        case requestChanges = "REQUEST_CHANGES"
    }

    struct DraftPullRequestReviewThread: Codable {
        let body: String
        // let commit_id: String
        let path: String

        let startLine: Int?
        let line: Int // last line

        let startSide: String?
        let side: String = "RIGHT"
    }

    static func findPullRequestId(prNumber: Int) throws -> String {
        let query = """
            query findPullRequestId($prNumber: Int!) {
                repository(owner: "instructure", name: "canvas-ios") {
                    pullRequest(number: $prNumber) { id }
                }
            }
            """
        return try (cmd(
                "curl", "-sf", "https://api.github.com/graphql",
                "-X", "POST",
                "-H", "Authorization: Bearer \(token)",
                "--data-binary", "@-"
            ).inputJSON(from: GraphQLRequest(
                query: query,
                variables: [ "prNumber": prNumber ]
            )) | cmd("jq", ".data.repository.pullRequest.id")
        ).runJson(String.self)
    }

    static func postReview(_ input: AddPullRequestReviewInput) throws {
        let query = """
            mutation review($input: AddPullRequestReviewInput!) {
                addPullRequestReview(input: $input) {
                    pullRequestReview { url }
                }
            }
            """
        let result = try (cmd(
                "curl", "-sf", "https://api.github.com/graphql",
                "-X", "POST",
                "-H", "Accept: application/vnd.github.comfort-fade-preview+json",
                "-H", "Authorization: Bearer \(token)",
                "--data-binary", "@-"
            ).inputJSON(from: GraphQLRequest(
                query: query,
                variables: [ "input": input ]
            )) | cmd("jq")
        ).runJson()
        print(result)
    }
}

var snapshotHash = try! cmd("git", "stash", "create").runString() // may be an empty string if nothing to stash
if snapshotHash.isEmpty {
    snapshotHash = "HEAD"
}
_ = try! cmd("./scripts/runSwiftLint.sh", "fix").runString(joinErr: true)

// don't read gitconfig, it might mess with diff format
let gitEnv = ["GIT_CONFIG_NOGLOBAL": "1", "HOME": "", "XDG_CONFIG_HOME": ""]
let diffText = try! cmd("git", "diff", "-U0", snapshotHash, addEnv: gitEnv).runString()
print(diffText)

// undo fixes
try! cmd("git", "checkout", snapshotHash, "--", ".").run()

let diffs = DiffParser(input: diffText).parseDiffedFiles()

let commit = try! cmd("git", "rev-parse", "HEAD").runString()

guard let prNumber = Int(env["BITRISE_PULL_REQUEST"] ?? "") else {
    envError("BITRISE_PULL_REQUEST")
}
let prID = try Github.findPullRequestId(prNumber: prNumber)

var review = Github.AddPullRequestReviewInput(
  commitOID: commit,
  event: .comment,
  pullRequestId: prID,
  body: "fix lint"
)

for diff in diffs {
    for hunk in diff.hunks {
        print(diff.previousFilePath, hunk.oldLineStart, hunk.oldLineSpan)
        let suggestion = (hunk.changes.compactMap { $0.type == "deletion" ? nil : "\($0.text)" }).joined(separator: "\n")
        let isSingleLine = hunk.oldLineSpan == 1
        let thread = Github.DraftPullRequestReviewThread(
          body: """
            ```suggestion
            \(suggestion)
            ```
            """,
          path: diff.previousFilePath,
          startLine: isSingleLine ? nil : hunk.oldLineStart,
          line: hunk.oldLineStart + hunk.oldLineSpan - 1,
          startSide: isSingleLine ? nil : "RIGHT"
        )
        review.threads.append(thread)
    }
}

try cmd("jq").inputJSON(from: review).run()
try Github.postReview(review)
