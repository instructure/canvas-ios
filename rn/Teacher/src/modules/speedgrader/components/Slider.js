//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// @flow

import React, { Component } from 'react'
import {
  View,
  Animated,
  PanResponder,
  Image,
  requireNativeComponent,
  AccessibilityInfo,
  TouchableHighlight,
} from 'react-native'
import i18n from 'format-message'
import { Text } from '../../../common/text'
import { createStyleSheet } from '../../../common/stylesheet'
import Images from '../../../images/index'

const AdjustableView = requireNativeComponent('Adjustable')
const AnimatedAdjustable = Animated.createAnimatedComponent(AdjustableView)

type Props = {
  excused: boolean,
  score: number,
  pointsPossible: number,
  excuseAssignment: () => void,
  setScrollEnabled: (boolean) => void,
  setScore: (string) => void,
}

type State = {
  showTooltip: boolean,
  noGrade: boolean,
  excused: boolean,
}

export default class Slider extends Component<Props, State> {
  panResponder: PanResponder
  value: number
  scoringTimeout: TimeoutID
  noGradeTimeout: TimeoutID
  excusedTimeout: TimeoutID
  value: number = 0
  width: number = 1
  slide: Animated.Value = new Animated.Value(0)
  tooltipPop: Animated.Value = new Animated.Value(1)

  constructor (props: Props) {
    super(props)
    this.state = {
      width: 0,
      showTooltip: false,
      noGrade: props.score == null && !props.excused,
      excused: props.excused,
    }
  }

  componentWillMount () {
    // Add a listener for the delta value change
    this.slide.addListener(({ value }) => {
      let newValue = this.capValue(value)
      if (newValue === this.value) return
      clearTimeout(this.excusedTimeout)
      clearTimeout(this.noGradeTimeout)

      if (this.state.excused && newValue !== this.width) {
        this.setState({ excused: false })
      } else if (this.state.noGrade && newValue !== 0) {
        this.setState({ noGrade: false })
      } else if (newValue === 0) {
        this.noGradeTimeout = setTimeout(() => {
          this.popTooltip()
          this.setState({
            noGrade: true,
          })
        }, 1000)
      } else if (newValue === this.width) {
        this.excusedTimeout = setTimeout(() => {
          this.popTooltip()
          this.setState({
            excused: true,
          })
        }, 1000)
      }
      this.value = newValue
      requestAnimationFrame(() => this.forceUpdate())
    })

    // Initialize PanResponder with move handling
    this.panResponder = PanResponder.create({
      onStartShouldSetPanResponder: (evt, gestureState) => true,
      onStartShouldSetPanResponderCapture: (evt, gestureState) => true,
      onMoveShouldSetPanResponder: (evt, gestureState) => true,
      onMoveShouldSetPanResponderCapture: (evt, gestureState) => true,
      onPanResponderGrant: () => {
        this.props.setScrollEnabled(false)
        this.setState({
          showTooltip: true,
          excused: false,
          noGrade: false,
        })
      },
      onPanResponderMove: Animated.event([
        null, { dx: this.slide },
      ]),
      onShouldBlockNativeResponder: () => false,
      onPanResponderRelease: () => this.interactionFinished(),
      onPanResponderTerminate: () => this.interactionFinished(),
    })
  }

  componentWillUnmount () {
    clearTimeout(this.scoringTimeout)
    clearTimeout(this.noGradeTimeout)
    clearTimeout(this.excusedTimeout)
  }

  popTooltip = () => {
    Animated.sequence([
      Animated.timing(this.tooltipPop, {
        toValue: 1.1,
        duration: 100,
      }),
      Animated.timing(this.tooltipPop, {
        toValue: 1,
        duration: 100,
      }),
    ]).start()
  }

  capValue = (value: number) => {
    return Math.min(Math.max(value, 0), this.width)
  }

  onLayout = (e: any) => {
    this.width = e.nativeEvent.layout.width - 30
    let value = this.determineSliderValue(this.state.excused, this.state.noGrade, this.props.score, this.props.pointsPossible)
    this.moveTo(value, false)
  }

  determineSliderValue = (excused: boolean, noGrade: boolean, score: number, pointsPossible: number) => {
    if (excused) {
      return this.width
    } else if (noGrade) {
      return 0
    } else {
      return this.determineSliderValueFromScore(score, pointsPossible)
    }
  }

  determineSliderValueFromScore = (score: number, pointsPossible: number): number => {
    let normalizedScore = Math.min(score, pointsPossible)
    let percentage = normalizedScore / pointsPossible
    return percentage * this.width
  }

  calculateScore = () => {
    if (this.state.noGrade) return i18n('No Grade')
    if (this.state.excused) return i18n('Excused')

    let cappedValue = this.capValue(this.value)
    let widthRelativeValue = cappedValue / this.width
    if (widthRelativeValue === 1) {
      return this.props.pointsPossible
    } else {
      return i18n.number(Math.round(widthRelativeValue * this.props.pointsPossible))
    }
  }

  setScore = () => {
    if (this.state.noGrade) {
      return this.props.setScore('')
    }

    if (this.state.excused) {
      return this.props.excuseAssignment()
    }

    let score = this.calculateScore()
    return this.props.setScore(score.toString())
  }

  interactionFinished = (timeout: number = 0) => {
    this.slide.setOffset(this.value)
    this.slide.setValue(0)
    this.props.setScrollEnabled(true)
    this.setState({ showTooltip: false })

    clearTimeout(this.scoringTimeout)
    this.scoringTimeout = setTimeout(this.setScore, timeout)
  }

