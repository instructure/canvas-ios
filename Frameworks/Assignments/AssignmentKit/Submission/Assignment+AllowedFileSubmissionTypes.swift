//
//  Assignment+AllowedFileSubmissionTypes.swift
//  Assignments
//
//  Created by Derrick Hathaway on 12/2/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import Foundation

import MobileCoreServices

extension Assignment {
    // these are the allowed file types
    public var allowedSubmissionUTIs: [String] {
        var utis: [String] = []
        
        var startDotStar = false
        
        if submissionTypes.contains(.Upload) {
            if allowedExtensions?.count > 0 {
                utis += (allowedExtensions ?? []).map(toUTI)
            } else {
                startDotStar = true
                utis = [kUTTypeItem as String]
            }
        }
        
        if !startDotStar && submissionTypes.contains(.MediaRecording) {
            utis += [kUTTypeMovie as String, kUTTypeAudio as String]
        }

        if submissionTypes.contains(.Text) {
            utis += [kUTTypeText as String]
        }

        if submissionTypes.contains(.URL) {
            utis += [kUTTypeURL as String]
        }

        return utis
    }

    public var allowsAllFiles: Bool {
        return allowedSubmissionUTIs.contains(kUTTypeItem as String)
    }
    
    public var allowsPhotos: Bool {
        return allowsAllFiles || allowedSubmissionUTIs.filter(isUTIPhoto).count > 0
    }
    
    public var allowsVideo: Bool {
        return allowsAllFiles || allowedSubmissionUTIs.filter(isUTIVideo).count > 0
    }
    
    public var allowsAudio: Bool {
        return allowsAllFiles || allowedSubmissionUTIs.filter(isUTIAudio).count > 0
    }
    
    public var allowedImagePickerControllerMediaTypes: [String] {
        let images =  allowsPhotos ? [kUTTypeImage as String] : []
        let video = allowsVideo ? [kUTTypeMovie as String] : []
        
        return images + video
    }
}


private func toUTI(ext: String) -> String {
    print(UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil))
    let cfUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)
        .map { $0.takeRetainedValue() }
        .map { $0 as String }
    
    return cfUTI ?? ""
}

private func isUTIVideo(uti: String) -> Bool {
    return UTTypeConformsTo(uti as CFString, kUTTypeMovie)
}

private func isUTIPhoto(uti: String) -> Bool {
    return UTTypeConformsTo(uti as CFString, kUTTypeImage)
}

private func isUTIAudio(uti: String) -> Bool {
    return UTTypeConformsTo(uti as CFString, kUTTypeAudio)
}

