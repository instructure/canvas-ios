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
  FlatList,
  Image,
  StyleSheet,
} from 'react-native'
import Screen from '../../routing/Screen'
import Colors from '../../common/colors'
import Images from '../../images'
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
        navBarTitleColors={Colors.darkText}
        navBarButtonColor={Colors.link}
        drawUnderNavBar
      >
        <FlatList
          style={styles.container}
          data={Object.keys(options)}
          renderItem={({ item: key }) =>
            <Row
              key={key}
              border='bottom'
              title={options[key]}
              titleStyles={{ fontWeight: 'normal' }}
              onPress={() => onSelect(key)}
              accessories={
                key === selectedValue &&
                <Image
                  style={styles.check}
                  source={Images.check}
                />
              }
              accessibilityTraits={key === selectedValue ? ['button', 'selected'] : 'button'}
            />
          }
        />
      </Screen>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: Colors.grey1,
  },
  check: {
    tintColor: Colors.checkmarkGreen,
    height: 20,
    width: 20,
    resizeMode: 'contain',
    marginLeft: global.style.defaultPadding,
  },
})
