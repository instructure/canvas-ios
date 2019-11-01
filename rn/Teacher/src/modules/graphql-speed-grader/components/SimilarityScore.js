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

type StateProps = {
  status: ?string,
  score: ?number,
  url: ?string,
}

export type Props = StateProps

export default class SimilarityScore extends Component<Props, any> {
  render () {
    let selectedSubmission = this.props.submission.submissionHistory.edges[this.props.selectedIndex].submission
    if (selectedSubmission.turnitinData == null) return null

    if (!['online_text_entry', 'online_upload'].includes(selectedSubmission.submissionType)) return null

    let turnitinData
    if (selectedSubmission.submissionType === 'online_text_entry') {
      turnitinData = selectedSubmission.turnitinData
        .find(data => data.target.__typename === 'Submission' && data.target._id === selectedSubmission.rootId)
    } else if (selectedSubmission.submissionType === 'online_upload') {
      let selectedAttachmentIndex = this.props.selectedAttachmentIndex
      let selectedAttachment = selectedSubmission.attachments[selectedAttachmentIndex]
      turnitinData = selectedSubmission.turnitinData
        .find(data => data.target.__typename === 'File' && data.target._id === selectedAttachment._id)
    }

    if (turnitinData == null) return null

    const { status, score } = turnitinData
    if (!status) {
      return null
    }

    return (
      <TouchableHighlight
        underlayColor='white'
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
    return this.renderStatus(images.speedGrader.turnitin.pending, '#72818B')
  }

  renderError () {
    return this.renderStatus(images.speedGrader.turnitin.error, '#F30017')
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
    borderBottomColor: '#D8D8D8',
    borderBottomWidth: vars.hairlineWidth,
    borderStyle: 'solid',
    marginHorizontal: vars.padding,
    paddingVertical: 4,
    alignItems: 'center',
    backgroundColor: colors.white,
  },
  label: {
    fontSize: 14,
    color: colors.textDark,
    fontFamily: '.SFUIDisplay-semibold',
  },
  scoreContainer: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
  },
  score: {
    fontSize: 16,
    color: colors.white,
    fontFamily: '.SFUIDisplay-semibold',
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
