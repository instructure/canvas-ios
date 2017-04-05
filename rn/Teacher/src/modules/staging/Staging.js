// @flow

import React, { Component } from 'react'
import {
  View,
  TextInput,
  StyleSheet,
  Alert,
  AsyncStorage,
 } from 'react-native'
import { Button } from '../../common/buttons'
import { route } from '../../routing'

const stagingKey = 'teacher.staging.path'

class Staging extends Component<*, NavProps, *> {
  componentDidMount = () => {
    AsyncStorage.getItem(stagingKey)
      .then(path => this.setState({ path }))
  }

  navigate = (nav: (screen: any) => void) => {
    let path = this.state && this.state.path || ''
    try {
      let screen = route(path)
      nav(screen)
      AsyncStorage.setItem(stagingKey, path)
    } catch (e) {
      Alert.alert(
        'Route Not Found',
        `No route was found matching '${path}'`,
        [
          { text: 'Dismiss' },
        ],
      )
    }
  }

  purgeStorage = () => {
    AsyncStorage.clear()
  }

  go = () => {
    this.navigate(screen => this.props.navigator.push(screen))
  }

  modal = () => {
    this.navigate(screen => this.props.navigator.showModal(screen))
  }

  render () {
    const path = this.state && this.state.path || ''
    return (
      <View style={styles.mainContainer} >
        <TextInput
          value={ path }
          autoFocus={ true }
          placeholder='Path'
          ref='url'
          keyboardType='url'
          returnKeyLabel='Go!'
          returnKeyType='go'
          onChangeText={(path) => {
            this.setState({ path })
          }}
          onSubmitEditing={ this.go }
          style={styles.urlInput} />
        <View style={ styles.buttonRow }>
          <Button
            testID='staging.modal-button'
            onPress={ this.modal }
            style={ styles.buttonText }>
            Modal!
            </Button>
          <View style={{ paddingLeft: 8 }}>
            <Button
              testID='staging.go-button'
              onPress={ this.go }
              style={ styles.buttonText }>
              Push!
            </Button>
          </View>
        </View>
        <View style={styles.purge}>
          <Button
            onPress={ this.purgeStorage }
          >
            Purge AsyncStorage
          </Button>
        </View>
      </View>
    )
  }
}

let styles = StyleSheet.create({
  mainContainer: {
    flex: 1,
    padding: 30,
    marginTop: 64,
    flexDirection: 'column',
    backgroundColor: 'white',
  },
  urlInput: {
    paddingLeft: 20,
    paddingRight: 20,
    fontSize: 18,
    height: 44,
    borderWidth: 1,
    borderColor: '#BBB',
    borderRadius: 8,
  },
  buttonText: {
    color: 'white',
    fontSize: 18,
    alignSelf: 'center',
    paddingBottom: 2,
    width: 72,
  },
  buttonRow: {
    flexDirection: 'row',
    paddingTop: 12,
    justifyContent: 'flex-end',
  },
  purge: {
    marginTop: 16,
  },
})

export default Staging
