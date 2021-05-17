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
  TouchableOpacity,
  ScrollView,
} from 'react-native'

import { Text } from '../../../common/text'
import { colors, createStyleSheet } from '../../../common/stylesheet'
import i18n from 'format-message'

export type InboxFilterHeaderProps = {
  selected: InboxScope,
  onFilterChange: (InboxScope) => void,
}

export default class InboxFilterHeader extends Component<InboxFilterHeaderProps, any> {
  constructor (props: InboxFilterHeaderProps) {
    super(props)
    const filters = [{ name: i18n('All'), scope: 'all' },
      { name: i18n('Unread'), scope: 'unread' },
      { name: i18n('Starred'), scope: 'starred' },
      { name: i18n('Sent'), scope: 'sent' },
      { name: i18n('Archived'), scope: 'archived' }]

    this.state = {
      filters,
    }
  }

  _onPress = (scope: InboxScope) => {
    this.props.onFilterChange(scope)
  }

  _renderButton = (item: any) => {
    const selected = this.props.selected === item.scope
    const textStyle = selected ? [styles.selectedButtonText, { color: colors.primary }] : styles.buttonText
    return (
      <TouchableOpacity testID={`inbox.filter-btn-${item.scope}`} style={styles.button} key={item.scope} onPress={() => this._onPress(item.scope)} accessibilityRole={['button']} accessibilityState={{ selected: selected }}>
        <Text style={textStyle}>{item.name}</Text>
        { selected &&
          <View
            style={[styles.selectedLine, { backgroundColor: colors.primary }]}
          />
        }
      </TouchableOpacity>
    )
  }

  render () {
    return (<View style={styles.container}>
      <ScrollView horizontal={true} contentContainerStyle={styles.scrollView}>
        {this.state.filters.map((item) => {
          return this._renderButton(item)
        })}
      </ScrollView>
    </View>)
  }
}

const styles = createStyleSheet((colors, vars) => ({
  container: {
    height: 44,
    borderBottomWidth: vars.hairlineWidth,
    borderBottomColor: colors.borderMedium,
  },
  scrollView: {
    flex: 0,
    alignItems: 'center',
  },
  button: {
    height: 44,
    justifyContent: 'center',
    paddingLeft: 16,
    paddingRight: 16,
  },
  buttonText: {
    fontSize: 14,
    fontWeight: '600',
    color: colors.textDark,
  },
  selectedButtonText: {
    fontSize: 14,
    fontWeight: '600',
  },
  selectedLine: {
    position: 'absolute',
    height: 3,
    bottom: 0,
    left: 8,
    right: 8,
    backgroundColor: colors.primary,
  },
}))
