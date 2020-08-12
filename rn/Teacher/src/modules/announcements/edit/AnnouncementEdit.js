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

/* @flow */

import React, { Component } from 'react'
import { connect } from 'react-redux'
import ReactNative, {
  View,
  LayoutAnimation,
  NativeModules,
  processColor,
} from 'react-native'
import i18n from 'format-message'
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view'
import DateTimePicker from '@react-native-community/datetimepicker'
import Screen from '../../../routing/Screen'
import { FormLabel } from '../../../common/text'
import RowWithTextInput from '../../../common/components/rows/RowWithTextInput'
import RowWithSwitch from '../../../common/components/rows/RowWithSwitch'
import RowWithDateInput from '../../../common/components/rows/RowWithDateInput'
import RowWithDetail from '../../../common/components/rows/RowWithDetail'
import { colors, createStyleSheet } from '../../../common/stylesheet'
import images from '../../../images'
import RichTextEditor from '../../../common/components/rich-text-editor/RichTextEditor'
import { extractDateFromString } from '../../../utils/dateUtils'
import ModalOverlay from '../../../common/components/ModalOverlay'
import { default as EditDiscussionActions } from '../../discussions/edit/actions'
import { alertError } from '../../../redux/middleware/error-handler'
import UnmetRequirementBanner from '../../../common/components/UnmetRequirementBanner'
import RequiredFieldSubscript from '../../../common/components/RequiredFieldSubscript'
import AssigneePickerActions from '../../assignee-picker/actions'
import DisclosureIndicator from '../../../common/components/DisclosureIndicator'
import { isTeacher } from '../../app/index'

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
  refreshSections: AssigneePickerActions.refreshSections,
}

type OwnProps = {
  announcementID: ?string,
  context: CanvasContext,
  contextID: string,
}

type DataProps = {
  title: ?string,
  message: ?string,
  require_initial_post: ?boolean,
  delayed_post_at: ?string,
  attachment: ?Attachment,
  sections: Section[],
  selectedSections: string[],
}

export type Props = DataProps & OwnProps & AsyncState & NavigationProps & typeof Actions & {
  defaultDate?: Date,
}

export class AnnouncementEdit extends Component<Props, any> {
  scrollView: KeyboardAwareScrollView
  editor: ?RichTextEditor

  state = {
    title: this.props.title,
    message: this.props.message,
    locked: this.props.locked ?? true,
    require_initial_post: this.props.require_initial_post ?? false,
    delayed_post_at: this.props.delayed_post_at,
    delayPosting: Boolean(this.props.delayed_post_at),
    delayedPostAtPickerShown: false,
    attachment: this.props.attachment,
    isValid: true,
    selectedSections: this.props.selectedSections || [],
    pending: false,
  }

  componentWillUnmount () {
    this.props.deletePendingNewDiscussion(this.props.context, this.props.contextID)
  }

  componentDidMount () {
    if (this.props.context === 'courses') {
      this.props.refreshSections(this.props.contextID)
    }
  }

