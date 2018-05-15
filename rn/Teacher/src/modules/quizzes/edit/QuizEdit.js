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

/* eslint-disable flowtype/require-valid-file-annotation */

import React, { Component } from 'react'
import { connect } from 'react-redux'
import i18n from 'format-message'
import {
  View,
  StyleSheet,
  Image,
  Text,
  LayoutAnimation,
  PickerIOS,
  DatePickerIOS,
  NativeModules,
} from 'react-native'
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view'
import { Heading1 } from '../../../common/text'
import colors from '../../../common/colors'
import images from '../../../images'
import RowWithTextInput from '../../../common/components/rows/RowWithTextInput'
import Row from '../../../common/components/rows/Row'
import RowWithDetail from '../../../common/components/rows/RowWithDetail'
import RowWithDateInput from '../../../common/components/rows/RowWithDateInput'
import RowWithSwitch from '../../../common/components/rows/RowWithSwitch'
import formatter, { SCORING_POLICIES, QUIZ_TYPES } from '../formatter'
import { extractDateFromString } from '../../../utils/dateUtils'
import { default as QuizEditActions } from './actions'
import { alertError } from '../../../redux/middleware/error-handler'
import Navigator from '../../../routing/Navigator'
import Screen from '../../../routing/Screen'
import AssignmentActions from '../../assignments/actions'
import AssignmentDatesEditor from '../../assignment-details/components/AssignmentDatesEditor'
import UnmetRequirementBanner from '../../../common/components/UnmetRequirementBanner'
import RequiredFieldSubscript from '../../../common/components/RequiredFieldSubscript'
import canvas from '../../../canvas-api'
import SavingBanner from '../../../common/components/SavingBanner'

const { NativeAccessibility } = NativeModules

const { updateAssignment, refreshAssignment } = AssignmentActions

const Actions = {
  ...QuizEditActions,
  updateAssignment,
  refreshAssignment,
}

type Validation = {
  isValid: boolean,
  title: boolean,
  showCorrectAnswerDates: boolean,
  accessCode: boolean,
}

type OwnProps = {
  quizID: string,
  courseID: string,
}

type State = {
  quiz: Quiz,
  assignmentGroups: { [string]: AssignmentGroup },
  assignment: ?Assignment,
}

type Props = State & OwnProps & typeof Actions & AsyncState & {
  navigator: Navigator,
  defaultDate?: Date,
}

function booleanTransformer<T> (truthy: T, falsey: T): (b: boolean) => T {
  return (b) => b ? truthy : falsey
}

const PickerItem = PickerIOS.Item

export class QuizEdit extends Component<Props, any> {
  static defaultProps = {
    updateQuiz: canvas.updateQuiz,
  }

  datesEditor: AssignmentDatesEditor
  scrollView: KeyboardAwareScrollView

  state = {
    pending: false,
    quiz: this.props.quiz,
    pickers: {},
    assignment: this.props.assignment,
    validation: {
      isValid: true,
      title: true,
      showCorrectAnswerDates: true,
      accessCode: true,
    },
  }

  componentWillReceiveProps ({ quiz, pending, error, assignment }: Props) {
    this.setState({
      quiz: {
        ...quiz,
        ...this.state.quiz,
      },
      assignment: assignment && {
        ...assignment,
        ...this.state.assignment,
      },
    })
  }

  componentWillUnmount () {
    if (this.state.quiz.quiz_type === 'assignment' && this.state.assignment) {
      this.props.refreshAssignment(this.props.courseID, this.state.assignment.id)
    }
  }

