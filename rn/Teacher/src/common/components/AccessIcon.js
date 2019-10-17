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

/**
* @flow
*/

import React from 'react'
import {
  View,
  Image,
} from 'react-native'

import instIcon from '../../images/inst-icons'
import { createStyleSheet } from '../stylesheet'
import i18n from 'format-message'
import { isTeacher } from '../../modules/app'

export type Props = {
  entry: Object, /* {
    published?: boolean,
    locked?: boolean,
    hidden?: boolean,
    lock_at?: ?string,
    unlock_at?: ?string,
  }, */
  tintColor: ?string,
  image: any,
  showAccessIcon: boolean,
  disableAppSpecificChecks?: boolean,
}

export default class AccessIcon extends React.Component<Props> {
  static defaultProps = {
    entry: {},
    showAccessIcon: true,
    disableAppSpecificChecks: false,
  }

  render () {
    const { published, locked, hidden, lock_at, unlock_at } = this.props.entry
    let icon = instIcon('publish', 'solid')
    let iconStyle = styles.publishedIcon
    let accessibilityLabel = i18n('Published')
    let showAccessIcon = this.props.showAccessIcon
    if (!this.props.disableAppSpecificChecks) {
      showAccessIcon = isTeacher()
    }
    if (published == null && (hidden || lock_at || unlock_at)) { // eslint-disable-line camelcase
      icon = instIcon('cloudLock', 'line')
      iconStyle = styles.restrictedIcon
      accessibilityLabel = i18n('Restricted')
    } else if (published === false || (published == null && locked === true)) {
      icon = instIcon('no', 'solid')
      iconStyle = styles.unpublishedIcon
      accessibilityLabel = i18n('Not Published')
    }
    if (!isTeacher()) { accessibilityLabel = '' }
    let isIcon = typeof this.props.image === 'number'
    return (
      <View style={styles.container} accessibilityLabel={accessibilityLabel}>
        <Image
          source={this.props.image}
          style={[isIcon && { tintColor: this.props.tintColor }, { minWidth: 24, minHeight: 24 }]}
          testID='access-icon-image'
          resizeMode='cover'
        />
        { showAccessIcon &&
          <View style={styles.publishedIconContainer}>
            <Image source={icon} style={iconStyle} testID='access-icon-icon' />
          </View>
        }
      </View>
    )
  }
}

const styles = createStyleSheet(colors => ({
  container: {
    flex: 0,
    alignItems: 'center',
  },
  publishedIconContainer: {
    justifyContent: 'center',
    alignItems: 'center',
    position: 'absolute',
    bottom: -6,
    right: -5,
    backgroundColor: colors.backgroundLightest,
    height: 16,
    width: 16,
    borderRadius: 8,
  },
  publishedIcon: {
    height: 12,
    width: 12,
    tintColor: colors.textSuccess,
  },
  unpublishedIcon: {
    height: 12,
    width: 12,
    tintColor: colors.textDark,
  },
  restrictedIcon: {
    height: 14,
    width: 14,
    tintColor: colors.textWarning,
  },
}))
