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
import Core
import QuickLook

class UrlSubmissionContentViewController: UIViewController {

    @IBOutlet weak var descriptionLabel: DynamicLabel!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var urlButton: UIButton!
    var submission: Submission?

    static func create(submission: Submission?) -> UrlSubmissionContentViewController {
        let controller = Bundle.loadController(self)
        controller.submission = submission
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = submission?.url {
            urlButton.setTitle(url.absoluteString, for: .normal)
        }

        if let attachment = submission?.attachments?.first {
            previewImageView.load(url: attachment.url)
        }
    }

    @IBAction func openUrl(_ sender: Any) {
        guard let url = submission?.url else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @IBAction func openImageInQuickLook(_ sender: Any) {
        let ql = QLPreviewController(nibName: nil, bundle: nil)
        ql.dataSource = self
        ql.addDoneButton(side: .left)
        let nav = UINavigationController(rootViewController: ql)
        present(nav, animated: true, completion: nil)
    }
}

extension UrlSubmissionContentViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        if let attachment = submission?.attachments?.first,
            let cached = URLCache.shared.cachedResponse(for: URLRequest(url: attachment.url)) {
            let image = UIImage(data: cached.data)
            if let tryFileInfo = try? image?.temporarilyStoreForSubmission(), let fileInfo = tryFileInfo {
                return fileInfo.url as QLPreviewItem
            }
        }
        return URL(fileURLWithPath: NSTemporaryDirectory()) as QLPreviewItem
    }
}
