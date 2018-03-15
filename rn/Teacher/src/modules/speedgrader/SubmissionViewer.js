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
  StyleSheet,
} from 'react-native'
import i18n from 'format-message'
import { Text, MEDIUM_FONT } from '../../common/text'
import type {
  SubmissionDataProps,
} from '../submissions/list/submission-prop-types'
import CanvasWebView from '../../common/components/CanvasWebView'
import Video from '../../common/components/Video'
import AuthenticatedWebView from '../../common/components/AuthenticatedWebView'
import URLSubmissionViewer from './submission-viewers/URLSubmissionViewer'
import CanvadocViewer from './components/CanvadocViewer'
import ImageSubmissionViewer from './submission-viewers/ImageSubmissionViewer'

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

export default class SubmissionViewer extends Component<SubmissionViewerProps> {
  videoPlayer: ?Video

  componentWillReceiveProps (newProps: SubmissionViewerProps) {
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
    return <View style={styles.centeredText}>
      <Text style={styles.noSubText}>{text}</Text>
    </View>
  }

  renderFile (submission: Submission) {
    if (submission.attachments) {
      let attachment = submission.attachments[this.props.selectedAttachmentIndex]
      if (attachment.mime_class === 'image') {
        return <ImageSubmissionViewer attachment={attachment} {...this.props.size} />
      } else {
        return <CanvadocViewer
          config={{
            previewPath: attachment.preview_url,
            fallbackURL: attachment.url,
            filename: attachment.filename,
            drawerInset: this.props.drawerInset,
          }}
          style={styles.pdfContainer}
        />
      }
    }

    return null
  }

  renderSubmission (submission: Submission) {
    let body = <View></View>
    if (submission.submission_type) {
      switch (submission.submission_type) {
        case 'online_url':
          body = <URLSubmissionViewer
            submission={submission}
            drawerInset={this.props.drawerInset}
          />
          break
        case 'online_text_entry':
          body = <CanvasWebView
            style={styles.webContainer}
            html={submission.body || ''}
            contentInset={{ bottom: this.props.drawerInset }}
            navigator={this.props.navigator}
          />
          break
        case 'online_quiz':
        case 'discussion_topic':
        case 'basic_lti_launch':
        case 'external_tool':
          body = <AuthenticatedWebView
            style={styles.webContainer}
            source={{ uri: submission.preview_url }}
            contentInset={{ bottom: this.props.drawerInset }}
            navigator={this.props.navigator}
          />
          break
        case 'media_recording':
          const width = this.props.size.width - global.style.defaultPadding * 2.0
          const height = Math.ceil(width * 9.0 / 16.0)
          const url = submission.media_comment
            ? submission.media_comment.url
            : ''
          body = <Video
            testID='submission-viewer.video'
            ref={this.captureVideoPlayer}
            style={{ height }}
            source={{ uri: url }}
          />
          break
        default:
          let text = this.unviewableSubmissionText(submission.submission_type)
          body = this.renderCenteredText(text)
      }
    }
    return <View style={styles.container}>{body}</View>
  }

  render () {
    const submission = this.currentSubmission()
    if (submission && submission.attempt) {
      if (submission.attachments && submission.submission_type === 'online_upload') {
        return this.renderFile(submission) || <View />
      } else {
        return this.renderSubmission(submission)
      }
    }

    let text = this.unviewableSubmissionText(this.props.assignmentSubmissionTypes)
    text = text || (this.props.submissionProps.groupID
      ? i18n('This group does not have a submission for this assignment.')
      : i18n('This student does not have a submission for this assignment.'))
    return <View style={styles.container}>
      {this.renderCenteredText(text)}
    </View>
  }
}

const styles = StyleSheet.create({
  container: {
    paddingTop: 16,
    paddingLeft: 16,
    paddingRight: 16,
    flex: 1,
    backgroundColor: 'white',
  },
  webContainer: {
    flex: 1,
  },
  pdfContainer: {
    paddingTop: 16,
    paddingLeft: 16,
    paddingRight: 16,
    flex: 1,
    backgroundColor: '#A3ADB3',
  },
  centeredText: {
    height: 200,
    flex: 0,
    justifyContent: 'center',
    alignItems: 'center',
  },
  noSubText: {
    textAlign: 'center',
    fontFamily: MEDIUM_FONT,
  },
})
