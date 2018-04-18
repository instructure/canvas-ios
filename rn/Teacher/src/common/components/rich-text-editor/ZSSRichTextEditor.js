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
  StyleSheet,
  WebView,
  NativeModules,
  Clipboard,
} from 'react-native'

import isEqual from 'lodash/isEqual'
import RNFS from 'react-native-fs'
import canvas from './../../../canvas-api'

const { NativeFileSystem } = NativeModules

type Props = {
  onLoad?: () => void,
  onFocus?: () => void,
  onBlur?: () => void,
  editorItemsChanged?: (items: string[]) => void,
  scrollEnabled?: boolean,
  navigator: Navigator,
  getFile: typeof canvas.getFile,
}

type State = {
  source: ?string,
  linkModalVisible: boolean,
  items: string[],
}

function extractFileID (string: string): ?string {
  // cant have spaces
  if (string.indexOf(' ') >= 0) {
    return null
  }

  // make sure it's a download url
  const urlMatcher = /^https:\/\/.*[^\s]\/files\/\d+\/download$/
  if (!string.match(urlMatcher)) {
    return null
  }

  const match = string.match(/files\/\d+\/download/)

  // $FlowFixMe - `match` is guaranteed to be defined because of previous check
  return match[0].split('/')[1]
}

export default class ZSSRichTextEditor extends Component<Props, State> {
  static defaultProps = {
    getFile: canvas.getFile,
  }

  webView: ?WebView
  showingLinkModal: boolean
  onHTML: ?((string) => void)

  state: State = {
    linkModalVisible: false,
    items: [],
    source: null,
  }

  async componentDidMount () {
    const path = await NativeFileSystem.pathForResource('zss-rich-text-editor', 'html')
    const source = await RNFS.readFile(`file://${path}`)
    this.setState({ source })
  }

  render () {
    return (
      <WebView
        source={{ html: this.state.source || '', baseUrl: RNFS.MainBundlePath }}
        ref={webView => { this.webView = webView }}
        onMessage={this._onMessage}
        onLoad={this._onLoad}
        scalesPageToFit={true}
        scrollEnabled={this.props.scrollEnabled === undefined || this.props.scrollEnabled}
        style={styles.editor}
        hideKeyboardAccessoryView={true}
      />
    )
  }

  // PUBLIC ACTIONS

  setBold = () => {
    this.trigger('zss_editor.setBold();')
  }

  setItalic = () => {
    this.trigger('zss_editor.setItalic();')
  }

  insertLink = () => {
    this.trigger(`
      var selection = getSelection().toString();
      postMessage(JSON.stringify({type: 'INSERT_LINK', data: selection}));
    `)
  }

  prepareInsert = () => {
    this.trigger('zss_editor.prepareInsert();')
  }

  updateHTML = (html: ?string) => {
    const cleanHTML = this._escapeJSONString(html || '')
    this.trigger(`zss_editor.setHTML("${cleanHTML}");`)
  }

  setCustomCSS = (css?: string) => {
    if (!css) { css = '' }
    this.trigger(`zss_editor.setCustomCSS('${css}');`)
  }

  setUnorderedList = () => {
    this.trigger(`zss_editor.setUnorderedList();`)
  }

  setOrderedList = () => {
    this.trigger(`zss_editor.setOrderedList();`)
  }

  setTextColor = (color: string) => {
    this.prepareInsert()
    this.trigger(`zss_editor.setTextColor('${color}');`)
  }

  focusEditor = () => {
    this.trigger('zss_editor.focusEditor();')
  }

  blurEditor = () => {
    this.trigger('zss_editor.blurEditor();')
  }

  getHTML = async () => {
    const promise = new Promise((resolve, reject) => {
      this.onHTML = resolve
    })
    this.trigger(`zss_editor.postHTML();`)
    return promise
  }

  undo = () => {
    this.trigger('zss_editor.undo();')
  }

  redo = () => {
    this.trigger('zss_editor.redo();')
  }

  setContentHeight = (height: number) => {
    this.trigger(`zss_editor.contentHeight = ${height};`)
  }

  setPlaceholder = (placeholder: ?string) => {
    if (placeholder) {
      this.trigger(`zss_editor.setPlaceholder('${placeholder}');`)
    } else {
      this.trigger(`zss_editor.setPlaceholder(null);`)
    }
  }

  insertImage = (url: string) => {
    this.trigger(`zss_editor.insertImage('${url}');`)
  }

  insertVideoComment = (mediaID: string) => {
    this.trigger(`zss_editor.insertVideoComment('${mediaID}');`)
  }