  render () {
    const quiz = this.state.quiz
    const assignmentGroup = quiz.assignment_group_id && this.props.assignmentGroups[quiz.assignment_group_id]

    const allowsMultipleAttempts = ![0, 1].includes(quiz.allowed_attempts)
    const graded = ['assignment', 'graded_survey'].includes(quiz.quiz_type)
    const readable = formatter(quiz)

    const defaultDate = this.props.defaultDate || new Date()
    return (
      <Screen
        title={i18n('Edit Quiz Details')}
        navBarTitleColor={colors.darkText}
        navBarButtonColor={colors.link}
        rightBarButtons={[
          {
            title: i18n('Done'),
            testID: 'quizzes.edit.doneButton',
            style: 'done',
            action: this._donePressed,
            disabled: this.state.pending,
          },
        ]}
        dismissButtonTitle={i18n('Cancel')}
      >
        <View style={{ flex: 1, backgroundColor: '#F5F5F5' }}>
          { this.state.pending && <SavingBanner style={style.savingBanner} />}
          { !this.state.validation.isValid && <UnmetRequirementBanner text={i18n('Invalid field')} testID={'quizEdit.unmet-requirement-banner'}/> }
          <KeyboardAwareScrollView
            style={style.container}
            keyboardShouldPersistTaps='handled'
            ref={scrollView => { this.scrollView = scrollView }}
          >
            <Heading1 style={style.heading}>{i18n('Title')}</Heading1>
            <RowWithTextInput
              defaultValue={quiz.title}
              border='both'
              onChangeText={this._updateQuiz('title')}
              placeholder={i18n('Title')}
            />
            <RequiredFieldSubscript title={i18n('A title is required')} visible={!this.state.validation.title} />

            <Heading1 style={style.heading}>{i18n('Description')}</Heading1>
            <Row
              disclosureIndicator={true}
              border='both'
              testID='quizzes.edit.description-row'
              onPress={this._editDescription}
            >
              <View style={style.buttonInnerContainer}>
                <Image source={images.edit} style={style.buttonImage} />
                <Text style={style.buttonText}>{i18n('Edit Description')}</Text>
              </View>
            </Row>

            <Heading1 style={style.heading} accessible={false}> </Heading1>
            <RowWithDetail
              title={i18n('Quiz Type')}
              detailSelected={this.state.pickers.quiz_type}
              detail={readable.quizType}
              disclosureIndicator={true}
              border='both'
              testID='quizzes.edit.quiz-type-row'
              onPress={this._togglePicker('quiz_type')}
            />
            { this.state.pickers.quiz_type &&
              <PickerIOS
                selectedValue={quiz.quiz_type}
                onValueChange={this._updateQuiz('quiz_type', null, false)}
                testID='quizzes.edit.quiz-type-picker'>
                {Object.keys(QUIZ_TYPES).map((type) => (
                  <PickerItem
                    key={type}
                    value={type}
                    label={QUIZ_TYPES[type]}
                  />
                ))}
              </PickerIOS>
            }
            { (!quiz.published || quiz.can_unpublish) &&
              <RowWithSwitch
                title={i18n('Publish')}
                border='bottom'
                onValueChange={this._updateQuiz('published')}
                value={quiz.published}
                identifier='quizzes.edit.published-toggle'
              />
            }
            { graded &&
              <View>
                <RowWithDetail
                  title={i18n('Assignment Group')}
                  detailSelected={this.state.pickers.assignment_group_id}
                  detail={assignmentGroup && assignmentGroup.name}
                  disclosureIndicator={true}
                  border='bottom'
                  testID='quizzes.edit.assignment-group-row'
                  onPress={this._togglePicker('assignment_group_id')}
                />
                { this.state.pickers.assignment_group_id &&
                  <PickerIOS
                    selectedValue={quiz.assignment_group_id}
                    onValueChange={this._updateQuiz('assignment_group_id', null, false)}
                    testID='quizzes.edit.assignment-group-picker'>
                    {Object.keys(this.props.assignmentGroups).map((id) => (
                      <PickerItem
                        key={id}
                        value={id}
                        label={this.props.assignmentGroups[id].name}
                      />
                    ))}
                  </PickerIOS>
                }
              </View>
            }
            <RowWithSwitch
              title={i18n('Shuffle Answers')}
              border='bottom'
              value={quiz.shuffle_answers}
              onValueChange={this._updateQuiz('shuffle_answers')}
              identifier='quizzes.edit.shuffle-answers-toggle'
            />
            <RowWithSwitch
              title={i18n('Time Limit')}
              border='bottom'
              identifier='quizzes.edit.time-limit-toggle'
              value={Boolean(quiz.time_limit) || this.state.pickers.time_limit}
              onValueChange={this._togglePicker('time_limit', !quiz.time_limit && !this.state.pickers.time_limit, (shown) => {
                !shown && this._updateQuiz('time_limit')(null)
              })}
            />
            { (Boolean(quiz.time_limit) || this.state.pickers.time_limit) &&
              <RowWithTextInput
                title={i18n('Length in minutes')}
                border='bottom'
                placeholder={i18n('Minutes')}
                inputWidth={200}
                onChangeText={this._updateQuiz('time_limit')}
                keyboardType='number-pad'
                defaultValue={quiz.time_limit && String(quiz.time_limit)}
              />
            }

            <Heading1 style={style.heading} accessible={false}> </Heading1>
            <RowWithSwitch
              title={i18n('Allow Multiple Attempts')}
              border='both'
              value={allowsMultipleAttempts}
              onValueChange={this._updateQuiz('allowed_attempts', booleanTransformer(-1, 1))}
            />
            { allowsMultipleAttempts &&
              <View>
                <RowWithDetail
                  title={i18n('Quiz Score to Keep')}
                  detailSelected={this.state.pickers.scoring_policy}
                  detail={readable.scoringPolicy}
                  disclosureIndicator={true}
                  border='bottom'
                  onPress={this._togglePicker('scoring_policy')}
                />
                { this.state.pickers.scoring_policy &&
                  <PickerIOS
                    selectedValue={quiz.scoring_policy}
                    onValueChange={this._updateQuiz('scoring_policy', null, false)}
                    testID='quizzes.edit.scoring-policy-picker'>
                    {Object.keys(SCORING_POLICIES).map((key) => (
                      <PickerItem
                        key={key}
                        value={key}
                        label={SCORING_POLICIES[key]}
                      />
                    ))}
                  </PickerIOS>
                }
                <RowWithTextInput
                  title={i18n('Allowed Attempts')}
                  border='bottom'
                  defaultValue={quiz.allowed_attempts > 0 ? String(quiz.allowed_attempts) : ''}
                  placeholder={i18n('Unlimited')}
                  onChangeText={this._updateQuiz('allowed_attempts', a => a ? Number(a) : -1)}
                  keyboardType='number-pad'
                  inputWidth={200}
                />
              </View>
            }

            <Heading1 style={style.heading} accessible={false}> </Heading1>
            <RowWithSwitch
              title={i18n('Let Students See Their Quiz Responses')}
              border='both'
              value={quiz.hide_results !== 'always'}
              onValueChange={this._updateHideResults}
              identifier='quizzes.edit.hide-results-toggle'
            />
            { quiz.hide_results !== 'always' &&
              <View>
                <RowWithSwitch
                  title={i18n('Only Once After Each Attempt')}
                  border='bottom'
                  onValueChange={this._updateQuiz('hide_results', b => b ? 'until_after_last_attempt' : null)}
                  value={quiz.hide_results === 'until_after_last_attempt'}
                  identifier='quizzes.edit.hide-results-after-attempt-toggle'
                />
                <RowWithSwitch
                  title={i18n('Let Students See the Correct Answer')}
                  border='bottom'
                  value={quiz.show_correct_answers}
                  onValueChange={this._updateQuiz('show_correct_answers')}
                  identifier='quizzes.edit.show-correct-answers-toggle'
                />
                { quiz.show_correct_answers &&
                  <View>
                    <View style={{ flexDirection: 'row' }}>
                      <View style={{ flex: 1 }}>
                        <RowWithDateInput
                          title={i18n('Show Correct Answers At')}
                          date={quiz.show_correct_answers_at}
                          selected={this.state.pickers.show_correct_answers_at}
                          showRemoveButton={quiz.show_correct_answers_at}
                          border='bottom'
                          onPress={this._togglePicker('show_correct_answers_at', null, (shown) => {
                            const d = defaultDate.toISOString()
                            shown && !quiz.show_correct_answers_at && this._updateQuiz('show_correct_answers_at')(d)
                          })}
                          onRemoveDatePress={this._pressedClearDate('show_correct_answers_at')}
                          testID={'quizzes.edit.show-correct-answers-at-row'}
                          removeButtonTestID={'quizzes.edit.clear_show_correct_answers_at_button'}
                        />
                      </View>
                    </View>
                    { this.state.pickers.show_correct_answers_at &&
                      <DatePickerIOS
                        date={extractDateFromString(quiz.show_correct_answers_at) || defaultDate}
                        onDateChange={this._updateQuiz('show_correct_answers_at', d => d.toISOString())}
                        testID='quizzes.edit.show-correct-answers-at-date-picker'
                      />
                    }
                    <View style={{ flexDirection: 'row' }}>
                      <View style={{ flex: 1 }}>
                        <RowWithDateInput
                          title={i18n('Hide Correct Answers At')}
                          date={quiz.hide_correct_answers_at}
                          selected={this.state.pickers.hide_correct_answers_at}
                          showRemoveButton={quiz.hide_correct_answers_at}
                          border='bottom'
                          onPress={this._togglePicker('hide_correct_answers_at', null, (shown) => {
                            const d = defaultDate.toISOString()
                            shown && !quiz.hide_correct_answers_at && this._updateQuiz('hide_correct_answers_at')(d)
                          })}
                          onRemoveDatePress={this._pressedClearDate('hide_correct_answers_at')}
                          testID={'quizzes.edit.hide-correct-answers-at-row'}
                          removeButtonTestID={'quizzes.edit.clear_hide_correct_answers_at_button'}
                        />
                      </View>
                    </View>
                    { this.state.pickers.hide_correct_answers_at &&
                      <DatePickerIOS
                        date={extractDateFromString(quiz.hide_correct_answers_at) || defaultDate}
                        onDateChange={this._updateQuiz('hide_correct_answers_at', d => d.toISOString())}
                        testID='quizzes.edit.hide-correct-answers-at-date-picker'
                      />
                    }
                  </View>
                }
              </View>
            }
            <RequiredFieldSubscript title={i18n("'Hide Date' cannot be before 'Show Date'")} visible={!this.state.validation.showCorrectAnswerDates} />

            <Heading1 style={style.heading} accessible={false}> </Heading1>
            <RowWithSwitch
              title={i18n('Show One Question at a Time')}
              border='both'
              onValueChange={(b) => {
                this._setQuiz({
                  one_question_at_a_time: b,
                  cant_go_back: false,
                }, true)
              }}
              value={quiz.one_question_at_a_time}
              identifier='quizzes.edit.one-question-at-a-time-toggle'
            />
            { quiz.one_question_at_a_time &&
              <RowWithSwitch
                title={i18n('Lock Questions After Answering')}
                border='bottom'
                value={quiz.cant_go_back}
                onValueChange={this._updateQuiz('cant_go_back')}
                identifier='quizzes.edit.cant-go-back-toggle'
              />
            }

            <Heading1 style={style.heading} accessible={false}> </Heading1>
            <RowWithSwitch
              title={i18n('Require an Access Code')}
              border='both'
              value={quiz.access_code != null}
              onValueChange={this._updateQuiz('access_code', b => b ? '' : null)}
              identifier='quizzes.edit.access-code-toggle'
            />
            { quiz.access_code != null &&
              <RowWithTextInput
                title={i18n('Access Code')}
                border='bottom'
                inputWidth={200}
                defaultValue={quiz.access_code}
                onChangeText={this._updateQuiz('access_code')}
                placeholder={i18n('Enter code')}
              />
            }
            <RequiredFieldSubscript title={i18n('You must enter an access code')} visible={!this.state.validation.accessCode} />

            <AssignmentDatesEditor
              assignment={this.state.assignment || { ...quiz, all_dates: quiz.all_dates.filter(d => d.base) }}
              ref={c => { this.datesEditor = c }}
              navigator={this.props.navigator}
              canEditAssignees={Boolean(this.state.assignment)}
              canAddDueDates={Boolean(this.state.assignment)}
            />
          </KeyboardAwareScrollView>
        </View>
      </Screen>
    )
  }

