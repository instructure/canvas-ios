/**
 * @flow
 */

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
} from 'react-native'
import i18n from 'format-message'
import { Heading1, Paragraph } from '../../../common/text'
import { Button } from '../../../common/buttons'

type Props = {
  onAddCoursePressed: () => void,
}

export class NoCourses extends Component {
  props: Props

  render () {
    let welcome = i18n('Welcome!')

    let bodyText = i18n('Add a few of your favorite courses to make this place your home.')

    let buttonText = i18n('Add Courses')

    return (
      <View style={style.container}>
        <Heading1 testID='mt-fav-courses.welcome-lbl'>{welcome}</Heading1>
        <Paragraph
          style={style.paragraph} testID='mt-fav-courses.descr-lbl'>{bodyText}</Paragraph>
        <Button accessibilityLabel={buttonText} testID='mt-fav-courses.add-courses-btn' onPress={this.props.onAddCoursePressed}>
          {buttonText}
        </Button>
      </View>
    )
  }
}

const style = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
  },
  paragraph: {
    textAlign: 'center',
    padding: 15,
  },
})

export default (NoCourses: any)
