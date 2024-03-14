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
import Vision

class TextRectangleDetector {
    // MARK: - Dependencies

    private let analysisDidComplete: ([VNTextObservation?]?) -> Void

    // MARK: - Private properties

    private var request: VNDetectTextRectanglesRequest?

    // MARK: - Init

    init(analysisDidComplete: @escaping ([VNTextObservation?]?) -> Void) {
        self.analysisDidComplete = analysisDidComplete
        request = VNDetectTextRectanglesRequest(completionHandler: requestDidComplete)
        request?.reportCharacterBoxes = true
    }

    public func processImage(pixelBuffer: CVPixelBuffer) {
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        if let request = request {
            try? handler.perform([request])
        }
    }

    private func requestDidComplete(request: VNRequest, error _: Error?) {
        guard let observations = request.results else {
            return
        }
        let regions: [VNTextObservation?] = observations.map { $0 as? VNTextObservation }
        DispatchQueue.main.async { [weak self] in
            self?.analysisDidComplete(regions)
        }
    }
}
