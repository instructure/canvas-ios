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
import {
  StyleSheet,
  TouchableHighlight,
  Image,
} from 'react-native'
import Row from '../../common/components/rows/Row'
import images from '../../images'
import colors from '../../common/colors'

export type Props = {
  title: string,
  subtitle: ?string,
  progress: number,
  error: ?string,
  testID: string,
  onRemovePressed: () => void,
  onPress: () => void,
}

export default class AttachmentRow extends Component<any, Props, any> {
  render () {
    return (
      <Row
        title={this.props.title}
        subtitle={this.props.subtitle}
        image={images.attachments.complete}
        imageTint={colors.primaryBrandColor}
        accessories={this.removeButton}
        onPress={this.props.onPress}
        testID={this.props.testID}
      />
    )
  }

  removeButton = (
    <TouchableHighlight
      onPress={this.props.onRemovePressed}
      underlayColor='white'
      hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
    >
      <Image source={images.x} style={styles.remove} />
    </TouchableHighlight>
  )
}

const styles = StyleSheet.create({
  removeContainer: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
  },
  remove: {
    width: 14,
    height: 14,
    tintColor: 'black',
  },
})
