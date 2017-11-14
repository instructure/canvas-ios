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

const COLORS = [
  'white',
  'black',
  '#8B969E',
  '#EC463D',
  '#E42565',
  '#8E4195',
  '#654C9B',
  '#4656A2',
  '#2684C2',
  '#3BA5DA',
  '#2EBCD1',
  '#219588',
  '#479F4B',
  '#8CC152',
  '#FBBF40',
  '#F69637',
  '#ED5A34',
  '#EE6491',
]

export default class ColorPicker extends Component<Props, any> {
  render () {
    return (
      <View style={styles.container}>
        <ScrollView horizontal={true} testID={'color-picker.options'}>
          <View style={styles.scrollViewContent}>
            {COLORS.map((color) => {
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
                  accessibilityLabel={`${i18n('Choose')} ${color}`}
                  accessibilityTraits={['button']}
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
