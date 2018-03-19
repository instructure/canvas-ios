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
} from 'react-native'

import isEqual from 'lodash/isEqual'
import RNFS from 'react-native-fs'

type Props = {
  onInputChange?: (value: string) => void,
  onHeightChange?: (height: number) => void,
  onLoad?: () => void,
  onFocus?: () => void,
  onBlur?: () => void,
  editorItemsChanged?: (items: string[]) => void,
  scrollEnabled?: boolean,
  navigator: Navigator,
}

type State = {
  source: ?string,
  linkModalVisible: boolean,
  lastHeightUpdate: number,
  items: string[],
}

export default class ZSSRichTextEditor extends Component<Props, State> {
  webView: ?WebView
  showingLinkModal: boolean

  state: State = {
    linkModalVisible: false,
    lastHeightUpdate: 0,
    items: [],
    source: null,
  }

  async componentDidMount () {
    const path = `${RNFS.MainBundlePath}/zss-rich-text-editor.html`
    const source = await RNFS.readFile(path)
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
    this.trigger('zss_editor.setBold();', true)
  }

  setItalic = () => {
    this.trigger('zss_editor.setItalic();', true)
  }

  insertLink = () => {
    this.trigger(`
      var selection = getSelection().toString();
      postMessage(JSON.stringify({type: 'INSERT_LINK', data: selection}));
    `, true)
  }

  prepareInsert = () => {
    this.trigger('zss_editor.prepareInsert();')
  }

  updateHTML = (html: ?string) => {
    const cleanHTML = this._escapeJSONString(html || '')
    this.trigger(`zss_editor.setHTML("${cleanHTML}");`, true)
  }

  setCustomCSS = (css?: string) => {
    if (!css) { css = '' }
    this.trigger(`zss_editor.setCustomCSS('${css}');`, true)
  }

  setUnorderedList = () => {
    this.trigger(`zss_editor.setUnorderedList();`, true)
  }

  setOrderedList = () => {
    this.trigger(`zss_editor.setOrderedList();`, true)
  }

  setTextColor = (color: string) => {
    this.prepareInsert()
    this.trigger(`zss_editor.setTextColor('${color}');`, true)
  }

  focusEditor = () => {
    this.trigger('zss_editor.focusEditor();')
  }

  blurEditor = () => {
    this.trigger('zss_editor.blurEditor();')
  }

  getHTML = () => {
    this.trigger(`setTimeout(function() { zss_editor.postInput() }, 1);`)
  }

  undo = () => {
    this.trigger('zss_editor.undo();', true)
  }

  redo = () => {
    this.trigger('zss_editor.redo();', true)
  }

  setNeedsHeightUpdate = () => {
    this.trigger(`
      var height = $('#zss_editor_content').height();
      postMessage(JSON.stringify({type: 'HEIGHT_UPDATE', data: height}));
    `)
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
    this.trigger(`zss_editor.insertImage('${url}');`, true)
  }

  insertVideoComment = (uri: string, mediaID: string) => {
    this.trigger(`zss_editor.insertVideoComment('${uri}', '${mediaID}');`, true)
  }

  trigger = async (js: string, inputChanged?: boolean) => {
    if (!this.webView) return
    try {
      await this.webView.injectJavaScript(js)
      if (inputChanged) {
        setTimeout(this.getHTML, 100)
      }
    } catch (error) {
      // dont crash
    }
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
      case 'EDITOR_INPUT':
        this._handleInput(message.data)
        break
      case 'HEIGHT_UPDATE':
        this._handleHeight(message.data)
        break
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

  _handleInput = (value) => {
    if (this.props.onInputChange) {
      this.props.onInputChange(value)
    }
    this.setNeedsHeightUpdate()
  }

  _insertLink = (url, title) => {
    this.trigger(`zss_editor.insertLink("${url}", "${title}");`, true)
    this._hideLinkModal()
  }

  _updateLink = (url, title) => {
    this.trigger(`zss_editor.updateLink("${url}", "${title}");`, true)
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

  _onZSSLoaded = () => {
    this.setCustomCSS()
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

  _handleHeight (height: number) {
    if (this.props.onHeightChange && height !== this.state.lastHeightUpdate) {
      this.setState({ lastHeightUpdate: height })
      // $FlowFixMe
      this.props.onHeightChange(height)
    }
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
