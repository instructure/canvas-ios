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

public class FileListViewController: UIViewController, ColoredNavViewProtocol {
    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet weak var emptyMessageLabel: UILabel!
    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var errorView: ListErrorView!
    @IBOutlet weak var keyboardSpace: NSLayoutConstraint!
    let refreshControl = CircleRefreshControl()
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var loadingView: CircleProgressView!
    @IBOutlet weak var tableView: UITableView!

    lazy var addButton = UIBarButtonItem(image: .addSolid, style: .plain, target: self, action: #selector(addItem))
    lazy var editButton = UIBarButtonItem(
        title: NSLocalizedString("Edit", bundle: .core, comment: ""), style: .plain,
        target: self, action: #selector(edit)
    )

    let batchID = UUID.string
    public var color: UIColor?
    let env = AppEnvironment.shared
    public let titleSubtitleView = TitleSubtitleView.create()
    var context = Context.currentUser
    lazy var filePicker = FilePicker(delegate: self)
    var keyboard: KeyboardTransitioning?
    var path = ""
    var searchTerm: String?
    var results: [APIFile] = []

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavBar()
    }
    lazy var course = context.contextType == .course ? env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.updateNavBar()
    } : nil
    lazy var folder = env.subscribe(GetFolder(context: context, path: path)) { [weak self] in
        self?.updateFolder()
    }
    var items: Store<GetFolderItems>?
    lazy var group = context.contextType == .group ? env.subscribe(GetGroup(groupID: context.id)) { [weak self] in
        self?.updateNavBar()
    } : nil
    lazy var uploads = UploadManager.shared.subscribe(batchID: batchID) { [weak self] in
        self?.updateUploads()
    }

    public static func create(context: Context, path: String? = nil) -> FileListViewController {
        let controller = loadFromStoryboard()
        controller.context = context
        controller.path = path ?? ""
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        setupTitleViewInNavbar(title: NSLocalizedString("Files", bundle: .core, comment: ""))

        addButton.accessibilityIdentifier = "FileList.addButton"
        addButton.accessibilityLabel = NSLocalizedString("Add Item", bundle: .core, comment: "")

        editButton.accessibilityIdentifier = "FileList.editButton"

        emptyImageView.image = UIImage(named: "PandaFilePicker", in: .core, compatibleWith: nil)
        emptyMessageLabel.text = NSLocalizedString("This folder is empty.", bundle: .core, comment: "")
        emptyTitleLabel.text = NSLocalizedString("No Files", bundle: .core, comment: "")
        errorView.messageLabel.text = NSLocalizedString("There was an error loading files. Pull to refresh to try again.", bundle: .core, comment: "")
        errorView.retryButton.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)

        loadingView.color = nil

        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        refreshControl.color = nil

        searchBar.placeholder = NSLocalizedString("Search", bundle: .core, comment: "")
        searchBar.backgroundColor = .backgroundLightest

        tableView.backgroundColor = .backgroundLightest
        tableView.refreshControl = refreshControl
        tableView.separatorColor = .borderMedium
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.tableView.contentOffset.y = self.searchBar.frame.height
        }

        colors.refresh()
        course?.refresh()
        group?.refresh()
        folder.refresh()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboard = KeyboardTransitioning(view: view, space: keyboardSpace)
        tableView.selectRow(at: nil, animated: true, scrollPosition: .none)
        if context.contextType == .user {
            navigationController?.navigationBar.useGlobalNavStyle()
        } else if let color = color {
            navigationController?.navigationBar.useContextColor(color)
        }
        env.pageViewLogger.startTrackingTimeOnViewController()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        var eventName = "\(context == .currentUser ? "" : context.pathComponent)/files"
        if !path.isEmpty {
            eventName += "/folder/\(path)"
        }
        env.pageViewLogger.stopTrackingTimeOnViewController(eventName: eventName, attributes: [:])
    }

    func updateNavBar() {
        if let course = course?.first {
            updateNavBar(subtitle: course.name, color: course.color)
        } else if let group = group?.first {
            updateNavBar(subtitle: group.name, color: group.color)
        } else if context.contextType == .user {
            color = .textDark
        }
        view.tintColor = color
        updateNavButtons()
    }

    func updateFolder() {
        if let folderID = items?.useCase.folderID, folder.isEmpty {
            let updated: Folder? = env.database.viewContext.first(where: #keyPath(Folder.id), equals: folderID)
            if let folder = updated, !env.database.viewContext.isObjectDeleted(folder) {
                // Folder was renamed, make sure next refresh doesn't 404.
                path = folder.path
                self.folder = env.subscribe(GetFolder(context: context, path: path)) { [weak self] in
                    self?.updateFolder()
                }
            } else {
                // Folder was deleted, go back.
                env.router.dismiss(self)
            }
        }

        loadingView.isHidden = !folder.pending || !folder.isEmpty || folder.error != nil || refreshControl.isRefreshing
        emptyView.isHidden = folder.pending || !folder.isEmpty || folder.error != nil
        errorView.isHidden = folder.error == nil
        titleSubtitleView.title = (path.isEmpty ? nil : folder.first?.name) ?? NSLocalizedString("Files", bundle: .core, comment: "")
        updateNavButtons()

        guard let folder = folder.first, items == nil else { return }
        items = env.subscribe(GetFolderItems(folderID: folder.id)) { [weak self] in
            self?.update()
        }
        items?.refresh()
    }

    @objc func refresh() {
        folder.refresh(force: true)
        items?.refresh(force: true) { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }
        search()
    }

    func update() {
        guard let items = items, searchTerm == nil else { return }
        loadingView.isHidden = !items.pending || !items.isEmpty || items.error != nil || refreshControl.isRefreshing
        emptyView.isHidden = items.pending || !items.isEmpty || items.error != nil
        errorView.isHidden = items.error == nil
        tableView.reloadData()
    }
}

