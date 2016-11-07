//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import UIKit

private func pandifyImages(fromIndex start: Int, toIndex end: Int) -> [UIImage] {
    var images: [UIImage] = []
    for i in start...end {
        let imageName = String(format: "pandify-%d", i)
        if let image = UIImage(named: imageName, inBundle: NSBundle(forClass: PandatarBuilderViewController.classForCoder()), compatibleWithTraitCollection: nil) {
            images.append(image)
        }
    }
    return images
}

public class PandatarBuilderViewController: UIViewController {

    @IBOutlet var pandatarBox: UIView!
    @IBOutlet var headViews: InfinitePagedImagesView!
    @IBOutlet var bodyViews: InfinitePagedImagesView!
    @IBOutlet var legViews: InfinitePagedImagesView!

    public var doneBuilding: (UIImage)->Void = { _ in }
    public var canceledBuilding: (Void)->Void = { }

    lazy var headImages: [UIImage] = {
        return pandifyImages(fromIndex: 1, toIndex: 9)
    }()
    lazy var bodyImages: [UIImage] = {
        return pandifyImages(fromIndex: 10, toIndex: 22)
    }()
    lazy var legImages: [UIImage] = {
        return pandifyImages(fromIndex: 23, toIndex: 27)
    }()

    init() {
        super.init(nibName: "PandatarBuilderViewController", bundle: NSBundle(forClass: PandatarBuilderViewController.classForCoder()))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = NSLocalizedString("Build Your Panda!", tableName: "Localizable", bundle: NSBundle(forClass: self.dynamicType), value: "", comment: "Title for screen to build a panda avatar")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(PandatarBuilderViewController.cancel(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(PandatarBuilderViewController.done(_:)))

        automaticallyAdjustsScrollViewInsets = false
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        buildFrankenPanda()
        navigationItem.rightBarButtonItem?.enabled = false // don't allow the user to press done until the randomizePanda animation is completed
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        randomizePanda()
    }

    func cancel(sender: UIBarButtonItem) {
        canceledBuilding()
    }

    func done(sender: UIBarButtonItem) {
        let image = snapshotPanda()
        doneBuilding(image)
    }

    private func buildFrankenPanda() {
        headViews.setImages(headImages)
        bodyViews.setImages(bodyImages)
        legViews.setImages(legImages)
    }

    private func randomizePanda() {
        pandatarBox.userInteractionEnabled = false
        navigationItem.rightBarButtonItem?.enabled = false
        UIView.animateWithDuration(2.0, delay: 0.0, options: UIViewAnimationOptions(rawValue: 0), animations: {
            let headPage = arc4random_uniform(UInt32(self.headImages.count-1))+1
            var bodyPage = headPage
            if self.bodyImages.count > 2 {
                while bodyPage == headPage { bodyPage = arc4random_uniform(UInt32(self.bodyImages.count-1))+1 }
            } else {
                bodyPage = arc4random_uniform(UInt32(self.bodyImages.count))
            }
            var legPage = headPage
            if self.legImages.count > 3 {
                while legPage == headPage || legPage == bodyPage { legPage = arc4random_uniform(UInt32(self.legImages.count-1))+1 }
            } else {
                legPage = arc4random_uniform(UInt32(self.legImages.count))
            }
            self.headViews.goToPage(Int(headPage), animated: false)
            self.bodyViews.goToPage(Int(bodyPage), animated: false)
            self.legViews.goToPage(Int(legPage), animated: false)
        }, completion: { finished in
            self.pandatarBox.userInteractionEnabled = true
            self.navigationItem.rightBarButtonItem?.enabled = true
        })
    }

    private func snapshotPanda() -> UIImage {
        let padding: CGFloat = 0.25
        let headSize = headImages.first!.size
        let clipSize = CGSize(width: headSize.width * (1 + (padding * 2)), height: headSize.height * (1 + (padding * 2)))
        let clipFrame = CGRect(x: CGRectGetMidX(pandatarBox.frame) - clipSize.width/2.0, y: 0 - (headSize.height * padding), width: clipSize.width, height: clipSize.height)

        UIGraphicsBeginImageContextWithOptions(clipFrame.size, true, UIScreen.mainScreen().scale)
        let ctx = UIGraphicsGetCurrentContext()

        CGContextTranslateCTM(ctx!, -clipFrame.origin.x, -clipFrame.origin.y)

        CGContextSetFillColorWithColor(ctx!, UIColor.lightGrayColor().CGColor)
        CGContextFillRect(ctx!, clipFrame)

        pandatarBox.layer.renderInContext(ctx!)

        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return img!
    }

}
