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

import AVFoundation
import Foundation
import Vision

class TextRecognizer: NSObject, AVCapturePhotoCaptureDelegate {
    // MARK: - Dependencies

    private let cameraLayer: AVCaptureVideoPreviewLayer?
    private let analysisDidComplete: ([String]) -> Void
    private let queue: DispatchQueue

    // MARK: - Private properties

    private var request: VNRecognizeTextRequest?
    private var photoData: Data?
    private var photoCgImage: CGImage?

    init(
        cameraLayer: inout AVCaptureVideoPreviewLayer?,
        analysisDidComplete: @escaping ([String]) -> Void,
        queue: DispatchQueue = DispatchQueue(label: "com.instructure.icanvas.text-recognizer-queue")
    ) {
        self.cameraLayer = cameraLayer
        self.analysisDidComplete = analysisDidComplete
        self.queue = queue
        super.init()
        request = VNRecognizeTextRequest(completionHandler: requestDidComplete)
        request?.recognitionLevel = .accurate
        request?.recognitionLanguages = ["en_US"]
    }

    private func processImage(data: Data?) {
        guard
            let data = data,
            let cgImage = UIImage(data: data)?.cgImage,
            let request = request
        else {
            return
        }
        var requests: [VNRequest] = []
        requests.append(request)
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .right, options: [:])
        queue.async {
            do {
                try requestHandler.perform(requests)
            } catch {
                print("TextRecognizer | VNImageRequestHandler error: \(error)")
            }
        }
    }

    private func requestDidComplete(request: VNRequest?, error: Error?) {
        if let error = error {
            print("TextRecognizer | VNRequest error: \(error)")
            return
        }
        guard let results = request?.results, results.count > 0 else {
            print("TextRecognizer | VNRequest no results.")
            return
        }

        var recognizedTexts = [String]()

        for result in results {
            if let observation = result as? VNRecognizedTextObservation {
                for text in observation.topCandidates(1) {
                    recognizedTexts.append(text.string)
                }
            }
        }
        analysisDidComplete(recognizedTexts)
    }

    func photoOutput(_: AVCapturePhotoOutput, willCapturePhotoFor _: AVCaptureResolvedPhotoSettings) {
        cameraLayer?.opacity = 0
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.cameraLayer?.opacity = 1
        }
    }

    func photoOutput(_: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("TextRecognizer | didFinishProcessingPhoto error: \(error)")
        } else {
            photoData = photo.fileDataRepresentation()
        }
    }

    func photoOutput(_: AVCapturePhotoOutput, didFinishCaptureFor _: AVCaptureResolvedPhotoSettings, error: Error?) {
        if let error = error {
            print("TextRecognizer | didFinishCaptureFor error: \(error)")
            return
        }

        processImage(data: photoData)
    }
}
