import React, { Component } from 'react'
import {
  View,
  Image,
  Button,
  NativeModules,
  StyleSheet,
} from 'react-native'
import i18n from 'format-message'
import { Text } from '../../common/text'

import { getSession } from '../../api/session'

export default class Profile extends Component {

  logout = () => {
    const nativeLogin = NativeModules.NativeLogin
    nativeLogin.logout()
  }

  render (): React.Element {
    const session = getSession()
    const user = session.user
    return (
      <View testID="module.profile" accessible={true} style={styles.container}>
        <View style={styles.headerImage} />
        <View style={styles.bottomContainer}>
          <Image source={ { uri: user.avatar_url } } style={styles.profileImage} />
          <Text style={styles.nameLabel}>{user.name}</Text>
          <Text style={styles.emailLabel}>{user.primary_email}</Text>
          <Button
            onPress={this.logout}
            title={i18n('Logout')} />
        </View>
        </View>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  bottomContainer: {
    flex: 1,
    alignItems: 'center',
    top: -60,
  },
  headerImage: {
    height: 200,
    backgroundColor: 'lightgrey',
  },
  profileImage: {
    width: 120,
    height: 120,
    borderRadius: 60,
    borderColor: 'white',
    borderWidth: 5,
    marginBottom: 8,
  },
  nameLabel: {
    fontSize: 18,
  },
  emailLabel: {
    color: 'grey',
    fontWeight: '200',
  },
})
