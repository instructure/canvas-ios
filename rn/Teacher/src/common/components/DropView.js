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
import { requireNativeComponent, Platform, View } from 'react-native'

const DropViewNative = requireNativeComponent('DropView', null)

type BaseProps = {
  children?: React$Node,
}
type DataProps = { dragItem?: string } | { dragItems?: string[] }
export type Props = BaseProps & DataProps

export default class DragView extends Component<Props> {
  render () {
    // Ensure that we are on iOS 11+
    const validPlatform = (
      Platform.OS === 'ios' &&
      parseInt(Platform.Version, 10) >= 11
    )

    if (!validPlatform) {
      console.warn('DropView can only be used on iOS 11+')
      return <View {...this.props} />
    }

    // Finally, return the view with the child inside it
    return <DropViewNative {...this.props} />
  }
}
