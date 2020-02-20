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
import { connect } from 'react-redux'
import i18n from 'format-message'
import { colors, createStyleSheet } from '../../../common/stylesheet'
import images from '../../../images'
import DisclosureIndicator from '../../../common/components/DisclosureIndicator'

import {
  Text,
  TouchableHighlight,
  View,
  Image,
} from 'react-native'

type OwnProps = {
  submissionID: ?string,
}

type StateProps = {
  status: ?string,
  score: ?number,
  url: ?string,
}

export type Props = StateProps

export class SimilarityScore extends Component<Props, any> {
  render () {
    const { status, score } = this.props
    if (!status) {
      return null
    }

    return (
      <TouchableHighlight
        underlayColor={colors.backgroundLightest}
        testID='speedgrader.similarity-score.container'
      >
        <View style={style.container}>
          <Text
            style={style.label}
            testID='speedgrader.similarity-score.label'
          >
            {i18n('Similarity Score')}
          </Text>
          { status === 'scored' && score != null && this.renderScore(score) }
          { status === 'pending' && this.renderPending() }
          { status !== 'scored' && status !== 'pending' && this.renderError() }
        </View>
      </TouchableHighlight>
    )
  }

  renderScore (score: number) {
    let color = colors.textInfo
    switch (true) {
      case (score >= 75):
        color = colors.textDanger
        break
      case (score >= 50):
        color = colors.textAlert
        break
      case (score >= 25):
        color = colors.textWarning
        break
      case (score >= 1):
        color = colors.textSuccess
        break
      default:
        color = colors.textInfo
    }

    return (
      <View style={{ flexDirection: 'row' }}>
        <View
          style={[style.scoreContainer, { backgroundColor: color }]}
          testID='speedgrader.similarity-score.score.container'
        >
          <Text
            style={style.score}
            testID='speedgrader.similarity-score.score.label'
          >
            {`${score}%`}
          </Text>
        </View>
        { Boolean(this.props.url) &&
          <DisclosureIndicator />
        }
      </View>
    )
  }

  renderPending () {
    return this.renderStatus(images.speedGrader.turnitin.pending, colors.textDark)
  }

  renderError () {
    return this.renderStatus(images.speedGrader.turnitin.error, colors.textDanger)
  }

  renderStatus (icon: any, color: string) {
    return (
      <View
        style={[style.statusContainer, { backgroundColor: color }]}
        testID='speedgrader.similarity-score.status.container'
      >
        <Image
          source={icon}
          style={style.statusIcon}
          testID='speedgrader.similarity-score.status.icon'
        />
      </View>
    )
  }
}

const style = createStyleSheet((colors, vars) => ({
  container: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    borderBottomColor: colors.borderMedium,
    borderBottomWidth: vars.hairlineWidth,
    borderStyle: 'solid',
    marginHorizontal: 16,
    paddingVertical: 4,
    alignItems: 'center',
    backgroundColor: colors.backgroundLightest,
  },
  label: {
    fontSize: 14,
    color: colors.textDarkest,
    fontWeight: '600',
  },
  scoreContainer: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
  },
  score: {
    fontSize: 16,
    color: colors.white,
    fontWeight: '600',
  },
  statusIcon: {
    width: 18,
    height: 18,
    tintColor: colors.white,
  },
  statusContainer: {
    borderRadius: 4,
    padding: 4,
  },
}))

export function mapStateToProps (state: AppState, ownProps: OwnProps): StateProps {
  const { submissionID } = ownProps

  if (submissionID &&
    state.entities.submissions[submissionID]?.submission) {
    // get selected submission
    const submissionData = state.entities.submissions[submissionID]
    const { submission, selectedIndex, selectedAttachmentIndex } = submissionData
    const selectedSubmission = selectedIndex != null ? submission.submission_history[selectedIndex] : submission

    if (selectedSubmission && selectedSubmission.turnitin_data) {
      // online text entry
      if (selectedSubmission.submission_type === 'online_text_entry') {
        const data = selectedSubmission.turnitin_data[`submission_${selectedSubmission.id}`]
        if (data) {
          return mapTurnItInDataToProps(data)
        }
      }

      // online upload
      if (selectedSubmission.submission_type === 'online_upload') {
        if (selectedSubmission.attachments && selectedSubmission.attachments.length > 0) {
          const { attachments } = selectedSubmission
          const selectedAttachment = selectedAttachmentIndex != null ? attachments[selectedAttachmentIndex] : attachments[0]
          const data = selectedSubmission.turnitin_data[`attachment_${selectedAttachment.id}`]
          if (data) {
            return mapTurnItInDataToProps(data)
          }
        }
      }
    }
  }

  return {
    status: null,
    score: null,
    url: null,
  }
}

function mapTurnItInDataToProps (data: TurnItInData): StateProps {
  const { status, similarity_score } = data
  const url = data.outcome_response ? data.outcome_response.outcomes_tool_placement_url : null
  return {
    status,
    url,
    score: similarity_score,
  }
}

let Connected = connect(mapStateToProps)(SimilarityScore)
export default (Connected: any)
