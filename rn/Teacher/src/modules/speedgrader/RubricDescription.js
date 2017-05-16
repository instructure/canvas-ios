// @flow

import React, { Component } from 'react'
import { connect } from 'react-redux'
import i18n from 'format-message'
import WebContainer from '../../common/components/WebContainer'
import Navigator from '../../routing/Navigator'
import Screen from '../../routing/Screen'

export class RubricDescription extends Component {

  dismiss = () => {
    this.props.navigator.dismiss()
  }

  render () {
    let html = this.props.description + '<style>body { padding: 24 16 }</style>'
    return (
      <Screen
        title={i18n('Rubric Description')}
        rightBarButtons={[{
          title: i18n('Done'),
          style: 'done',
          testID: 'rubric-description.done',
          action: this.dismiss,
        }]}>
        <WebContainer html={html} />
      </Screen>
    )
  }
}

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
