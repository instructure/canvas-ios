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
    
    

#import "CKByteCountFormatter.h"

@implementation CKByteCountFormatter

- (NSString *)stringFromByteCount:(long long)byteCount {
    
    if (byteCount >= 1 * 1000 * 1000 * 1000) {
        NSString *template = NSLocalizedString(@"%0.2f GB", @"Gigabytes");
        return [NSString stringWithFormat:template, (double)byteCount / (1 * 1000 * 1000 * 1000)];
    }
    else if (byteCount >= 1 * 1000 * 1000) {
        NSString *template = NSLocalizedString(@"%0.2f MB", @"Megabytes");
        return [NSString stringWithFormat:template, (double)byteCount / (1 * 1000 * 1000)];
    }
    else if (byteCount >= 1 * 1000) {
        NSString *template = NSLocalizedString(@"%0.2f KB", @"Kilobytes");
        return [NSString stringWithFormat:template, (double)byteCount / (1 * 1000)];
    }
    else {
        NSString *template = NSLocalizedString(@"%qu bytes", @"As in, '15 bytes'");
        return [NSString stringWithFormat:template, byteCount];
    }
    
}


@end
