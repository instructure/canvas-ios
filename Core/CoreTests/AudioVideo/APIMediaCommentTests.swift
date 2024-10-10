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

import XCTest
@testable import Core

class APIMediaCommentTests: XCTestCase {
    let url = URL.make()

    func testTokenDecode() {
        XCTAssertEqual(try PostMediaUploadTokenRequest(body: nil).decode("<id>token123</id>".data(using: .utf8)!).id, "token123")
    }

    func testUploadQuery() {
        XCTAssertEqual(PostMediaUploadRequest(fileURL: url, type: .audio, ks: "1ks2", token: "3t4").query, [
            .value("service", "uploadtoken"),
            .value("action", "upload"),
            .value("uploadTokenId", "3t4"),
            .value("ks", "1ks2")
        ])
    }

    func testUploadForm() {
        let audio = PostMediaUploadRequest(fileURL: url, type: .audio, ks: "k", token: "t").form
        XCTAssertEqual(audio?.count, 1)
        XCTAssertEqual(audio?.first?.key, "fileData")
        XCTAssertEqual(audio?.first?.value, .file(filename: "audiocomment.m4a", type: "audio/x-m4a", at: url))
        let video = PostMediaUploadRequest(fileURL: url, type: .video, ks: "k", token: "t").form
        XCTAssertEqual(video?.count, 1)
        XCTAssertEqual(video?.first?.key, "fileData")
        XCTAssertEqual(video?.first?.value, .file(filename: "videocomment.mp4", type: "video/mp4", at: url))
    }

    func testMediaIDEncode() {
        let request = PostMediaIDRequest(ks: "k", token: "t", type: .audio)
        XCTAssertEqual(
            String(data: try request.encode(request.body!), encoding: .utf8),
            "{\"mediaEntry:mediaType\":\"5\",\"mediaEntry:name\":\"Media Comment\"}"
        )
        XCTAssertEqual(
            String(data: try request.encode(.init(mediaType: .video)), encoding: .utf8),
            "{\"mediaEntry:mediaType\":\"1\",\"mediaEntry:name\":\"Media Comment\"}"
        )
    }

    func testMediaIDQuery() {
        XCTAssertEqual(PostMediaIDRequest(ks: "k", token: "t", type: .audio).query, [
            .value("service", "media"),
            .value("action", "addFromUploadedFile"),
            .value("uploadTokenId", "t"),
            .value("ks", "k")
        ])
    }

    func testMediaIDDecode() {
        XCTAssertEqual(try PostMediaIDRequest(ks: "k", token: "t", type: .audio).decode("<id>token123</id>".data(using: .utf8)!).id, "token123")
    }
}
