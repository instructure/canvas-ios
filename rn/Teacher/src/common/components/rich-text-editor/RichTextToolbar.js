/* @flow */

import React, { Component } from 'react'
import {
  StyleSheet,
  TouchableHighlight,
  Image,
  ScrollView,
  View,
  Button,
} from 'react-native'

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

export default class RichTextToolbar extends Component<any, Props, any> {
  render () {
    return (
      <View style={styles.container}>
        <ScrollView horizontal={true}>
          {ITEMS.filter((item) => this.props[item.action]).map((item) => {
            return (
              <TouchableHighlight
                style={styles.item}
                onPress={this.props[item.action]}
                underlayColor={colors.grey1}
                key={item.image}
                testID={`rich-text-toolbar-item-${item.image}`}
              >
                {this._renderItem(item)}
              </TouchableHighlight>
            )
          })}
        </ScrollView>
        <View style={styles.doneContainer}>
          <Button
            style={styles.done}
            onPress={this.props.onTappedDone}
            title='Done'
            color='white'
            testID='rich-text-toolbar-item-done'
          />
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
}

function isWhite (color: string): boolean {
  const whites = ['white', 'rgb(255,255,255)']
  return whites.includes(color.replace(/[ ]/g, ''))
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
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
  doneContainer: {
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: colors.primaryButtonColor,
    margin: 10,
    borderRadius: 8,
    overflow: 'hidden',
  },
})
