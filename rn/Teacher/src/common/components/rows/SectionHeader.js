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

/**
* @flow
*/

import React, { PureComponent } from 'react'
import {
  View,
  StyleSheet,
} from 'react-native'
import { Heading1 } from '../../../common/text'
import color from '../../colors'

type Props = {
  title: string,
  sectionKey?: string,
  top?: boolean, // Draw a line at the top of the section header. Usually used if the section header is the topmost of the list
}

export default class SectionHeader extends PureComponent<Props, any> {
  render () {
    const key = this.props.sectionKey ? this.props.sectionKey : this.props.title
    const topHairline = this.props.top ? styles.topHairline : undefined
    const containerStyle = [styles.section, styles.bottomHairline, topHairline].filter(Boolean)
    return (
      <View style={containerStyle} key={key} accessibilityTraits='header'>
        <Heading1 style={styles.title}>{this.props.title}</Heading1>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  section: {
    flex: 1,
    height: 'auto',
    backgroundColor: '#F5F5F5',
    justifyContent: 'center',
    paddingLeft: 16,
    paddingRight: 8,
    paddingVertical: global.style.defaultPadding / 4,
  },
  title: {
    fontSize: 14,
    backgroundColor: '#F5F5F5',
    color: '#73818C',
    fontWeight: '600',
  },
  topHairline: {
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: color.seperatorColor,
  },
  bottomHairline: {
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: color.seperatorColor,
  },
})