  _validateChanges (): Validation {
    const quiz = this.state.quiz

    let validator = {
      isValid: true,
      title: true,
      showCorrectAnswerDates: true,
      accessCode: true,
    }

    if (!quiz.title || quiz.title.replace(/\s/g, '') === '') {
      validator = {
        ...validator,
        title: false,
        isValid: false,
      }
    }

    if (quiz.show_correct_answers && quiz.show_correct_answers_at && quiz.hide_correct_answers_at) {
      let show = extractDateFromString(quiz.show_correct_answers_at)
      let hide = extractDateFromString(quiz.hide_correct_answers_at)
      if (show && hide && hide < show) {
        validator = {
          ...validator,
          showCorrectAnswerDates: false,
          isValid: false,
        }
      }
    }

    if (quiz.access_code != null && quiz.access_code.replace(/\s/g, '') === '') {
      validator = {
        ...validator,
        accessCode: false,
        isValid: false,
      }
    }

    const datesAreValid = this.datesEditor.validate()
    if (!datesAreValid) {
      validator = {
        ...validator,
        isValid: false,
      }
    }

    return validator
  }

  _updateQuiz (property: string, transformer?: any, animated?: boolean = true): Function {
    return (value) => {
      if (transformer) { value = transformer(value) }
      this._setQuiz({ [property]: value }, animated)
    }
  }

