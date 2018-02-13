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
  entry: Object, /* {
    published?: boolean,
    locked?: boolean,
    hidden?: boolean,
    lock_at?: ?string,
    unlock_at?: ?string,
  }, */
  tintColor: ?string,
  image: any,
  // Offset for the status icon that appears in the bottom right.
  // Needed because some images have different sizes so a single offset doesn't work for all images
  statusOffset?: {
    top?: number,
    left?: number,
  },
}

export default class AccessIcon extends React.Component<Props> {
  static defaultProps = {
    entry: {},
  }

  render () {
    const { published, locked, hidden, lock_at, unlock_at } = this.props.entry
    let icon = Images.published
    let iconStyle = styles.publishedIcon
    let accessibilityLabel = i18n('Published')
    if (published == null && (hidden || lock_at || unlock_at)) { // eslint-disable-line camelcase
      icon = Images.restricted
      iconStyle = styles.restrictedIcon
      accessibilityLabel = i18n('Restricted')
    } else if (published === false || (published == null && locked === true)) {
      icon = Images.unpublished
      iconStyle = styles.unpublishedIcon
      accessibilityLabel = i18n('Not Published')
    }
    return (
      <View style={styles.container} accessibilityLabel={accessibilityLabel}>
        <Image source={this.props.image} style={[styles.image, { tintColor: this.props.tintColor }]} />
        <View style={[styles.publishedIconContainer, this.props.statusOffset]}>
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
  restrictedIcon: {
    height: 14,
    width: 14,
    tintColor: '#FF0000',
  },
})
