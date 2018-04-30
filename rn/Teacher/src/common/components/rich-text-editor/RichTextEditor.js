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
import ZSSRichTextEditor from './ZSSRichTextEditor'
import RichTextToolbar from './RichTextToolbar'
import KeyboardSpacer from 'react-native-keyboard-spacer'
import {
  StyleSheet,
  View,
  Dimensions,
  NativeModules,
} from 'react-native'

export type Props = {
  defaultValue?: ?string,
  showToolbar?: 'never' | 'always' | 'onFocus',
  keyboardAware?: boolean,
  scrollEnabled?: boolean,
  contentHeight?: number,
  placeholder?: string,
  focusOnLoad?: boolean,
  navigator: Navigator,
  attachmentUploadPath: ?string,
  onFocus?: Function,
}

type State = {
  activeEditorItems: string[],
  editorFocused: boolean,
  topKeyboardSpace: number,
  editorLoaded: boolean,
}

export default class RichTextEditor extends Component<Props, State> {
  editor: ZSSRichTextEditor
  container: View

  state: State = {
    activeEditorItems: [],
    editorFocused: false,
    topKeyboardSpace: 0,
    editorLoaded: false,
  }

  getHTML = async () => {
    return this.editor.getHTML()
  }

  onLayout = () => {
    this._setKeyboardSpace()
  }

  onKeyboardSpaceToggle = () => {
    this._setKeyboardSpace()
  }

  componentWillReceiveProps (newProps: Props) {
    if (newProps.defaultValue !== this.props.defaultValue) {
      this.editor.updateHTML(newProps.defaultValue)
    }
  }

  render () {
    return (
      <View
        style={styles.container}
        ref={this._captureContainer}
        onLayout={this.onLayout}
      >
        <ZSSRichTextEditor
          ref={(editor: any) => { this.editor = editor }}
          onLoad={this._onLoad}
          onFocus={this._onFocus}
          onBlur={this._onBlur}
          editorItemsChanged={this._onEditorItemsChanged}
          scrollEnabled={this.props.scrollEnabled === undefined || this.props.scrollEnabled}
          navigator={this.props.navigator}
        />
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
            insertImage={this.props.attachmentUploadPath ? this._insertImage : null}
          />
        }
        { (this.props.keyboardAware === undefined || this.props.keyboardAware) &&
          <KeyboardSpacer
            topSpacing={this.state.topKeyboardSpace}
            onToggle={this.onKeyboardSpaceToggle}
          />
        }
      </View>
    )
  }

  _captureContainer = (ref: any) => { this.container = ref }

  _setKeyboardSpace = () => {
    this.container.measureInWindow((x, y, width, height) => {
      const window = Dimensions.get('window')
      const space = (window.height - (y + height)) * -1
      this.setState({ topKeyboardSpace: space })
    })
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
    if (this.props.defaultValue) {
      this.editor.updateHTML(this.props.defaultValue)
    }

    this.setState({ editorLoaded: true })
  }

  _onEditorItemsChanged = (activeEditorItems: string[]) => {
    this.setState({ activeEditorItems })
  }

  _onFocus = () => {
    this._setKeyboardSpace()
    this.setState({ editorFocused: true })
    this.props.onFocus && this.props.onFocus()
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
  _insertImage = () => {
    this.editor.prepareInsert()
    this.props.navigator.show('/attachments', { modal: true }, {
      storageOptions: {
        uploadPath: this.props.attachmentUploadPath,
        mediaServer: true,
      },
      onComplete: this.insertAttachments,
      fileTypes: ['image', 'video'],
      userFiles: true,
    })
  }

  insertAttachments = (attachments: [Attachment]) => {
    // images
    const images = attachments.filter(a => a.mime_class === 'image')
    images.reverse().forEach(a => this.editor.insertImage(a.url))

    // videos
    const videos = attachments.filter(a => a.mime_class === 'video')
    videos
      .filter(a => a.media_entry_id)
      .reverse()
      .forEach(a => this.editor.insertVideoComment(a.media_entry_id))
  }

  toolbarShown (): boolean {
    if (!this.state.editorLoaded) {
      return false
    }

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
})
