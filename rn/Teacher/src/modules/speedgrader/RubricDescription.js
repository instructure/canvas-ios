// @flow

import React, { Component } from 'react'
import { connect } from 'react-redux'
import i18n from 'format-message'
import WebContainer from '../../common/components/WebContainer'

export class RubricDescription extends Component {

  static navigatorButtons = {
    rightButtons: [
      {
        title: i18n('Done'),
        id: 'done',
        testID: 'rubric-description.done',
      },
    ],
  }

  constructor (props: RubricDescriptionProps) {
    super(props)

    props.navigator.setTitle({
      title: i18n('Rubric Description'),
    })
    props.navigator.setOnNavigatorEvent(this.onNavigatorEvent)
  }

  onNavigatorEvent = (event: NavigatorEvent) => {
    if (event.type === 'NavBarButtonPress') {
      switch (event.id) {
        case 'done':
          this.props.navigator.dismissModal()
          break
      }
    }
  }

  render () {
    let html = this.props.description + '<style>body { padding: 24 16 }</style>'
    return (
      <WebContainer html={html} />
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
  navigator: ReactNavigator,
}

type RubricDescriptionDataProps = {
  description: string,
}

type RubricDescriptionProps = RubricDescriptionOwnProps
