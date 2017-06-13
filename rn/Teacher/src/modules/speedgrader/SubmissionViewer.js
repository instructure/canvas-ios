// @flow

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
  WebView,
} from 'react-native'
import i18n from 'format-message'
import { Text, MEDIUM_FONT } from '../../common/text'
import type {
  SubmissionDataProps,
} from '../submissions/list/submission-prop-types'
import WebContainer from '../../common/components/WebContainer'
import Video from '../../common/components/Video'
import URLSubmissionViewer from './submission-viewers/URLSubmissionViewer'
import CanvadocViewer from './components/CanvadocViewer'

type SubmissionViewerProps = {
  isCurrentStudent: boolean,
  submissionProps: SubmissionDataProps,
  selectedIndex: ?number,
  selectedAttachmentIndex: number,
  assignmentSubmissionTypes: Array<SubmissionType>,
  size: { width: number, height: number },
  isModeratedGrading: boolean,
}

export default class SubmissionViewer extends Component {
  props: SubmissionViewerProps
  videoPlayer: ?Video

  componentWillReceiveProps (newProps: SubmissionViewerProps) {
    if (this.videoPlayer && !newProps.isCurrentStudent) {
      this.videoPlayer.pause()
    }
  }

  captureVideoPlayer = (video: Video) => {
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
    } else if (type === 'external_tool') {
      text = i18n('This assignment links to an external tool for submissions.')
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
      return <CanvadocViewer config={{ previewPath: submission.attachments[this.props.selectedAttachmentIndex].preview_url }} style={styles.container} />
    }

    return null
  }

  renderSubmission (submission: Submission) {
    let body = <View></View>
    if (submission.submission_type) {
      switch (submission.submission_type) {
        case 'online_url':
          body = <URLSubmissionViewer submission={submission} />
          break
        case 'online_text_entry':
          body = <WebContainer style={styles.webContainer} html={submission.body} />
          break
        case 'online_quiz':
        case 'discussion_topic':
          body = <WebView style={styles.webContainer} source={{ uri: submission.preview_url }} />
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
    if (this.props.isModeratedGrading) {
      return (
        <View style={styles.container}>
          {this.renderCenteredText(i18n('Moderated grading is not currently supported in mobile SpeedGrader.'))}
        </View>
      )
    }

    const submission = this.currentSubmission()
    if (submission && submission.attempt) {
      if (submission.attachments && submission.submission_type === 'online_upload') {
        return this.renderFile(submission) || <View />
      } else {
        return this.renderSubmission(submission)
      }
    }

    let text = this.unviewableSubmissionText(this.props.assignmentSubmissionTypes)
    text = text || i18n('This student does not have a submission for this assignment.')
    return <View style={styles.container}>
      {this.renderCenteredText(text)}
    </View>
  }
}

const styles = StyleSheet.create({
  container: {
    paddingLeft: 16,
    paddingRight: 16,
    flex: 1,
  },
  webContainer: {
    flex: 1,
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
