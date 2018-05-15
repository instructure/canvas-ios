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
  PickerIOS,
  DatePickerIOS,
  Image,
  NativeModules,
  processColor,
} from 'react-native'
import i18n from 'format-message'
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view'
import Button from 'react-native-button'

import Screen from '../../../routing/Screen'
import { Heading1 } from '../../../common/text'
import RowWithTextInput from '../../../common/components/rows/RowWithTextInput'
import RowWithSwitch from '../../../common/components/rows/RowWithSwitch'
import RowWithDetail from '../../../common/components/rows/RowWithDetail'
import RowWithDateInput from '../../../common/components/rows/RowWithDateInput'
import colors from '../../../common/colors'
import RichTextEditor from '../../../common/components/rich-text-editor/RichTextEditor'
import Images from '../../../images'
import ModalOverlay from '../../../common/components/ModalOverlay'
import { default as EditDiscussionActions } from '../../discussions/edit/actions'
import { default as DiscussionDetailsActions } from '../../discussions/details/actions'
import { alertError } from '../../../redux/middleware/error-handler'
import { gradeDisplayOptions } from '../../assignment-details/AssignmentDetailsEdit'
import AssignmentDatesEditor from '../../assignment-details/components/AssignmentDatesEditor'
import { default as AssignmentsActions } from '../../assignments/actions'
import UnmetRequirementBanner from '../../../common/components/UnmetRequirementBanner'
import RequiredFieldSubscript from '../../../common/components/RequiredFieldSubscript'
import { extractDateFromString } from '../../../utils/dateUtils'
import { isTeacher } from '../../app'

const { NativeAccessibility } = NativeModules

const {
  createDiscussion,
  deletePendingNewDiscussion,
  updateDiscussion,
  subscribeDiscussion,
} = EditDiscussionActions

const { refreshDiscussionEntries } = DiscussionDetailsActions

const { updateAssignment } = AssignmentsActions

const Actions = {
  createDiscussion,
  updateDiscussion,
  deletePendingNewDiscussion,
  subscribeDiscussion,
  refreshDiscussionEntries,
  updateAssignment,
}

const PickerItem = PickerIOS.Item

type OwnProps = {
  discussionID: ?string,
  context: CanvasContext,
  contextID: string,
}

type State = {
  title: ?string,
  message: ?string,
  published: ?boolean,
  discussion_type: ?DiscussionType,
  subscribed: ?boolean,
  require_initial_post: ?boolean,
  delayed_post_at: ?string,
  lock_at: ?string,
  can_unpublish: ?boolean,
  assignment: ?Assignment,
  attachment: ?Attachment,
}

export type Props = State & OwnProps & AsyncState & NavigationProps & typeof Actions & {
  defaultDate?: ?Date,
}

export class DiscussionEdit extends Component<Props, any> {
  scrollView: KeyboardAwareScrollView
  datesEditor: ?AssignmentDatesEditor
  editor: ?RichTextEditor

  constructor (props: Props) {
    super(props)

    const { assignment } = props

    this.state = {
      title: props.title,
      message: props.message,
      published: props.published,
      discussion_type: props.discussion_type || 'side_comment',
      subscribed: props.subscribed,
      require_initial_post: props.require_initial_post,
      lock_at: props.lock_at,
      delayed_post_at: props.delayed_post_at,
      assignment: props.assignment,
      points_possible: assignment ? assignment.points_possible : null,
      grading_type: assignment ? assignment.grading_type : 'points',
      can_unpublish: props.can_unpublish == null || props.can_unpublish,
      gradingTypePickerShown: false,
      showingDatePicker: {
        delayed_post_at: false,
        lock_at: false,
      },
      errors: {},
      attachment: props.attachment,
    }
  }

  componentWillUnmount () {
    this.props.deletePendingNewDiscussion(this.props.context, this.props.contextID)
    if (this.props.discussionID) {
      this.props.refreshDiscussionEntries(this.props.context, this.props.contextID, this.props.discussionID, true)
    }
  }

  componentWillReceiveProps (props: Props) {
    const error = props.error
    if (error) {
      this.setState({ pending: false })
      this._handleError(error)
      return
    }

    if (this.state.pending && !props.pending) {
      this.props.navigator.dismissAllModals()
      return
    }

    if (!this.state.pending) {
      this.setState({
        title: props.title,
        message: props.message,
        published: props.published,
        discussion_type: props.discussion_type || 'side_comment',
        subscribed: props.subscribed,
        require_initial_post: props.require_initial_post,
        lock_at: props.lock_at,
        delayed_post_at: props.delayed_post_at,
        assignment: props.assignment,
        can_unpublish: props.can_unpublish == null || props.can_unpublish,
        attachment: props.attachment,
      })
    }
  }

