//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

final class EDXLoginStartViewController: UIViewController {

    // MARK: - Properties -

    private var logoImageView: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(named: "edx_logo_splash")
        )
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let degreesImageView: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(named: "second_logo_splash_landscape")
        )
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var logInButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("Log In", bundle: .core, comment: ""), for: .normal)
        button.backgroundColor = .edxAcceptColor
        button.setTitleColor(
            UIColor(red: 0.00, green: 0.15, blue: 0.17, alpha: 1.00),
            for: .normal
        )
        button.layer.cornerRadius = 4
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        return button
    }()

    private var qrButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString(" QR Login", bundle: .core, comment: ""), for: .normal)
        button.setTitleColor(
            .edxAcceptColor,
            for: .normal
        )
        button.tintColor = .edxAcceptColor
        button.setImage(.qrCode, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()

    private var digitalcampusHost: String = "digitalcampus.test.instructure.com"
    let env = AppEnvironment.shared
    weak var loginDelegate: LoginDelegate?
    var app: App = .student

    private var views: [UIView] {
        [
            logInButton,
            qrButton,
            logoImageView,
            degreesImageView
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        views.forEach {
            $0.removeFromSuperview()
            view.addSubview($0)
        }
        layout()
        UIView.animate(withDuration: 0.15) {
            self.view.layoutIfNeeded()
        }
    }

    private func configure() {
        view.backgroundColor = .edxColor
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        logInButton.addTarget(self, action: #selector(onLogin), for: .touchUpInside)
        qrButton.addTarget(self, action: #selector(scanQRCode), for: .touchUpInside)

        layout()
    }

    private func layout() {
        let isLandscape = UIDevice.current.orientation.isLandscape
        let isPhone = UIDevice.current.userInterfaceIdiom == .phone
        if isPhone, isLandscape {
            logoImageView.widthAnchor.constraint(equalToConstant: 160).isActive = true
            logoImageView.heightAnchor.constraint(equalToConstant: 85).isActive = true
            logoImageView.topAnchor.constraint(equalTo: logInButton.topAnchor).isActive = true
            logoImageView.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -50).isActive = true

            degreesImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            degreesImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            degreesImageView.heightAnchor.constraint(equalToConstant: 128).isActive = true
            degreesImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
            degreesImageView.image = UIImage(named: "second_logo_splash_landscape")

            logInButton.widthAnchor.constraint(equalToConstant: 300).isActive = true
            logInButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            logInButton.bottomAnchor.constraint(equalTo: qrButton.topAnchor, constant: -15).isActive = true
            logInButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 50).isActive = true

            qrButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
            qrButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
            qrButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -35).isActive = true
            qrButton.centerXAnchor.constraint(equalTo: logInButton.centerXAnchor).isActive = true
        } else {
            logoImageView.widthAnchor.constraint(equalToConstant: 160).isActive = true
            logoImageView.heightAnchor.constraint(equalToConstant: 85).isActive = true
            logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 77).isActive = true
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

            degreesImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            degreesImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            degreesImageView.heightAnchor.constraint(equalToConstant: 128).isActive = true
            degreesImageView.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 40).isActive = true
            degreesImageView.image = UIImage(named: "second_logo_splash")

            logInButton.widthAnchor.constraint(equalToConstant: 300).isActive = true
            logInButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            logInButton.bottomAnchor.constraint(equalTo: qrButton.topAnchor, constant: -15).isActive = true
            logInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

            qrButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
            qrButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
            qrButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -35).isActive = true
            qrButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        }
    }

    @objc
    private func onLogin(_ sender: UIButton) {
        let controller = LoginWebViewController.create(
            host: digitalcampusHost,
            loginDelegate: loginDelegate,
            method: .normalLogin
        )
        env.router.show(controller, from: self, analyticsRoute: "/login/weblogin")
    }

    @objc
    func scanQRCode(_ sender: UIButton) {
        showLoginQRCodeTutorial()
    }

    private func showLoginQRCodeTutorial() {
        Analytics.shared.logEvent("qr_code_login_clicked")
        let tutorial = LoginQRCodeTutorialViewController.create()
        tutorial.delegate = self
        env.router.show(tutorial, from: self, options: .modal(embedInNav: true), analyticsRoute: "/login/qr/tutorial")
    }

    private func launchQRScanner() {
        let scanner = ScannerViewController()
        scanner.delegate = self
        self.env.router.show(scanner, from: self, options: .modal(.fullScreen), analyticsRoute: "/login/qr")
    }

    private func logIn(withCode code: String) {
        guard let url = URL(string: code), let login = GetSSOLogin(url: url, app: app) else {
            showQRCodeError()
            return
        }
        var cancelled = false
        let loading = UIAlertController(
            title: NSLocalizedString("Logging you in", bundle: .core, comment: ""),
            message: NSLocalizedString("Please wait, this might take a minute.", bundle: .core, comment: ""),
            preferredStyle: .alert
        )
        loading.addAction(UIAlertAction(
            title: NSLocalizedString("Cancel", bundle: .core, comment: ""),
            style: .cancel,
            handler: { _ in cancelled = true }
        ))
        env.router.show(loading, from: self) {
            login.fetch { [weak self, weak loading] session, error in
                if cancelled { return }
                guard let session = session, error == nil else {
                    loading?.dismiss(animated: true) {
                        self?.showQRCodeError()
                    }
                    return
                }
                // don't dismiss loading here
                // it will eventually be dismissed once userDidLogin api calls are finished
                Analytics.shared.logEvent("qr_code_login_success")
                self?.loginDelegate?.userDidLogin(session: session)
            }
        }
    }

    private func showQRCodeError() {
        Analytics.shared.logEvent("qr_code_login_failure")
        showAlert(
            title: NSLocalizedString("Login Error", bundle: .core, comment: ""),
            message: NSLocalizedString("Please generate another QR Code and try again.", bundle: .core, comment: ""),
            actions: [
                UIAlertAction(
                    title: NSLocalizedString("Cancel", bundle: .core, comment: ""),
                    style: .cancel
                )
            ]
        )
    }

}

