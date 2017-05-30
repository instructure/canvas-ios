// @flow

import React, { Component, PropTypes } from 'react'
import { requireNativeComponent } from 'react-native'

type Props = {
  source: { uri: string },
  style?: Object,
}

export default class Video extends Component<any, Props, any> {
  _container: ?VideoContainer

  pause = () => {
    if (this._container) {
      this._container.setNativeProps({ paused: true })
    }
  }

  captureContainer = (container: VideoContainer) => {
    this._container = container
  }

  render () {
    return <VideoContainer
      ref={this.captureContainer}
      style={this.props.style}
      {...this.props}
    />
  }
}

Video.propTypes = {
  source: PropTypes.shape({ uri: PropTypes.string.isRequired }).isRequired,
}

const VideoContainer = requireNativeComponent('VideoContainer', Video, {
  nativeOnly: {
    paused: true,
  },
})
