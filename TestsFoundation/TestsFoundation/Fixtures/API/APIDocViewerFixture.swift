//
// Copyright (C) 2018-present Instructure, Inc.
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

@testable import Core

extension APIDocViewerAnnotation: Fixture {
    public static var template: Template {
        return [
            "id": "1",
            "user_id": "1",
            "user_name": "a",
            "page": 0,
            "type": "text",
            "contents": "",
        ]
    }
}

extension APIDocViewerMetadata: Fixture {
    public static var template: Template {
        return [
            "annotations": APIDocViewerAnnotationsMetadata.fixture(),
            "urls": APIDocViewerURLsMetadata.fixture(),
        ]
    }
}

extension APIDocViewerAnnotationsMetadata: Fixture {
    public static var template: Template {
        return [
            "enabled": true,
            "user_id": "1",
            "user_name": "Bob",
            "permissions": "readwritemanage",
        ]
    }
}

extension APIDocViewerURLsMetadata: Fixture {
    public static var template: Template {
        return [
            "pdf_download": "download",
        ]
    }
}
