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

import Foundation
import Core
import MobileCoreServices

typealias CameraCaptureResult = [UIImagePickerController.InfoKey: Any]

protocol FileViewModel {
    var url: URL { get }
    var size: Int { get }
    var error: String? { get }
}

protocol FilePickerPresenterProtocol: class {
    var view: FilePickerViewProtocol? { get set }

    func viewIsReady()
    func add(fromSource source: FilePickerSource)
    func add(withInfo info: FileInfo)
    func add(fromURL url: URL)
    func add(withCameraResult result: CameraCaptureResult)
    func didSelectFile(_ file: FileViewModel)
}

extension FilePickerPresenterProtocol {
    func add(fromURL url: URL) {
        let size = url.lookupFileSize()
        let info = FileInfo(url: url, size: size)
        add(withInfo: info)
    }
}
