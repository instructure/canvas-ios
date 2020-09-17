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

/**
 * @flow
 */

import React, { Component } from 'react'
import { connect } from 'react-redux'
import { updateMapStateToProps, type AssignmentDetailsProps } from './map-state-to-props'
import AssignmentActions from '../assignments/actions'
import i18n from 'format-message'
import AssignmentDatesEditor from './components/AssignmentDatesEditor'
import { TextInput, FormLabel } from '../../common/text'
import ModalOverlay from '../../common/components/ModalOverlay'
import UnmetRequirementBanner from '../../common/components/UnmetRequirementBanner'
import RequiredFieldSubscript from '../../common/components/RequiredFieldSubscript'
import { alertError } from '../../redux/middleware/error-handler'
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view'
import { createStyleSheet } from './../../common/stylesheet'
import RowWithSwitch from '../../common/components/rows/RowWithSwitch'
import RowWithDetail from '../../common/components/rows/RowWithDetail'
import RowWithTextInput from '../../common/components/rows/RowWithTextInput'
import RichContentEditor from '../../common/components/RichContentEditor'
import Screen from '../../routing/Screen'
import ReactNative, {
  View,
  LayoutAnimation,
  NativeModules,
} from 'react-native'
import { Picker } from '@react-native-community/picker'

const { NativeAccessibility } = NativeModules

type Validation = {
  invalid: string,
  title: string,
  points: string,
}

export function gradeDisplayOptions (): Map<string, string> {
  return new Map([
    ['percent', i18n('Percentage')],
    ['pass_fail', i18n('Complete/Incomplete')],
    ['points', i18n('Points')],
    ['letter_grade', i18n('Letter Grade')],
    ['gpa_scale', i18n('GPA Scale')],
    ['not_graded', i18n('Not Graded')],
  ])
}

export class AssignmentDetailsEdit extends Component<AssignmentDetailsProps, any> {
  props: AssignmentDetailsProps
  state: any = {}
  datesEditor: AssignmentDatesEditor
  currentPickerMap: ?Map<*, *> = null
  static gradeDisplayOptions: Map<string, string>

  constructor (props: AssignmentDetailsProps) {
    super(props)

    this.state = {
      assignment: Object.assign({}, props.assignmentDetails),
      showPicker: false,
      pickerSelectedValue: 'initial value set in constructor',
      currentAssignmentKey: null,
      validation: {
        invalid: '',
        title: '',
        points: '',
      },
    }
  }

  componentWillUnmount () {
    this.props.refreshAssignment(this.props.courseID, this.props.assignmentID)
  }

  renderTextInput (fieldName: string, placeholder: string, testID: string, styleParam: any = {}, focus: boolean = false, keyboardType: string = 'default') {
    return (
      <TextInput style={styleParam}
        value={ this.defaultValueForInput(fieldName) }
        placeholder={ placeholder }
        returnKeyType={'done'}
        keyboardType={keyboardType}
        blurOnSubmit={true}
        onChangeText={ value => this.updateFromInput(fieldName, value) }
        onFocus={(event) => this._scrollToInput}
        testID={testID}
      />
    )
  }

  _scrollToInput = (event: any) => {
    const input = ReactNative.findNodeHandle(event.target)
    this.scrollView.scrollToFocusedInput(input)
  }

  _scrollToRCE = () => {
    const input = ReactNative.findNodeHandle(this.editor)
    this.scrollView.scrollToFocusedInput(input)
  }

  renderDataMapPicker = () => {
    if (!this.state.showPicker) return <View/>

    return (
      <View>
        <Picker
          selectedValue={this.state.pickerSelectedValue}
          onValueChange={this.pickerValueDidChange.bind(this)}
          testID='assignmentPicker'>
          {this.currentPickerMap && Array.from(this.currentPickerMap.keys()).map((key) => (
            <Picker.Item
              key={key}
              value={key}
              label={this.currentPickerMap ? this.currentPickerMap.get(key) : ''}
            />
          ))}
        </Picker>
      </View>
    )
  }

