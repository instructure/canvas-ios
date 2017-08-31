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


function onLoadAllImages(callback) {
    var images = document.getElementsByTagName('img');
    
    if (images.length <= 0) {
        return;
    }
    
    for (var i = 0; i < images.length; i++) {
        if (images[i].src == '' || images[i].src == undefined || !images[i].hasAttribute('src')) {
            images[i].parentNode.removeChild(images[i]);
        }
    }
    
    images = document.getElementsByTagName('img');
    
    var loadedImageCount = 0;
    
    if (images.length > 0) {
        for(var i = 0; i < images.length; i++) {
            images[i].onload=checkIfImagesLoaded;
            images[i].onerror=checkIfImagesLoaded;
        }
    } else {
        callback();
    }
    
    function checkIfImagesLoaded() {
        loadedImageCount++;
        if(loadedImageCount == images.length) {
            callback();
        }
    }
}