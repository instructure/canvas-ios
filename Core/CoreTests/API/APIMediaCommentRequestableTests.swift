//
// Copyright (C) 2019-present Instructure, Inc.
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

class APIMediaCommentRequestableTests: XCTestCase {
    let url = URL(string: "/")!

    func testTokenDecode() {
        XCTAssertEqual(try PostMediaUploadTokenRequest(body: nil).decode("<id>token123</id>".data(using: .utf8)!).id, "token123")
    }

    func testUploadQuery() {
        XCTAssertEqual(PostMediaUploadRequest(fileURL: url, type: .audio, ks: "1ks2", token: "3t4").query, [
            .value("service", "uploadtoken"),
            .value("action", "upload"),
            .value("uploadTokenId", "3t4"),
            .value("ks", "1ks2"),
        ])
    }

    func testUploadForm() {
        XCTAssertEqual(PostMediaUploadRequest(fileURL: url, type: .audio, ks: "k", token: "t").form, [
            "fileData": APIFormDatum.file(filename: "audiocomment.m4a", type: "audio/x-m4a", at: url),
        ])
        XCTAssertEqual(PostMediaUploadRequest(fileURL: url, type: .video, ks: "k", token: "t").form, [
            "fileData": APIFormDatum.file(filename: "videocomment.mp4", type: "video/mp4", at: url),
        ])
    }

    func testMediaIDEncode() {
        let request = PostMediaIDRequest(ks: "k", token: "t", type: .audio)
        XCTAssertEqual(
            String(data: try request.encode(request.body!), encoding: .utf8),
            "{\"mediaEntry:name\":\"Media Comment\",\"mediaEntry:mediaType\":\"5\"}"
        )
        XCTAssertEqual(
            String(data: try request.encode(.init(mediaType: .video)), encoding: .utf8),
            "{\"mediaEntry:name\":\"Media Comment\",\"mediaEntry:mediaType\":\"1\"}"
        )
    }

    func testMediaIDQuery() {
        XCTAssertEqual(PostMediaIDRequest(ks: "k", token: "t", type: .audio).query, [
            .value("service", "media"),
            .value("action", "addFromUploadedFile"),
            .value("uploadTokenId", "t"),
            .value("ks", "k"),
        ])
    }

    func testMediaIDDecode() {
        XCTAssertEqual(try PostMediaIDRequest(ks: "k", token: "t", type: .audio).decode("<id>token123</id>".data(using: .utf8)!).id, "token123")
    }
}