  render () {
    let sectionTitle = i18n('Title')
    let sectionDescription = i18n('Description')
    let sectionDetails = i18n('Details')

    let savingText = i18n('Saving')

    let titlePlaceHolder = i18n('Title')
    let pointsLabel = i18n('Points')
    let displayGradeAs = i18n('Display Grade As')
    let publish = i18n('Publish')

    return (
      <Screen
        title={i18n('Edit Assignment')}
        rightBarButtons={[
          {
            title: i18n('Done'),
            style: 'done',
            testID: 'edit-assignment.dismiss-btn',
            action: this.actionDonePressed,
          },
        ]}
        leftBarButtons={[
          {
            title: i18n('Cancel'),
            testID: 'edit-assignment.cancel-btn',
            action: this.actionCancelPressed,
          },
        ]}
        showDismissButton={false}
      >
        <View style={{ flex: 1 }}>
          <ModalOverlay text={savingText} visible={this.state.pending}/>
          <UnmetRequirementBanner text={this.state.validation.invalid} visible={this.state.validation.invalid} testID={'assignmentDetailsEdit.unmet-requirement-banner'}/>
          <KeyboardAwareScrollView
            style={style.container}
            ref={scrollView => { this.scrollView = scrollView }}
            keyboardShouldPersistTaps='handled'
            enableAutoAutomaticScroll={false}
          >
            {/* Title */}
            <FormLabel>{sectionTitle}</FormLabel>
            <View style={[style.row, style.topRow, style.bottomRow]}>
              { this.renderTextInput('name', titlePlaceHolder, 'titleInput', style.title) }
            </View>
            <RequiredFieldSubscript title={this.state.validation.title} visible={this.state.validation.title} />

            {/* Description */}
            <FormLabel>{sectionDescription}</FormLabel>
            <View style={style.description}>
              <RichContentEditor
                ref={(r) => { this.editor = r }}
                onFocus={this._scrollToRCE}
                html={this.state.assignment.description}
                placeholder={i18n('Description')}
                uploadContext={`courses/${this.props.courseID}/files`}
                context={`courses/${this.props.courseID}`}
              />
            </View>

            {/* Points */}
            <FormLabel>{sectionDetails}</FormLabel>
            <RowWithTextInput
              title={pointsLabel}
              border='both'
              placeholder='--'
              inputWidth={200}
              onChangeText={detail => this.updateFromInput('points_possible', detail)}
              keyboardType='number-pad'
              defaultValue={this.defaultValueForInput('points_possible')}
              onFocus={this._scrollToInput}
              identifier='assignmentDetails.edit.points_possible.input'
              style={style.detailRow}
            />
            <RequiredFieldSubscript title={this.state.validation.points} visible={this.state.validation.points} />

            {/* Display Grade As */}
            <RowWithDetail
              title={displayGradeAs}
              detailSelected={this.state.showPicker}
              detail={gradeDisplayOptions().get(this.state.assignment.grading_type) || ''}
              onPress={this.toggleDisplayGradeAsPicker}
              border='bottom'
              testID="assignment-details.toggle-display-grade-as-picker"
              style={style.detailRow}
            />
            {this.renderDataMapPicker()}

            {/* Publish */}
            { (!this.props.assignmentDetails.published || this.props.assignmentDetails.unpublishable) &&
              <RowWithSwitch
                title={publish}
                border='bottom'
                value={this.defaultValueForBooleanInput('published')}
                identifier='published'
                onValueChange={this._updateToggleValue}
                style={style.detailRow}
              />
            }

            {/* Due Dates */}
            <AssignmentDatesEditor
              assignment={this.props.assignmentDetails}
              ref={(c: any) => { this.datesEditor = c }}
              canEditAssignees={Boolean(this.state.assignment)}
              navigator={this.props.navigator}
            />
          </KeyboardAwareScrollView>
        </View>
      </Screen>
    )
  }

  _updateToggleValue = (value: boolean, key: string) => {
    this.updateFromInput(key, value)
  }

  pickerValueDidChange (value: any) {
    if (this.state.currentAssignmentKey) {
      this.state.assignment[this.state.currentAssignmentKey] = value
      this.setState({ pickerSelectedValue: value, assignment: this.state.assignment })
    }
  }

  toggleDisplayGradeAsPicker = (identifier: string) => {
    this.togglePicker('grading_type', gradeDisplayOptions())
  }

  togglePicker = (selectedField: string, map: ?Map<*, *>) => {
    LayoutAnimation.easeInEaseOut()
    this.currentPickerMap = map
    this.setState({ pickerSelectedValue: this.state.assignment[selectedField], showPicker: !this.state.showPicker, currentAssignmentKey: selectedField })
  }

  updateFromInput (key: string, value: any) {
    this.setState({ assignment: { ...this.state.assignment, [key]: value } })
  }

  defaultValueForInput (key: string): string {
    const value = this.state.assignment[key]
    if (value == null || !value.toString) return ''
    return value.toString()
  }

  defaultValueForBooleanInput (key: string): boolean {
    let assignment = this.state.assignment
    return assignment[key]
  }