  _setQuiz (properties: any, animated?: boolean) {
    if (animated) {
      LayoutAnimation.easeInEaseOut()
    }
    this.setState({
      quiz: {
        ...this.state.quiz,
        ...properties,
      },
    })
  }

  _updateHideResults = (showResults: boolean) => {
    this._setQuiz({
      show_correct_answers: false,
      show_correct_answers_last_attempt: false,
      show_correct_answers_at: null,
      hide_correct_answers_at: null,
      hide_results: showResults ? null : 'always',
    })
  }

  _togglePicker (picker: string, show?: ?boolean, callback?: (shown: boolean) => void): Function {
    return () => {
      let showPicker = picker === 'hide_correct_answers_at' ? false : this.state.pickers['show_correct_answers_at']
      let hidePicker = picker === 'show_correct_answers_at' ? false : this.state.pickers['hide_correct_answers_at']

      const shown = show == null ? !this.state.pickers[picker] : show
      LayoutAnimation.easeInEaseOut()
      this.setState({
        pickers: {
          ...this.state.pickers,
          show_correct_answers_at: showPicker,
          hide_correct_answers_at: hidePicker,
          [picker]: shown,
        },
      })
      this.state.pickers[picker]
      if (callback) {
        callback(shown)
      }
    }
  }

  _pressedClearDate (identifier: string): Function {
    return () => {
      const pickerOpen = this.state.pickers[identifier]
      this._updateQuiz(identifier, null, pickerOpen)(null)
      if (pickerOpen) {
        this._togglePicker(identifier)()
      }
    }
  }