  render () {
    const title = this.props.discussionID ? i18n('Edit') : i18n('New')
    const defaultDate = this.props.defaultDate || new Date()
    const gradeDisplayOpts = gradeDisplayOptions()

    return (
      <Screen
        title={i18n('{title} Discussion', { title })}
        rightBarButtons={[
          {
            title: i18n('Done'),
            testID: 'discussions.edit.doneButton',
            style: 'done',
            action: this._donePressed,
          },
          {
            image: Images.attachmentLarge,
            testID: 'discussions.edit.attachment-btn',
            action: this.addAttachment,
            accessibilityLabel: i18n('Edit attachment ({count})', { count: this.state.attachment ? '1' : i18n('none') }),
            badge: this.state.attachment && {
              text: '1',
              backgroundColor: processColor('#008EE2'),
              textColor: processColor('white'),
            },
          },
        ]}
        dismissButtonTitle={i18n('Cancel')}
      >
        <View style={{ flex: 1 }}>
          <ModalOverlay text={i18n('Saving')} visible={this.state.pending}/>
          <UnmetRequirementBanner
            text={i18n('Invalid field')}
            visible={Boolean(Object.keys(this.state.errors).length)}
            testID='discussions.edit.unmet-requirement-banner'
          />
          <KeyboardAwareScrollView
            style={style.container}
            keyboardShouldPersistTaps='handled'
            enableAutoAutomaticScroll={false}
            ref={(r) => { this.scrollView = r }}
            keyboardDismissMode={'on-drag'}
          >
            <Heading1 style={style.heading}>{i18n('Title')}</Heading1>
            <RowWithTextInput
              defaultValue={this.state.title}
              border='both'
              onChangeText={this._valueChanged('title')}
              identifier='discussions.edit.titleInput'
              placeholder={i18n('Add title (required)')}
              onFocus={this._scrollToInput}
            />
            <RequiredFieldSubscript
              title={this.state.errors.title}
              visible={Boolean(this.state.errors.title)}
              testID='discussions.edit.title.validation-error'
            />

            <Heading1 style={style.heading}>{i18n('Description')}</Heading1>
            <View
              style={style.description}
            >
              <RichTextEditor
                ref={(r) => { this.editor = r }}
                defaultValue={this.props.message}
                showToolbar='always'
                keyboardAware={false}
                scrollEnabled={true}
                contentHeight={150}
                placeholder={i18n('Add description')}
                navigator={this.props.navigator}
                attachmentUploadPath={isTeacher() ? `/${this.props.context}/${this.props.contextID}/files` : '/users/self/files'}
                onFocus={this._scrollToRCE}
              />
            </View>

            <Heading1 style={style.heading}>{i18n('Options')}</Heading1>
            { this.state.can_unpublish && isTeacher() &&
              <RowWithSwitch
                title={i18n('Publish')}
                border='both'
                value={this.state.published}
                onValueChange={this._valueChanged('published')}
                testID='discussions.edit.published.switch'
              />
            }
            <RowWithSwitch
              title={i18n('Allow threaded replies')}
              border='bottom'
              value={this.state.discussion_type === 'threaded'}
              onValueChange={this._valueChanged('discussion_type', b => b ? 'threaded' : 'side_comment')}
              identifier='discussions.edit.discussion_type.switch'
            />
            { this.props.discussionID &&
              <RowWithSwitch
                title={i18n('Subscribe')}
                border='bottom'
                value={this.state.subscribed}
                onValueChange={this._subscribe}
                identifier='discussions.edit.subscribed.switch'
              />
            }
            { isTeacher() &&
              <RowWithSwitch
                title={i18n('Students must post before seeing replies')}
                border='bottom'
                value={this.state.require_initial_post}
                onValueChange={this._valueChanged('require_initial_post')}
              />
            }
            { this.isGraded() &&
              <View>
                <RowWithTextInput
                  title={i18n('Points')}
                  border='bottom'
                  placeholder='--'
                  inputWidth={200}
                  onChangeText={this._valueChanged('points_possible')}
                  keyboardType='number-pad'
                  defaultValue={(this.state.points_possible && String(this.state.points_possible)) || '0'}
                  onFocus={this._scrollToInput}
                  identifier='discussions.edit.points_possible.input'
                />
                <RowWithDetail
                  title={i18n('Display Grade as...')}
                  detailSelected={this.state.gradingTypePickerShown}
                  detail={gradeDisplayOpts.get(this.state.grading_type) || ''}
                  disclosureIndicator={true}
                  border='bottom'
                  onPress={this._toggleGradingTypePicker}
                  testID='discussions.edit.grading_type.row'
                />
                { this.state.gradingTypePickerShown &&
                  <PickerIOS
                    selectedValue={this.state.grading_type}
                    onValueChange={this._valueChanged('grading_type', null, false)}
                    testID='discussions.edit.grading_type.picker'>
                    {Array.from(gradeDisplayOpts.keys()).map((key) => (
                      <PickerItem
                        key={key}
                        value={key}
                        label={gradeDisplayOpts.get(key)}
                      />
                    ))}
                  </PickerIOS>
                }
                <RequiredFieldSubscript
                  title={this.state.errors.points_possible}
                  visible={Boolean(this.state.errors.points_possible)}
                  testID='discussions.edit.points_possible.validation-error'
                />
              </View>
            }

            { this.isGraded() &&
              <AssignmentDatesEditor
                assignment={this.state.assignment}
                ref={c => { this.datesEditor = c }}
                navigator={this.props.navigator}
              />
            }

            { isTeacher() && !this.isGraded() &&
              <View>
                <Heading1 style={style.heading}>{i18n('Availability')}</Heading1>
                <RowWithDateInput
                  title={i18n('Available From')}
                  date={this.state.delayed_post_at}
                  selected={this.state.showingDatePicker.delayed_post_at}
                  showRemoveButton={Boolean(this.state.delayed_post_at)}
                  border='bottom'
                  onPress={this._toggleDatePicker('delayed_post_at')}
                  onRemoveDatePress={this._clearDate('delayed_post_at')}
                  testID={'discussions.edit.delayed_post_at.row'}
                  removeButtonTestID={'discussions.edit.clear-delayed-post-at.button'}
                />
                { this.state.showingDatePicker.delayed_post_at &&
                  <DatePickerIOS
                    date={extractDateFromString(this.state.delayed_post_at) || defaultDate}
                    onDateChange={this._valueChanged('delayed_post_at', d => d.toISOString())}
                    testID='discussions.edit.delayed_post_at.picker'
                    accessories={ Boolean(this.state.delayed_post_at) &&
                      <View style={{ marginLeft: 8 }}>
                        <Button
                          testID={`discussions.edit.clear-delayed-post-at.button`}
                          activeOpacity={1}
                          onPress={this._clearDate('delayed_post_at')}
                        >
                          <Image source={Images.clear} />
                        </Button>
                      </View>
                    }
                  />
                }
                <RowWithDateInput
                  title={i18n('Available Until')}
                  date={this.state.lock_at}
                  selected={this.state.showingDatePicker.lock_at}
                  showRemoveButton={Boolean(this.state.lock_at)}
                  border='bottom'
                  onPress={this._toggleDatePicker('lock_at')}
                  onRemoveDatePress={this._clearDate('lock_at')}
                  testID={'discussions.edit.lock_at.row'}
                  removeButtonTestID={'discussions.edit.clear-lock-at.button'}
                />
                { this.state.showingDatePicker.lock_at &&
                  <DatePickerIOS
                    date={extractDateFromString(this.state.lock_at) || defaultDate}
                    onDateChange={this._valueChanged('lock_at', d => d.toISOString())}
                    testID='discussions.edit.lock_at.picker'
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

  _donePressed = () => {
    if (!this.validate()) {
      setTimeout(function () { NativeAccessibility.focusElement('discussions.edit.unmet-requirement-banner') }, 500)
      return
    }
    this.setState({ pending: true })
    this.updateAssignment()
    this.updateDiscussion()
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

  _toggleGradingTypePicker = () => {
    LayoutAnimation.easeInEaseOut()
    this.setState({
      gradingTypePickerShown: !this.state.gradingTypePickerShown,
    })
  }

  _toggleDatePicker = (dateField) => {
    return () => {
      const willShow = !this.state.showingDatePicker[dateField]
      if (willShow && !this.state[dateField]) {
        this._valueChanged(dateField, null, false)(this.props.defaultDate || new Date())
      }
      this.setState({
        showingDatePicker: {
          ...this.state.showingDatePicker,
          [dateField]: willShow,
        },
      })
    }
  }

  _clearDate = (dateField) => {
    return () => {
      LayoutAnimation.easeInEaseOut()
      this.setState({
        [dateField]: null,
        showingDatePicker: {
          ...this.state.showingDatePicker,
          [dateField]: false,
        },
      })
    }
  }

  _subscribe = (shouldSubscribe: boolean) => {
    this.props.subscribeDiscussion(this.props.context, this.props.contextID, this.props.discussionID, shouldSubscribe)
  }

  validate () {
    const errors = {}
    if (this.state.assignment && this.datesEditor && !this.datesEditor.validate()) {
      errors.dates = true
    }

    if (!this.state.title) {
      errors.title = i18n('A title is required')
    }

    if (this.state.assignment) {
      const pointsPossible = String(this.state.points_possible)
      if (isNaN(pointsPossible) || !pointsPossible) {
        errors.points_possible = i18n('Points possible must be a number')
      } else if (Number(pointsPossible) < 0) {
        errors.points_possible = i18n('The value of possible points must be zero or greater')
      }
    }

    this.setState({ errors })

    return !Object.keys(errors).length
  }

  updateAssignment () {
    if (this.state.assignment && this.datesEditor) {
      const updatedAssignment = this.datesEditor.updateAssignment({ ...this.state.assignment })
      updatedAssignment.points_possible = this.state.points_possible || 0
      updatedAssignment.grading_type = this.state.grading_type
      this.props.updateAssignment(this.props.contextID, updatedAssignment, this.props.assignment)
    }
  }

  async updateDiscussion () {
    const message = this.editor ? await this.editor.getHTML() : ''
    let params = {
      title: this.state.title || i18n('No Title'),
      message: message,
      published: !isTeacher() || this.state.published || false,
      discussion_type: this.state.discussion_type || 'side_comment',
      subscribed: this.state.subscribed || false,
      require_initial_post: this.state.require_initial_post || false,
      lock_at: this.state.lock_at,
      delayed_post_at: this.state.delayed_post_at,
      attachment: this.state.attachment,
    }

    if (this.props.discussionID) {
      // $FlowFixMe
      params.id = this.props.discussionID
    }
    if (this.props.attachment && !this.state.attachment) {
      // $FlowFixMe
      params.remove_attachment = true
    }

    this.props.discussionID
      ? this.props.updateDiscussion(this.props.context, this.props.contextID, params)
      : this.props.createDiscussion(this.props.context, this.props.contextID, params)
  }

  isGraded = () => Boolean(this.state.assignment)

  addAttachment = () => {
    this.props.navigator.show('/attachments', { modal: true }, {
      attachments: this.state.attachment ? [this.state.attachment] : [],
      maxAllowed: 1,
      storageOptions: {
        uploadPath: isTeacher() ? null : 'users/self/files',
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

export function mapStateToProps ({ entities }: AppState, { context, contextID, discussionID }: OwnProps): State {
  let discussion = {}
  let error = null
  let pending = 0
  let assignment = null
  let attachment = null

  let origin: DiscussionOriginEntity = context === 'courses' ? entities.courses : entities.groups

  if (!discussionID &&
    origin &&
    origin[contextID] &&
    origin[contextID].discussions &&
    origin[contextID].discussions.new) {
    const newState = origin[contextID].discussions.new
    error = newState.error
    pending = pending + (newState.pending || 0)
    discussionID = newState.id
  }

  if (discussionID &&
    entities.discussions &&
    entities.discussions[discussionID] &&
    entities.discussions[discussionID].data) {
    const entity = entities.discussions[discussionID]
    discussion = entity.data
    attachment = discussion.attachments && discussion.attachments.length && discussion.attachments[0]
    pending = pending + (entity.pending || 0)
    error = error || entity.error
  }

  if (discussion &&
    discussion.assignment_id &&
    entities.assignments &&
    entities.assignments[discussion.assignment_id] &&
    entities.assignments[discussion.assignment_id].data) {
    const assignmentEntity = entities.assignments[discussion.assignment_id]
    assignment = assignmentEntity.data
    pending = pending + (assignmentEntity.pending || 0)
    error = error || assignmentEntity.error
  }

  const {
    title,
    message,
    published,
    discussion_type,
    subscribed,
    require_initial_post,
    lock_at,
    delayed_post_at,
    can_unpublish,
  } = discussion
  return {
    title,
    message,
    published,
    discussion_type,
    subscribed,
    require_initial_post,
    delayed_post_at,
    lock_at,
    can_unpublish,
    assignment,
    pending,
    error,
    attachment,
  }
}

const Connected = connect(mapStateToProps, Actions)(DiscussionEdit)
export default (Connected: Component<Props, any>)
