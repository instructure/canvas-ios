//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
