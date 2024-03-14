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
import CoreVideo
import UIKit

public protocol VideoStreamDelegate: AnyObject {
    func videoCapture(_ capture: VideoStream, didCaptureVideoFrame: CVPixelBuffer?)
}

public class VideoStream: NSObject {
    public var previewLayer: AVCaptureVideoPreviewLayer?

    // MARK: - Dependencies

    private let sessionPreset: AVCaptureSession.Preset
    private let delegate: VideoStreamDelegate
    private let queue: DispatchQueue

    // MARK: - Private properties

    private let fps = 15
    private var lastTimestamp = CMTime()
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let photoOutput = AVCapturePhotoOutput()

    // MARK: - Init

    init(
        sessionPreset: AVCaptureSession.Preset = .hd1920x1080,
        delegate: VideoStreamDelegate,
        queue: DispatchQueue = DispatchQueue(label: "com.instructure.icanvas.video-stream-queue")
    ) {
        self.sessionPreset = sessionPreset
        self.delegate = delegate
        self.queue = queue
        super.init()
        configureSession()
    }

    private func configureSession() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = sessionPreset

        guard let captureDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ) else {
            print("VideoStream | AVCaptureDevice initialization failed.")
            return
        }

        guard let videoInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            print("VideoStream | AVCaptureDeviceInput initialization failed.")
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        previewLayer.connection?.videoOrientation = .portrait
        self.previewLayer = previewLayer

        let settings: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA),
        ]

        videoOutput.videoSettings = settings
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        videoOutput.connection(with: AVMediaType.video)?.videoOrientation = .portrait

        captureSession.commitConfiguration()
    }

    public func start() {
        queue.async { [weak self] in
            if self?.captureSession.isRunning == false {
                self?.captureSession.startRunning()
            }
        }
    }

    public func stop() {
        queue.async { [weak self] in
            if self?.captureSession.isRunning == true {
                self?.captureSession.stopRunning()
            }
        }
    }

    public func capturePhoto(with settings: AVCapturePhotoSettings, delegate: AVCapturePhotoCaptureDelegate) {
        photoOutput.capturePhoto(with: settings, delegate: delegate)
    }
}

extension VideoStream: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(
        _: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from _: AVCaptureConnection
    ) {
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let deltaTime = timestamp - lastTimestamp
        if deltaTime >= CMTimeMake(value: 1, timescale: Int32(fps)) {
            lastTimestamp = timestamp
            let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            delegate.videoCapture(self, didCaptureVideoFrame: imageBuffer)
        }
    }

    public func captureOutput(_: AVCaptureOutput, didDrop _: CMSampleBuffer, from _: AVCaptureConnection) {}
}