  validateChanges (assignment): Validation {
    let requiredText = i18n('Invalid field')

    let validator = {
      invalid: '',
      title: '',
      points: '',
    }

    if (!assignment.name || assignment.name.replace(/\s/g, '') === '') {
      validator = {
        ...validator,
        title: i18n('A title is required'),
        invalid: requiredText,
      }
    }

    const pointsPossible = String(assignment.points_possible)
    if (isNaN(pointsPossible) || !pointsPossible) {
      validator = {
        ...validator,
        points: i18n('Points possible must be a number'),
        invalid: requiredText,
      }
    } else if (Number(pointsPossible) < 0) {
      validator = {
        ...validator,
        points: i18n('The value of possible points must be zero or greater'),
        invalid: requiredText,
      }
    }

    const datesAreValid = this.datesEditor.validate()
    if (!datesAreValid) {
      validator = {
        ...validator,
        invalid: requiredText,
      }
    }

    return validator
  }

  actionDonePressed = async () => {
    const description = await this.editor?.getHTML() ?? ''
    const assignment = { ...this.state.assignment, description }

    const validator = this.validateChanges(assignment)

    if (validator.invalid !== '') {
      this.setState({ validation: validator })
      setTimeout(function () { NativeAccessibility.focusElement('assignmentDetailsEdit.unmet-requirement-banner') }, 500)
      return
    }

    const updatedAssignment = this.datesEditor.updateAssignment(assignment)
    this.setState({
      pending: true,
      assignment: updatedAssignment,
      validation: validator,
    })

    return this.props.updateAssignment(this.props.courseID, updatedAssignment, this.props.assignmentDetails)
  }

  actionCancelPressed = () => {
    this.props.cancelAssignmentUpdate(this.props.assignmentDetails)
    this.props.navigator.dismiss()
  }

  componentDidUpdate () {
    if (this.state.error) {
      this.handleError()
    }
  }

  handleError () {
    setTimeout(() => { alertError(this.state.error); delete this.state.error }, 1000)
  }

  UNSAFE_componentWillReceiveProps (nextProps: AssignmentDetailsProps) {
    if (!nextProps.pending) {
      if (nextProps.error) {
        const error = nextProps.error.response
        this.setState({ pending: false, error, assignment: Object.assign({}, this.state.assignment) })
        return
      }

      if (this.state.pending && nextProps.assignmentDetails) {
        this.setState({ error: undefined })
        this.props.navigator.dismissAllModals()
        return
      }

      this.setState({ assignment: nextProps.assignmentDetails })
    }
  }
}

const style = createStyleSheet((colors, vars) => ({
  container: {
    flex: 1,
    backgroundColor: colors.backgroundGrouped,
  },
  row: {
    paddingVertical: Math.floor(vars.padding / 2),
    paddingLeft: vars.padding,
    paddingRight: vars.padding,
    backgroundColor: colors.backgroundGroupedCell,
  },
  detailRow: {
    backgroundColor: colors.backgroundGroupedCell,
  },
  twoColumnRow: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    height: 'auto',
    minHeight: 54,
    borderBottomWidth: vars.hairlineWidth,
    borderBottomColor: colors.borderMedium,
  },
  topRow: {
    borderTopWidth: vars.hairlineWidth,
    borderTopColor: colors.borderMedium,
  },
  bottomRow: {
    borderBottomWidth: vars.hairlineWidth,
    borderBottomColor: colors.borderMedium,
  },
  twoColumnRowLeftText: {
    flex: 1,
    fontWeight: '600',
  },
  title: {
    height: 45,
    color: colors.textDarkest,
  },
  points: {
    width: 50,
    textAlign: 'right',
  },
  colorPicker: {
    position: 'absolute',
    left: 0,
    right: 0,
  },
  toolbar: {
    position: 'absolute',
    left: 0,
    right: 0,
  },
  buttonInnerContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingRight: vars.padding,
  },
  buttonText: {
    fontSize: 16,
    fontWeight: '600',
    color: colors.linkColor,
  },
  buttonImage: {
    tintColor: colors.linkColor,
    marginRight: 8,
    height: 18,
    width: 18,
  },
  description: {
    borderTopWidth: vars.hairlineWidth,
    borderTopColor: colors.borderMedium,
    borderBottomWidth: vars.hairlineWidth,
    borderBottomColor: colors.borderMedium,
    backgroundColor: colors.backgroundLightest,
    minHeight: 200,
  },
}))

let Connected = connect(updateMapStateToProps, AssignmentActions)(AssignmentDetailsEdit)
export default (Connected: Component<AssignmentDetailsProps, any>)
