// @flow

import React, { Component } from 'react'
import {
  View,
  Image,
  StyleSheet,
  AlertIOS,
} from 'react-native'
import i18n from 'format-message'
import { Text } from '../../../common/text'
import { CircleToggle, LinkButton } from '../../../common/buttons'
import Images from '../../../images'

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
      (value) => {
        value = +value
        if (isNaN(value)) {
          this.promptCustom(i18n('Please enter a number'))
        }

        this.changeSelected(+value)
      },
      'plain-text',
      this.isCustomGrade() ? String(this.state.selectedOption) : '',
      'number-pad'
    )
  }

  render () {
    let { rubricItem } = this.props
    let isCustomGrade = this.isCustomGrade()
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
          >
            { isCustomGrade
              ? this.state.selectedOption
              : <Image source={Images.add} />
            }
          </CircleToggle>
        </View>
        <View style={styles.buttons}>
          <LinkButton style={styles.button}>{i18n('Add Comment')}</LinkButton>
          <LinkButton
            style={styles.button}
            onPress={this.showDescription}
            testID='rubric-item.description'
          >
            {i18n('View long description')}
          </LinkButton>
        </View>
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
})

type RubricItemProps = {
  rubricItem: Rubric,
  grade: RubricAssessment,
  showDescription: (string) => void,
  changeRating: (string, number) => void,
}

type RubricItemState = {
  selectedOption: ?number,
}
