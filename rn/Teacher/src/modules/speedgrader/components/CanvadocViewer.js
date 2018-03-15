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
  config: {
    drawerInset: number,
    previewPath: string,
  },
  style?: any,
}

export default class CanvadocViewer extends Component<Props> {
  shouldComponentUpdate (newProps: Props) {
    return (
      this.props.style !== newProps.style ||
      this.props.config.drawerInset !== newProps.config.drawerInset ||
      this.props.config.previewPath !== newProps.config.previewPath
    )
  }
  render () {
    return <CanvadocView {...this.props} />
  }
}

CanvadocViewer.propTypes = {
  config: PropTypes.shape({
    drawerInset: PropTypes.number.isRequired,
    previewPath: PropTypes.string.isRequired,
  }).isRequired,
}

const CanvadocView = requireNativeComponent('CanvadocView', CanvadocViewer)
