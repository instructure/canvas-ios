//
//  CKIActivityStreamCollaborationItem.h
//  CanvasKit
//
//  Created by Jason Larsen on 11/4/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIActivityStreamItem.h"

@interface CKIActivityStreamCollaborationItem : CKIActivityStreamItem

/**
 The ID of the collaboration.
 */
@property (nonatomic, copy) NSString *collaborationID;

@end