  insertHTML = (html: string) => {
    this.trigger(`zss_editor.insertHTML('${html}');`)
  }

  trigger = async (js: string) => {
    if (!this.webView) return
    try {
      await this.webView.injectJavaScript(js)
    } catch (e) {}
  }

  // PRIVATE

  _onMessage = (event) => {
    const message = JSON.parse(event.nativeEvent.data)
    switch (message.type) {
      case 'CALLBACK':
        this._handleItemsCallback(message.data)
        break
      case 'LINK_TOUCHED':
        this._handleLinkTouched(message.data)
        break
      case 'INSERT_LINK':
        this._handleInsertLink(message.data)
        break
      case 'ZSS_LOADED':
        this._onZSSLoaded()
        break
      case 'EDITOR_FOCUSED':
        this._handleFocus()
        break
      case 'EDITOR_BLURRED':
        this._handleBlur()
        break
      case 'EDITOR_HTML':
        this._handleHTML(message.data)
        break
      case 'EDITOR_PASTE':
        this._handlePaste()
        break
    }
  }

  _handlePaste = async () => {
    let string = await Clipboard.getString()
    if (!string) return

    try {
      let fileID = extractFileID(string)
      if (fileID) {
        let { data } = await this.props.getFile(fileID)
        this.prepareInsert()
        if (data.mime_class === 'image') {
          this.insertImage(data.url)
        } else {
          this.insertHTML(string)
        }
      } else {
        this.prepareInsert()
        this.insertHTML(string)
      }
    } catch (error) {
      this.prepareInsert()
      this.insertHTML(string)
    }
  }

  _handleItemsCallback = (items) => {
    if (isEqual(items, this.state.items)) {
      return
    }

    this.setState({ items })

    if (this.props.editorItemsChanged) {
      this.props.editorItemsChanged(items)
    }
  }

  _handleLinkTouched = (link) => {
    this.prepareInsert()
    this._showLinkModal(link.url, link.title)
  }

  _handleInsertLink = (selection) => {
    this.prepareInsert()
    this._showLinkModal(null, selection)
  }

  _handleHTML = (value) => {
    this.onHTML && this.onHTML(value)
  }

  _insertLink = (url, title) => {
    this.trigger(`zss_editor.insertLink("${url}", "${title}");`)
    this._hideLinkModal()
  }

  _updateLink = (url, title) => {
    this.trigger(`zss_editor.updateLink("${url}", "${title}");`)
    this._hideLinkModal()
  }

  _showLinkModal (url, title) {
    if (this.showingLinkModal) return
    this.showingLinkModal = true
    this.props.navigator.show(
      '/rich-text-editor/link',
      {
        modal: true,
        modalPresentationStyle: 'overCurrentContext',
        modalTransitionStyle: 'fade',
        embedInNavigationController: false,
      },
      {
        url: url,
        title: title,
        linkUpdated: this._updateLink,
        linkCreated: this._insertLink,
        onCancel: this._hideLinkModal,
      },
    )
  }

  _hideLinkModal = () => {
    this.props.navigator.dismiss()
    this.focusEditor()
    this.showingLinkModal = false
  }

  _onZSSLoaded = async () => {
    this.setCustomCSS()
    await this._setVideoPreviewImagePath()
    this.props.onLoad && this.props.onLoad()
  }

  _onLoad = () => {
    this._zssInit()
  }

  _zssInit () {
    this.trigger('zss_editor.init();')
  }

  _handleFocus () {
    if (this.props.onFocus) {
      this.props.onFocus()
    }
  }

  _handleBlur () {
    if (this.props.onBlur) {
      this.props.onBlur()
    }
  }

  _setVideoPreviewImagePath = async () => {
    const path = await NativeFileSystem.pathForResource('video-preview', 'png')
    await this.trigger(`zss_editor.videoPreviewImagePath = '${path}';`)
  }

  // UTILITIES

  _escapeJSONString (string) {
    return string
      .replace(/[\\]/g, '\\\\')
      .replace(/["]/g, '\\"')
      .replace(/[/]/g, '\\/')
      .replace(/[\b]/g, '\\b')
      .replace(/[\f]/g, '\\f')
      .replace(/[\n]/g, '\\n')
      .replace(/[\r]/g, '\\r')
      .replace(/[\t]/g, '\\t')
  }
}

const styles = StyleSheet.create({
  editor: {
    backgroundColor: 'transparent',
    flex: 1,
    flexDirection: 'column',
  },
})
