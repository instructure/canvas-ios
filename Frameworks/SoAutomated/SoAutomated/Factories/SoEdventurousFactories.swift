//
//  SoEdventurousFactories.swift
//  SoAutomated
//
//  Created by Nathan Armstrong on 9/13/16.
//  Copyright © 2016 instructure. All rights reserved.
//

@testable import SoEdventurous
import CoreData

extension Module {
    public static func build(inContext context: NSManagedObjectContext,
                                id: String = "1",
                                courseID: String = "1",
                                name: String = "Module 1",
                                position: Int = 0,
                                requireSequentialProgress: Bool = false,
                                itemCount: Int = 1,
                                state: Module.State = .unlocked,
                                workflowState: Module.WorkflowState = .active,
                                unlockDate: NSDate? = nil,
                                prerequisiteModuleIDs: [String] = []) -> Module {
        let module = Module(inContext: context)
        module.id = id
        module.courseID = courseID
        module.name = name
        module.position = position
        module.requireSequentialProgress = requireSequentialProgress
        module.itemCount = itemCount
        module.state = state
        module.workflowState = workflowState
        module.unlockDate = unlockDate
        module.prerequisiteModuleIDs = prerequisiteModuleIDs

        try! context.saveFRD()
        return module
    }
}

extension ModuleItem {
    public static func build(inContext context: NSManagedObjectContext,
                                id: String = "1",
                                courseID: String = "1",
                                moduleID: String = "1",
                                position: Float = 0,
                                title: String = "Module Item 1",
                                content: Content = .Assignment(id: "1"),
                                completed: Bool = false,
                                completionRequirement: CompletionRequirement? = nil) -> ModuleItem {
        let item = ModuleItem(inContext: context)
        item.id = id
        item.courseID = courseID
        item.moduleID = moduleID
        item.position = position
        item.title = title
        item.content = content
        item.completionRequirement = completionRequirement
        item.completed = false

        try! context.saveFRD()
        return item
    }
}
