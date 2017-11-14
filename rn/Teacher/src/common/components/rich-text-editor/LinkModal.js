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
  View,
  Button,
  TextInput,
  Text,
} from 'react-native'
import KeyboardSpacer from 'react-native-keyboard-spacer'
import Screen from '../../../routing/Screen'

type Props = {
  visible: boolean,
  title?: ?string,
  url?: ?string,
  linkUpdated: (url: string, title: string) => void,
  linkCreated: (url: string, title: string) => void,
  onCancel: () => void,
}

export default class LinkModal extends Component<Props, any> {
  constructor (props: Props) {
    super(props)

    this.state = {
      title: props.title,
      url: props.url,
    }
  }

  render () {
    return (
      <Screen backgroundColor='rgba(0,0,0,0.5)'>
        <View style={{ flex: 1, backgroundColor: 'transparent' }}>
          <View style={styles.container}>
            <View style={styles.innerContainer}>
              <Text style={styles.titleText}>
                Link to Website URL
              </Text>
              <View style={styles.textInputContainer}>
                <TextInput
                  placeholder='Title'
                  style={styles.textInput}
                  defaultValue={this.props.title}
                  autoCapitalize='none'
                  testID='rich-text-editor.link-modal.titleInput'
                  onChangeText={ (title) => this.setState({ title })}
                  autoFocus={ typeof (jest) === 'undefined' }
                />
              </View>
              <View style={styles.textInputContainer}>
                <TextInput
                  style={styles.textInput}
                  defaultValue={this.props.url}
                  placeholder='URL'
                  keyboardType='url'
                  autoCapitalize='none'
                  autoCorrect={false}
                  testID='rich-text-editor.link-modal.urlInput'
                  onChangeText={ (url) => this.setState({ url })}
                />
              </View>
              <View style={[styles.separator, { height: 1, marginTop: 6 }]}/>
              <View style={styles.actionsContainer}>
                <View style={styles.actionContainer}>
                  <Button
                    title='Cancel'
                    testID='rich-text-editor.link-modal.cancelButton'
                    onPress={this._onPressCancel}
                  />
                </View>
                <View style={[styles.separator, { width: 1 }]}/>
                <View style={styles.actionContainer}>
                  <Button
                    title='OK'
                    testID='rich-text-editor.link-modal.okButton'
                    onPress={this._onPressOK}
                  />
                </View>
              </View>
            </View>
          </View>
          <KeyboardSpacer />
        </View>
      </Screen>
    )
  }

  componentWillReceiveProps (nextProps: Props) {
    if (!this.props.visible) {
      this.setState({
        title: nextProps.title,
        url: nextProps.url,
      })
    }
  }

  _onPressOK = () => {
    let url = this.state.url
    if (url && !url.startsWith('http://') && !url.startsWith('https://')) {
      url = `http://${url}`
    }
    this.props[this.props.url ? 'linkUpdated' : 'linkCreated'](url, this.state.title)
  }

  _onPressCancel = () => {
    this.props.onCancel()
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    backgroundColor: 'transparent',
    padding: 50,
  },
  innerContainer: {
    flexDirection: 'column',
    backgroundColor: '#e9e9e9',
    alignItems: 'stretch',
    borderRadius: 8,
    overflow: 'hidden',
  },
  titleText: {
    paddingTop: 15,
    paddingBottom: 15,
    fontSize: 18,
    textAlign: 'center',
  },
  textInputContainer: {
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#ddd',
    marginLeft: 10,
    marginRight: 10,
    marginBottom: 4,
    padding: 4,
  },
  textInput: {
    height: 20,
  },
  actionsContainer: {
    flexDirection: 'row',
  },
  actionContainer: {
    flex: 1,
  },
  separator: {
    backgroundColor: '#ddd',
  },
})
