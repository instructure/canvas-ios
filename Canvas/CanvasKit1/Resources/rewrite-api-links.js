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