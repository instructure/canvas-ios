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

export default class InboxFilterHeader extends Component<any, InboxFilterHeaderProps, any> {

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
    const textStyle = [selected ? styles.selectedButtonText : styles.buttonText, { color: branding.primaryBrandColor }]
    return (
      <TouchableOpacity testID={`inbox.filter-btn-${item.scope}`} style={styles.button} key={item.scope} onPress={() => this._onPress(item.scope)}>
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
    flex: 1,
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
  },
})
