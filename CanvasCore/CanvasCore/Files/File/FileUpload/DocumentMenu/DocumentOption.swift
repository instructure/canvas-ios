//
// Copyright (C) 2017-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
