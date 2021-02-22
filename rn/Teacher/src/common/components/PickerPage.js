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
  FlatList,
  Image,
} from 'react-native'
import Screen from '../../routing/Screen'
import { createStyleSheet } from '../stylesheet'
import icon from '../../images/inst-icons'
import Row from './rows/Row'

type Props = {
  onSelect: (string) => any,
  options: { [string]: string },
  selectedValue: string,
  title: string,
}

export default class PickerPage extends Component<Props> {
  render () {
    const { onSelect, options, selectedValue, title } = this.props
    return (
      <Screen
        title={title}
        drawUnderNavBar
      >
        <FlatList
          style={styles.container}
          data={Object.keys(options)}
          renderItem={({ item: key }) =>
            <Row
              key={key}
              style={styles.row}
              border='bottom'
              title={options[key]}
              titleStyles={{ fontWeight: 'normal' }}
              onPress={() => onSelect(key)}
              accessories={
                key === selectedValue &&
                <Image
                  style={styles.check}
                  source={icon('check', 'solid')}
                />
              }
              accessibilityState={{ selected: (key === selectedValue) }}
            />
          }
        />
      </Screen>
    )
  }
}

const styles = createStyleSheet((colors, vars) => ({
  container: {
    backgroundColor: colors.backgroundGrouped,
  },
  row: {
    backgroundColor: colors.backgroundGroupedCell,
  },
  check: {
    tintColor: colors.textSuccess,
    height: 20,
    width: 20,
    resizeMode: 'contain',
    marginLeft: vars.padding,
  },
}))
