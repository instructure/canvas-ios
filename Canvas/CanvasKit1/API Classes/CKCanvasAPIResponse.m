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
    
    

#import "CKCanvasAPIResponse.h"
#import "TouchXML.h"

@interface CKCanvasAPIResponse ()
@property (readwrite, copy) NSData *data;
@end

@implementation CKCanvasAPIResponse
@synthesize data = _data;


- (id)initWithResponse:(NSHTTPURLResponse *)response data:(NSData *)data {
    self = [super initWithURL:response.URL
                   statusCode:response.statusCode
                  HTTPVersion:@"HTTP/1.1"
                 headerFields:response.allHeaderFields];
    if (self) {
        _data = [data copy];
    }
    return self;
}


#pragma mark - Read-only properties

- (id)JSONValue
{
    if (self.data) {
        NSError *error;
        id result = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:&error];
        return result;
    }
    else {
        return nil;
    }
}

- (CXMLDocument *)XMLValue
{
    if (self.data) {
        return [[CXMLDocument alloc] initWithData:self.data options:0 error:nil];
    }
    else {
        return nil;
    }
}

@end
