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

// Remove all but last comment left by github user "instructure-cx" from a pull
// request
//
// Note, swift-sh should be installed to resolve dependencies
//   brew install mxcl/made/swift-sh

import Foundation
import swsh // @cobbal == 0.2.0

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
        envError("GITHUB_ACCESS_TOKEN")
    }

    static func listCheckmarxCommentIds(forPrNumber prNumber: Int) throws -> [String] {
        let query = """
          query {
            repository(owner:"instructure", name:"canvas-ios") {
              pullRequest(number:\(prNumber)) {
                comments(first:100) {nodes {author {login} id}}
              }
            }
          }
          """
        return try (
          cmd(
            "curl", "-sf", "https://api.github.com/graphql",
            "-X", "POST",
            "-H", "Authorization: Bearer \(token)",
            "--data-binary", "@-"
          ) | cmd(
            "jq", """
                    .data.repository.pullRequest.comments.nodes |
                    map(select(.author.login == "instructure-cx") | .id)
                    """
          )).input(withJSONObject: ["query": query])
          .runJson([String].self)
    }

    static func deleteComments(withIds ids: [String]) throws {
        var queryLines = ["mutation {"]
        for (whoCares, id) in ids.enumerated() {
            queryLines.append("  _\(whoCares): deleteIssueComment(input:{id: \"\(id)\"}){clientMutationId}")
        }
        queryLines.append("}")
        let query = queryLines.joined(separator: "\n")
        print(query)

        try (cmd(
               "curl", "-sf", "https://api.github.com/graphql",
               "-X", "POST",
               "-H", "Authorization: Bearer \(token)",
               "--data-binary", "@-"
             ) | cmd("jq")).input(withJSONObject: ["query": query]).run()
    }
}

let args = CommandLine.arguments
guard args.count == 2, let prNumber = Int(args[1]) else {
    print("usage: kill-cx.swift pull-request-number")
    exit(1)
}

let annoyingComments = Array(try Github.listCheckmarxCommentIds(forPrNumber: prNumber).dropLast(1))
try Github.deleteComments(withIds: annoyingComments)
print("Done!")
