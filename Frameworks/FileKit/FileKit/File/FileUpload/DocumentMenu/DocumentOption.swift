//
//  DocumentOption.swift
//  FileKit
//
//  Created by Nathan Armstrong on 1/26/17.
//  Copyright © 2017 Instructure. All rights reserved.
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
                                     bundle: .fileKit,
                                     value: "",
                                     comment: "Choose record audio submission")
        case let .camera(allowsPhotos: allowsPhotos, allowsVideos: allowsVideos):
            switch (allowsPhotos, allowsVideos) {
            case (true, false):
                return NSLocalizedString("Take a Photo",
                                         tableName: "Localizable",
                                         bundle: .fileKit,
                                         value: "",
                                         comment: "Take a photo submission choice")
            case (false, true):
                return NSLocalizedString("Take a Video",
                                         tableName: "Localizable",
                                         bundle: .fileKit,
                                         value: "",
                                         comment: "Take a video submission choice")
            case (true, true):
                return NSLocalizedString("Take Photo or Video",
                                         tableName: "Localizable",
                                         bundle: .fileKit,
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
                                         bundle: .fileKit,
                                         value: "",
                                         comment: "Pick a photo from library")
            case (false, true):
                return NSLocalizedString("Choose a Video",
                                         tableName: "Localizable",
                                         bundle: .fileKit,
                                         value: "",
                                         comment: "Pick a video from library")
            case (true, true):
                return NSLocalizedString("Choose a Photo or Video",
                                         tableName: "Localizable",
                                         bundle: .fileKit,
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
