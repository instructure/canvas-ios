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
import { View, Text } from 'react-native'
import { connect } from 'react-redux'
import i18n from 'format-message'
import Navigator from '../../routing/Navigator'
import Screen from '../../routing/Screen'
import CanvasWebView from '../../common/components/CanvasWebView'
import { createStyleSheet } from '../../common/stylesheet'

export class RubricDescription extends Component<*> {
  renderLongDescription () {
    if (!this.props.description || this.props.description.length === 0) {
      return (
        <View style={styles.emptyState}>
          <Text style={styles.emptyStateText}>{i18n('There currently is no long description for this item.')}</Text>
        </View>
      )
    }
    return (
      <View style={styles.container}>
        <CanvasWebView html={this.props.description} automaticallySetHeight navigator={this.props.navigator}/>
      </View>
    )
  }

  render () {
    const description = this.renderLongDescription()
    return (
      <Screen
        title={i18n('Long Description')}
      >
        { description }
      </Screen>
    )
  }
}

const styles = createStyleSheet(colors => ({
  container: {
    paddingTop: 24,
    paddingHorizontal: 16,
  },
  emptyState: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 32,
  },
  emptyStateText: {
    color: colors.textDarkest,
    fontSize: 16,
    lineHeight: 19,
    textAlign: 'center',
  },
}))

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
