//
//  Client.swift
//  CanvasKeymaster2
//
//  Created by Garrett Richards on 8/2/18.
//  Copyright © 2018 Instructure. All rights reserved.
//

import Foundation
import WebKit

public enum AuthenticationMethod {
    case defaultMethod
    case forcedCanvasLogin
    case siteAdmin
}

protocol LoginViewProtocol: class {
    func didConstructAuthenticationRequest(_ request: URLRequest)
    func userDidLogin(auth: APIOAuthToken)
}

class LoginPresenter {
    var mobileVerifyModel: APIVerifyClient?
    var authenticationProvider = ""
    var host = ""
    var session: URLSession = URLSession.shared
    private var operationQueue = OperationQueue()
    weak var view: (LoginViewProtocol & ErrorViewController)?

    init(host: String) {
        self.host = host
    }

    deinit {
        operationQueue.cancelAllOperations()
    }

    func constructAuthenticationRequest(method: AuthenticationMethod) {
        let params = LoginParams(host: host, authenticationProvider: authenticationProvider, method: method)
        let op = ConstructLoginRequest(params: params, urlSession: session)
        op.completionBlock = { [weak op, weak self] in
            self?.mobileVerifyModel = op?.mobileVerify
            if let request = op?.request {
                DispatchQueue.main.async {
                    self?.view?.didConstructAuthenticationRequest(request)
                }
            }
        }

        operationQueue.addOperation(op)
    }

    static func prepLoginRequest(_ toRequest: URLRequest?, method: AuthenticationMethod) -> URLRequest {
        var req = toRequest ?? URLRequest(url: URL(string: "localhost")!)
        req.setValue(UserAgent.safari.description, forHTTPHeaderField: HttpHeader.userAgent)
        return req
    }

    func navigationActionPolicyForUrl(url: URL) -> WKNavigationActionPolicy {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return .allow
        }

        let queryItems = components.queryItems

        if ((components.host ?? "").contains("community.canvaslms.com")) {
            UIApplication.shared.open(url, options: [:]) { (_) in }
            return .cancel
        }

        if (components.scheme == "about" && components.path == "blank") {
            return .cancel
        }

        // I dunno why, but we have to wait for the code to be the first param cuz it can keep changing as we follow redirects
        //  "/canvas/login?code="
        if let code = codeFromQueryItems(queryItems), let mobileVerify = mobileVerifyModel {
            let getAuthToken = GetAuthToken(api: URLSessionAPI(urlSession: session), mobileVerify: mobileVerify, code: code)
            getAuthToken.completionBlock = { [weak self] in
                if let model = getAuthToken.response {
                    DispatchQueue.main.async {
                        self?.view?.userDidLogin(auth: model)
                    }
                }
                if let error = getAuthToken.error as NSError? {
                    DispatchQueue.main.async {
                        self?.view?.showError(error)
                    }
                }
            }
            operationQueue.addOperation(getAuthToken)

            return .cancel
        } else if queryItems?.first(where: { $0.name == "error" }) != nil {
            let error = NSError.instructureError(NSLocalizedString("Authentication failed. Most likely the user denied the request for access.", comment: ""))
            self.view?.showError(error)
            return .cancel
        }
        return .allow
    }

    private func codeFromQueryItems(_ queryItems: [URLQueryItem]?) -> String? {
        guard let firstItem = queryItems?.first else { return nil }
        guard let value = firstItem.value else { return nil }

        if firstItem.name == "code" && !value.isEmpty {
            return value
        }
        return nil
    }
}

struct LoginParams {
    var host = ""
    var authenticationProvider = ""
    var method: AuthenticationMethod = .defaultMethod
}