extension EDXLoginStartViewController: LoginQRCodeTutorialDelegate {
    func loginQRCodeTutorialDidFinish(_ controller: LoginQRCodeTutorialViewController) {
        env.router.dismiss(controller) {
            self.launchQRScanner()
        }
    }
}

extension EDXLoginStartViewController: PairWithStudentQRCodeTutorialDelegate {
    func pairWithStudentQRCodeTutorialDidFinish(_ controller: PairWithStudentQRCodeTutorialViewController) {
        env.router.dismiss(controller) {
            self.launchQRScanner()
        }
    }
}

extension EDXLoginStartViewController: ScannerDelegate, ErrorViewController {
    func scanner(_ scanner: ScannerViewController, didScanCode code: String) {
        env.router.dismiss(scanner) { [weak self] in
            guard let self = self else {
                return
            }
            guard let url = URL(string: code),
                  let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let host = components.host else {
                self.showQRCodeError()
                return
            }

            guard let queryItem = components.queryItems?.first(where: {$0.name == "domain"}), queryItem.value?.lowercased() == self.digitalcampusHost.lowercased() else {
                self.showQRCodeError()
                return
            }

            if  components.path == "/pair",
                let code = components.queryItems?.first(where: { $0.name == "code" })?.value {
                self.createAccount(host: host, pairingCode: code)
            } else {
                self.logIn(withCode: code)
            }
        }
    }

    func createAccount(host: String, pairingCode: String) {
        let login = LoginWebViewController.create(
            host: host,
            loginDelegate: loginDelegate,
            method: .canvasLogin,
            pairingCode: pairingCode
        )
        self.env.router.show(login, from: self)
    }
}
