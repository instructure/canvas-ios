// @flow
import React, { Component } from 'react'
import ReactNative, {
  TouchableHighlight,
  View,
  StyleSheet,
  Image,
} from 'react-native'
import i18n from 'format-message'
import Images from '../../../../images/'

type Props = {
  color: string,
  onPress: (color: string) => void,
  selected: boolean,
}

export default class ColorButton extends Component {
  props: Props

  onPress = (event: ReactNative.NativeSyntheticEvent) => {
    this.props.onPress(this.props.color)
  }

  render (): React.Element<*> {
    return (
      <TouchableHighlight
        style={styles.button}
        accessibilityLabel={i18n({
          default: 'Choose {color}',
          description: 'Accessibility label to select a color',
        }, { color: this.props.color })}
        onPress={this.onPress}
        underlayColor='#fff'
        testID={`colorButton.${this.props.color}`}
      >
        <View
          style={[styles.color, { backgroundColor: this.props.color }]}
        >
          {this.props.selected &&
            <Image source={Images.check} />
          }
        </View>
      </TouchableHighlight>
    )
  }
}

const styles = StyleSheet.create({
  button: {
    height: 48,
    margin: 8,
  },
  color: {
    width: 48,
    height: 48,
    borderRadius: 24,
    alignItems: 'center',
    justifyContent: 'center',
  },
})
