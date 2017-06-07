// @flow

import React, { PureComponent } from 'react'
import {
  AsyncStorage,
  View,
  Image,
  StyleSheet,
  Animated,
} from 'react-native'
import { LinkButton } from '../../../common/buttons'
import { Text } from '../../../common/text'
import i18n from 'format-message'

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

export default class Tutorial extends PureComponent {
  props: Props
  state: State
  opacity: Animated.Value

  constructor (props: Props) {
    super(props)

    this.state = {
      hasLoaded: false,
      hasSeen: {},
      currentTutorial: null,
    }

    this.opacity = new Animated.Value(0)
  }

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
    ).start()
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
      ).start(resolve)
    })

    this.setState({
      hasSeen,
      currentTutorial: nextTutorial,
    })
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
          <Text style={styles.text}>{currentTutorial.text}</Text>
          <Image style={styles.image} source={currentTutorial.image} />
          <LinkButton
            style={styles.button}
            onPress={this.onPress}
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
    alignItems: 'center',
    shadowColor: 'black',
    shadowRadius: 10,
    shadowOpacity: 0.5,
    shadowOffset: { width: 0, height: 10 },
  },
  text: {
    fontWeight: '600',
    fontSize: 18,
  },
  button: {
    fontSize: 16,
    fontWeight: '600',
  },
  image: {
    marginVertical: 24,
  },
})
