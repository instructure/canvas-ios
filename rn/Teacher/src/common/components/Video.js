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

// @flow

import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { requireNativeComponent } from 'react-native'

type Props = {
  source: { uri: string },
  style?: Object | number,
}

export default class Video extends Component<Props, any> {
  _container: ?typeof VideoContainer

  pause = () => {
    // $FlowFixMe
    this._container && this._container.setNativeProps({ paused: true })
  }

  play = () => {
    // $FlowFixMe
    this._container && this._container.setNativeProps({ playing: true })
  }

  captureContainer = (container: ?typeof VideoContainer) => {
    this._container = container
  }

  render () {
    return <VideoContainer
      // $FlowFixMe
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
    playing: true,
  },
})
