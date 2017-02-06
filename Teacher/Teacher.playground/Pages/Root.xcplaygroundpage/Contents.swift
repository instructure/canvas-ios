//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport
let page = PlaygroundPage.current
page.needsIndefiniteExecution = true

import TeacherKit
import DoNotShipThis

TEnv.pushEnvironment(session: .ivy)
TEnv.pushEnvironment(router: .teacher)

page.liveView = try! rootLoggedInViewController()
