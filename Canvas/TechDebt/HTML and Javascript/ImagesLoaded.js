
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