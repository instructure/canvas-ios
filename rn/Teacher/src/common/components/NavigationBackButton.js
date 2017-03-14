// @flow

import React from 'react'
import { View, Image, StyleSheet } from 'react-native'
import Button from 'react-native-button'
import Images from '../../images'

export default class NavigationBackButton extends React.Component {
  render (): React.Element<View> {
    return <Button style={styles.backButton} {...this.props}>
            <View style={{ paddingRight: 31 }}>
              <Image source={Images.backIcon} style={styles.navButtonImage} />
            </View>
           </Button>
  }
}

const styles = StyleSheet.create({
  backButton: {
    color: 'white',
    backgroundColor: 'transparent',
  },
})
