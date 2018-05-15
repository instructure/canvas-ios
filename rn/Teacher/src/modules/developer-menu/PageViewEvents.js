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

const { PageViewEventLogger } = NativeModules

type Props = {}

export default class PageViewEvents extends Component<Props, any> {
  data () {
    const eventsJSONStr = PageViewEventLogger.allEvents()
    let events = JSON.parse(eventsJSONStr)
    events = events.map((o) => {
      let attr = o['attributes']
      delete o['attributes']
      return { ...o, url: attr['url'] }
    }).filter((o) => { return o.eventName !== '/dev-menu' && o.eventName !== '/page-view-events' })
    return events
  }

  render () {
    let events = this.data()

    return (
      <Screen
        title='Page View Events'
        rightBarButtons={[{
          title: 'Clear',
          action: this.clearAllEvents,
          testID: 'page-view-events.action.clear',
        }, {
          title: 'Copy',
          action: this.copyAll,
          testID: 'page-view-events.action.copy-all',
        },
        ]}
      >
        <View style={{ flex: 1 }}>
          <FlatList
            data={events.reverse()}
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

  clearAllEvents = async () => {
    await PageViewEventLogger.clearAllEvents()
    this.setState({})
  }

  copyAll = () => {
    const events = this.data()
    Clipboard.setString(JSON.stringify(events, null, 2))
  }
}
