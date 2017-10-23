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

// This script checks for data-api-endpoint attributes inside <a> tags.
// If present, it replaces the href with the endpoint, with a few changes.
//
// The final href will look something like this:
//
//   x-canvas-discussion://canvas.instructure.com/api/v1/courses/12345/discussion_topics/54321
//   x-canvas-folder-array://canvas.instructure.com/api/v1/folders/12345/folders
//
// The scheme name is composed as follows:
//
//   'x-canvas-' + <dataset['apiReturnType'].toLowerCase()> [ + '-array' ]
//
// The rest of the URL is as in the data-api-endpoint attribute.


if (typeof String.prototype.startsWith != 'function') {
    String.prototype.startsWith = function (str){
        return this.indexOf(str, 0) == 0;
    };
}

if (typeof String.prototype.endsWith != 'function') {
    String.prototype.endsWith = function (str){
        var startAt = this.length - str.length
        return this.lastIndexOf(str, startAt) == startAt;
    };
}

function rewriteLinks() {
    elements = document.getElementsByTagName('a')
    for (var i=0; i<elements.length; i++) {
        var link = elements[i]
        
        var endpoint = link.dataset['apiEndpoint']
        var datatype = (link.dataset['apiReturntype'] || "").toLowerCase()
        
        if (datatype.startsWith('[') && datatype.endsWith(']')) {
            datatype = datatype.slice(1, -1) + '-array'
        }
        if (endpoint != undefined && datatype != undefined) {
            var schemeSplit = endpoint.split('://')
            schemeSplit[0] = 'x-canvas-' + datatype
            endpoint = schemeSplit.join('://')
            link.href = endpoint
        }
    }
}
rewriteLinks();