extension FileListViewController: UISearchBarDelegate {
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.searchBar(searchBar, textDidChange: "")
        searchBarSearchButtonClicked(searchBar)
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        tableView.setContentOffset(CGPoint(x: 0, y: searchBar.frame.height), animated: true)
    }

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let newSearch = searchText.count >= 3 ? searchText : nil
        tableView.setContentOffset(.zero, animated: true)
        guard newSearch != searchTerm else { return }
        searchTerm = newSearch
        if searchTerm != nil {
            emptyImageView.image = UIImage(named: "PandaNoResults", in: .core, compatibleWith: nil)
            emptyMessageLabel.text = NSLocalizedString("We couldn’t find any files like that.", bundle: .core, comment: "")
            emptyTitleLabel.text = NSLocalizedString("No Results", bundle: .core, comment: "")
        } else {
            emptyImageView.image = UIImage(named: "PandaFilePicker", in: .core, compatibleWith: nil)
            emptyMessageLabel.text = NSLocalizedString("This folder is empty.", bundle: .core, comment: "")
            emptyTitleLabel.text = NSLocalizedString("No Files", bundle: .core, comment: "")
        }
        search()
    }

    func search() {
        results = []
        guard let searchTerm = searchTerm else { return tableView.reloadData() }
        loadingView.isHidden = false
        emptyView.isHidden = true
        errorView.isHidden = true
        tableView.reloadData()
        env.api.makeRequest(GetFilesRequest(context: context, searchTerm: searchTerm)) { [weak self] files, _, error in performUIUpdate {
            guard self?.searchTerm == searchTerm else { return }
            self?.showResults(files ?? [], error: error)
        } }
    }

    func showResults(_ results: [APIFile], error: Error?) {
        self.results = results
        loadingView.isHidden = true
        emptyView.isHidden = !results.isEmpty
        errorView.isHidden = error == nil
        tableView.reloadData()
    }
}

extension FileListViewController: FilePickerDelegate {
    func updateNavButtons() {
        navigationItem.rightBarButtonItems = [
            canAddItem ? addButton : nil,
            canEditFolder ? editButton : nil,
        ].compactMap { $0 }
    }

    var canEditFolder: Bool {
        !path.isEmpty && // Can't edit root folder
        folder.first?.forSubmissions == false &&
        (
            context == .currentUser ||
            course?.first?.hasTeacherEnrollment == true
        )
    }

    @objc func edit() {
        guard let folderID = folder.first?.id else { return }
        env.router.route(to: "/folders/\(folderID)/edit", from: self, options: .modal(.formSheet, isDismissable: false, embedInNav: true))
    }

    var canAddItem: Bool {
        folder.first?.canUpload == true
    }

    @objc func addItem() {
        let sheet = BottomSheetPickerViewController.create()
        sheet.addAction(
            image: .folderLine,
            title: NSLocalizedString("Add Folder", bundle: .core, comment: ""),
            accessibilityIdentifier: "FileList.addFolderButton"
        ) { [weak self] in
            self?.addFolder()
        }
        sheet.addAction(
            image: .addDocumentLine,
            title: NSLocalizedString("Add File", bundle: .core, comment: ""),
            accessibilityIdentifier: "FileList.addFileButton"
        ) { [weak self] in
            guard let self = self else { return }
            self.filePicker.pick(from: self)
        }
        env.router.show(sheet, from: self, options: .modal())
    }

