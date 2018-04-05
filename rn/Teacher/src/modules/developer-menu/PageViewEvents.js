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
