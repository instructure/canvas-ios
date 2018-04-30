//
//  LTIViewController.swift
//  CanvasCore
//
//  Created by Derrick Hathaway on 11/7/17.
//  Copyright © 2017 Instructure, Inc. All rights reserved.
//

import Foundation
import UIKit
import Marshal
import SafariServices

public class LTIViewController: UIViewController {
    public let toolName: String
    public let courseID: String?
    public let launchURL: URL
    public let session: Session
    public let fallbackURL: URL?

    var spinner: UIActivityIndicatorView!
    var button: UIButton!

    public convenience init(toolName: String, courseID: String?, launchURL: URL, in session: Session) {
        self.init(toolName: toolName, courseID: courseID, launchURL: launchURL, in: session, fallbackURL: nil)
    }
    
    public init(toolName: String, courseID: String?, launchURL: URL, in session: Session, fallbackURL: URL? = nil) {
        self.toolName = toolName
        self.courseID = courseID
        self.launchURL = launchURL
        self.session = session
        self.fallbackURL = fallbackURL

        super.init(nibName: nil, bundle: nil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        button = UIButton(type: .system)
        button.setTitleColor(Brand.current.primaryButtonTextColor, for: .normal)
        button.backgroundColor = Brand.current.primaryButtonColor
        button.setTitle(NSLocalizedString("Launch External Tool", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(launch), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        button.sizeToFit()
        view.addSubview(button)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        ])

        spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: spinner, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: spinner, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        ])
    }

    func launch() {
        showLoading(true)
        let presentingVC = navigationController ?? self
        ExternalToolManager.shared.launch(launchURL, in: session, from: presentingVC, fallbackURL: fallbackURL) { [weak self] in
            self?.showLoading(false)
        }
    }

    func showLoading(_ loading: Bool) {
        loading ? spinner.startAnimating() : spinner.stopAnimating()
        button.isHidden = loading
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("not supported")
    }
}
