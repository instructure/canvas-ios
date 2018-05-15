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
  View,
  Text,
  StyleSheet,
  Image,
  TouchableOpacity,
} from 'react-native'
import i18n from 'format-message'

import Images from '../../../images'
import colors from '../../../common/colors'
import Avatar from '../../../common/components/Avatar'

type Props = {
  item: AddressBookResult,
  delete: (id: string) => void,
}

export default class AddressBookToken extends Component<Props, any> {
  _delete = () => {
    this.props.delete(this.props.item.id)
  }

  render () {
    const recipientAccessibilityLabel = i18n('Recipient: { recipient }', {
      recipient: this.props.item.name,
    })
    const deleteButtonAccessibilityLabel = i18n('Delete recipient { recipient }', {
      recipient: this.props.item.name,
    })
    let leftTextPadding = this.props.item.avatar_url ? TOKEN_SUBVIEW_SPACING : 8
    return (
      <View style={styles.token} accessibilityLabel={recipientAccessibilityLabel}>
        { this.props.item.avatar_url &&
          <Avatar avatarURL={this.props.item.avatar_url} userName={this.props.item.name} height={TOKEN_HEIGHT - 6}/>
        }
        <Text key={this.props.item.id} style={{ marginLeft: leftTextPadding }}>{this.props.item.name}</Text>
        <TouchableOpacity
          onPress={this._delete}
          accessible={true}
          accessibilityLabel={deleteButtonAccessibilityLabel}
          accessibilityTraits={['button']}
          testID={`message-recipient.${this.props.item.id}.delete-btn`}
        >
          <Image source={Images.x} style={styles.deleteIcon} />
        </TouchableOpacity>
      </View>
    )
  }
}

const TOKEN_HEIGHT = 30
const TOKEN_SUBVIEW_SPACING = 8
const styles = StyleSheet.create({
  token: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    marginVertical: 4,
    marginRight: 6,
    paddingRight: 12,
    paddingLeft: 2,
    height: TOKEN_HEIGHT,
    borderRadius: TOKEN_HEIGHT / 2,
    backgroundColor: '#EBEDEE',
  },
  deleteIcon: {
    marginLeft: TOKEN_SUBVIEW_SPACING,
    tintColor: colors.darkText,
    width: 12,
    height: 12,
  },
})
