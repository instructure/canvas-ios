/**
 * @flow
 */

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
} from 'react-native'
import i18n from 'format-message'
import { Heading1, Paragraph } from '../../common/text'
import { Button } from '../../common/buttons'

export class NoCourses extends Component {

  render (): React.Element<View> {
    let welcome = i18n({
      default: 'Welcome!',
      description: 'Welcome header text when user has no courses yet.',
    })

    let bodyText = i18n({
      default: 'Add a few of your favorite courses to make this place your home.',
      description: 'Body text when you do not have any courses on course list page.',
    })

    let buttonText = i18n({
      default: 'Add Courses',
      description: 'Button text to take action and add a course.',
    })

    return (
      <View style={style.container}>
        <Heading1 style={style.header}>{welcome}</Heading1>
        <Paragraph
          style={style.paragraph}>{bodyText}</Paragraph>
        <Button accessibilityLabel={buttonText}>
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

// TODO - this any needs to go away.
export default (NoCourses: any)
