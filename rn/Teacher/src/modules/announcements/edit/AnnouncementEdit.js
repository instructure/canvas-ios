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

/* @flow */

import React, { Component } from 'react'
import { connect } from 'react-redux'
import ReactNative, {
  View,
  StyleSheet,
  LayoutAnimation,
  DatePickerIOS,
  Alert,
  NativeModules,
  processColor,
} from 'react-native'
import i18n from 'format-message'
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view'
import moment from 'moment'
import Screen from '../../../routing/Screen'
import { Heading1 } from '../../../common/text'
import RowWithTextInput from '../../../common/components/rows/RowWithTextInput'
import RowWithSwitch from '../../../common/components/rows/RowWithSwitch'
import RowWithDateInput from '../../../common/components/rows/RowWithDateInput'
import colors from '../../../common/colors'
import images from '../../../images'
import RichTextEditor from '../../../common/components/rich-text-editor/RichTextEditor'
import { extractDateFromString } from '../../../utils/dateUtils'
import ModalActivityIndicator from '../../../common/components/ModalActivityIndicator'
import { default as EditDiscussionActions } from '../../discussions/edit/actions'
import { ERROR_TITLE } from '../../../redux/middleware/error-handler'
import UnmetRequirementBanner from '../../../common/components/UnmetRequirementBanner'
import RequiredFieldSubscript from '../../../common/components/RequiredFieldSubscript'

const { NativeAccessibility } = NativeModules

const {
  createDiscussion,
  deletePendingNewDiscussion,
  updateDiscussion,
} = EditDiscussionActions

const Actions = {
  createDiscussion,
  updateDiscussion,
  deletePendingNewDiscussion,
}

type OwnProps = {
  announcementID: ?string,
  courseID: string,
}

type State = {
  title: ?string,
  message: ?string,
  require_initial_post: ?boolean,
  delayed_post_at: ?string,
  attachment: ?Attachment,
}

export type Props = State & OwnProps & AsyncState & NavigationProps & typeof Actions & {
  defaultDate?: Date,
}

export class AnnouncementEdit extends Component<any, Props, any> {
  scrollView: KeyboardAwareScrollView

  constructor (props: Props) {
    super(props)

    this.state = {
      title: props.title,
      message: props.message,
      require_initial_post: props.require_initial_post,
      delayed_post_at: props.delayed_post_at,
      delayPosting: Boolean(props.delayed_post_at),
      delayedPostAtPickerShown: false,
      attachment: props.attachment,
      isValid: true,
    }
  }

  componentWillUnmount () {
    this.props.deletePendingNewDiscussion(this.props.courseID)
  }

  componentWillReceiveProps (props: Props) {
    const error = props.error
    if (error) {
      this.setState({ pending: false })
      this._handleError(error)
      return
    }

    if (this.state.pending && !props.pending) {
      this.setState({ pending: false })
      this.props.navigator.dismissAllModals()
      return
    }

    if (!this.state.pending) {
      this.setState({
        title: props.title,
        message: props.message,
        require_initial_post: props.require_initial_post,
        delayed_post_at: props.delayed_post_at,
        delayPosting: Boolean(props.delayed_post_at),
        attachment: props.attachment,
      })
    }
  }

