//
//  registerSharedNativeViewControllers.swift
//  CanvasCore
//
//  Created by Matt Sessions on 4/9/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

public func registerSharedNativeViewControllers() {
    HelmManager.shared.registerNativeViewController(for: "/support/:type", factory: { props in
        guard let type = props["type"] as? String else { return nil }
        
        let storyboard = UIStoryboard(name: "SupportTicket", bundle: Bundle(for: SupportTicketViewController.self))
        let controller = storyboard.instantiateInitialViewController()!.childViewControllers[0] as! SupportTicketViewController
        if type == "feature" {
            controller.ticketType = SupportTicketTypeFeatureRequest
        } else {
            controller.ticketType = SupportTicketTypeProblem
        }
        return UINavigationController(rootViewController: controller)
    })
}
