//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

class LoginStartViewController: UIViewController {
    @IBOutlet weak var authenticationMethodLabel: UILabel!
    @IBOutlet weak var canvasNetworkButton: UIButton!
    @IBOutlet weak var findSchoolButton: DynamicButton!
    @IBOutlet weak var lastLoginButton: UIButton!
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var wordmark: UIImageView!
    @IBOutlet weak var previousLoginsLabel: UILabel!
    @IBOutlet weak var previousLoginsTableView: UITableView!
    @IBOutlet weak var previousLoginsView: UIView!
    @IBOutlet weak var whatsNewContainer: UIView!
    @IBOutlet weak var whatsNewLabel: UILabel!
    @IBOutlet weak var whatsNewLink: UIButton!
    @IBOutlet weak var useQRCodeButton: UIButton!
    @IBOutlet weak var useQRCodeDivider: UIView!

    @IBOutlet weak var animatableLogo: UIImageView!
    @IBOutlet weak var animatableLogoPosX: NSLayoutConstraint!
    @IBOutlet weak var animatableLogoPosY: NSLayoutConstraint!
    @IBOutlet weak var loginTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var previousLoginsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var qrLoginStackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonStackViewCenterYConstraint: NSLayoutConstraint!
    private var originalButtonStackViewCenterYConstraint: NSLayoutConstraint!
    private var offlineModeInteractor: OfflineModeInteractor?

    let env = AppEnvironment.shared
    weak var loginDelegate: LoginDelegate?
    var mdmObservation: NSKeyValueObservation?
    var method = AuthenticationMethod.normalLogin
    var sessions: [LoginSession] = []
    var shouldAnimateFromLaunchScreen = false
    var app: App = .student
    var lastLoginAccount: APIAccountResult? {
        didSet {
            lastLoginButton.isHidden = lastLoginAccount == nil
            guard let lastLoginAccount = lastLoginAccount else { return }
            let buttonTitle = lastLoginAccount.name.isEmpty ? lastLoginAccount.domain : lastLoginAccount.name
            lastLoginButton.setTitle(buttonTitle, for: .normal)
            alternateFindSchoolButton()
        }
    }

    static func create(loginDelegate: LoginDelegate?,
                       fromLaunch: Bool,
                       app: App,
                       offlineModeInteractor: OfflineModeInteractor
    ) -> LoginStartViewController {
        let controller = loadFromStoryboard()
        controller.loginDelegate = loginDelegate
        controller.shouldAnimateFromLaunchScreen = fromLaunch
        controller.app = app
        controller.offlineModeInteractor = offlineModeInteractor
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .backgroundLightest

        if let findSchoolButtonTitle = loginDelegate?.findSchoolButtonTitle {
            findSchoolButton.setTitle(findSchoolButtonTitle, for: .normal)
        }
        authenticationMethodLabel.isHidden = true
        animatableLogo.tintColor = .currentLogoColor()
        previousLoginsView.isHidden = true
        self.lastLoginAccount = nil
        previousLoginsLabel.text = String(localized: "Previous Logins", bundle: .core)
        whatsNewLabel.text = String(localized: "We've made a few changes.", bundle: .core)
        whatsNewLink.setTitle(String(localized: "See what's new.", bundle: .core), for: .normal)
        useQRCodeButton.setTitle(String(localized: "QR Login", bundle: .core), for: .normal)
        whatsNewContainer.isHidden = loginDelegate?.whatsNewURL == nil

        switch self.app {
        case .parent:
            logoView.image = UIImage(resource: .parentLogo)
            wordmark.image = UIImage(resource: .parentWordmark)
            logoView.superview?.accessibilityLabel = "Canvas Parent"
        case .teacher:
            logoView.image = UIImage(resource: .teacherLogo)
            wordmark.image = UIImage(resource: .teacherWordmark)
            logoView.superview?.accessibilityLabel = "Canvas Teacher"
        default:
            logoView.image = UIImage(resource: .studentLogo)
            wordmark.image = UIImage(resource: .studentWordmark)
            logoView.superview?.accessibilityLabel = "Canvas"
        }

        let loginText = String(localized: "Log In", bundle: .core)
        if MDMManager.shared.host != nil {
            findSchoolButton.isHidden = true
            lastLoginButton.setTitle(loginText, for: .normal)
            lastLoginButton.isHidden = false
        } else if let data = UserDefaults.standard.data(forKey: "lastLoginAccount"),
                    let savedAccount = try? APIJSONDecoder().decode(APIAccountResult.self, from: data) {
            lastLoginAccount = savedAccount
        }

        mdmObservation = MDMManager.shared.observe(\.loginsRaw, changeHandler: { [weak self] _, _ in
            self?.update()
        })

        NotificationCenter.default.addObserver(self, selector: #selector(userDefaultsDidChange(_:)), name: UserDefaults.didChangeNotification, object: nil)

        // iPhone SE (3rd gen) 
        if UIScreen.main.bounds.height <= 667 {
            qrLoginStackViewTopConstraint.constant = 16
        }

        // Store the original buttonStackViewCenterYConstraint so we can use it when the orientation changes
        originalButtonStackViewCenterYConstraint = buttonStackViewCenterYConstraint
        updateButtonStackViewLayout()

        update()
        refreshLogins()
    }

    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        updateButtonStackViewLayout()
    }