  UNSAFE_componentWillReceiveProps (props: Props) {
    const error = props.error
    if (error) {
      this.setState({ pending: false })
      this._handleError(error)
      return
    }

    if (this.props.pending && !props.pending) {
      this.setState({ pending: false }, () => {
        const isNew = !this.props.announcementID
        this.props.navigator.dismissAllModals()
          .then(() => {
            if (isNew) {
              NativeModules.AppStoreReview.handleSuccessfulSubmit()
            }
          })
      })
      return
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
            image: images.paperclip,
            testID: 'announcements.edit.attachment-btn',
            action: this.addAttachment,
            accessibilityLabel: i18n('Add attachment'),
            badge: this.state.attachment && {
              text: '1',
              backgroundColor: processColor(colors.buttonPrimaryBackground),
              textColor: processColor(colors.primary),
            },
          },
        ]}
        dismissButtonTitle={i18n('Cancel')}
      >
        <View style={{ flex: 1 }}>
          <ModalOverlay text={i18n('Saving')} visible={this.state.pending}/>
          <UnmetRequirementBanner text={i18n('Invalid field')} visible={!this.state.isValid} testID='announcement.edit.unmet-requirement-banner'/>
          <KeyboardAwareScrollView
            style={style.container}
            keyboardShouldPersistTaps='handled'
            enableAutoAutomaticScroll={false}
            ref={(r) => { this.scrollView = r }}
          >
            <FormLabel>{i18n('Title')}</FormLabel>
            <RowWithTextInput
              defaultValue={this.state.title}
              border='both'
              onChangeText={this._valueChanged('title')}
              identifier='announcements.edit.titleInput'
              placeholder={i18n('Add title')}
              onFocus={this._scrollToInput}
            />

            <FormLabel>{i18n('Description')}</FormLabel>
            <View style={style.description}>
              <RichTextEditor
                ref={(r) => { this.editor = r }}
                defaultValue={this.props.message}
                showToolbar='always'
                keyboardAware={false}
                scrollEnabled={true}
                contentHeight={150}
                placeholder={i18n('Add description (required)')}
                navigator={this.props.navigator}
                attachmentUploadPath={`/${this.props.context}/${this.props.contextID}/files`}
                onFocus={this._scrollToRCE}
                context={this.props.context}
                contextID={this.props.contextID}
              />
            </View>
            <RequiredFieldSubscript title={i18n('A description is required')} visible={!this.state.isValid} />

            { isTeacher() &&
              <View>
                <FormLabel>{i18n('Options')}</FormLabel>
                {this.props.context === 'courses' &&
                  <RowWithDetail
                    title={i18n('Sections')}
                    border='both'
                    onPress={this.selectSections}
                    detail={
                      this.state.selectedSections.length
                        ? this.state.selectedSections
                          .map(id => {
                            let section = this.props.sections.find(s => s.id === id)
                            return section && section.name
                          })
                          .filter(s => s)
                          .join(', ')
                        : i18n('All')

                    }
                    accessories={<DisclosureIndicator />}
                  />
                }
                <RowWithSwitch
                  title={i18n('Delay Posting')}
                  border='bottom'
                  value={this.state.delayPosting}
                  onValueChange={this._toggleDelayPosting}
                  identifier='announcements.edit.delay-posting-toggle'
                />
                { this.state.delayPosting &&
                  <View>
                    <RowWithDateInput
                      title={i18n('Post at...')}
                      date={this.state.delayed_post_at}
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
                      <DateTimePicker
                        value={extractDateFromString(this.state.delayed_post_at) || this.props.defaultDate || new Date()}
                        onChange={(event, date) => this._valuesChanged({ delayed_post_at: date.toISOString() }, true)}
                        testID='announcements.edit.delayed-post-at-date-picker'
                      />
                    }
                  </View>
                }
                <RowWithSwitch
                  testID='announcement.edit.locked'
                  title={i18n('Allow users to comment')}
                  border='bottom'
                  value={!this.state.locked}
                  onValueChange={this._toggleLocked}
                />
                {this.state.locked === false &&
                  <RowWithSwitch
                    testID='announcement.edit.initial-post'
                    title={i18n('Students must post before seeing replies')}
                    border='bottom'
                    value={this.state.require_initial_post}
                    onValueChange={this._valueChanged('require_initial_post')}
                  />
                }
              </View>
            }
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

  _toggleLocked = () => {
    this.setState((prevState) => ({
      locked: !prevState.locked,
      require_initial_post: false,
    }))
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

  _donePressed = async () => {
    const message = this.editor && await this.editor.getHTML()
    if (!message) {
      this.setState({ isValid: false })
      setTimeout(function () { NativeAccessibility.focusElement('announcement.edit.unmet-requirement-banner') }, 500)
      return
    }

    const params: CreateDiscussionParameters | UpdateDiscussionParameters = {
      title: this.state.title ?? i18n('No Title'),
      message: message,
      locked: this.state.locked,
      require_initial_post: this.state.require_initial_post ?? false,
      delayed_post_at: this.state.delayed_post_at,
      is_announcement: true,
      attachment: this.state.attachment,
    }

    if (this.state.selectedSections.length) {
      params.specific_sections = this.state.selectedSections.join(',')
      params.sections = this.state.selectedSections.map(sectionID => this.props.sections.find(({ id }) => id === sectionID))
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
      ? this.props.updateDiscussion(this.props.context, this.props.contextID, params)
      : this.props.createDiscussion(this.props.context, this.props.contextID, params)
  }

  _cancelPressed = () => {
    this.props.navigator.dismiss()
  }

  _scrollToInput = (event: any) => {
    const input = ReactNative.findNodeHandle(event.target)
    this.scrollView.scrollToFocusedInput(input)
  }

  _scrollToRCE = () => {
    const input = ReactNative.findNodeHandle(this.editor)
    // $FlowFixMe
    this.scrollView.scrollToFocusedInput(input)
  }

  _handleError (error: string) {
    setTimeout(() => {
      alertError(error)
    }, 1000)
  }

  addAttachment = () => {
    this.props.navigator.show('/attachments', { modal: true }, {
      attachments: this.state.attachment ? [this.state.attachment] : [],
      maxAllowed: 1,
      storageOptions: {
        uploadPath: undefined,
      },
      onComplete: this._valueChanged('attachment', (as) => as[0]),
    })
  }

  selectSections = () => {
    this.props.navigator.show(`/courses/${this.props.contextID}/section-selector`, {}, {
      updateSelectedSections: this.updateSelectedSections,
      currentSelectedSections: this.state.selectedSections,
    })
  }

  updateSelectedSections = (sectionIDs: string) => {
    this.setState({
      selectedSections: sectionIDs,
    })
  }
}

const style = createStyleSheet((colors, vars) => ({
  container: {
    flex: 1,
    backgroundColor: colors.backgroundLight,
  },
  description: {
    borderTopWidth: vars.hairlineWidth,
    borderTopColor: colors.borderMedium,
    borderBottomWidth: vars.hairlineWidth,
    borderBottomColor: colors.borderMedium,
    backgroundColor: colors.backgroundLightest,
    height: 200,
  },
  deleteButtonTitle: {
    color: colors.textDanger,
  },
}))

export function mapStateToProps ({ entities }: AppState, { context, contextID, announcementID }: OwnProps): DataProps {
  let announcement = {}
  let error = null
  let pending = 0
  let attachment = null

  let origin: DiscussionOriginEntity = context === 'courses' ? entities.courses : entities.groups

  if (!announcementID &&
    origin &&
    origin[contextID] &&
    origin[contextID].discussions &&
    origin[contextID].discussions.new) {
    const newState = origin[contextID].discussions.new
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
    sections,
    locked,
  } = announcement

  let selectedSections = sections && sections.map(({ id }) => id) || []
  let courseSections: Section[] = []
  if (context === 'courses') {
    // $FlowFixMe
    courseSections = Object.values(entities.sections).filter(s => s.course_id === contextID)
  }

  return {
    title,
    message,
    require_initial_post,
    delayed_post_at,
    locked,
    pending,
    error,
    attachment,
    sections: courseSections,
    selectedSections,
  }
}

const Connected = connect(mapStateToProps, Actions)(AnnouncementEdit)
export default (Connected: Component<Props, any>)
