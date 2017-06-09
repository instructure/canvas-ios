/* @flow */

import React, { Component } from 'react'
import ZSSRichTextEditor from './ZSSRichTextEditor'
import RichTextToolbar from './RichTextToolbar'
import Screen from '../../../routing/Screen'
import KeyboardSpacer from 'react-native-keyboard-spacer'
import {
  StyleSheet,
  View,
  NativeModules,
} from 'react-native'

type Props = {
  onChangeValue: (value: string) => void,
  defaultValue: string,
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
      <Screen>
        <View style={styles.container}>
          <ZSSRichTextEditor
            ref={(editor) => { this.editor = editor }}
            html={this.props.defaultValue}
            onLoad={this._onLoad}
            onFocus={this._onFocus}
            onBlur={this._onBlur}
            editorItemsChanged={this._onEditorItemsChanged}
            onInputChange={this.props.onChangeValue}
          />
          { this.state.editorFocused &&
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
            />
          }
          <KeyboardSpacer />
        </View>
      </Screen>
    )
  }

  // EDITOR EVENTS

  _onLoad = () => {
    NativeModules.WebViewHacker.removeInputAccessoryView()
    NativeModules.WebViewHacker.setKeyboardDisplayRequiresUserAction(false)
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
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column',
  },
})
