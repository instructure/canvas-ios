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
import CoreMedia
import UIKit
import Vision

public protocol TextRecognizerViewControllerDelegate: AnyObject {
    func didFinishTextScanning(_ string: String)
}

public class TextRecognizerViewController: UIViewController {
    // MARK: - Public properties

    public weak var delegate: TextRecognizerViewControllerDelegate?

    // MARK: - Views

    private var videoStreamContainerView = UIView(frame: .zero)
    private var boundingBoxOverlayView = BoundingBoxOverlayView(frame: .zero)
    private var tipOverlayView = TextRecognizerTipOverlayView()
    private var videoStream: VideoStream!

    // MARK: - Vision requests

    private lazy var textRecognizer = TextRecognizer(cameraLayer: &videoStream.previewLayer, analysisDidComplete: textRecognitionDidFinish)
    private lazy var textRectangleDetector = TextRectangleDetector(analysisDidComplete: updateBoundingBoxes)

    // MARK: - Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupVideoStream()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Scan",
            style: .plain,
            target: self,
            action: #selector(capturePhotoButtonDidTap)
        )
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        videoStream.start()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tipOverlayView.animate()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoStream.stop()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tipOverlayView.resetAnimation()
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resizePreviewLayer()
    }

    private func setupViews() {
        view.backgroundColor = .backgroundLightest
        view.addSubview(videoStreamContainerView)
        videoStreamContainerView.backgroundColor = .backgroundLightest
        videoStreamContainerView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(boundingBoxOverlayView)
        boundingBoxOverlayView.translatesAutoresizingMaskIntoConstraints = false
        boundingBoxOverlayView.backgroundColor = .clear

        view.addSubview(tipOverlayView)
        tipOverlayView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            videoStreamContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            videoStreamContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoStreamContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoStreamContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            boundingBoxOverlayView.topAnchor.constraint(equalTo: videoStreamContainerView.topAnchor),
            boundingBoxOverlayView.leadingAnchor.constraint(equalTo: videoStreamContainerView.leadingAnchor),
            boundingBoxOverlayView.trailingAnchor.constraint(equalTo: videoStreamContainerView.trailingAnchor),
            boundingBoxOverlayView.bottomAnchor.constraint(equalTo: videoStreamContainerView.bottomAnchor),

            tipOverlayView.topAnchor.constraint(equalTo: videoStreamContainerView.topAnchor),
            tipOverlayView.leadingAnchor.constraint(equalTo: videoStreamContainerView.leadingAnchor),
            tipOverlayView.trailingAnchor.constraint(equalTo: videoStreamContainerView.trailingAnchor),
            tipOverlayView.bottomAnchor.constraint(equalTo: videoStreamContainerView.bottomAnchor),
        ])
    }

    @objc private func capturePhotoButtonDidTap() {
        videoStream.capturePhoto(with: AVCapturePhotoSettings(), delegate: textRecognizer)
    }

    private func setupVideoStream() {
        videoStream = VideoStream(
            sessionPreset: .hd4K3840x2160,
            delegate: self
        )

        if let previewLayer = videoStream.previewLayer {
            videoStreamContainerView.layer.addSublayer(previewLayer)
            resizePreviewLayer()
        }

        videoStream.start()
    }

    private func resizePreviewLayer() {
        videoStream.previewLayer?.frame = videoStreamContainerView.bounds
    }

    private func updateBoundingBoxes(_ regions: [VNTextObservation?]?) {
        boundingBoxOverlayView.regions = regions
    }

    private func textRecognitionDidFinish(_ strings: [String]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.didFinishTextScanning(strings.joined(separator: "<br>"))
            AppEnvironment.shared.router.pop(from: self)
        }
    }
}

// MARK: - VideoStreamDelegate

extension TextRecognizerViewController: VideoStreamDelegate {
    public func videoCapture(_: VideoStream, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?) {
        if let pixelBuffer = pixelBuffer {
            textRectangleDetector.processImage(pixelBuffer: pixelBuffer)
        }
    }
}
