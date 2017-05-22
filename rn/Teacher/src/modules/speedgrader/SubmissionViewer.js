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
import WebContainer from '../../common/components/WebContainer'

type SubmissionViewerProps = {
  submissionProps: SubmissionDataProps,
  selectedIndex: ?number,
  selectedAttachmentIndex: ?number,
}

export default class SubmissionViewer extends Component {
  props: SubmissionViewerProps

  currentSubmission () {
    let submission = this.props.submissionProps.submission
    const selectedIndex = this.props.selectedIndex
    if (!submission) return null
    return selectedIndex != null ? submission.submission_history[selectedIndex] : submission
  }

  renderFile (submission: SubmissionWithHistory) {
    // TODO: display files
    return <View style={styles.container}><Text>File</Text></View>
  }

  renderSubmission (submission: SubmissionWithHistory) {
    let body = <View></View>
    // TODO: submissions not allowed (MBL-7561)
    if (submission.submission_type === 'online_text_entry') {
      body = <WebContainer style={styles.webContainer} html={submission.body} />
    }
    return <View style={styles.container}>{body}</View>
  }

  render () {
    const submission = this.currentSubmission()
    if (submission) {
      if (this.props.selectedAttachmentIndex != null && submission.attachments) {
        return this.renderFile(submission)
      } else {
        return this.renderSubmission(submission)
      }
    } else {
      const text = i18n('This student does not have a submission for this assignment.')
      return <View style={styles.container}>
        <View style={styles.centeredText}>
          <Text style={styles.noSubText}>{text}</Text>
        </View>
      </View>
    }
  }
}

const styles = StyleSheet.create({
  container: {
    paddingLeft: 16,
    paddingRight: 16,
    paddingTop: 16,
  },
  webContainer: {
    flex: 0,
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
