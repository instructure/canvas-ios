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
import Screen from '../../routing/Screen'
import {
  View,
  TextInput,
  StyleSheet,
  NativeModules,
  Alert,
  Image,
  TouchableHighlight,
  Animated,
} from 'react-native'
import i18n from 'format-message'
import Images from '../../images'
import { Text, Heading2 } from '../../common/text'
import colors from '../../common/colors'
import { getSession } from '../../canvas-api/session'
import URL from 'url-parse'
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view'

export default class Masquerade extends Component<*, any> {
  animatedOpacity = new Animated.Value(0)
  domainTextInput: TextInput
  userIdTextInput: TextInput

  constructor (props: Object) {
    super(props)
    const session = getSession()
    const url = URL(session.baseURL)
    const domain = url.host
    this.state = {
      userId: '',
      domain,
      submitButtonDisabled: true,
    }
  }

  async componentDidMount () {
    Animated.loop(
      Animated.sequence([
        Animated.timing(
          this.animatedOpacity,
          {
            toValue: 1,
            duration: 1000,
            delay: 2000,
          }
        ),
        Animated.timing(
          this.animatedOpacity,
          {
            toValue: 0,
            duration: 1000,
            delay: 4000,
          }
        ),
      ]),
    ).start()
  }

  nextInput = () => {
    this.domainTextInput.focus()
  }

  finishInput = () => {
    this.domainTextInput.blur()
  }

  updateUserId = (userId: string) => {
    this.setState({
      userId,
      submitButtonDisabled: !userId || !this.state.domain,
    })
  }

  updateDomain = (domain: string) => {
    this.setState({
      domain,
      submitButtonDisabled: !this.state.userId || !domain,
    })
  }

  submit = async () => {
    try {
      await NativeModules.NativeLogin.masquerade(this.state.userId, this.state.domain)
      await this.props.navigator.dismiss()
    } catch (e) {
      Alert.alert(i18n('Error'), i18n('There was an error with Act as User. Please try again later.'))
    }
  }

  render () {
    const buttonTraits = ['button']
    if (this.state.submitButtonDisabled) {
      buttonTraits.push('disabled')
    }
    const translateY = this.animatedOpacity.interpolate({
      inputRange: [0, 1],
      outputRange: [15, 0],
    })
    const translateX = this.animatedOpacity.interpolate({
      inputRange: [0, 1],
      outputRange: [-60, 0],
    })
    const rotate = this.animatedOpacity.interpolate({
      inputRange: [0, 1],
      outputRange: ['-30deg', '0deg'],
    })
    return (<Screen
      title={i18n('Act as User')}
    >
      <KeyboardAwareScrollView extraScrollHeight={16}>
        <View style={styles.container}>
          <View style={styles.header}>
            <View style={styles.innerHeader}>
              <Image source={Images.masquerade.whitePanda} style={styles.whitePanda} />
              <Animated.Image source={Images.masquerade.redPanda} style={[styles.redPanda, { transform: [{ translateY }, { translateX }, { rotate }] }]} />
            </View>
          </View>
          <View style={styles.infoContainer}>
            <Text style={styles.infoText}>
              { i18n("\"Act as\" is essentially logging in as this user without a password. You will be able to take any action as if you were this user, and from other users' points of view, as if this user performed them. However, audit logs record that you were the one who performed the actions on behalf of this user.") }
            </Text>
          </View>
          <View style={styles.textInputContainer}>
            <TextInput
              placeholder={i18n('User ID')}
              style={styles.textInput}
              returnKeyType={'next'}
              ref={(r: any) => { this.userIdTextInput = r }}
              onSubmitEditing={ this.nextInput }
              onChangeText={this.updateUserId}
              autoCapitalize="none"
              autoCorrect={false}
              value={this.state.userId} />
          </View>
          <View style={styles.textInputContainer}>
            <TextInput
              placeholder={i18n('Domain')}
              style={styles.textInput}
              returnKeyType={'done'}
              ref={(r: any) => { this.domainTextInput = r }}
              onSubmitEditing={ this.finishInput }
              onChangeText={this.updateDomain}
              autoCapitalize="none"
              autoCorrect={false}
              value={this.state.domain} />
          </View>
          <TouchableHighlight
            style={[styles.submitButton, this.state.submitButtonDisabled ? { opacity: 0.5 } : undefined]}
            onPress={this.submit}
            disabled={this.state.submitButtonDisabled}
            accessibilityTraits={buttonTraits}>
            <View style={styles.submitButtonContainer}>
              <Heading2 style={styles.submitButtonText}>{i18n('Act as User')}</Heading2>
            </View>
          </TouchableHighlight>
        </View>
      </KeyboardAwareScrollView>
    </Screen>)
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 24,
  },
  header: {
    alignItems: 'center',
    marginBottom: 40,
  },
  innerHeader: {
    height: 103,
    width: 84,
  },
  infoContainer: {
    marginBottom: 24,
  },
  infoText: {
    fontSize: 14,
  },
  redPanda: {
    height: 103,
    width: 74,
    position: 'absolute',
    left: 5,
  },
  whitePanda: {
    height: 103,
    width: 84,
  },
  textInputContainer: {
    height: 50,
    padding: global.style.defaultPadding,
    marginBottom: 12,
    justifyContent: 'center',
    borderWidth: StyleSheet.hairlineWidth,
    borderRadius: 4,
    borderColor: colors.grey2,
  },
  textInput: {
    fontSize: 16,
  },
  submitButton: {
    height: 50,
    borderRadius: 4,
  },
  submitButtonContainer: {
    flex: 1,
    backgroundColor: '#008EE2',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 4,
  },
  submitButtonText: {
    color: 'white',
    fontSize: 16,
  },
})
