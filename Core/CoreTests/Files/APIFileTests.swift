//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

import XCTest
@testable import Core

private let decoder = APIJSONDecoder()

class APIFileTests: XCTestCase {
    func testAPIFileDecode() {
        var fixture = validFixture
        var data = try! serialize(json: fixture)
        XCTAssertNoThrow(try decoder.decode(APIFile.self, from: data))

        fixture["url"] = ""
        data = try! serialize(json: fixture)
        var file = try! decoder.decode(APIFile.self, from: data)
        XCTAssertNil(file.url)

        fixture["thumbnail_url"] = ""
        data = try! serialize(json: fixture)
        file = try! decoder.decode(APIFile.self, from: data)
        XCTAssertNil(file.thumbnail_url)
    }

    func testGetFileRequest() {
        let request = GetFileRequest(context: .course("1"), fileID: "2", include: [.avatar])
        XCTAssertEqual(request.path, "courses/1/files/2")
        XCTAssertEqual(request.queryItems, [ URLQueryItem(name: "include[]", value: "avatar") ])
    }

    func testGetFileRequestWithRootContext() {
        let request = GetFileRequest(context: nil, fileID: "2", include: [.avatar])
        XCTAssertEqual(request.path, "files/2")
        XCTAssertEqual(request.queryItems, [ URLQueryItem(name: "include[]", value: "avatar") ])
    }

    func testGetContextFolderHierarchyRequest() {
        let request = GetContextFolderHierarchyRequest(context: .course("1"), fullPath: "a/b")
        XCTAssertEqual(request.path, "courses/1/folders/by_path/a/b")
        XCTAssertEqual(request.queryItems, [ URLQueryItem(name: "include[]", value: "usage_rights") ])
    }

    func testListFoldersRequest() {
        let request = ListFoldersRequest(context: .course("1"))
        XCTAssertEqual(request.path, "courses/1/folders")
        XCTAssertEqual(request.queryItems, [
            URLQueryItem(name: "include[]", value: "usage_rights"),
            URLQueryItem(name: "per_page", value: "100"),
        ])
    }

    func testListFilesRequest() {
        let request = ListFilesRequest(context: .course("1"))
        XCTAssertEqual(request.path, "courses/1/files")
        XCTAssertEqual(request.queryItems, [
            URLQueryItem(name: "include[]", value: "usage_rights"),
            URLQueryItem(name: "per_page", value: "100"),
        ])
    }

    func testGetFolderRequest() {
        let request = GetFolderRequest(context: .course("1"), id: "2")
        XCTAssertEqual(request.path, "courses/1/folders/2")
        XCTAssertEqual(request.queryItems, [ URLQueryItem(name: "include[]", value: "usage_rights") ])
    }

    func testListFilesRequestWithRootContext() {
        let request = GetFolderRequest(context: nil, id: "2")
        XCTAssertEqual(request.path, "folders/2")
        XCTAssertEqual(request.queryItems, [ URLQueryItem(name: "include[]", value: "usage_rights") ])
    }

    func testDeleteFileRequest() {
        let request = DeleteFileRequest(fileID: "43")
        XCTAssertEqual(request.method, .delete)
        XCTAssertEqual(request.path, "files/43")
    }
}

extension APIFileTests {
    var validFixture: [String: Any?] {
        [
            "id": "1",
            "uuid": "abc123",
            "folder_id": nil,
            "display_name": "File 1",
            "filename": "file1.jpg",
            "content-type": "image",
            "url": "https://canvas.instructure.com/files/1",
            "size": 10,
            "created_at": "2020-02-10T22:26:48Z",
            "updated_at": "2020-02-10T22:26:48Z",
            "unlock_at": nil,
            "locked": false,
            "hidden": false,
            "lock_at": nil,
            "hidden_for_user": false,
            "thumbnail_url": nil,
            "modified_at": "2020-02-10T22:26:48Z",
            "mime_class": "image/jpg",
            "media_entry_id": nil,
            "locked_for_user": false,
            "lock_explanation": nil,
            "preview_url": nil,
            "avatar": nil,
        ]
    }

    func serialize(json: [String: Any?]) throws -> Data {
        try JSONSerialization.data(withJSONObject: json, options: [])
    }
}

class PostFileUploadTargetRequestTests: XCTestCase {
    func testPostFileUploadTargetRequest() {
        let body = PostFileUploadTargetRequest.Body(
            name: "File.jpg",
            on_duplicate: .rename,
            parent_folder_id: nil,
            size: 0
        )
        let request = PostFileUploadTargetRequest(
            context: .submission(courseID: "1", assignmentID: "2", comment: nil),
            body: body
        )
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.body, body)
    }

    func testPostFileUploadTargetRequestSubmission() {
        let body = PostFileUploadTargetRequest.Body(
            name: "File.jpg",
            on_duplicate: .rename,
            parent_folder_id: nil,
            size: 0
        )
        let request = PostFileUploadTargetRequest(
            context: .submission(courseID: "1", assignmentID: "2", comment: nil),
            body: body
        )
        XCTAssertEqual(request.path, "courses/1/assignments/2/submissions/self/files")
    }

    func testPostFileUploadTargetRequestCourse() {
        let body = PostFileUploadTargetRequest.Body(
            name: "File.jpg",
            on_duplicate: .rename,
            parent_folder_id: nil,
            size: 0
        )
        let request = PostFileUploadTargetRequest(
            context: .context(Context(.course, id: "1")),
            body: body
        )
        XCTAssertEqual(request.path, "courses/1/files")
    }

    func testPostFileUploadTargetRequestUser() {
        let body = PostFileUploadTargetRequest.Body(
            name: "File.jpg",
            on_duplicate: .rename,
            parent_folder_id: nil,
            size: 0
        )
        let request = PostFileUploadTargetRequest(
            context: .context(Context(.user, id: "1")),
            body: body
        )
        XCTAssertEqual(request.path, "users/1/files")
    }

    func testPostFileUploadTargetRequestMyFiles() {
        let body = PostFileUploadTargetRequest.Body(
            name: "File.jpg",
            on_duplicate: .rename,
            parent_folder_id: nil,
            size: 0
        )
        let request = PostFileUploadTargetRequest(
            context: .myFiles,
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
        let requestable = PostFileUploadRequest(fileURL: fileURL, target: target)

        XCTAssertEqual(requestable.path, "s3://some/bucket/")
        XCTAssertEqual(requestable.method, .post)
        XCTAssertEqual(requestable.headers, [
            HttpHeader.authorization: nil,
        ])
        XCTAssertEqual(requestable.form?.count, 2)
        XCTAssertEqual(requestable.form?.last?.key, "file")
    }
}

class SetUsageRightsRequestTests: XCTestCase {
//    func test
    func testSetUsageRightsRequest() throws {
        let request = SetUsageRightsRequest(context: .course("1"))
        XCTAssertEqual(request.path, "courses/1/usage_rights")
    }
}