  render () {
    const title = this.props.announcementID ? i18n('Edit') : i18n('New')
    return (
      <Screen
        title={i18n('{title} Announcement', { title })}
        rightBarButtons={[
          {
            title: i18n('Done'),
            testID: 'announcements.edit.doneButton',
            style: 'done',
            action: this._donePressed,
          },
          {
            image: images.attachmentLarge,
            testID: 'announcements.edit.attachment-btn',
            action: this.addAttachment,
            accessibilityLabel: i18n('Add attachment'),
            badge: this.state.attachment && {
              text: '1',
              backgroundColor: processColor(colors.primaryButtonColor),
              textColor: processColor(colors.primaryBrandColor),
            },
          },
        ]}
        leftBarButtons={[
          {
            title: i18n('Cancel'),
            testID: 'announcements.edit.cancelButton',
            style: 'cancel',
            action: this._cancelPressed,
          },
        ]}
      >
        <View style={{ flex: 1 }}>
          <ModalActivityIndicator text={i18n('Saving')} visible={this.state.pending}/>
          <UnmetRequirementBanner text={i18n('Invalid field')} visible={!this.state.isValid} testID='announcement.edit.unmet-requirement-banner'/>
          <KeyboardAwareScrollView
            style={style.container}
            keyboardShouldPersistTaps='handled'
            enableAutoAutomaticScroll={false}
            ref={(r) => { this.scrollView = r }}
          >
            <Heading1 style={style.heading}>{i18n('Title')}</Heading1>
            <RowWithTextInput
              defaultValue={this.state.title}
              border='both'
              onChangeText={this._valueChanged('title')}
              identifier='announcements.edit.titleInput'
              placeholder={i18n('Add title')}
              onFocus={this._scrollToInput}
            />

            <Heading1 style={style.heading}>{i18n('Description')}</Heading1>
            <View
              style={style.description}
            >
              <RichTextEditor
                onChangeValue={this._valueChanged('message')}
                defaultValue={this.props.message}
                showToolbar='always'
                keyboardAware={false}
                scrollEnabled={true}
                contentHeight={150}
                placeholder={i18n('Add description (required)')}
              />
            </View>
            <RequiredFieldSubscript title={i18n('A description is required')} visible={!this.state.isValid} />

            <Heading1 style={style.heading}>{i18n('Options')}</Heading1>
            <RowWithSwitch
              title={i18n('Delay Posting')}
              border='both'
              value={this.state.delayPosting}
              onValueChange={this._toggleDelayPosting}
              identifier='announcements.edit.delay-posting-toggle'
            />
            { this.state.delayPosting &&
              <View>
                <RowWithDateInput
                  title={i18n('Post at...')}
                  date={this.state.delayed_post_at ? moment(this.state.delayed_post_at).format(`MMM D  h:mm A`) : '--'}
                  selected={this.state.delayedPostAtPickerShown}
                  showRemoveButton={Boolean(this.state.delayed_post_at)}
                  border='bottom'
                  onPress={this._toggleDelayedPostAtPicker}
                  onRemoveDatePress={this._clearDelayedPostAt}
                  testID={'announcements.edit.delayed-post-at-row'}
                  dateTestID={'announcements.edit.delayed-post-at-value-label'}
                  removeButtonTestID={'announcements.edit.clear-delayed-post-at-button'}
                />
                { this.state.delayedPostAtPickerShown &&
                  <DatePickerIOS
                    date={extractDateFromString(this.state.delayed_post_at) || this.props.defaultDate || new Date()}
                    onDateChange={this._valueChanged('delayed_post_at', d => d.toISOString())}
                    testID='announcements.edit.delayed-post-at-date-picker'
                  />
                }
              </View>
            }
            <RowWithSwitch
              title={i18n('Users must post before seeing replies')}
              border='bottom'
              value={this.state.require_initial_post}
              onValueChange={this._valueChanged('require_initial_post')}
            />
          </KeyboardAwareScrollView>
        </View>
      </Screen>
    )
  }

  _valueChanged (property: string, transformer?: any, animated?: boolean = true): Function {
    return (value) => {
      if (transformer) { value = transformer(value) }
      this._valuesChanged({ [property]: value }, animated)
    }
  }

  _valuesChanged (values: Object, animated?: boolean) {
    if (animated) {
      LayoutAnimation.easeInEaseOut()
    }
    this.setState({ ...values })
  }

  _toggleDelayPosting = (delayPosting: boolean) => {
    LayoutAnimation.easeInEaseOut()
    this.setState({
      delayPosting: delayPosting,
      delayed_post_at: null,
    })
  }

