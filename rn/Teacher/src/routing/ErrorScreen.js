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
  StyleSheet,
} from 'react-native'
import Screen from './Screen'
import i18n from 'format-message'
import { Text } from '../common/text'
import { colors } from '../common/stylesheet'

export default class ErrorScreen extends Component<*> {
  render () {
    let screenProps = {}
    if (!this.props.navigator.isModal) {
      screenProps.navBarColor = colors.navBackground
      screenProps.navBarStyle = 'dark'
    }
    return (
      <Screen
        title={i18n('Error')}
        {...screenProps}
      >
        <View style={styles.container}>
          <Text style={styles.heading}>{i18n('Whoops!')}</Text>
          <Text style={styles.text}>
            {i18n("Something went wrong on our end. Don't worry, we've recorded this and will be taking care of it shortly.")}
          </Text>
        </View>
      </Screen>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
  },
  heading: {
    fontSize: 32,
    fontWeight: '300',
    margin: 8,
  },
  text: {
    textAlign: 'center',
  },
})
