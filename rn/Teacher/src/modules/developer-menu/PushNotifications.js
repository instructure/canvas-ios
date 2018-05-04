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
  FlatList,
  NativeModules,
  Clipboard,
} from 'react-native'

import Screen from '../../routing/Screen'
import Row from '../../common/components/rows/Row'
import RowSeparator from '../../common/components/rows/RowSeparator'

const { PushNotifications } = NativeModules

type Props = {}

export default class PushNotificationsList extends Component<Props, any> {
  render () {
    return (
      <Screen
        title='Push Notifications'
      >
        <View style={{ flex: 1 }}>
          <FlatList
            data={PushNotifications.pushNotifications().reverse()}
            renderItem={this.renderRow}
            keyExtractor={(item, index) => `${index}`}
            ItemSeparatorComponent={RowSeparator}
          />
        </View>
      </Screen>
    )
  }

  renderRow = ({ item }: { item: any }) => {
    return (
      <Row
        title={JSON.stringify(item, null, 2)}
        onPress={this.onPress(item)}
      />
    )
  }

  onPress = (item: any) => () => {
    Clipboard.setString(JSON.stringify(item, null, 2))
  }
}
