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
    
    

import Foundation

extension String {
    public func UTF8Data() throws -> Data {
        guard let data = data(using: String.Encoding.utf8) else {
            let title = NSLocalizedString("Encoding Error", tableName: "Localizable", bundle: .core, value: "", comment: "Data encoding error title")
            let message = NSLocalizedString("There was a problem encoding UTF8 Data", tableName: "Localizable", bundle: .core, value: "", comment: "Data encoding error message")
            throw NSError(subdomain: "SoLazy", code: 0, title: title, description: message)
        }
        
        return data
    }
}


public func +=(lhs: inout Data, rhs: Data) {
    lhs.append(rhs)
}
