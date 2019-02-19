//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit
import PSPDFKit
import PSPDFKitUI

protocol DocViewerViewProtocol: ErrorViewController {
    func load(document: PSPDFDocument)
    func resetInk()
}

public class DocViewerViewController: UIViewController, DocViewerViewProtocol {
    @IBOutlet weak var contentView: UIView?
    @IBOutlet weak var loadingView: UIActivityIndicatorView?
    weak var pdfViewController: PSPDFViewController?
    var presenter: DocViewerPresenter?
    weak var parentNavigationItem: UINavigationItem?

    public static func setup(_ secret: Secret) {
        if let key = secret.string {
            PSPDFKit.setLicenseKey(key)
        }
        stylePSPDFKit()
    }

    public static func create(filename: String, previewURL: URL?, fallbackURL: URL, navigationItem: UINavigationItem? = nil, env: AppEnvironment = .shared) -> DocViewerViewController {
        let controller = Bundle.loadController(self)
        controller.parentNavigationItem = navigationItem
        controller.presenter = DocViewerPresenter(env: env, view: controller, filename: filename, previewURL: previewURL, fallbackURL: fallbackURL)
        return controller
    }

    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedPSPDFViewController", let controller = segue.destination as? PSPDFViewController {
            self.pdfViewController = controller
            controller.view?.isHidden = true
            controller.updateConfiguration(builder: docViewerConfigurationBuilder)
            controller.delegate = presenter
            let share = UIBarButtonItem(barButtonSystemItem: .action, target: controller.activityButtonItem.target, action: controller.activityButtonItem.action)
            share.accessibilityIdentifier = "DocViewer.shareButton"
            let search = UIBarButtonItem(barButtonSystemItem: .search, target: controller.searchButtonItem.target, action: controller.searchButtonItem.action)
            search.accessibilityIdentifier = "DocViewer.searchButton"
            parentNavigationItem?.rightBarButtonItems = [ share, search ]
        }
    }

    public override func viewDidLoad() {
        loadingView?.color = Brand.shared.primary.ensureContrast(against: .named(.backgroundLightest))
        presenter?.viewIsReady()
    }

    func load(document: PSPDFDocument) {
        pdfViewController?.document = document
        pdfViewController?.documentViewController?.scrollToSpread(at: 0, scrollPosition: .start, animated: false)
        pdfViewController?.view?.isHidden = false
        loadingView?.stopAnimating()
    }

    func resetInk() {
        guard pdfViewController?.annotationStateManager.state == .ink, let variant = pdfViewController?.annotationStateManager.variant else { return }
        pdfViewController?.annotationStateManager.toggleState(.ink, variant: variant)
        pdfViewController?.annotationStateManager.toggleState(.ink, variant: variant)
    }

    public func showError(_ error: Error) {
        loadingView?.stopAnimating()
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        let dismiss = NSLocalizedString("Dismiss", bundle: .core, comment: "")
        alert.addAction(UIAlertAction(title: dismiss, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
