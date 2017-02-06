//: [Previous](@previous)

import UIKit
import PlaygroundSupport
let page = PlaygroundPage.current
page.needsIndefiniteExecution = true

import TeacherKit
import SixtySix
import DoNotShipThis


class Deets: UIViewController, Destination {
    static func visit(with: (String, String)) -> UIViewController {
        let d = Deets()
        d.view.backgroundColor = UIColor(hue: 0.6, saturation: 0.8, brightness: 1.0, alpha: 1.0)
        return d
    }
}


page.liveView = Deets.visit(with: ("12", "55"))
