//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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
  Image,
  Alert,
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
import { colors, createStyleSheet } from '../../../common/stylesheet'

const CANCEL = 2
const DELETE = 1

export default class RubricItem extends Component<RubricItemProps, RubricItemState> {
  customizeButton: any

  state: RubricItemState = {
    selectedRatingID: this.props.grade && this.props.grade.rating_id,
    selectedPoints: this.props.grade && this.props.grade.points,
  }

  UNSAFE_componentWillReceiveProps (nextProps: RubricItemProps) {
    this.setState({
      selectedRatingID: nextProps.grade && nextProps.grade.rating_id,
      selectedPoints: nextProps.grade && nextProps.grade.points,
    })
  }

  showDescription = () => {
    this.props.showDescription(this.props.rubricItem.id)
  }

  changeSelected = (points: ?number, rating_id: ?string) => {
    this.setState({ selectedRatingID: rating_id, selectedPoints: points })
    this.props.changeRating(this.props.rubricItem.id, points, rating_id)
  }

  clearSelected = () => {
    this.setState({ selectedRatingID: null, selectedPoints: null })
    this.props.changeRating(this.props.rubricItem.id, null, null)
  }

  isCustomGrade = () => {
    if (this.props.freeFormCriterionComments) { return this.state.selectedPoints != null }
    return this.state.selectedRatingID == null && this.state.selectedPoints != null
  }

  promptCustom = () => {
    let message = i18n('Out of {points, number}', { points: this.props.rubricItem.points })
    Alert.prompt(
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
      this.isCustomGrade() ? String(this.state.selectedPoints) : '',
      'decimal-pad'
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

  showToolTip = (itemID: string, { x, y, width }: { x: number, y: number, width: number }) => {
    const rubricItem = this.props.rubricItem
    const rating = rubricItem.ratings.find(rating => rating.id === itemID)
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
        {rubricItem.ignore_for_scoring &&
          <Text
            style={styles.noScoreText}
            testID={`rubric-item.${rubricItem.id}-no-score`}
          >
            {i18n('This criterion will not impact the score.')}
          </Text>
        }
        <View style={styles.ratings}>
          {!freeFormCriterionComments && rubricItem.ratings.slice().reverse().map(rating => (
            <CircleToggle
              key={rating.id}
              itemID={rating.id}
              style={styles.circle}
              on={this.state.selectedRatingID === rating.id}
              value={rating.points}
              onPress={(this.state.selectedRatingID === rating.id) ? this.clearSelected : this.changeSelected}
              onLongPress={this.showToolTip}
              onPressOut={this.dismissToolTip}
              accessibilityLabel={`${rating.points} — ${rating.description}`}
              testID={`rubric-item.points-${rating.id}`}
            >
              { (this.state.selectedRatingID === rating.id)
                ? i18n.number(this.state.selectedPoints || rating.points)
                : i18n.number(rating.points)
              }
            </CircleToggle>
          ))}
          <CircleToggle
            key='add'
            style={styles.circle}
            on={isCustomGrade}
            value={isCustomGrade ? String(this.state.selectedPoints) : ''}
            onPress={isCustomGrade ? this.clearSelected : this.promptCustom}
            accessibilityLabel={
              isCustomGrade
                ? i18n('Customize Grade {value}', { value: this.state.selectedPoints })
                : i18n('Customize Grade')}
            testID={`rubric-item.customize-grade-${rubricItem.id}`}
            ref={r => { this.customizeButton = r }}
          >
            { isCustomGrade
              ? i18n.number(this.state.selectedPoints || 0)
              : <Image style={{ tintColor: colors.textDark }} source={Images.add} />
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
              color: colors.textDark,
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

const styles = createStyleSheet(colors => ({
  container: {
    paddingTop: 16,
    paddingBottom: 12,
    paddingHorizontal: 16,
  },
  description: {
    fontWeight: '600',
  },
  noScoreText: {
    marginTop: 2,
    fontSize: 12,
    color: colors.textDark,
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
    color: colors.textDark,
  },
}))

type RubricItemProps = {
  rubricItem: Rubric,
  freeFormCriterionComments: boolean,
  grade: RubricAssessment,
  showDescription: (string) => void,
  changeRating: (string, ?number, ?string) => void,
  openCommentKeyboard: (string) => void,
  deleteComment: (string) => void,
  showToolTip?: (sourcePoint: { x: number, y: number }, tip: string) => void,
  dismissToolTip?: () => void,
}

type RubricItemState = {
  selectedRatingID: ?string,
  selectedPoints: ?number,
}
