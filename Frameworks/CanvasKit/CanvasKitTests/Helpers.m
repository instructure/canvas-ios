//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Helpers.h"

id loadJSONFixture(NSString *fixtureName)
{
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.instructure.CanvasKitTests"];
    NSString *filePath = [bundle pathForResource:[fixtureName stringByDeletingPathExtension] ofType:@"json"];
    NSCAssert(filePath, @"Cannot find fixture %@.json", fixtureName);
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if (error) {
        return nil;
    }
    return result;
}