  _clearDelayedPostAt = () => {
    LayoutAnimation.easeInEaseOut()
    this.setState({
      delayedPostAtPickerShown: false,
      delayed_post_at: null,
    })
  }

  _toggleDelayedPostAtPicker = () => {
    const defaultDate = this.props.defaultDate || new Date()
    const date = defaultDate.toISOString()
    LayoutAnimation.easeInEaseOut()
    this.setState({
      delayedPostAtPickerShown: !this.state.delayedPostAtPickerShown,
      delayed_post_at: this.state.delayed_post_at || date,
    })
  }

  _donePressed = () => {
    if (!this.state.message) {
      this.setState({ isValid: false })
      setTimeout(function () { NativeAccessibility.focusElement('announcement.edit.unmet-requirement-banner') }, 500)
      return
    }

    const params = {
      title: this.state.title === '' ? null : this.state.title,
      message: this.state.message,
      require_initial_post: this.state.require_initial_post || false,
      delayed_post_at: this.state.delayed_post_at,
      is_announcement: true,
      attachment: this.state.attachment,
    }
    if (this.props.announcementID) {
      // $FlowFixMe
      params.id = this.props.announcementID
    }
    if (this.props.attachment && !this.state.attachment) {
      // $FlowFixMe
      params.remove_attachment = true
    }
    this.setState({ pending: true, isValid: true })
    this.props.announcementID
      ? this.props.updateDiscussion(this.props.courseID, params)
      : this.props.createDiscussion(this.props.courseID, params)
  }

  _cancelPressed = () => {
    this.props.navigator.dismiss()
  }

  _scrollToInput = (event: any) => {
    const input = ReactNative.findNodeHandle(event.target)
    this.scrollView.scrollToFocusedInput(input)
  }

  _handleError (error: string) {
    setTimeout(() => {
      Alert.alert(ERROR_TITLE, error)
    }, 1000)
  }

  addAttachment = () => {
    this.props.navigator.show('/attachments', { modal: true }, {
      attachments: this.state.attachment ? [this.state.attachment] : [],
      maxAllowed: 1,
      storageOptions: {
        upload: false,
      },
      onComplete: this._valueChanged('attachment', (as) => as[0]),
    })
  }

}

const style = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5F5F5',
  },
  heading: {
    color: colors.darkText,
    marginLeft: global.style.defaultPadding,
    marginTop: global.style.defaultPadding,
    marginBottom: global.style.defaultPadding / 2,
  },
  description: {
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: colors.seperatorColor,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: colors.seperatorColor,
    backgroundColor: 'white',
    height: 200,
  },
  deleteButtonTitle: {
    color: '#EE0612',
  },
})

export function mapStateToProps ({ entities }: AppState, { courseID, announcementID }: OwnProps): State {
  let announcement = {}
  let error = null
  let pending = 0
  let attachment = null

  if (!announcementID &&
    entities.courses &&
    entities.courses[courseID] &&
    entities.courses[courseID].discussions &&
    entities.courses[courseID].discussions.new) {
    const newState = entities.courses[courseID].discussions.new
    error = newState.error
    pending = newState.pending || 0
    announcementID = newState.id
  }

  if (announcementID &&
    entities.discussions &&
    entities.discussions[announcementID] &&
    entities.discussions[announcementID].data) {
    const entity = entities.discussions[announcementID]
    announcement = entity.data
    attachment = announcement.attachments && announcement.attachments.length && announcement.attachments[0]
    pending = entity.pending || 0
    error = entity.error
  }
  const {
    title,
    message,
    require_initial_post,
    delayed_post_at,
  } = announcement
  return {
    title,
    message,
    require_initial_post,
    delayed_post_at,
    pending,
    error,
    attachment,
  }
}

const Connected = connect(mapStateToProps, Actions)(AnnouncementEdit)
export default (Connected: Component<any, Props, any>)
