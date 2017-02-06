//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport
let page = PlaygroundPage.current
page.needsIndefiniteExecution = true

import TeacherKit
import DoNotShipThis

TEnv.pushEnvironment(session: .ivy)

import EnrollmentKit

let r = try Course.refresher(TEnv.current.session)
r.refresh(true)

let assignments = try AssignmentsTableViewController.visit(with: "968776")

page.liveView = assignments

