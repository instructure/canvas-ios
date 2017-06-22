// @flow

import React, { Component } from 'react'
import { View, StyleSheet, Text, ScrollView } from 'react-native'
import { connect } from 'react-redux'
import i18n from 'format-message'
import Navigator from '../../routing/Navigator'
import Screen from '../../routing/Screen'

export class RubricDescription extends Component {

  dismiss = () => {
    this.props.navigator.dismiss()
  }

  renderLongDescription () {
    if (!this.props.description) {
      return (
        <View style={styles.emptyState}>
          <Text style={styles.emptyStateText}>There currently is no long description for this item.</Text>
        </View>
      )
    }
    return (
      <View style={styles.container}>
        <ScrollView bounces={false}>
          <Text style={styles.text}>{this.props.description}</Text>
        </ScrollView>
      </View>
    )
  }

  render () {
    const description = this.renderLongDescription()
    return (
      <Screen
        title={i18n('Long Description')}
        rightBarButtons={[{
          title: i18n('Done'),
          style: 'done',
          testID: 'rubric-description.done',
          action: this.dismiss,
        }]}>
        { description }
      </Screen>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    paddingTop: 24,
    paddingHorizontal: 16,
    paddingBottom: 16,
  },
  emptyState: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 32,
  },
  emptyStateText: {
    color: '#2D3B45',
    fontSize: 16,
    lineHeight: 19,
    textAlign: 'center',
  },
  text: {
    color: '#2D3B45',
    fontSize: 16,
    lineHeight: 19,
  },
})

export function mapStateToProps (state: AppState, ownProps: RubricDescriptionOwnProps): RubricDescriptionDataProps {
  let rubric = state.entities.assignments[ownProps.assignmentID].data.rubric
  if (!rubric) {
    return { description: '' }
  }

  return {
    description: rubric.find(r => r.id === ownProps.rubricID).long_description,
  }
}

const Connected = connect(mapStateToProps)(RubricDescription)
export default (Connected: any)

type RubricDescriptionOwnProps = {
  assignmentID: string,
  rubricID: string,
  navigator: Navigator,
}

type RubricDescriptionDataProps = {
  description: string,
}
