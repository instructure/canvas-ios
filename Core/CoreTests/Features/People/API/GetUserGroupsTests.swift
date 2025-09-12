//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
@testable import Core

class GetUserGroupsTests: XCTestCase {
    let jsonData = """
    {
      "data": {
        "course": {
          "groupSets": [
            {
              "_id": "1271",
              "name": "Primary Course's Group",
              "groups": [
                {
                  "_id": "2779",
                  "name": "Primary Course's Group 1",
                  "nonCollaborative": false,
                  "membersConnection": {
                    "nodes": []
                  }
                }
              ]
            },
            {
              "_id": "3466",
              "name": "single_tag",
              "groups": [
                {
                  "_id": "7813",
                  "name": "single_tag",
                  "nonCollaborative": true,
                  "membersConnection": {
                    "nodes": [
                      {
                        "user": {
                          "_id": "96692"
                        }
                      }
                    ]
                  }
                }
              ]
            },
            {
              "_id": "3467",
              "name": "My Tags",
              "groups": [
                {
                  "_id": "7814",
                  "name": "another_tag_in_group",
                  "nonCollaborative": true,
                  "membersConnection": {
                    "nodes": []
                  }
                },
                {
                  "_id": "7815",
                  "name": "tag_in_group",
                  "nonCollaborative": true,
                  "membersConnection": {
                    "nodes": [
                      {
                        "user": {
                          "_id": "96504"
                        }
                      }
                    ]
                  }
                }
              ]
            }
          ]
        }
      }
    }
    """.data(using: .utf8)!

    func testDeserialization() {
        let expectedResponse = GetUserGroupsResponse(
            data: GetUserGroupsResponse.ResponseData(
                course: GetUserGroupsResponse.Course(
                    groupSets: [
                        GetUserGroupsResponse.GroupSet(
                            _id: "1271",
                            name: "Primary Course's Group",
                            groups: [
                                GetUserGroupsResponse.Group(
                                    _id: "2779",
                                    name: "Primary Course's Group 1",
                                    nonCollaborative: false,
                                    membersConnection: GetUserGroupsResponse.MembersConnection(
                                        nodes: []
                                    )
                                )
                            ]
                        ),
                        GetUserGroupsResponse.GroupSet(
                            _id: "3466",
                            name: "single_tag",
                            groups: [
                                GetUserGroupsResponse.Group(
                                    _id: "7813",
                                    name: "single_tag",
                                    nonCollaborative: true,
                                    membersConnection: GetUserGroupsResponse.MembersConnection(
                                        nodes: [
                                            GetUserGroupsResponse.MembersConnection.Member(
                                                user: GetUserGroupsResponse.MembersConnection.Member.User(
                                                    _id: "96692"
                                                )
                                            )
                                        ]
                                    )
                                )
                            ]
                        ),
                        GetUserGroupsResponse.GroupSet(
                            _id: "3467",
                            name: "My Tags",
                            groups: [
                                GetUserGroupsResponse.Group(
                                    _id: "7814",
                                    name: "another_tag_in_group",
                                    nonCollaborative: true,
                                    membersConnection: GetUserGroupsResponse.MembersConnection(
                                        nodes: []
                                    )
                                ),
                                GetUserGroupsResponse.Group(
                                    _id: "7815",
                                    name: "tag_in_group",
                                    nonCollaborative: true,
                                    membersConnection: GetUserGroupsResponse.MembersConnection(
                                        nodes: [
                                            GetUserGroupsResponse.MembersConnection.Member(
                                                user: GetUserGroupsResponse.MembersConnection.Member.User(
                                                    _id: "96504"
                                                )
                                            )
                                        ]
                                    )
                                )
                            ]
                        )
                    ]
                )
            )
        )

        let decoder = JSONDecoder()
        let actualResponse = try! decoder.decode(GetUserGroupsResponse.self, from: jsonData)

        XCTAssertEqual(actualResponse, expectedResponse)
        XCTAssertEqual(actualResponse.groupSets, expectedResponse.groupSets)
    }

    func testRequestInitialization() {
        let request = GetUserGroupsRequest(courseId: "12345")

        XCTAssertEqual(request.variables.courseId, "12345")
        XCTAssertTrue(GetUserGroupsRequest.query.contains("GetUserGroupsRequest"))
        XCTAssertTrue(GetUserGroupsRequest.query.contains("$courseId: ID!"))
        XCTAssertTrue(GetUserGroupsRequest.query.contains("groupSets(includeNonCollaborative: true)"))
    }
}
