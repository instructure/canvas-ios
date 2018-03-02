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

import React, { Component } from 'react'
import {
  View,
  Image,
  StyleSheet,
  AlertIOS,
  ActionSheetIOS,
  AccessibilityInfo,
  findNodeHandle,
} from 'react-native'
import i18n from 'format-message'
import { Text } from '../../../common/text'
import { LinkButton } from '../../../common/buttons'
import CircleToggle from '../../../common/components/CircleToggle'
import Images from '../../../images'
import ChatBubble from '../comments/ChatBubble'
import colors from '../../../common/colors'

const CANCEL = 2
const DELETE = 1

export default class RubricItem extends Component<RubricItemProps, RubricItemState> {
  customizeButton: any

  state: RubricItemState = {
    selectedOption: this.props.grade && this.props.grade.points,
  }

  componentWillReceiveProps (nextProps: RubricItemProps) {
    this.setState({
      selectedOption: nextProps.grade && nextProps.grade.points,
    })
  }

  showDescription = () => {
    this.props.showDescription(this.props.rubricItem.id)
  }

  changeSelected = (value: ?number) => {
    this.setState({ selectedOption: value })
    this.props.changeRating(this.props.rubricItem.id, value)
  }

  clearSelected = () => {
    this.setState({ selectedOption: null })
    this.props.changeRating(this.props.rubricItem.id, null)
  }

  isCustomGrade = () => {
    if (this.props.freeFormCriterionComments) { return this.state.selectedOption != null }
    return this.props.rubricItem.ratings.every(({ points }) => points !== this.state.selectedOption) && this.state.selectedOption != null
  }

  promptCustom = () => {
    let message = i18n('Out of {points, number}', { points: this.props.rubricItem.points })
    AlertIOS.prompt(
      i18n('Customize Grade'),
      message,
      [{
        text: i18n('Cancel'),
        style: 'cancel',
        // $FlowFixMe
        onPress: () => AccessibilityInfo.setAccessibilityFocus(findNodeHandle(this.customizeButton)),
      }, {
        text: i18n('OK'),
        onPress: (value) => {
          let numValue = +value
          if (isNaN(numValue)) {
            // This should be impossible because we are using a number pad
            this.promptCustom()
            return
          }

          this.changeSelected(numValue)
          // $FlowFixMe
          AccessibilityInfo.setAccessibilityFocus(findNodeHandle(this.customizeButton))
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

  dismissToolTip = () => {
    if (this.props.dismissToolTip) {
      this.props.dismissToolTip()
    }
  }

  render () {
    const { rubricItem, freeFormCriterionComments } = this.props
    const isCustomGrade = this.isCustomGrade()
    const hasComment = this.props.grade && !!this.props.grade.comments
    const showAddComment = !hasComment && freeFormCriterionComments
    return (
      <View style={styles.container}>
        <Text style={styles.description}>{rubricItem.description}</Text>
        <View style={styles.ratings}>
          {!freeFormCriterionComments && rubricItem.ratings.slice().reverse().map(rating => (
            <CircleToggle
              key={rating.id}
              style={styles.circle}
              on={this.state.selectedOption === rating.points}
              value={rating.points}
              onPress={(this.state.selectedOption === rating.points) ? this.clearSelected : this.changeSelected}
              onLongPress={this.showToolTip}
              onPressOut={this.dismissToolTip}
              accessibilityLabel={`${rating.points} — ${rating.description}`}
              testID={`rubric-item.points-${rating.id}`}
            >
              {i18n.number(rating.points)}
            </CircleToggle>
          ))}
          <CircleToggle
            key='add'
            style={styles.circle}
            on={isCustomGrade}
            value={isCustomGrade ? String(this.state.selectedOption) : ''}
            onPress={isCustomGrade ? this.clearSelected : this.promptCustom}
            accessibilityLabel={
              isCustomGrade
                ? i18n('Customize Grade {value}', { value: this.state.selectedOption })
                : i18n('Customize Grade')}
            testID={`rubric-item.customize-grade-${rubricItem.id}`}
            ref={r => { this.customizeButton = r }}
          >
            { isCustomGrade
              ? i18n.number(this.state.selectedOption || 0)
              : <Image style={{ tintColor: colors.grey4 }} source={Images.add} />
            }
          </CircleToggle>
        </View>
        <View style={styles.buttons}>
          {showAddComment &&
            <LinkButton
              textStyle={styles.buttonText}
              onPress={this.openKeyboard}
              testID={`rubric-item.add-comment-${rubricItem.id}`}
            >
              {i18n('Add Comment')}
            </LinkButton>
          }
          {showAddComment &&
            <Text accessible={false} style={{
              fontSize: 12,
              alignSelf: 'center',
              color: colors.grey4,
              paddingHorizontal: 6,
            }}>•</Text>
          }
          <LinkButton
            textStyle={styles.buttonText}
            onPress={this.showDescription}
            testID='rubric-item.description'
          >
            {i18n('View Long Description')}
          </LinkButton>
        </View>
        {hasComment &&
          <View style={styles.chatBubble}>
            <ChatBubble from='them' message={this.props.grade.comments} />
            <LinkButton
              style={styles.editButton}
              textStyle={styles.editButtonText}
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
    paddingBottom: 12,
    paddingHorizontal: 16,
  },
  description: {
    fontWeight: '600',
  },
  ratings: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginTop: 12,
    marginBottom: 6,
  },
  circle: {
    marginRight: 4,
    marginBottom: 4,
  },
  buttons: {
    flexDirection: 'row',
  },
  buttonText: {
    fontSize: 14,
    fontWeight: '500',
  },
  chatBubble: {
    paddingTop: 8,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  editButton: {
    marginLeft: 16,
  },
  editButtonText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#73818C',
  },
})

type RubricItemProps = {
  rubricItem: Rubric,
  freeFormCriterionComments: boolean,
  grade: RubricAssessment,
  showDescription: (string) => void,
  changeRating: (string, ?number) => void,
  openCommentKeyboard: (string) => void,
  deleteComment: (string) => void,
  showToolTip?: (sourcePoint: { x: number, y: number }, tip: string) => void,
  dismissToolTip?: () => void,
}

type RubricItemState = {
  selectedOption: ?number,
}