  _donePressed = async () => {
    const validator = this._validateChanges()
    if (!validator.isValid) {
      this.setState({ validation: validator })
      setTimeout(function () { NativeAccessibility.focusElement('quizEdit.unmet-requirement-banner') }, 500)
      return
    }

    // Update assignment overrides
    let updatedAssignment = this.state.assignment
    if (this.state.quiz.quiz_type === 'assignment' && this.state.assignment) {
      updatedAssignment = this.datesEditor.updateAssignment({ ...this.state.assignment })
      let overrides = {
        id: updatedAssignment.id,
        assignment_overrides: updatedAssignment.assignment_overrides,
      }
      this.props.updateAssignment(this.props.courseID, overrides, this.props.assignment)
    }

    const updatedQuiz = this.datesEditor.updateAssignment({ ...this.state.quiz })
    this.setState({
      quiz: updatedQuiz,
      assignment: updatedAssignment,
      pending: true,
      validation: validator,
    })

    try {
      const result = await this.props.updateQuiz(updatedQuiz, this.props.courseID)
      this.props.quizUpdated(result.data)
      this.props.navigator.dismiss()
    } catch (error) {
      this.setState({ pending: this.props.pending || false })
      alertError(error)
    }
  }

  _editDescription = () => {
    this.props.navigator.show('/rich-text-editor', { modal: true, modalPresentationStyle: 'fullscreen' }, {
      defaultValue: this.state.quiz.description,
      onChangeValue: this._updateQuiz('description'),
      showToolbar: 'always',
      placeholder: i18n('Description'),
      attachmentUploadPath: `/courses/${this.props.courseID}/files`,
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
  buttonInnerContainer: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    paddingRight: global.style.defaultPadding,
  },
  buttonText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#008EE2',
  },
  buttonImage: {
    tintColor: colors.primaryButton,
    marginRight: 8,
    height: 18,
    width: 18,
  },
  savingBanner: {
    backgroundColor: 'transparent',
  },
})

export function mapStateToProps ({ entities }: AppState, { courseID, quizID }: OwnProps): State {
  const entity = entities.quizzes[quizID]
  const quiz = entity.data
  let { error, pending } = entity

  let assignmentGroups = {}
  if (entities.courses &&
    entities.courses[courseID] &&
    entities.courses[courseID].assignmentGroups &&
    entities.courses[courseID].assignmentGroups.refs) {
    const assignmentGroupRefs = entities.courses[courseID].assignmentGroups.refs
    assignmentGroups = assignmentGroupRefs.reduce((incoming, ref) => ({
      ...incoming,
      [ref]: entities.assignmentGroups[ref].group,
    }), {})
  }

  let assignment = null
  if (quiz.quiz_type === 'assignment' &&
    quiz.assignment_id &&
    entities.assignments &&
    entities.assignments[quiz.assignment_id] &&
    entities.assignments[quiz.assignment_id].data) {
    const assignmentEntity = entities.assignments[quiz.assignment_id]
    assignment = entities.assignments[quiz.assignment_id].data
    pending = pending + assignmentEntity.pending
    error = error || assignmentEntity.error
  }

  return {
    quiz,
    assignmentGroups,
    pending,
    error,
    assignment,
  }
}

const Connected = connect(mapStateToProps, Actions)(QuizEdit)
export default (Connected: Component<Props, any>)
