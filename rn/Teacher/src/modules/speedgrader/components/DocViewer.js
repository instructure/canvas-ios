//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import React, { Component } from 'react'
import { requireNativeComponent } from 'react-native'

const NativeDocViewer = requireNativeComponent('DocViewer', null)
NativeDocViewer.displayName = 'DocViewer'

export default class DocViewer extends Component {
  shouldComponentUpdate (newProps) {
    return (
      this.props.contentInset?.bottom !== newProps.contentInset?.bottom ||
      this.props.contentInset?.left !== newProps.contentInset?.left ||
      this.props.contentInset?.right !== newProps.contentInset?.right ||
      this.props.contentInset?.top !== newProps.contentInset?.top ||
      this.props.fallbackURL !== newProps.fallbackURL ||
      this.props.filename !== newProps.filename ||
      this.props.previewURL !== newProps.previewURL ||
      this.props.style !== newProps.style
    )
  }

  render () {
    return <NativeDocViewer {...this.props} />
  }
}
