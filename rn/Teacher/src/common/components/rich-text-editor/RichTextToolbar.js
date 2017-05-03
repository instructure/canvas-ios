/* @flow */

import React, { Component } from 'react'
import {
  StyleSheet,
  TouchableHighlight,
  Image,
  ScrollView,
  View,
  LayoutAnimation,
} from 'react-native'

import { ColorPicker } from './'
import images from '../../../images'
import colors from '../../colors'

type Props = {
  active?: string[],
  setBold?: () => void,
  setItalic?: () => void,
  setTextColor?: (color: string) => void,
  setUnorderedList?: () => void,
  setOrderedList?: () => void,
  insertLink?: () => void,
  insertImage?: () => void,
  onTappedDone: () => void,
}

type Item = {
  image: string,
  action: string,
}

function item (image: string, action: string): Item {
  return { image, action }
}

const ITEMS = [
  item('undo', 'undo'),
  item('redo', 'redo'),
  item('bold', 'setBold'),
  item('italic', 'setItalic'),
  item('textColor', 'setTextColor'),
  item('unorderedList', 'setUnorderedList'),
  item('orderedList', 'setOrderedList'),
  item('link', 'insertLink'),
  item('embedImage', 'insertImage'),
]

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

export default class RichTextToolbar extends Component<any, Props, any> {
  constructor (props: Props) {
    super(props)

    this.state = {
      colorPickerVisible: false,
    }
  }

  render () {
    const height = this.state.colorPickerVisible ? 100 : 50
    return (
      <View style={[styles.container, { height }]}>
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
                  underlayColor={colors.grey1}
                  key={item.image}
                  testID={`rich-text-toolbar-item-${item.image}`}
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

  _renderItem ({ image }: Item) {
    switch (image) {
      case 'textColor':
        const textColorKey = this.props.active && this.props.active.find((s) => s.startsWith('textColor'))
        const textColor = textColorKey && textColorKey.split(':')[1]
        const style = {
          backgroundColor: textColor || 'black',
          borderWidth: textColor && isWhite(textColor) ? 1 : 0,
          borderColor: textColor && isWhite(textColor) ? '#E6E9EA' : 'transparent',
        }
        return <View style={[styles.textColor, style]} />
      default:
        const isActive = (this.props.active || []).includes(image) && images.rce.active[image]
        const icon = (isActive ? images.rce.active : images.rce)[image]
        return <Image source={icon} />
    }
  }

  _toggleColorPicker = () => {
    LayoutAnimation.configureNext(ColorPickerAnimation)
    this.setState({ colorPickerVisible: !this.state.colorPickerVisible })
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
  const whites = ['white', 'rgb(255,255,255)']
  return whites.includes(color.replace(/[ ]/g, ''))
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'column',
    backgroundColor: 'white',
    justifyContent: 'flex-end',
  },
  itemsContainer: {
    borderTopWidth: 1,
    borderTopColor: '#C7CDD1',
    backgroundColor: 'white',
  },
  item: {
    width: 50,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 8,
  },
  textColor: {
    width: 26,
    height: 26,
    borderRadius: 13,
  },
})
