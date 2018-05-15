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
  StyleSheet,
  TouchableOpacity,
  ScrollView,
} from 'react-native'

import { Text } from '../../../common/text'
import color from '../../../common/colors'
import i18n from 'format-message'
import branding from '../../../common/branding'

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
    const textStyle = selected ? [styles.selectedButtonText, { color: branding.primaryBrandColor }] : styles.buttonText
    return (
      <TouchableOpacity testID={`inbox.filter-btn-${item.scope}`} style={styles.button} key={item.scope} onPress={() => this._onPress(item.scope)} accessibilityTraits={selected ? ['button', 'selected'] : 'button'}>
        <Text style={textStyle}>{item.name}</Text>
        { selected &&
          <View
            style={[styles.selectedLine, { backgroundColor: branding.primaryBrandColor }]}
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

const styles = StyleSheet.create({
  container: {
    height: 44,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: color.seperatorColor,
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
    color: color.grey4,
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
    backgroundColor: branding.primaryBrandColor,
  },
})