    func addFolder() {
        let prompt = UIAlertController(title: NSLocalizedString("Add Folder", bundle: .core, comment: ""), message: nil, preferredStyle: .alert)
        prompt.addTextField { field in
            field.placeholder = NSLocalizedString("Name", bundle: .core, comment: "")
        }
        prompt.addAction(AlertAction(NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .cancel))
        prompt.addAction(AlertAction(NSLocalizedString("OK", bundle: .core, comment: ""), style: .default) { [weak self] _ in
            let name = prompt.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !name.isEmpty else { return }
            self?.addFolder(name: name)
        })
        env.router.show(prompt, from: self, options: .modal())
    }

    func addFolder(name: String) {
        guard let folderID = folder.first?.id else { return }
        CreateFolder(context: context, name: name, parentFolderID: folderID).fetch()
    }

    public func filePicker(didPick url: URL) {
        UploadManager.shared.upload(url: url, batchID: batchID, to: .context(context), folderPath: path)
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }

    public func filePicker(didRetry file: File) {
        UploadManager.shared.upload(file: file, to: .context(context), folderPath: path)
    }

    func updateUploads() {
        let completes = uploads.filter { $0.url != nil && $0.uploadError == nil }
        guard !completes.isEmpty else { return tableView.reloadData() }

        // Copy file object from globalDatabase
        var context = env.database.viewContext
        context.performAndWait {
            for file in completes {
                FolderItem.save(context.copy(file), in: context)
            }
            try? context.save()
        }

        // Delete from globalDatabase
        context = UploadManager.shared.viewContext
        context.perform {
            context.delete(completes)
            try? context.save()
        }
    }
}

extension FileListViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard errorView.isHidden else { return 0 }
        switch section {
        case 0: return uploads.count
        case 1: return results.count
        default: return searchTerm != nil ? 0 : items?.count ?? 0
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: FileListUploadCell = tableView.dequeue(for: indexPath)
            cell.update(uploads[indexPath.row])
            return cell
        }

        let cell: FileListCell = tableView.dequeue(for: indexPath)
        cell.accessibilityIdentifier = "FileList.\(indexPath.row)"
        cell.backgroundColor = .backgroundLightest
        if indexPath.section == 1 {
            cell.update(result: results[indexPath.row])
        } else {
            cell.update(item: items?[indexPath.row])
        }
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0, let file = uploads[indexPath.row] {
            filePicker.showOptions(for: file, from: self)
        } else if indexPath.section == 1 {
            let id = results[indexPath.row].id.value
            env.router.route(to: "/\(context.pathComponent)/files/\(id)", from: self, options: .detail)
        } else if let id = items?[indexPath.row]?.file?.id {
            env.router.route(to: "/\(context.pathComponent)/files/\(id)", from: self, options: .detail)
        } else if let path = items?[indexPath.row]?.folder?.path {
            env.router.route(to: "/\(context.pathComponent)/files/folder/\(path)", from: self, options: .push)
        }
    }
}

class FileListUploadCell: UITableViewCell {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var progressView: CircleProgressView!
    @IBOutlet weak var sizeLabel: UILabel!

    func update(_ file: File?) {
        iconView.isHidden = file?.uploadError == nil
        nameLabel.text = file?.filename
        progressView.color = nil
        progressView.progress = file.map { CGFloat($0.bytesSent) / CGFloat($0.size) }
        progressView.isHidden = file?.uploadError != nil
        sizeLabel.text = file?.uploadError ?? file.map { String.localizedStringWithFormat(
            NSLocalizedString("Uploading %@ of %@", bundle: .core, comment: "Uploading X KB of Y MB"),
            $0.bytesSent.humanReadableFileSize,
            $0.size.humanReadableFileSize
        ) }
        sizeLabel.textColor = file?.uploadError == nil ? .textDark : .textDanger
    }
}

class FileListCell: UITableViewCell {
    @IBOutlet weak var iconView: AccessIconView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!

    func update(item: FolderItem?) {
        nameLabel.text = item?.name
        if let folder = item?.folder {
            iconView.icon = .folderSolid
            sizeLabel.text = String.localizedStringWithFormat(
                NSLocalizedString("d_items", bundle: .core, comment: ""),
                folder.filesCount + folder.foldersCount
            )
            return
        }
        if let url = item?.file?.thumbnailURL {
            iconView.load(url: url)
        } else {
            iconView.icon = item?.file?.icon
        }
        sizeLabel.text = item?.file?.size.humanReadableFileSize
    }

    func update(result: APIFile?) {
        nameLabel.text = result?.display_name
        if let url = result?.thumbnail_url?.rawValue {
            iconView.load(url: url)
        } else {
            iconView.icon = File.icon(mimeClass: result?.mime_class, contentType: result?.contentType)
        }
        sizeLabel.text = result?.size?.humanReadableFileSize
    }
}
