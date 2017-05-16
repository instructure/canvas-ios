/**
 * @flow
 */

import React, { Component } from 'react'
import { WebView } from 'react-native'

const TEMPLATE = `
<html>
    <head>
        <meta name="viewport" content="width={{content-width}},
            initial-scale = 1.0, user-scalable = no" />
        <style>
            body {
                font: -apple-system-body;
                margin: 0;
                padding: 0;
                color: {{font-color}};
                background-color: {{background-color}};
            }
            img {
                width: auto;
                height: auto;
                max-width: 100%;
            }
            video {
                width: auto;
                height: auto;
                max-width: 100%;
            }
            #whizzy_content {
                padding: {{padding}};
                margin: 0;
            }
        </style>
    </head>
<body>
    <div id='whizzy_content'>
    {{content}}
    </div>
</body>

<script type="text/javascript">
    function onLoadAllImages(callback) {
        var images = document.getElementsByTagName('img');

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
        }
        else {
            callback();
        }

        function checkIfImagesLoaded() {
            loadedImageCount++;
            if(loadedImageCount == images.length) {
                callback();
            }
        }
    }

    onLoadAllImages(function () {
        // Inform the DiscussionEntryCell that all the images are loaded
        var iframe = document.createElement("iframe");
        iframe.setAttribute("src", "whizzywig://finishedLoadingImages/");
        document.documentElement.appendChild(iframe);
        iframe.parentNode.removeChild(iframe);
        iframe = null;
    });
</script>
</html>
`

const POST_HEIGHT_MESSAGE = `
  var height = document.getElementById('whizzy_content').clientHeight;
  postMessage(JSON.stringify({type: 'UPDATE_HEIGHT', data: height}));
`

type Props = {
  html: string,
  style?: any,
}
export default class WebContainer extends Component<any, Props, any> {
  constructor (props: Props) {
    super(props)
    this.state = {
      webViewHeight: props.height || 0,
    }
  }

  render (): ReactElement<*> {
    let { html, style } = this.props
    const _html = TEMPLATE.replace('{{content}}', html)
    return (
      <WebView
        style={[style, { height: this.state.webViewHeight }]}
        source={{ html: _html }}
        injectedJavaScript={POST_HEIGHT_MESSAGE}
        onMessage={this._onMessage}
      />
    )
  }

  _onMessage = (event) => {
    const message = JSON.parse(event.nativeEvent.data)
    switch (message.type) {
      case 'UPDATE_HEIGHT':
        this.setState({ webViewHeight: message.data })
        break
    }
  }
}
