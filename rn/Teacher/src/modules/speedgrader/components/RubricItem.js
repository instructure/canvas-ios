// @flow

import React, { Component } from 'react'
import {
  View,
  Image,
  StyleSheet,
  AlertIOS,
  NativeModules,
} from 'react-native'
import i18n from 'format-message'
import { Text } from '../../../common/text'
import { CircleToggle, LinkButton } from '../../../common/buttons'
import Images from '../../../images'
import ChatBubble from '../comments/ChatBubble'

const { NativeAccessibility } = NativeModules

export default class RubricItem extends Component {
  props: RubricItemProps
  state: RubricItemState

  constructor (props: RubricItemProps) {
    super(props)

    let grade = this.props.grade && this.props.grade.points

    this.state = {
      selectedOption: String(grade),
    }
  }

  showDescription = () => {
    this.props.showDescription(this.props.rubricItem.id)
  }

  changeSelected = (value: string) => {
    this.setState({ selectedOption: value })
    this.props.changeRating(this.props.rubricItem.id, +value)
  }

  isCustomGrade = () => this.props.rubricItem.ratings.every(({ points }) => points !== this.state.selectedOption) && this.state.selectedOption != null

  promptCustom = (customMessage: ?string) => {
    AlertIOS.prompt(
      i18n('Customize Grade'),
      customMessage,
      [{
        text: i18n('Cancel'),
        style: 'cancel',
        onPress: () => NativeAccessibility.focusElement(`rubric-item.customize-grade-${this.props.rubricItem.id}`),
      }, {
        text: i18n('Ok'),
        onPress: (value) => {
          let numValue = +value
          if (isNaN(numValue)) {
            this.promptCustom(i18n('Please enter a number'))
          }

          NativeAccessibility.focusElement(`rubric-item.customize-grade-${this.props.rubricItem.id}`)
          this.changeSelected(value)
        },
      }],
      'plain-text',
      this.isCustomGrade() ? this.state.selectedOption : '',
      'number-pad'
    )
  }

  openKeyboard = () => {
    this.props.openCommentKeyboard(this.props.rubricItem.id)
  }

  render () {
    let { rubricItem } = this.props
    let isCustomGrade = this.isCustomGrade()
    let hasComment = this.props.grade && !!this.props.grade.comments
    return (
      <View style={styles.container}>
        <Text style={styles.description}>{rubricItem.description}</Text>
        <View style={styles.ratings}>
          {rubricItem.ratings.slice().reverse().map(rating => (
            <CircleToggle
              key={rating.id}
              style={styles.circle}
              on={this.state.selectedOption === rating.points}
              value={rating.points}
              onPress={this.changeSelected}
              testID={`rubric-item.points-${rating.id}`}
            >
              {rating.points}
            </CircleToggle>
          ))}
          <CircleToggle
            key='add'
            style={styles.circle}
            on={isCustomGrade}
            value={isCustomGrade ? this.state.selectedOption : ''}
            onPress={this.promptCustom}
            accessibilityLabel={i18n('Customize Grade')}
            testID={`rubric-item.customize-grade-${rubricItem.id}`}
          >
            { isCustomGrade
              ? this.state.selectedOption
              : <Image source={Images.add} />
            }
          </CircleToggle>
        </View>
        <View style={styles.buttons}>
          {!hasComment &&
            <LinkButton style={styles.button} onPress={this.openKeyboard} testID={`rubric-item.add-comment-${rubricItem.id}`}>
              {i18n('Add Comment')}
            </LinkButton>
          }
          <LinkButton
            style={styles.button}
            onPress={this.showDescription}
            testID='rubric-item.description'
          >
            {i18n('View long description')}
          </LinkButton>
        </View>
        {hasComment &&
          <View style={styles.chatBubble}>
            <ChatBubble from='them' message={this.props.grade.comments} />
            <LinkButton
              style={styles.editButton}
              testID='rubric-item.comment-edit'
            >
              {i18n('Edit')}
            </LinkButton>
          </View>
        }
      </View>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    paddingTop: 16,
    paddingBottom: 8,
    paddingHorizontal: 16,
    overflow: 'hidden',
  },
  description: {
    fontWeight: '600',
  },
  ratings: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginTop: 12,
    marginBottom: 8,
  },
  circle: {
    marginRight: 8,
    marginBottom: 8,
  },
  buttons: {
    flexDirection: 'row',
  },
  button: {
    fontSize: 14,
    fontWeight: '500',
    paddingRight: 16,
  },
  chatBubble: {
    paddingTop: 16,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  editButton: {
    fontSize: 16,
    fontWeight: '600',
    color: '#73818C',
  },
})

type RubricItemProps = {
  rubricItem: Rubric,
  grade: RubricAssessment,
  showDescription: (string) => void,
  changeRating: (string, number) => void,
  openCommentKeyboard: (string) => void,
}

type RubricItemState = {
  selectedOption: ?string,
}
