//
//  CKStudent.m
//  CanvasKit
//
//  Created by Zach Wily on 5/17/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
//

#import "CKStudent.h"


@implementation CKStudent

@synthesize ident, name;

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if (self) {
        [self updateWithInfo:info];
    }
    return self;
}

- (void)updateWithInfo:(NSDictionary *)info
{
    self.ident = [info[@"id"] unsignedLongLongValue];
    self.name = info[@"name"];
}


- (NSString *)keyString
{
    return [NSString stringWithFormat:@"%qu", self.ident];
}

+ (NSMutableArray *)shuffledArrayOfStudents:(NSArray *)studentsToSort
{
    NSInteger studentCount = [studentsToSort count];
    NSString *STUDENT_KEY = @"student_key";
    NSString *RANDOM_KEY = @"random_key";
    
    NSMutableArray *sortingArray = [NSMutableArray arrayWithCapacity:studentCount];
    for (CKStudent *student in studentsToSort) {
        // Place the student and a random number into an array
        // It is possible that multiple students could end up with the same random number, but we are not concerned about that in this case.
        // If we were, we would detect the collision and perform the sort again.
        [sortingArray addObject:@{STUDENT_KEY: student,RANDOM_KEY: @(arc4random() % studentCount)}];
    }
    
    // Sort that array on the random number
    [sortingArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:RANDOM_KEY ascending:YES]]];
    
    // Put the students into the new array
    NSMutableArray *sortedStudents = [NSMutableArray arrayWithCapacity:studentCount];
    for (NSDictionary *randomStudent in sortingArray) {
        [sortedStudents addObject:randomStudent[STUDENT_KEY]];
    }
    
    return sortedStudents;
}

- (NSUInteger)hash {
    return self.ident;
}

@end
