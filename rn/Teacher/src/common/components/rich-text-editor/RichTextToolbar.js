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

/* @flow */

import React, { Component } from 'react'
import {
  TouchableHighlight,
  Image,
  ScrollView,
  View,
  LayoutAnimation,
  NativeModules,
} from 'react-native'

import ColorPicker, { getColors } from './ColorPicker'
import icon, { type InstIconName } from '../../../images/inst-icons'
import { colors, createStyleSheet } from '../../stylesheet'
import i18n from 'format-message'

type Props = {
  active?: string[],
  setBold?: () => void,
  setItalic?: () => void,
  setTextColor?: (color: string) => void,
  setUnorderedList?: () => void,
  setOrderedList?: () => void,
  insertLink?: () => void,
  insertImage?: ?(() => void),
  onTappedDone?: () => void,
  onColorPickerShown?: (shown: boolean) => void,
}

type State = {
  colorPickerVisible: boolean,
}

type Item = {
  image: InstIconName,
  state: ?string,
  action: string,
  accessibilityLabel: string,
}

function item (image: InstIconName, state: ?string, action: string, accessibilityLabel: string): Item {
  return { image, state, action, accessibilityLabel }
}

const ColorPickerAnimation = {
  duration: 200,
  create: {
    type: LayoutAnimation.Types.linear,
    property: LayoutAnimation.Properties.opacity,
    springDamping: 0.7,
  },
  update: {
    type: LayoutAnimation.Types.spring,
    springDamping: 0.7,
  },
}

const { NativeAccessibility } = NativeModules

export default class RichTextToolbar extends Component<Props, State> {
  state: State = {
    colorPickerVisible: false,
  }

  COLORS = getColors()

  render () {
    const ITEMS = [
      item('reply', null, 'undo', i18n('Undo')),
      item('forward', null, 'redo', i18n('Redo')),
      item('bold', 'bold', 'setBold', i18n('Bold')),
      item('italic', 'italic', 'setItalic', i18n('Italic')),
      item('textColor', null, 'setTextColor', ''),
      item('bulletList', 'unorderedList', 'setUnorderedList', i18n('Unordered List')),
      item('numberedList', 'orderedList', 'setOrderedList', i18n('Ordered List')),
      item('link', null, 'insertLink', i18n('Insert Link')),
      item('image', null, 'insertImage', i18n('Insert Image')),
    ]

    return (
      <View style={styles.container}>
        { this.state.colorPickerVisible && this.props.setTextColor &&
          <ColorPicker pickedColor={this._pickColor} />
        }
        <View style={styles.itemsContainer}>
          <ScrollView horizontal={true}>
            {ITEMS.filter((item) => this.props[item.action]).map((item) => {
              return (
                <TouchableHighlight
                  style={styles.item}
                  onPress={this._actionForItem(item)}
                  underlayColor={colors.backgroundLight}
                  key={item.action}
                  testID={`rich-text-toolbar-item-${item.action}`}
                  accessibilityLabel={item.accessibilityLabel || this.getTextColorLabel()}
                  accessibilityTraits={['button']}
                >
                  {this._renderItem(item)}
                </TouchableHighlight>
              )
            })}
          </ScrollView>
        </View>
      </View>
    )
  }

  getTextColor () {
    const textColorKey = this.props.active && this.props.active.find((s) => s.startsWith('textColor'))
    return (textColorKey && textColorKey.split(':')[1] || '#2D3B45').replace(/\brgba?\s*\(\s*(\d+)\D+(\d+)\D+(\d+)\D*(\d+)?\D*\)/g, (s, r, g, b, a) => {
      return '#' + [a || 255, r, g, b]
        .map(n => (+n).toString(16).padStart(2, '0'))
        .join('')
        .replace(/^ff/i, '')
        .toUpperCase()
    })
  }

  getTextColorLabel () {
    const colorHex = this.getTextColor()
    const colorName = this.COLORS[colorHex]
    return colorName
      ? i18n('Text Color {colorName} ({colorHex})', { colorName, colorHex })
      : i18n('Text Color ({colorHex})', { colorHex })
  }

  _renderItem ({ image, state }: Item) {
    if (image === 'textColor') {
      const textColor = this.getTextColor()
      const style = {
        backgroundColor: textColor,
        borderWidth: isWhite(textColor) ? 1 : 0,
        borderColor: isWhite(textColor) ? colors.borderMedium : 'transparent',
      }
      return (
        <View style={styles.textColor}>
          <Image source={icon(image, 'solid')} style={styles.icon} />
          <View style={[styles.textColorSwatch, style]} />
        </View>
      )
    }
    const isActive = (this.props.active || []).includes(state)
    const tintColor = isActive ? colors.primary : colors.textDarkest
    return <Image source={icon(image, 'solid')} style={[styles.icon, { tintColor }]} />
  }

  _toggleColorPicker = () => {
    const shown = !this.state.colorPickerVisible
    LayoutAnimation.configureNext(ColorPickerAnimation, () => {
      if (this.props.onColorPickerShown) {
        this.props.onColorPickerShown(shown)
      }
    })
    this.setState({ colorPickerVisible: shown })
    setTimeout(function () { NativeAccessibility.focusElement('color-picker.options') }, 500)
  }

  _pickColor = (color: string) => {
    this.setState({ colorPickerVisible: false })
    this.props.setTextColor && this.props.setTextColor(color)
  }

  _actionForItem = (item: Item): Function => {
    switch (item.action) {
      case 'setTextColor':
        return this._toggleColorPicker
      default:
        return this.props[item.action]
    }
  }
}

function isWhite (color: string): boolean {
  const whites = ['white', 'rgb(255,255,255)', '#fff', '#ffffff']
  return whites.includes(color.toLowerCase().replace(/[ ]/g, ''))
}

const styles = createStyleSheet((colors) => ({
  container: {
    flexDirection: 'column',
    backgroundColor: colors.backgroundLightest,
    justifyContent: 'flex-end',
  },
  itemsContainer: {
    borderTopWidth: 1,
    borderTopColor: colors.borderMedium,
    backgroundColor: colors.backgroundLightest,
  },
  item: {
    width: 50,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 8,
  },
  icon: {
    tintColor: colors.textDarkest,
    height: 24,
    width: 24,
  },
  textColor: {
    width: 24,
    height: 24,
  },
  textColorSwatch: {
    position: 'absolute',
    bottom: 2,
    height: 5,
    left: 2.5,
    right: 2.5,
  },
}))
