//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// @flow

import React, { Component } from 'react'
import { requireNativeComponent, NativeModules, findNodeHandle } from 'react-native'
const { CanvadocViewManager } = NativeModules

type Props = {
  config: {
    drawerInset: number,
    previewPath: string,
    filename: string,
    fallbackURL: string,
  },
  style?: any,
}

export default class CanvadocViewer extends Component<Props> {
  shouldComponentUpdate (newProps: Props) {
    return (
      this.props.style !== newProps.style ||
      this.props.config.drawerInset !== newProps.config.drawerInset ||
      this.props.config.previewPath !== newProps.config.previewPath ||
      this.props.config.filename !== newProps.config.filename ||
      this.props.config.fallbackURL !== newProps.config.fallbackURL
    )
  }

  render () {
    return <CanvadocView {...this.props} />
  }

  getHandle = () => {
    return findNodeHandle(this)
  }

  syncAllAnnotations () {
    CanvadocViewManager.syncAllAnnotations(this.getHandle())
  }
}

const CanvadocView = requireNativeComponent('CanvadocView', null)
