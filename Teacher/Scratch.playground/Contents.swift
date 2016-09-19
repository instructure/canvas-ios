//: Playground - noun: a place where people can play

import UIKit
import URITemplate

let template = URITemplate(template: "/api/v1/courses/{courseID}/")
template.extract("/api/v1/courses/131/")
