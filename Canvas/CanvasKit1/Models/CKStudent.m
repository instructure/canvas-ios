//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
    return (NSUInteger)self.ident;
}

@end
