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

import React from 'react'
import {
  View,
  StyleSheet,
} from 'react-native'

import { isTeacher } from '../../modules/app'

export type Props = {
  visible: boolean,
  disableAppSpecificChecks?: boolean,
  testIdPrefix?: string,
}

export default class AccessLine extends React.PureComponent<Props> {
  static defaultProps = {
    visible: true,
    disableAppSpecificChecks: false,
  }

  render () {
    let props = {}
    if (this.props.testIdPrefix) {
      props = {
        testID: `${this.props.testIdPrefix}.${this.props.visible ? 'published' : 'unpublished'}`,
      }
    }

    if (!this.props.visible) {
      return <View {...props} />
    }

    if (!isTeacher() && !this.props.disableAppSpecificChecks) {
      return <View {...props}/>
    }

    props = {
      ...props,
      style: styles.accessLineStyle,
    }

    return <View {...props} />
  }
}

const styles = StyleSheet.create({
  accessLineStyle: {
    backgroundColor: '#00AC18',
    position: 'absolute',
    top: 4,
    bottom: 4,
    left: 0,
    width: 3,
  },
})
