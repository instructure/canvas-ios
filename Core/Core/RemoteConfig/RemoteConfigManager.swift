//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public class RemoteConfigManager {
    public static var shared = RemoteConfigManager()
    public var five9ConfigID: String = ""
    public var segmentKey: String = ""
    public var xpertKey: String = ""
    public var formadataLabel: String = ""

    public func saveRemoteConfig(key: String, value: String?) {
        if key == "five9_config_id" {
            five9ConfigID = value ?? "GS | Support_Main_Flow_Xpert"
        } else if key == "chat_segment_key" {
            segmentKey = value ?? "7BKIV04l1A90BkuAlqLMkPiNAUhgbatW"
        } else if key == "xpert_key" {
            xpertKey = value ?? "degrees-canvas-support"
        } else if key == "five9_formdata_label" {
            formadataLabel = value ?? "unknown"
        }
    }
}
