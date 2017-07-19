/* @flow */

import React, { Component } from 'react'
import ZSSRichTextEditor from './ZSSRichTextEditor'
import RichTextToolbar from './RichTextToolbar'
import KeyboardSpacer from 'react-native-keyboard-spacer'
import {
  StyleSheet,
  View,
  NativeModules,
} from 'react-native'

export type Props = {
  onChangeValue?: (value: string) => void,
  onChangeHeight?: (height: number) => void,
  defaultValue?: string,
  showToolbar?: 'never' | 'always' | 'onFocus',
  keyboardAware?: boolean,
  scrollEnabled?: boolean,
  contentHeight?: number,
  placeholder?: string,
  focusOnLoad?: boolean,
}

export default class RichTextEditor extends Component<any, Props, any> {
  editor: ZSSRichTextEditor

  constructor (props: Props) {
    super(props)

    this.state = {
      activeEditorItems: [],
      editorFocused: false,
    }
  }

  render () {
    return (
      <View style={styles.container}>
        <View style={styles.editor}>
          <ZSSRichTextEditor
            ref={(editor) => { this.editor = editor }}
            html={this.props.defaultValue}
            onLoad={this._onLoad}
            onFocus={this._onFocus}
            onBlur={this._onBlur}
            editorItemsChanged={this._onEditorItemsChanged}
            onInputChange={this.props.onChangeValue}
            onHeightChange={this.props.onChangeHeight}
            scrollEnabled={this.props.scrollEnabled === undefined || this.props.scrollEnabled}
          />
        </View>
        { this.toolbarShown() &&
          <RichTextToolbar
            setBold={this._setBold}
            setItalic={this._setItalic}
            setUnorderedList={this._setUnorderedList}
            setOrderedList={this._setOrderedList}
            insertLink={this._insertLink}
            setTextColor={this._setTextColor}
            active={this.state.activeEditorItems}
            undo={this._undo}
            redo={this._redo}
            onColorPickerShown={this._handleColorPickerShown}
          />
        }
        { (this.props.keyboardAware === undefined || this.props.keyboardAware) &&
          <KeyboardSpacer />
        }
      </View>
    )
  }

  // EDITOR EVENTS

  _onLoad = () => {
    NativeModules.WebViewHacker.removeInputAccessoryView()
    NativeModules.WebViewHacker.setKeyboardDisplayRequiresUserAction(false)
    if (this.props.contentHeight) {
      this.editor.setContentHeight(this.props.contentHeight)
    }
    if (this.props.placeholder) {
      this.editor.setPlaceholder(this.props.placeholder)
    }
    if (this.props.focusOnLoad) {
      this.editor.focusEditor()
    }
  }

  _onEditorItemsChanged = (activeEditorItems: string[]) => {
    this.setState({ activeEditorItems })
  }

  _onFocus = () => {
    this.setState({ editorFocused: true })
  }

  _onBlur = () => {
    this.setState({ editorFocused: false })
  }

  _handleColorPickerShown = (shown) => {
    const colorPickerHeight = 46
    if (shown) {
      this.editor.trigger(`
        var scrollTop = $(window).scrollTop();
        $(window).scrollTop(scrollTop+${colorPickerHeight});
      `)
    }
    if (this.props.contentHeight) {
      this.editor.setContentHeight(shown ? this.props.contentHeight - colorPickerHeight : this.props.contentHeight)
    }
  }

  // TOOLBAR EVENTS

  _setBold = () => {
    this.editor.setBold()
  }
  _setItalic = () => { this.editor.setItalic() }
  _setUnorderedList = () => { this.editor.setUnorderedList() }
  _setOrderedList = () => { this.editor.setOrderedList() }
  _insertLink = () => { this.editor.insertLink() }
  _setTextColor = (color: string) => { this.editor.setTextColor(color) }
  _undo = () => { this.editor.undo() }
  _redo = () => { this.editor.redo() }

  toolbarShown (): boolean {
    switch (this.props.showToolbar) {
      case 'always':
        return true
      case undefined:
      case null:
      case 'onFocus':
        return this.state.editorFocused
      default:
        return false
    }
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column',
  },
  editor: {
    flex: 1,
    paddingTop: global.style.defaultPadding / 1.25,
    paddingBottom: global.style.defaultPadding / 1.25,
    paddingLeft: global.style.defaultPadding,
    paddingRight: global.style.defaultPadding,
  },
})
