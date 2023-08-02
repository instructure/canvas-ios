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

import UIKit

class PairWithObserverViewController: UIViewController, ErrorViewController {
    @IBOutlet weak var instructionsLabel: DynamicLabel!
    @IBOutlet weak var spinner: CircleProgressView!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var qrCodeContainer: UIView!
    @IBOutlet weak var qrCodePairingCodeLabel: DynamicLabel!
    var animating: Bool = false
    var didGenerateCode = false
    var pairingCode: String?

    let env = AppEnvironment.shared

    static func create() -> PairWithObserverViewController {
        return  loadFromStoryboard()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Pair with Observer", bundle: .core, comment: "")
        instructionsLabel.text = NSLocalizedString("Have your parent scan this QR code from the Canvas Parent app to pair with you.", comment: "")

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(actionShare(sender:)))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !didGenerateCode { generatePairingCode() }
    }

    func generatePairingCode() {
        didGenerateCode = true
        env.api.makeRequest(PostObserverPairingCodes()) { [weak self] response, _, error in
            performUIUpdate {
                if let error = error {
                    self?.spinner.isHidden = true
                    self?.showError(error)
                } else {
                    self?.generateQRCode(pairingCode: response?.code)
                }
            }
        }
    }

    func generateQRCode(pairingCode: String?) {
        env.api.makeRequest(GetAccountTermsOfServiceRequest()) { [weak self] (response, _, error) in performUIUpdate {
            self?.spinner.isHidden = true
            if let error = error {
                self?.showError(error)
            } else {
                self?.displayQR(pairingCode: pairingCode, accountID: response?.account_id.value, baseURL: self?.env.api.baseURL)
            }
        } }
    }

    func displayQR(pairingCode: String?, accountID: String?, baseURL: URL?) {
        guard
            let code = pairingCode,
            let accountID = accountID, // Android requires the account id
            let host = baseURL?.host
        else { return }

        self.pairingCode = pairingCode
        let comps = URLComponents(string: "canvas-parent://\(host)/pair?code=\(code)&account_id=\(accountID)")
        let input = comps?.url?.absoluteString ?? ""
        let data = input.data(using: String.Encoding.ascii)
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return }
        qrFilter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        guard let qrImage = qrFilter.outputImage?.transformed(by: transform) else { return }

        qrCodeImageView.image = UIImage(ciImage: qrImage)
        qrCodeImageView.accessibilityIdentifier = "QRCodeImage"
        qrCodeContainer.isHidden = false
        let attrStr = NSAttributedString(
            string: NSLocalizedString("Pairing Code: ", comment: ""),
            attributes: [
                NSAttributedString.Key.font: UIFont.scaledNamedFont(.regular20),
                NSAttributedString.Key.foregroundColor: UIColor.textDarkest,
            ]
        )

        let attrStr2 = NSAttributedString(
            string: pairingCode ?? "",
            attributes: [
                NSAttributedString.Key.font: UIFont.scaledNamedFont(.semibold20),
                NSAttributedString.Key.foregroundColor: UIColor.textDarkest,
            ]
        )
        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(attrStr)
        mutableAttributedString.append(attrStr2)

        qrCodePairingCodeLabel.attributedText = mutableAttributedString
        qrCodeContainer.layer.borderWidth = 1
        qrCodeContainer.layer.borderColor = UIColor.borderMedium.cgColor
        qrCodeContainer.layer.cornerRadius = 4
    }

    @objc func actionShare(sender: UIBarButtonItem) {
        guard let code = pairingCode, !code.isEmpty else { return }
        let template = NSLocalizedString("Use this code to pair with me in Canvas Parent: %@", bundle: .core, comment: "")
        let message = String.localizedStringWithFormat(template, code)
        let vc = CoreActivityViewController(activityItems: [message], applicationActivities: nil)
        let popover = vc.popoverPresentationController
        popover?.barButtonItem = sender
        env.router.show(vc, from: self, options: .modal(isDismissable: false, embedInNav: false, addDoneButton: false))
    }
}
