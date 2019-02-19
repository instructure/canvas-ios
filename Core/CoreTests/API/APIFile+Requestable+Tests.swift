//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
@testable import Core

class APIFileRequestableTests: XCTestCase {
    func testGetFileRequest() {
        let request = GetFileRequest(context: ContextModel(.course, id: "1"), fileID: "2")
        XCTAssertEqual(request.path, "courses/1/files/2")
    }
}

class PostFileUploadTargetRequestTests: XCTestCase {
    func testPostFileUploadTargetRequest() {
        let body = PostFileUploadTargetRequest.Body(
            name: "File.jpg",
            on_duplicate: .rename,
            parent_folder_id: nil
        )
        let request = PostFileUploadTargetRequest(
            target: .submission(courseID: "1", assignmentID: "2"),
            body: body
        )
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.body, body)
    }

    func testPostFileUploadTargetRequestSubmission() {
        let body = PostFileUploadTargetRequest.Body(
            name: "File.jpg",
            on_duplicate: .rename,
            parent_folder_id: nil
        )
        let request = PostFileUploadTargetRequest(
            target: .submission(courseID: "1", assignmentID: "2"),
            body: body
        )
        XCTAssertEqual(request.path, "courses/1/assignments/2/submissions/self/files")
    }

    func testPostFileUploadTargetRequestCourse() {
        let body = PostFileUploadTargetRequest.Body(
            name: "File.jpg",
            on_duplicate: .rename,
            parent_folder_id: nil
        )
        let request = PostFileUploadTargetRequest(
            target: .course("1"),
            body: body
        )
        XCTAssertEqual(request.path, "courses/1/files")
    }

    func testPostFileUploadTargetRequestUser() {
        let body = PostFileUploadTargetRequest.Body(
            name: "File.jpg",
            on_duplicate: .rename,
            parent_folder_id: nil
        )
        let request = PostFileUploadTargetRequest(
            target: .user("1"),
            body: body
        )
        XCTAssertEqual(request.path, "users/1/files")
    }

    func testPostFileUploadTargetRequestMyFiles() {
        let body = PostFileUploadTargetRequest.Body(
            name: "File.jpg",
            on_duplicate: .rename,
            parent_folder_id: nil
        )
        let request = PostFileUploadTargetRequest(
            target: .myFiles,
            body: body
        )
        XCTAssertEqual(request.path, "users/self/files")
    }
}

class PostFileUploadRequestTests: XCTestCase {
    var bundle: Bundle {
        return Bundle(for: type(of: self))
    }

    var fileURL: URL {
        return bundle.url(forResource: "fileupload", withExtension: "txt")!
    }

    func expectedPostBody() throws -> String {
        // Note: the ^M characters in file-post-body.txt file are needed!!
        // If the body needs to change, write the data to disk and copy it over.
        let url = bundle.url(forResource: "file-post-body", withExtension: "txt")!
        return try String(contentsOf: url)
    }

    func testPostFileUploadRequest() throws {
        let target = PostFileUploadTargetRequest.Response(
            upload_url: URL(string: "s3://some/bucket/")!,
            upload_params: ["filename": "fileupload.txt"]
        )
        let requestable = PostFileUploadRequest(fileURL: fileURL, target: target, boundary: "3klfenalksjflkjoi9auf89eshajsnl3kjnwal")

        XCTAssertEqual(requestable.path, "s3://some/bucket/")
        XCTAssertEqual(requestable.method, .post)
        let contentType = "multipart/form-data; charset=utf-8; boundary=\"3klfenalksjflkjoi9auf89eshajsnl3kjnwal\""
        XCTAssertEqual(requestable.headers, [
            HttpHeader.authorization: nil,
            HttpHeader.contentType: contentType,
        ])
    }

    func testPostFileUploadRequestBody() throws {
        let target = PostFileUploadTargetRequest.Response(
            upload_url: URL(string: "s3://some/bucket/")!,
            upload_params: ["filename": "fileupload.txt"]
        )
        let requestable = PostFileUploadRequest(fileURL: fileURL, target: target, boundary: "3klfenalksjflkjoi9auf89eshajsnl3kjnwal")
        let baseURL = URL(string: "https://cgnuonline-eniversity.edu")!
        let request = try requestable.urlRequest(relativeTo: baseURL, accessToken: nil, actAsUserID: nil)
        let data = request.httpBody

        XCTAssertNotNil(data)
        let body = String(data: data!, encoding: .utf8)!
        let expected = try expectedPostBody()
        XCTAssertEqual(body, expected)
    }
}
