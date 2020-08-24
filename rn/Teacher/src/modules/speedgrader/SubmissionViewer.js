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
import { View } from 'react-native'
import i18n from 'format-message'
import { Text } from '../../common/text'
import type {
  SubmissionDataProps,
} from '../submissions/list/submission-prop-types'
import CoreWebView from '../../common/components/CoreWebView'
import Video from '../../common/components/Video'
import AuthenticatedWebView from '../../common/components/AuthenticatedWebView'
import URLSubmissionViewer from './submission-viewers/URLSubmissionViewer'
import ImageSubmissionViewer from './submission-viewers/ImageSubmissionViewer'
import DocViewer from './components/DocViewer'
import { createStyleSheet } from '../../common/stylesheet'

type SubmissionViewerProps = {
  isCurrentStudent: boolean,
  submissionProps: SubmissionDataProps,
  selectedIndex: ?number,
  selectedAttachmentIndex: number,
  assignmentSubmissionTypes: Array<SubmissionType>,
  size: { width: number, height: number },
  isModeratedGrading: boolean,
  drawerInset: number,
  navigator: Navigator,
}

export default class SubmissionViewer extends Component<SubmissionViewerProps, State> {
  videoPlayer: ?Video

  UNSAFE_componentWillReceiveProps (newProps: SubmissionViewerProps) {
    if (this.videoPlayer && !newProps.isCurrentStudent) {
      this.videoPlayer.pause()
    }
  }

  captureVideoPlayer = (video: ?Video) => {
    this.videoPlayer = video
  }

  currentSubmission (): ?Submission {
    let submission = this.props.submissionProps.submission
    const selectedIndex = this.props.selectedIndex
    if (!submission) return null
    return selectedIndex != null ? submission.submission_history[selectedIndex] : submission
  }

  unviewableSubmissionText (types: SubmissionType | Array<SubmissionType>): any {
    let type = types
    if (Array.isArray(types)) {
      type = types[0]
    }

    let text = null
    if (type === 'on_paper') {
      text = i18n('This assignment only allows on-paper submissions.')
    } else if (type === 'none') {
      text = i18n('This assignment does not allow submissions.')
    }
    return text
  }

  renderCenteredText (text: string) {
    return (
      <View style={styles.centeredText}>
        <Text style={styles.noSubText}>{text}</Text>
      </View>
    )
  }

  renderFile (submission: Submission) {
    const attachment = submission.attachments?.[this.props.selectedAttachmentIndex]
    if (!attachment) { return null }
    switch (attachment.mime_class) {
      case 'doc':
      case 'image':
      case 'pdf':
        return (
          <DocViewer
            previewURL={attachment.preview_url}
            fallbackURL={attachment.url}
            filename={attachment.filename}
            contentInset={{ bottom: this.props.drawerInset }}
            style={styles.viewer}
          />
        )
      case 'audio':
      case 'video':
        return (
          <View style={[styles.viewer, { paddingBottom: this.props.drawerInset }]}>
            <Video
              ref={this.captureVideoPlayer}
              source={{ uri: attachment.url }}
              style={styles.viewer}
              testID='submission-viewer.video'
            />
          </View>
        )
    }
    if (attachment['content-type'] === 'image/heic') {
      let { width, height } = this.props.size
      return (
        <ImageSubmissionViewer
          attachment={attachment}
          height={height}
          style={styles.viewer}
          width={width}
        />
      )
    }
    return (
      <CoreWebView
        contentInset={{ bottom: this.props.drawerInset }}
        html={submission.body || ''}
        navigator={this.props.navigator}
        style={styles.viewer}
      />
    )
  }

  renderSubmission (submission: Submission) {
    switch (submission.submission_type) {
      case 'online_url':
        return (
          <URLSubmissionViewer
            drawerInset={this.props.drawerInset}
            submission={submission}
          />
        )
      case 'online_text_entry':
        return (
          <CoreWebView
            contentInset={{ bottom: this.props.drawerInset }}
            html={submission.body || ''}
            navigator={this.props.navigator}
            style={styles.viewer}
          />
        )
      case 'online_quiz':
        return (
          <AuthenticatedWebView
            contentInset={{ bottom: this.props.drawerInset }}
            onNavigation={(url) => {
              this.props.navigator.show(url, {
                deepLink: true,
                modal: true,
              })
            }}
            openLinksInSafari={false}
            source={{ uri: submission.preview_url }}
            style={styles.viewer}
          />
        )
      case 'online_upload':
        return this.renderFile(submission)
      case 'discussion_topic':
      case 'basic_lti_launch':
      case 'external_tool':
        return (
          <AuthenticatedWebView
            contentInset={{ bottom: this.props.drawerInset }}
            navigator={this.props.navigator}
            openLinksInSafari
            source={{ uri: submission.preview_url }}
            style={styles.viewer}
          />
        )
      case 'media_recording':
        return (
          <View style={[styles.viewer, { paddingBottom: this.props.drawerInset }]}>
            <Video
              ref={this.captureVideoPlayer}
              source={{ uri: submission.media_comment?.url }}
              style={styles.viewer}
              testID='submission-viewer.video'
            />
          </View>
        )
      default:
        let text = this.unviewableSubmissionText(submission.submission_type)
        return this.renderCenteredText(text)
    }
  }

  render () {
    const submission = this.currentSubmission()
    if (submission && submission.attempt) {
      return this.renderSubmission(submission)
    }

    let text = this.unviewableSubmissionText(this.props.assignmentSubmissionTypes)
    text = text || (this.props.submissionProps.groupID
      ? i18n('This group does not have a submission for this assignment.')
      : i18n('This student does not have a submission for this assignment.'))
    return this.renderCenteredText(text)
  }
}

const styles = createStyleSheet((colors, vars) => ({
  viewer: {
    backgroundColor: colors.backgroundLightest,
    flex: 1,
  },
  centeredText: {
    padding: 16,
    height: 200,
    flex: 0,
    justifyContent: 'center',
    alignItems: 'center',
  },
  noSubText: {
    textAlign: 'center',
    fontWeight: '500',
  },
}))
