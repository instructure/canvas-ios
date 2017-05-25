// @flow

import _ from 'lodash'
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

type SubmissionViewerProps = {
  submissionProps: SubmissionDataProps,
  selectedIndex: ?number,
  selectedAttachmentIndex: ?number,
  assignmentSubmissionTypes: Array<SubmissionType>,
}

export default class SubmissionViewer extends Component {
  props: SubmissionViewerProps

  currentSubmission (): null | SubmissionWithHistory {
    let submission = this.props.submissionProps.submission
    const selectedIndex = this.props.selectedIndex
    if (!submission) return null
    return selectedIndex != null ? submission.submission_history[selectedIndex] : submission
  }

  unviewableSubmissionText (types: SubmissionType | Array<SubmissionType>): any {
    let type = types
    if (_.isArray(types)) {
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

  renderCenteredText (text: string): React.Element<*> {
    return <View style={styles.centeredText}>
      <Text style={styles.noSubText}>{text}</Text>
    </View>
  }

  renderFile (submission: SubmissionWithHistory): React.Element<*> {
    // TODO: display files
    return <View style={styles.container}><Text>File</Text></View>
  }

  renderSubmission (submission: SubmissionWithHistory): React.Element<*> {
    let body = <View></View>
    if (submission.submission_type) {
      switch (submission.submission_type) {
        case 'online_text_entry':
          body = <WebContainer style={styles.webContainer} html={submission.body} />
          break
        case 'online_quiz':
        case 'discussion_topic':
          body = <WebView style={styles.webContainer} source={{ uri: submission.preview_url }} />
          break
        default:
          let text = this.unviewableSubmissionText(submission.submission_type)
          body = this.renderCenteredText(text)
      }
    }
    return <View style={styles.container}>{body}</View>
  }

  render (): React.Element<*> {
    const submission = this.currentSubmission()
    if (submission && submission.attempt) {
      if (this.props.selectedAttachmentIndex != null && submission.attachments) {
        return this.renderFile(submission)
      } else {
        return this.renderSubmission(submission)
      }
    } else {
      let text = this.unviewableSubmissionText(this.props.assignmentSubmissionTypes)
      text = text || i18n('This student does not have a submission for this assignment.')
      return <View style={styles.container}>
        {this.renderCenteredText(text)}
      </View>
    }
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
    height: '84%',
    flex: 0,
    justifyContent: 'center',
    alignItems: 'center',
  },
  noSubText: {
    textAlign: 'center',
    fontFamily: MEDIUM_FONT,
  },
})
