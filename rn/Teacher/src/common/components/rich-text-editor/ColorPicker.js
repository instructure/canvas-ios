//
// Copyright (C) 2017-present Instructure, Inc.
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

/* @flow */

import React, { Component } from 'react'
import {
  View,
  ScrollView,
  StyleSheet,
  TouchableHighlight,
} from 'react-native'

import i18n from 'format-message'

type Props = {
  pickedColor: (color: string) => void,
}

export default class ColorPicker extends Component<Props, any> {
  COLORS = {
    'white': i18n('white'),
    '#2D3B45': i18n('black'),
    '#8B969E': i18n('grey'),
    '#EE0612': i18n('red'),
    '#FC5E13': i18n('orange'),
    '#FFC100': i18n('yellow'),
    '#89C540': i18n('green'),
    '#1482C8': i18n('blue'),
    '#65469F': i18n('purple'),
  }

  render () {
    return (
      <View style={styles.container}>
        <ScrollView horizontal={true} testID={'color-picker.options'}>
          <View style={styles.scrollViewContent}>
            {Object.keys(this.COLORS).map(color => {
              const style = {
                backgroundColor: color,
                borderWidth: color === 'white' ? 1 : 0,
                borderColor: color === 'white' ? '#E6E9EA' : 'transparent',
              }
              return (
                <TouchableHighlight
                  style={styles.optionContainer}
                  onPress={() => this.props.pickedColor(color)}
                  key={color}
                  testID={`color-picker-option-${color}`}
                  underlayColor='transparent'
                  accessibilityLabel={i18n('Set text color to {colorName} ({hexCode})', {
                    colorName: this.COLORS[color],
                    hexCode: color,
                  })}
                  accessibilityTraits='button'
                >
                  <View style={[styles.option, style]} />
                </TouchableHighlight>
              )
            })}
          </View>
        </ScrollView>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    borderTopWidth: 1,
    borderTopColor: '#C7CDD1',
    backgroundColor: 'white',
  },
  optionContainer: {
    width: 44,
    height: 44,
  },
  option: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    margin: 6,
    borderRadius: 19,
  },
  scrollViewContent: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
  },
})
