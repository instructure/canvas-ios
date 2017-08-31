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

import React from 'react'
import {
  View,
  Image,
  StyleSheet,
} from 'react-native'

import Images from '../../images'
import i18n from 'format-message'

type Props = {
  published: true,
  tintColor: string,
  image: any,
}

export default class PublishedIcon extends React.Component<any, Props, any> {
  render () {
    const published = this.props.published
    const icon = published ? Images.published : Images.unpublished
    const iconStyle = published ? styles.publishedIcon : styles.unpublishedIcon
    const accessibilityLabel = published ? i18n('Published') : i18n('Not Published')
    return (
      <View style={styles.container} accessibilityLabel={accessibilityLabel}>
        <Image source={this.props.image} style={[styles.image, { tintColor: this.props.tintColor }]} />
        <View style={styles.publishedIconContainer}>
          <Image source={icon} style={iconStyle} />
        </View>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 0,
    height: 32,
    width: 46,
    alignItems: 'center',
  },
  image: {
    position: 'absolute',
  },
  publishedIconContainer: {
    justifyContent: 'center',
    alignItems: 'center',
    position: 'absolute',
    top: 10,
    left: 20,
    backgroundColor: 'white',
    height: 16,
    width: 16,
    borderRadius: 8,
  },
  publishedIcon: {
    height: 12,
    width: 12,
    tintColor: '#00AC18',
  },
  unpublishedIcon: {
    height: 12,
    width: 12,
    tintColor: '#8B969E',
  },
})
