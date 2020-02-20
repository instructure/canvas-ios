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
import {
  View,
  Image,
  TouchableOpacity,
} from 'react-native'
import i18n from 'format-message'

import { Text } from '../../../common/text'
import icon from '../../../images/inst-icons'
import { createStyleSheet } from '../../../common/stylesheet'
import Avatar from '../../../common/components/Avatar'
import { personDisplayName } from '../../../common/formatters'

type Props = {
  item: AddressBookResult,
  delete: (id: string) => void,
  canDelete: boolean,
}

export default class AddressBookToken extends Component<Props, any> {
  static defaultProps = {
    canDelete: true,
  }

  _delete = () => {
    this.props.delete(this.props.item.id)
  }

  render () {
    const { name, pronouns } = this.props.item
    const recipientAccessibilityLabel = i18n('Recipient: { recipient }', {
      recipient: name,
    })
    const deleteButtonAccessibilityLabel = i18n('Delete recipient { recipient }', {
      recipient: name,
    })
    return (
      <View style={styles.token} accessibilityLabel={recipientAccessibilityLabel}>
        { this.props.item.avatar_url &&
          <Avatar
            avatarURL={this.props.item.avatar_url}
            userName={this.props.item.name}
            height={TOKEN_HEIGHT - 6}
          />
        }
        <Text
          key={this.props.item.id}
          style={{ marginLeft: TOKEN_SUBVIEW_SPACING }}
          testID={`message-recipient.${this.props.item.id}.label`}
        >
          {personDisplayName(name, pronouns)}
        </Text>
        {this.props.canDelete &&
          <TouchableOpacity
            onPress={this._delete}
            accessible={true}
            accessibilityLabel={deleteButtonAccessibilityLabel}
            accessibilityTraits={['button']}
            style={styles.deleteButton}
            testID={`message-recipient.${this.props.item.id}.delete-btn`}
          >
            <Image source={icon('x', 'line')} style={styles.deleteIcon} />
          </TouchableOpacity>
        }
      </View>
    )
  }
}

const TOKEN_HEIGHT = 30
const TOKEN_SUBVIEW_SPACING = 8
const styles = createStyleSheet(colors => ({
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
    backgroundColor: colors.backgroundLight,
  },
  deleteButton: {
    padding: TOKEN_SUBVIEW_SPACING,
    marginRight: -TOKEN_SUBVIEW_SPACING,
  },
  deleteIcon: {
    tintColor: colors.textDarkest,
    width: 12,
    height: 12,
  },
}))
