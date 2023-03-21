//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import UIKit

public protocol ScannerDelegate: AnyObject {
    func scanner(_ scanner: ScannerViewController, didScanCode code: String)
}

public class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    public weak var delegate: ScannerDelegate?

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return failed()
        }

        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return failed()
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return failed()
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return failed()
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        updateCameraPreviewOrientation()
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        let guide = QROverlayView()
        guide.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(guide)
        NSLayoutConstraint.activate([
            guide.widthAnchor.constraint(equalToConstant: 225),
            guide.heightAnchor.constraint(equalToConstant: 225),
            guide.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            guide.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])

        let promptContainer = UIView()
        promptContainer.translatesAutoresizingMaskIntoConstraints = false
        promptContainer.backgroundColor = UIColor.backgroundDarkest.withAlphaComponent(0.9)
        promptContainer.layer.cornerRadius = 8
        view.addSubview(promptContainer)
        let topPromptConstraint = promptContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80)
        topPromptConstraint.priority = .defaultLow
        NSLayoutConstraint.activate([
            promptContainer.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            // To prevent getting in front of the guide in landscape mode
            promptContainer.bottomAnchor.constraint(lessThanOrEqualTo: guide.topAnchor, constant: -15),
            topPromptConstraint,
        ])

        let prompt = UILabel()
        prompt.text = NSLocalizedString("Find a code to scan", bundle: .core, comment: "")
        prompt.font = .scaledNamedFont(.semibold16)
        prompt.textColor = .textLightest
        promptContainer.addSubview(prompt)
        prompt.pin(inside: promptContainer, leading: 16, trailing: 16, top: 16, bottom: 16)

        let cancel = UIButton()
        cancel.translatesAutoresizingMaskIntoConstraints = false
        cancel.backgroundColor = UIColor.backgroundDarkest.withAlphaComponent(0.9)
        cancel.setImage(UIImage.xLine, for: .normal)
        cancel.tintColor = .textLightest
        cancel.addTarget(self, action: #selector(cancelTapped(_:)), for: .primaryActionTriggered)
        cancel.layer.cornerRadius = 25
        view.addSubview(cancel)
        let cancelBottomConstraint = cancel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80)
        cancelBottomConstraint.priority = .defaultLow
        NSLayoutConstraint.activate([
            cancel.widthAnchor.constraint(equalToConstant: 50),
            cancel.heightAnchor.constraint(equalToConstant: 50),
            cancel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            // To prevent getting in front of the guide in landscape mode
            cancel.topAnchor.constraint(greaterThanOrEqualTo: guide.bottomAnchor, constant: 10),
            cancelBottomConstraint,
        ])

        // startRunning is blocking until the camera wakes up so
        // in order not to block the UI we start the session on a background thread
        DispatchQueue.global().async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    func failed() {
        let alert = UIAlertController(
            title: NSLocalizedString("Scanning not supported", bundle: .core, comment: ""),
            message: NSLocalizedString("Make sure you enable camera permissions in Settings", bundle: .core, comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", bundle: .core, comment: ""), style: .default) { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.present(alert, animated: true)
        }
        captureSession = nil
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if ProcessInfo.isUITest, let code = ProcessInfo.processInfo.environment["QR_CODE"] {
            found(code: code)
        }
    }

    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            captureSession.stopRunning()
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
    }

    func found(code: String) {
        delegate?.scanner(self, didScanCode: code)
    }

    public override var prefersStatusBarHidden: Bool {
        return true
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCameraPreviewOrientation()
    }

    @objc func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    private func updateCameraPreviewOrientation() {

        var orientation: UIDeviceOrientation
        let supportedOrientations = Bundle.main.infoDictionary?["UISupportedInterfaceOrientations"] as? [String]
        if supportedOrientations?.count == 1,
            supportedOrientations?.first?.contains("UIInterfaceOrientationPortrait") != nil {
            orientation = .portrait
        } else {
            orientation = UIDevice.current.orientation
        }

        guard
            let previewLayer = previewLayer,
            let connection = previewLayer.connection,
            connection.isVideoOrientationSupported,
            let videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue)
        else { return }

        previewLayer.frame = view.layer.bounds
        connection.videoOrientation = videoOrientation
    }
}

class QROverlayView: UIView {
    let arc = CAShapeLayer()
    var curveLength: CGFloat = 50

    override init(frame: CGRect) {
        super.init(frame: frame)
        arc.lineWidth = 8
        arc.fillColor = UIColor.clear.cgColor
        arc.strokeColor = UIColor.borderLightest.cgColor
        arc.lineCap = .round
        layer.addSublayer(arc)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()

        // top left
        path.move(to: CGPoint(x: 0, y: curveLength))
        path.addQuadCurve(to: CGPoint(x: curveLength, y: 0), controlPoint: CGPoint(x: 0, y: 0))

        // top right
        path.move(to: CGPoint(x: rect.width - curveLength, y: 0))
        path.addQuadCurve(to: CGPoint(x: rect.width, y: curveLength), controlPoint: CGPoint(x: rect.width, y: 0))

        // bottom right
        path.move(to: CGPoint(x: rect.width, y: rect.height - curveLength))
        path.addQuadCurve(to: CGPoint(x: rect.width - curveLength, y: rect.height), controlPoint: CGPoint(x: rect.width, y: rect.height))

        // bottom left
        path.move(to: CGPoint(x: curveLength, y: rect.height))
        path.addQuadCurve(to: CGPoint(x: 0, y: rect.height - curveLength), controlPoint: CGPoint(x: 0, y: rect.height))

        arc.path = path.cgPath
    }
}
