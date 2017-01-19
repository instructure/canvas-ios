//
//  CKIActivityStreamConferenceItem.h
//  CanvasKit
//
//  Created by Jason Larsen on 11/4/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIActivityStreamItem.h"

@interface CKIActivityStreamConferenceItem : CKIActivityStreamItem

/**
 The ID of the conference.
 */
@property (nonatomic, copy) NSString *conferenceID;

@end