    // Center Buttons Vertically when orientation is landscape
    private func updateButtonStackViewLayout() {
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            buttonStackViewCenterYConstraint = originalButtonStackViewCenterYConstraint
            buttonStackViewCenterYConstraint.isActive = true
        default:
            buttonStackViewCenterYConstraint.isActive = false
        }
    }

    func configureButtons() {
        canvasNetworkButton.setTitle(String(localized: "Canvas Network", bundle: .core), for: .normal)
        canvasNetworkButton.isHidden = loginDelegate?.supportsCanvasNetwork == false || MDMManager.shared.host != nil
        useQRCodeDivider.isHidden = canvasNetworkButton.isHidden
    }

    @objc func userDefaultsDidChange(_ notification: Notification) {
        performUIUpdate { self.update() }
    }

    func refreshLogins() {
        for session in LoginSession.sessions {
            API(session).makeRequest(GetUserRequest(userID: session.userID)) { [weak self] (response, _, error) in performUIUpdate {
                guard let response = response, error == nil else { return }
                let entry = LoginSession(
                    accessToken: session.accessToken,
                    baseURL: session.baseURL,
                    expiresAt: session.expiresAt,
                    lastUsedAt: session.lastUsedAt,
                    locale: response.locale ?? response.effective_locale,
                    masquerader: session.masquerader,
                    refreshToken: session.refreshToken,
                    userAvatarURL: response.avatar_url?.rawValue,
                    userID: session.userID,
                    userName: response.short_name,
                    userEmail: response.email,
                    clientID: session.clientID,
                    clientSecret: session.clientSecret
                )
                if LoginSession.sessions.contains(entry) {
                    LoginSession.add(entry)
                }
                if AppEnvironment.shared.currentSession == entry {
                    AppEnvironment.shared.currentSession = entry
                }
                self?.update()
            } }
        }
    }

    func update() {
        sessions = LoginSession.sessions.sorted { a, b in a.lastUsedAt > b.lastUsedAt }
        previousLoginsView.isHidden = sessions.isEmpty && MDMManager.shared.logins.isEmpty
        previousLoginsTableView.reloadData()
        configureButtons()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        prepareForAnimation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateLogoFromCenterToFinalPosition()
    }

    // MARK: - Animation

    private func prepareForAnimation() {
        guard shouldAnimateFromLaunchScreen else { return }

        for view in view.subviews {
            view.alpha = 0
        }
        animatableLogo.alpha = 1
        view.layoutIfNeeded()
    }

    private func animateLogoFromCenterToFinalPosition() {
        guard shouldAnimateFromLaunchScreen else { return }
        shouldAnimateFromLaunchScreen = false
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.75, delay: 0.25, animations: {
            let logoSizeHalf = self.logoView.frame.size.width / 2
            let logoCenter = self.logoView.convert(CGPoint(x: logoSizeHalf, y: logoSizeHalf), to: self.view)
            self.animatableLogoPosX.constant = logoCenter.x - self.view.frame.width / 2
            self.animatableLogoPosY.constant = logoCenter.y - self.view.frame.height / 2
            self.view.layoutIfNeeded()
        }, completion: fadeIn)
    }

    func fadeIn(_ completed: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
            for view in self.view.subviews {
                view.alpha = 1
            }
        }, completion: { _ in
            self.animatableLogo.alpha = 0
        })
    }

    // MARK: - User Actions

    @IBAction func canvasNetworkTapped(_ sender: UIButton) {
        guard isNetworkOnline() else { return }
        let controller = LoginWebViewController.create(host: "learn.canvas.net", loginDelegate: loginDelegate, method: method)
        env.router.show(controller, from: self)
    }

    @IBAction func findTapped(_ sender: UIButton) {
        guard isNetworkOnline() else { return }
        let controller: UIViewController = LoginFindSchoolViewController.create(loginDelegate: loginDelegate, method: method)
        env.router.show(controller, from: self, analyticsRoute: "/login/find")
    }

    @IBAction func lastLoginTapped(_ sender: UIButton) {
        guard isNetworkOnline() else { return }
        var controller: UIViewController = LoginFindSchoolViewController.create(loginDelegate: loginDelegate, method: method)
        var analyticsRoute = "/login/find"

        if let host = MDMManager.shared.host {
            let provider = MDMManager.shared.authenticationProvider
            if method == .manualOAuthLogin {
                controller = LoginManualOAuthViewController.create(
                    authenticationProvider: provider,
                    host: host,
                    loginDelegate: loginDelegate
                )
                analyticsRoute = "/login/manualoauth"
            } else {
                controller = LoginWebViewController.create(
                    authenticationProvider: provider,
                    host: host,
                    loginDelegate: loginDelegate,
                    method: method
                )
                analyticsRoute = "/login/weblogin"
            }
        } else if let host = lastLoginAccount?.domain {
            controller = LoginWebViewController.create(
                authenticationProvider: lastLoginAccount?.authentication_provider,
                host: host,
                loginDelegate: loginDelegate,
                method: method
            )
            analyticsRoute = "/login/weblogin"
        }

        env.router.show(controller, from: self, analyticsRoute: analyticsRoute)
    }

    @IBAction func scanQRCode(_ sender: UIButton) {
        guard isNetworkOnline() else { return }
        if app == .parent {
            let sheet = BottomSheetPickerViewController.create()
            sheet.addAction(image: nil, title: String(localized: "I have a Canvas account", bundle: .core)) { [weak self] in
                self?.showLoginQRCodeTutorial()
            }
            sheet.addAction(
                image: nil,
                title: String(localized: "I don't have a Canvas account", bundle: .core),
                accessibilityIdentifier: "LoginStart.dontHaveAccountAction"
            ) { [weak self] in
                self?.showInstructionsToPairFromStudentApp()
            }
            env.router.show(sheet, from: self, options: .modal())
        } else {
            showLoginQRCodeTutorial()
        }
    }

    @IBAction func whatsNewTapped(_ sender: UIButton) {
        guard let url = loginDelegate?.whatsNewURL, isNetworkOnline() else { return }
        loginDelegate?.openExternalURL(url)
    }

    @IBAction func authMethodTapped(_ sender: UIView) {
        switch method {
        case .normalLogin:
            method = .canvasLogin
            authenticationMethodLabel.text = String(localized: "Canvas Login", bundle: .core)
        case .canvasLogin:
            method = .siteAdminLogin
            authenticationMethodLabel.text = String(localized: "Site Admin Login", bundle: .core)
        case .siteAdminLogin:
            method = .manualOAuthLogin
            authenticationMethodLabel.text = String(localized: "Manual OAuth Login", bundle: .core)
        case .manualOAuthLogin:
            method = .normalLogin
            authenticationMethodLabel.text = nil
        }
        authenticationMethodLabel.isHidden = authenticationMethodLabel.text == nil
    }

    // MARK: - Private Methods

    func showInstructionsToPairFromStudentApp() {
        let tutorial = PairWithStudentQRCodeTutorialViewController.create()
        tutorial.delegate = self
        env.router.show(tutorial, from: self, options: .modal(embedInNav: true))
    }

    func showLoginQRCodeTutorial() {
        Analytics.shared.logEvent("qr_code_login_clicked")
        let tutorial = LoginQRCodeTutorialViewController.create()
        tutorial.delegate = self
        env.router.show(tutorial, from: self, options: .modal(embedInNav: true), analyticsRoute: "/login/qr/tutorial")
    }

    func launchQRScanner() {
        let scanner = ScannerViewController()
        scanner.delegate = self
        self.env.router.show(scanner, from: self, options: .modal(.fullScreen), analyticsRoute: "/login/qr")
    }

    func logIn(withCode code: String) {
        guard let url = URL(string: code), let login = GetSSOLogin(url: url, app: app) else {
            showQRCodeError()
            return
        }
        var cancelled = false
        let loading = UIAlertController(
            title: String(localized: "Logging you in", bundle: .core),
            message: String(localized: "Please wait, this might take a minute.", bundle: .core),
            preferredStyle: .alert
        )
        loading.addAction(UIAlertAction(
            title: String(localized: "Cancel", bundle: .core),
            style: .cancel,
            handler: { _ in cancelled = true }
        ))
        env.router.show(loading, from: self) {
            login.fetch { [weak self, weak loading] session, error in
                if cancelled { return }
                guard let session = session, error == nil else {
                    loading?.dismiss(animated: true) {
                        self?.showQRCodeError()
                        RemoteLogger.shared.logError(name: "QR code login failed", reason: error?.localizedDescription)
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

    func showQRCodeError() {
        Analytics.shared.logEvent("qr_code_login_failure")
        showAlert(
            title: String(localized: "Login Error", bundle: .core),
            message: String(localized: "Please generate another QR Code and try again.", bundle: .core)
        )
    }

    private func alternateFindSchoolButton() {
        findSchoolButton.setTitle(String(localized: "Find another school", bundle: .core), for: .normal)
        findSchoolButton.backgroundColorName = "backgroundLightest"
        findSchoolButton.textColorName = "textDarkest"
        findSchoolButton.borderColorName = "borderDarkest"
    }

    private func animatePreviousLoginsHeightChange(numberOfItems: Int) {
        switch numberOfItems {
        case 0:
            previousLoginsHeightConstraint.constant = 0
        case 1:
            previousLoginsHeightConstraint.constant = 80
        default:
            previousLoginsHeightConstraint.constant = 140
        }
        view.setNeedsUpdateConstraints()

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    private func isNetworkOnline() -> Bool {
        guard let offlineModeInteractor = offlineModeInteractor, offlineModeInteractor.isNetworkOffline() else { return true }
        UIAlertController.showItemNotAvailableInOfflineAlert()
        return false
    }
}

extension LoginStartViewController: UITableViewDataSource, UITableViewDelegate, LoginStartSessionDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = sessions.count + MDMManager.shared.logins.count
        animatePreviousLoginsHeightChange(numberOfItems: count)
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < sessions.count {
            let cell: LoginStartSessionCell = tableView.dequeue(for: indexPath)
            cell.update(entry: sessions[indexPath.row], delegate: self)
            return cell
        }

        let cell: LoginStartMDMLoginCell = tableView.dequeue(for: indexPath)
        cell.update(login: MDMManager.shared.logins[indexPath.row - sessions.count])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < sessions.count {
            env.router.show(LoadingViewController.create(), from: self)
            loginDelegate?.userDidLogin(session: sessions[indexPath.row].bumpLastUsedAt())
            return
        }

        let login = MDMManager.shared.logins[indexPath.row - sessions.count]
        let controller = LoginWebViewController.create(
            authenticationProvider: nil,
            host: login.host,
            mdmLogin: login,
            loginDelegate: loginDelegate,
            method: .canvasLogin
        )
        env.router.show(controller, from: self)
    }

    func removeSession(_ session: LoginSession) {
        guard let row = sessions.firstIndex(of: session) else { return }
        sessions.remove(at: row)
        previousLoginsTableView?.deleteRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
        loginDelegate?.userDidLogout(session: session)
        if sessions.isEmpty && MDMManager.shared.logins.isEmpty {
            UIView.animate(withDuration: 0.5) {
                self.previousLoginsView.alpha = 0
            }
        }
    }
}

extension LoginStartViewController: ScannerDelegate, ErrorViewController {
    func scanner(_ scanner: ScannerViewController, didScanCode code: String) {
        env.router.dismiss(scanner) {
            if let url = URL(string: code),
                let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                let host = components.host,
                components.path == "/pair",
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

extension LoginStartViewController: LoginQRCodeTutorialDelegate {
    func loginQRCodeTutorialDidFinish(_ controller: LoginQRCodeTutorialViewController) {
        env.router.dismiss(controller) {
            self.launchQRScanner()
        }
    }
}

extension LoginStartViewController: PairWithStudentQRCodeTutorialDelegate {
    func pairWithStudentQRCodeTutorialDidFinish(_ controller: PairWithStudentQRCodeTutorialViewController) {
        env.router.dismiss(controller) {
            self.launchQRScanner()
        }
    }
}

extension UIWindow {

    public var isShowingLoginStartViewController: Bool {
        guard
            let rootViewController = rootViewController as? LoginNavigationController
        else {
            return false
        }

        return rootViewController.topViewController is LoginStartViewController
    }
}
