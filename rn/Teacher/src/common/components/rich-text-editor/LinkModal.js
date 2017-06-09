/* @flow */

import React, { Component } from 'react'
import {
  StyleSheet,
  View,
  Button,
  Modal,
  TextInput,
  Text,
} from 'react-native'
import KeyboardSpacer from 'react-native-keyboard-spacer'

type Props = {
  visible: boolean,
  title?: ?string,
  url?: ?string,
  linkUpdated: () => void,
  linkCreated: () => void,
  onCancel: () => void,
}

export default class LinkModal extends Component<any, Props, any> {
  constructor (props: Props) {
    super(props)

    this.state = {
      title: props.title,
      url: props.url,
    }
  }

  render () {
    return (
      <Modal
        animationType='fade'
        transparent={true}
        visible={this.props.visible}
      >
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
                  style={styles.action}
                  testID='rich-text-editor.link-modal.cancelButton'
                  onPress={this._onPressCancel}
                />
              </View>
              <View style={[styles.separator, { width: 1 }]}/>
              <View style={styles.actionContainer}>
                <Button
                  title='OK'
                  style={styles.action}
                  testID='rich-text-editor.link-modal.okButton'
                  onPress={this._onPressOK}
                />
              </View>
            </View>
          </View>
        </View>
        <KeyboardSpacer />
      </Modal>
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
    this.props[this.props.url ? 'linkUpdated' : 'linkCreated'](this.state.url, this.state.title)
  }

  _onPressCancel = () => {
    this.props.onCancel()
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
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
