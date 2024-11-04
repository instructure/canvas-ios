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

enum Github {
    static let repoOwner = "instructure"
    static let repoName = "canvas-ios"
    static let repo = "\(repoOwner)/\(repoName)"

    static let token =
        Env.env["DANGER_GITHUB_API_TOKEN"] ??
        Env.env["GITHUB_ACCESS_TOKEN"] ??
        Env.error("GITHUB_ACCESS_TOKEN")

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
            )).inputJSON(from: GraphQLRequest<String>(query: query))
            .runJSON([String].self)
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

    struct IssueComment: Codable {
        let id: Int
        let body: String
        let user: User

        struct User: Codable {
            let login: String
        }
    }

    static func getAllIssueComments(prID: String) throws -> [IssueComment] {
        // TODO: paging, but it'll probably be in the first page, right?
        let url = "https://api.github.com/repos/\(repo)/issues/\(prID)/comments"
        return try cmd(
            "curl", "-sf", url,
            "-H", "Authorization: Bearer \(token)"
        ).runJSON([IssueComment].self)
    }

    static func postComment(prID: String, body: String) throws {
        try cmd(
            "curl", "-sf", "https://api.github.com/repos/\(repo)/issues/\(prID)/comments",
            "-X", "POST",
            "-H", "Content-Type: application/json; charset=utf-8",
            "-H", "Authorization: Bearer \(token)",
            "--data-binary", "@-"
        ).input(withJSONObject: [ "body": body ]).run()
    }

    static func updateComment(commentID: String, body: String) throws {
        try cmd(
            "curl", "-sf", "https://api.github.com/repos/\(repo)/issues/comments/\(commentID)",
            "-X", "PATCH",
            "-H", "Content-Type: application/json; charset=utf-8",
            "-H", "Authorization: Bearer \(token)",
            "--data-binary", "@-"
        ).input(withJSONObject: [ "body": body ]).run()
    }

    static func findAssociatedPullRequests(branch: String) throws -> [Int] {
        let query = """
        query findAssociatedPullRequests($branch: String!) {
            repository(owner: "instructure", name: "canvas-ios") {
                ref(qualifiedName: $branch) {
                    target { ... on Commit {
                        associatedPullRequests(first: 10) {
                            nodes { number closed } } } } } } }
        """
        let result = try cmd(
            "curl", "-sf", "https://api.github.com/graphql",
            "-X", "POST",
            "-H", "Authorization: Bearer \(token)",
            "--data-binary", "@-"
        ).input(withJSONObject: [
            "query": query,
            "variables": [ "branch": branch ],
        ]).runJSON()

        let keyPath = "data.repository.ref.target.associatedPullRequests.nodes"
        guard let nodes = (result as? NSDictionary)?.value(forKeyPath: keyPath) as? [[String: Any]] else {
            fatalError("Couldn't parse response from graphql" )
        }
        return nodes.compactMap { node in
            guard node["closed"] as? Bool == false else { return nil }
            return node["number"] as? Int
        }
    }

    struct GraphQLRequest<C: Codable>: Codable {
        let query: String
        let variables: C?

        init(query: String, variables: C? = nil) {
            self.query = query
            self.variables = variables
        }
    }

    struct AddPullRequestReviewInput: Codable {
        let threads: [DraftPullRequestReviewThread]
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
        enum CodingKeys: String, CodingKey {
            case body
            case path
            case line
        }

        let body: String
        // let commit_id: String
        let path: String
        let line: Int // last line

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
                                )) | cmd("jq", "-r", ".data.repository.pullRequest.id")).runString()
    }

    static func postReview(_ input: AddPullRequestReviewInput) throws {
        let query = """
          mutation review($input: AddPullRequestReviewInput!) {
          addPullRequestReview(input: $input) {
          pullRequestReview { url }
          }
          }
          """
        try (cmd(
               "curl", "-sf", "https://api.github.com/graphql",
               "-X", "POST",
               "-H", "Accept: application/vnd.github.comfort-fade-preview+json",
               "-H", "Authorization: Bearer \(token)",
               "--data-binary", "@-"
             ).inputJSON(from: GraphQLRequest(
                           query: query,
                           variables: [ "input": input ]
                         )) | cmd("jq")).run()
    }
}
