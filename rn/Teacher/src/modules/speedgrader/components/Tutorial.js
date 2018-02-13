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

// @flow

import React, { PureComponent } from 'react'
import {
  AsyncStorage,
  View,
  Image,
  StyleSheet,
  Animated,
  NativeModules,
} from 'react-native'
import { LinkButton } from '../../../common/buttons'
import { Text } from '../../../common/text'
import i18n from 'format-message'

const { NativeAccessibility } = NativeModules

type TutorialType = {
  id: string,
  text: string,
  image: any,
}

type Props = {
  tutorials: Array<TutorialType>,
}

type State = {
  hasLoaded: boolean,
  hasSeen: { [string]: boolean },
  currentTutorial: ?TutorialType,
}

const SPEED_GRADER_TUTORIAL_KEY = 'speed-grader-tutorial'

export default class Tutorial extends PureComponent<Props, State> {
  state: State = {
    hasLoaded: false,
    hasSeen: {},
    currentTutorial: null,
  }
  opacity: Animated.Value = new Animated.Value(0)

  componentDidMount () {
    this.setup()
  }

  setup = async () => {
    let data = await AsyncStorage.getItem(SPEED_GRADER_TUTORIAL_KEY)
    let hasSeen = JSON.parse(data || '{}')

    this.setState({
      hasLoaded: true,
      hasSeen,
      currentTutorial: this.props.tutorials.find(({ id }) => !hasSeen[id]),
    })

    Animated.timing(
      this.opacity,
      {
        toValue: 1,
      }
    ).start(this.focusCurrentTutorial)
  }

  onPress = async () => {
    let currentTutorial = this.state.currentTutorial
    if (!currentTutorial) return null

    let hasSeen = {
      ...this.state.hasSeen,
      [currentTutorial.id]: true,
    }
    AsyncStorage.setItem(SPEED_GRADER_TUTORIAL_KEY, JSON.stringify(hasSeen))
    let nextTutorial = this.props.tutorials.find(({ id }) => !hasSeen[id])

    await new Promise(resolve => {
      if (nextTutorial) return resolve()
      Animated.timing(
        this.opacity,
        {
          toValue: 0,
        }
      ).start(() => {
        this.focusCurrentTutorial()
        resolve()
      })
    })

    this.setState({
      hasSeen,
      currentTutorial: nextTutorial,
    })
  }

  focusCurrentTutorial = () => {
    if (this.state.currentTutorial) {
      const current = this.state.currentTutorial
      const elementID = `${current.id}-title`
      setTimeout(() => {
        NativeAccessibility.focusElement(elementID)
      }, 500)
    }
  }

  render () {
    let currentTutorial = this.state.currentTutorial
    if (!this.state.hasLoaded) return null
    if (!currentTutorial) return null

    return (
      <Animated.View
        style={[
          styles.tutorial,
          {
            opacity: this.opacity,
          },
        ]}
      >
        <View style={styles.box}>
          <Text style={styles.text} testID={`${currentTutorial.id}-title`}>{currentTutorial.text}</Text>
          <Image style={styles.image} source={currentTutorial.image} />
          <LinkButton
            textStyle={styles.buttonText}
            onPress={this.onPress}
            hitSlop={{ top: 10, left: 10, right: 10, bottom: 10 }}
            underlayColor='#fff'
            testID={`tutorial.button-${currentTutorial.id}`}
          >
            {i18n('OK')}
          </LinkButton>
        </View>
      </Animated.View>
    )
  }
}

const styles = StyleSheet.create({
  tutorial: {
    position: 'absolute',
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    backgroundColor: 'white',
    borderRadius: 8,
    padding: 16,
    marginHorizontal: 40,
    shadowColor: 'black',
    shadowRadius: 10,
    shadowOpacity: 0.5,
    shadowOffset: { width: 0, height: 10 },
  },
  text: {
    fontWeight: '600',
    fontSize: 18,
    marginBottom: 16,
  },
  buttonText: {
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
  },
  image: {
    marginBottom: 24,
  },
})
