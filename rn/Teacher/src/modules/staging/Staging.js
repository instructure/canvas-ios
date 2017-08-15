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
import { route, type RouteOptions } from '../../routing'
import Navigator from '../../routing/Navigator'
import Screen from '../../routing/Screen'

const stagingKey = 'teacher.staging.path'

type StagingProps = {
  navigator: Navigator,
}

export default class Staging extends Component<any, StagingProps, any> {
  componentDidMount = () => {
    AsyncStorage.getItem(stagingKey)
      .then(path => this.setState({ path }))
  }

  navigate = (nav: (route: RouteOptions) => void) => {
    let path = this.state && this.state.path || ''
    try {
      let r = route(path)
      nav(r)
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

  forceCrash = () => {
    // $FlowFixMe
    this.fakeFunction()
  }

  go = () => {
    this.navigate(route => this.props.navigator.show(route.screen, {}, route.passProps))
  }

  modal = () => {
    this.navigate(route => this.props.navigator.show(route.screen, { modal: true }, route.passProps))
  }

  close = () => {
    this.props.navigator.dismiss()
  }

  render () {
    const path = this.state && this.state.path || ''
    return (
      <Screen
        title='Dev Menu'
        leftBarButtons={[
          {
            action: this.close,
            title: 'Close',
          },
        ]}>
        <View style={styles.mainContainer} >
          <TextInput
            value={ path }
            autoFocus={ typeof (jest) === 'undefined' }
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
          <View style={styles.purge}>
            <Button onPress={ this.forceCrash }>
              Force Crash
            </Button>
          </View>
        </View>
      </Screen>
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