  increment = () => {
    let increment = this.width / this.props.pointsPossible
    this.moveTo(this.value + increment, false)
    this.interactionFinished(1000)
    AccessibilityInfo.announceForAccessibility(this.calculateScore().toString())
  }

  decrement = () => {
    let decrement = this.width / this.props.pointsPossible
    this.moveTo(this.value - decrement, false)
    this.interactionFinished(1000)
    AccessibilityInfo.announceForAccessibility(this.calculateScore().toString())
  }

  moveTo = (value: number, saveScore: ?boolean = true) => {
    if (isNaN(value)) return
    let distance = this.capValue(value) - this.value
    this.slide.setValue(distance)
    if (saveScore) {
      this.interactionFinished()
    } else {
      this.slide.setOffset(this.value)
      this.slide.setValue(0)
    }
  }

  moveToScore = (score: string | number, saveScore: ?boolean = true) => {
    score = +score
    if (isNaN(score)) return
    let value = this.determineSliderValueFromScore(score, this.props.pointsPossible)
    this.moveTo(value, saveScore)
  }

  sliderAccessibilityLabel () {
    if (this.props.excused) {
      return i18n('Excused')
    } else if (this.props.score !== null) {
      return i18n(`{ score, number } out of {
        points, plural,
            one {# point}
          other {# points}
      } possible`, {
        score: this.props.score,
        points: this.props.pointsPossible,
      })
    } else {
      return i18n('No Grade')
    }
  }

  render () {
    let slideInterpolation = this.slide.interpolate({
      inputRange: [0, 0, this.width, this.width],
      outputRange: [0, 0, this.width, this.width],
    })
    const slideStyle = {
      transform: [{
        translateX: slideInterpolation,
      }],
    }

    const tooltipStyle = {
      transform: [{
        translateX: slideInterpolation,
      }, {
        scaleX: this.tooltipPop,
      }, {
        scaleY: this.tooltipPop,
      }],
    }

    return (
      <View style={styles.sliderContainer}>
        <TouchableHighlight
          underlayColor='transparent'
          onPress={() => this.moveTo(0)}
          accessibilityTraits={['button']}
          accessibilityLabel={i18n('Lowest possible score, 0')}
          testID='slider.zero'
        >
          <View><Text style={styles.zeroPoints}>{i18n.number(0)}</Text></View>
        </TouchableHighlight>
        <View style={styles.slider} onLayout={this.onLayout}>
          <View
            style={styles.line}
            hitSlop={{ top: 15, bottom: 15 }}
            onStartShouldSetResponder={() => true}
            onResponderRelease={(e) => this.moveTo(e.nativeEvent.locationX - 15)} // center the thumb
            testID='slider.line'
          />
          <AnimatedAdjustable
            accessible
            accessibilityLabel={this.sliderAccessibilityLabel()}
            style={[slideStyle, styles.thumb]}
            {...this.panResponder.panHandlers}
            onAccessibilityIncrement={this.increment}
            onAccessibilityDecrement={this.decrement}
            hitSlop={{ top: 5, right: 5, bottom: 5, left: 5 }}
            testID='slider.adjustable'
          />
        </View>
        <TouchableHighlight
          underlayColor='transparent'
          onPress={() => this.moveTo(this.width)}
          accessibilityTraits={['button']}
          accessibilityLabel={i18n('Highest possible score, { pointsPossible, number }', { pointsPossible: this.props.pointsPossible })}
          testID='slider.pointsPossible'
        >
          <View><Text style={styles.pointsPossible}>{i18n.number(this.props.pointsPossible)}</Text></View>
        </TouchableHighlight>
        {this.state.showTooltip &&
          <View style={styles.tooltipContainer}>
            <Animated.View style={[styles.tooltipBubble, slideStyle, tooltipStyle]}>
              <Text style={styles.tooltipText} testID='slider.tooltip-text'>{this.calculateScore().toString()}</Text>
              <Image source={Images.upArrow} style={styles.tooltipArrow} />
            </Animated.View>
          </View>
        }
      </View>
    )
  }
}

const styles = createStyleSheet(colors => ({
  sliderContainer: {
    display: 'flex',
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: 20,
    marginBottom: 8,
  },
  zeroPoints: {
    flex: 0,
    marginRight: 8,
  },
  pointsPossible: {
    flex: 0,
    marginLeft: 8,
  },
  slider: {
    flex: 1,
    justifyContent: 'center',
  },
  line: {
    height: 1,
    borderTopColor: colors.borderMedium,
    borderTopWidth: 1,
  },
  thumb: {
    position: 'absolute',
    left: 0,
    height: 30,
    width: 30,
    borderRadius: 15,
    borderColor: colors.borderMedium,
    borderWidth: 1,
    backgroundColor: colors.backgroundLightest,
    shadowRadius: 2,
    shadowColor: '#000',
    shadowOpacity: 0.25,
    shadowOffset: { width: 0, height: 2 },
  },
  tooltipContainer: {
    position: 'absolute',
    left: 0,
    right: 0,
    top: -50,
  },
  tooltipBubble: {
    backgroundColor: colors.backgroundDarkest,
    padding: 8,
    width: 82,
    borderRadius: 5,
    marginLeft: -8,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },
  tooltipText: {
    color: colors.textLightest,
    textAlign: 'center',
  },
  tooltipArrow: {
    tintColor: colors.backgroundDarkest,
    position: 'absolute',
    width: 15,
    height: 10,
    top: 30,
    transform: [{ rotate: '180deg' }],
  },
}))
