// @flow

import React, { Component } from 'react'
import {
  View,
  Image,
  StyleSheet,
  AlertIOS,
  NativeModules,
  ActionSheetIOS,
} from 'react-native'
import i18n from 'format-message'
import { Text } from '../../../common/text'
import { LinkButton } from '../../../common/buttons'
import CircleToggle from '../../../common/components/CircleToggle'
import Images from '../../../images'
import ChatBubble from '../comments/ChatBubble'

const { NativeAccessibility } = NativeModules

const CANCEL = 2
const DELETE = 1

export default class RubricItem extends Component {
  props: RubricItemProps
  state: RubricItemState

  constructor (props: RubricItemProps) {
    super(props)

    let grade = this.props.grade && this.props.grade.points

    this.state = {
      selectedOption: grade,
    }
  }

  showDescription = () => {
    this.props.showDescription(this.props.rubricItem.id)
  }

  changeSelected = (value: number) => {
    this.setState({ selectedOption: value })
    this.props.changeRating(this.props.rubricItem.id, value)
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
          this.changeSelected(numValue)
        },
      }],
      'plain-text',
      this.isCustomGrade() ? String(this.state.selectedOption) : '',
      'number-pad'
    )
  }

  openKeyboard = () => {
    this.props.openCommentKeyboard(this.props.rubricItem.id)
  }

  openActionSheet = () => {
    ActionSheetIOS.showActionSheetWithOptions({
      options: [i18n('Edit'), i18n('Delete'), i18n('Cancel')],
      cancelButtonIndex: CANCEL,
      destructiveButtonIndex: DELETE,
      title: i18n('Edit Comment'),
    }, (button) => {
      if (button === CANCEL) return
      if (button === DELETE) return this.props.deleteComment(this.props.rubricItem.id)

      this.props.openCommentKeyboard(this.props.rubricItem.id)
    })
  }

  showToolTip = (value: ?number, { x, y, width }: { x: number, y: number, width: number }) => {
    const rubricItem = this.props.rubricItem
    const rating = rubricItem.ratings.find(rating => rating.points === value)
    if (rating && this.props.showToolTip) {
      this.props.showToolTip({ x: x + width / 2, y }, rating.description)
    }
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
              onLongPress={this.showToolTip}
              accessibilityLabel={`${rating.points} — ${rating.description}`}
              testID={`rubric-item.points-${rating.id}`}
            >
              {rating.points}
            </CircleToggle>
          ))}
          <CircleToggle
            key='add'
            style={styles.circle}
            on={isCustomGrade}
            value={isCustomGrade ? String(this.state.selectedOption) : ''}
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
              testID={`rubric-item.edit-comment-${rubricItem.id}`}
              onPress={this.openActionSheet}
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
  deleteComment: (string) => void,
  showToolTip?: (sourcePoint: { x: number, y: number }, tip: string) => void,
}

type RubricItemState = {
  selectedOption: ?number,
}
