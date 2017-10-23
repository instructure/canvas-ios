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

public enum DocumentOption {
    case camera(allowsPhotos: Bool, allowsVideos: Bool)
    case photoLibrary(allowsPhotos: Bool, allowsVideos: Bool)
    case recordAudio

    public var title: String {
        switch self {
        case .recordAudio:
            return NSLocalizedString("Record Audio",
                                     tableName: "Localizable",
                                     bundle: .core,
                                     value: "",
                                     comment: "Choose record audio submission")
        case let .camera(allowsPhotos: allowsPhotos, allowsVideos: allowsVideos):
            switch (allowsPhotos, allowsVideos) {
            case (true, false):
                return NSLocalizedString("Take a Photo",
                                         tableName: "Localizable",
                                         bundle: .core,
                                         value: "",
                                         comment: "Take a photo submission choice")
            case (false, true):
                return NSLocalizedString("Take a Video",
                                         tableName: "Localizable",
                                         bundle: .core,
                                         value: "",
                                         comment: "Take a video submission choice")
            case (true, true):
                return NSLocalizedString("Take Photo or Video",
                                         tableName: "Localizable",
                                         bundle: .core,
                                         value: "",
                                         comment: "Take a photo or video submission choice")
            case (false, false):
                fatalError("Should be one or the other or both")
            }
        case let .photoLibrary(allowsPhotos: allowsPhotos, allowsVideos: allowsVideos):
            switch (allowsPhotos, allowsVideos) {
            case (true, false):
                return NSLocalizedString("Choose a Photo",
                                         tableName: "Localizable",
                                         bundle: .core,
                                         value: "",
                                         comment: "Pick a photo from library")
            case (false, true):
                return NSLocalizedString("Choose a Video",
                                         tableName: "Localizable",
                                         bundle: .core,
                                         value: "",
                                         comment: "Pick a video from library")
            case (true, true):
                return NSLocalizedString("Choose a Photo or Video",
                                         tableName: "Localizable",
                                         bundle: .core,
                                         value: "",
                                         comment: "Pick a photo or video")
            case (false, false):
                fatalError("Should be one or the other or both")
            }
        }
    }

    public var icon: UIImage {
        switch self {
        case .camera:
            return .FileKitImageNamed("icon_camera")
        case .photoLibrary:
            return .FileKitImageNamed("icon_cameraroll")
        case .recordAudio:
            return .FileKitImageNamed("icon_audio")
        }
    }
}
