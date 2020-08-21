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
import {
  View,
  TouchableOpacity,
} from 'react-native'
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
import CanvadocViewer from './components/CanvadocViewer'
import debounce from 'lodash/debounce'
import { createStyleSheet, vars } from '../../common/stylesheet'

type State = {
  saving: boolean,
  saveError: ?string,
}

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
  canvadocViewer: ?CanvadocViewer
  state: State

  // This is tricky, because i want this to be updated all the time,
  // But I don't want the state of the component to be up to date all the time, because it needs to be debounced 😱
  saveState: { saving: boolean, error?: string }
  debouncedUpdateSaveState: Function

  constructor (props: any) {
    super(props)

    // $FlowFixMe
    this.state = {
      saving: false,
      saveError: undefined,
    }

    this.saveState = {
      saving: false,
    }

    this.debouncedUpdateSaveState = debounce(this.updateSaveState, 2000, { 'leading': true })
  }

  UNSAFE_componentWillReceiveProps (newProps: SubmissionViewerProps) {
    if (this.videoPlayer && !newProps.isCurrentStudent) {
      this.videoPlayer.pause()
    }
  }

  captureVideoPlayer = (video: ?Video) => {
    this.videoPlayer = video
  }

  captureCanvadocViewer = (viewer: ?CanvadocViewer) => {
    this.canvadocViewer = viewer
  }

  updateSaveState = (newSaveState: any) => {
    this.setState({
      saving: this.saveState.saving,
      saveError: this.saveState.error ? i18n('Error Saving. Tap to retry.') : undefined,
    })
  }

  saveStateChanged = (event: any) => {
    // If an error happened, keep it around forever
    // until the user taps retry
    const error = this.saveState.error || event.nativeEvent.error
    this.saveState = {
      saving: event.nativeEvent.saving,
      error,
    }
    this.debouncedUpdateSaveState()
  }

  saveAllAnnotations = () => {
    if (this.canvadocViewer) {
      this.canvadocViewer.syncAllAnnotations()
      this.saveState = {
        saving: true,
        error: undefined,
      }
      this.updateSaveState()
    }
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

  renderSavingHeader = () => {
    if (this.state.saveError) {
      return <TouchableOpacity style={styles.errorBanner} onPress={this.saveAllAnnotations}>
        <View>
          <Text style={styles.errorBannerText}>{i18n('Error Saving. Tap to retry.')}</Text>
        </View>
      </TouchableOpacity>
    }

    return <View style={styles.savingBanner}>
      { this.state.saving && <Text style={styles.savingBannerText}>{i18n('Saving...')}</Text> }
      { !this.state.saving && <Text style={styles.savingBannerText}>{i18n('All annotations saved.')}</Text> }
    </View>
  }

  renderFile (submission: Submission) {
    if (submission.attachments) {
      let attachment = submission.attachments[this.props.selectedAttachmentIndex]
      if (attachment['content-type'] === 'image/heic') {
        let { width, height } = this.props.size
        return (
          <View style={{ flex: 1 }}>
            <ImageSubmissionViewer
              width={width}
              height={height}
              attachment={attachment}
            />
          </View>
        )
      }
      return (
        <View style={{ flex: 1 }}>
          { this.renderSavingHeader() }
          <CanvadocViewer
            config={{
              previewPath: attachment.preview_url,
              fallbackURL: attachment.url,
              filename: attachment.filename,
              drawerInset: this.props.drawerInset,
            }}
            onSaveStateChange={this.saveStateChanged}
            ref={this.captureCanvadocViewer}
            style={styles.pdfContainer}
          />
        </View>
      )
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
          body = <CoreWebView
            style={styles.webContainer}
            html={submission.body || ''}
            contentInset={{ bottom: this.props.drawerInset }}
            navigator={this.props.navigator}
          />
          break
        case 'online_quiz':
          body = <AuthenticatedWebView
            style={styles.webContainer}
            source={{ uri: submission.preview_url }}
            contentInset={{ bottom: this.props.drawerInset }}
            openLinksInSafari={false}
            onNavigation={(url) => {
              this.props.navigator.show(url, {
                deepLink: true,
                modal: true,
              })
            }}
          />
          break
        case 'discussion_topic':
        case 'basic_lti_launch':
        case 'external_tool':
          body = <AuthenticatedWebView
            style={styles.webContainer}
            source={{ uri: submission.preview_url }}
            contentInset={{ bottom: this.props.drawerInset }}
            navigator={this.props.navigator}
            openLinksInSafari
          />
          break
        case 'media_recording':
          const width = this.props.size.width - vars.padding * 2.0
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

const styles = createStyleSheet((colors, vars) => ({
  container: {
    paddingTop: 16,
    paddingLeft: 16,
    paddingRight: 16,
    flex: 1,
    backgroundColor: colors.backgroundLightest,
  },
  webContainer: {
    flex: 1,
  },
  pdfContainer: {
    paddingTop: 16,
    paddingLeft: 16,
    paddingRight: 16,
    flex: 1,
    backgroundColor: colors.backgroundDark,
  },
  centeredText: {
    height: 200,
    flex: 0,
    justifyContent: 'center',
    alignItems: 'center',
  },
  noSubText: {
    textAlign: 'center',
    fontWeight: '500',
  },
  savingBanner: {
    height: 22,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.backgroundLight,
    borderBottomWidth: vars.hairlineWidth,
    borderBottomColor: colors.borderMedium,
    borderStyle: 'solid',
  },
  savingBannerText: {
    color: colors.textDark,
    textAlign: 'center',
    fontWeight: '500',
    fontSize: 12,
  },
  errorBanner: {
    height: 22,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.backgroundDanger,
  },
  errorBannerText: {
    color: colors.white,
    textAlign: 'center',
    fontWeight: '500',
    fontSize: 12,
  },
}))
