/**
 * @flow
 */

import React, { Component } from 'react'
import { connect } from 'react-redux'
import { updateMapStateToProps, type AssignmentDetailsProps } from './map-state-to-props'
import AssignmentActions from '../assignments/actions'
import i18n from 'format-message'
import EditSectionHeader from './components/EditSectionHeader'
import AssignmentDatesEditor from './components/AssignmentDatesEditor'
import { TextInput, Text } from '../../common/text'
import ModalActivityIndicator from '../../common/components/ModalActivityIndicator'
import UnmetRequirementBanner from '../../common/components/UnmetRequirementBanner'
import RequiredFieldSubscript from '../../common/components/RequiredFieldSubscript'
import { ERROR_TITLE, parseErrorMessage } from '../../redux/middleware/error-handler'
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view'
import color from './../../common/colors'
import images from '../../images/'
import DisclosureIndicator from '../../common/components/DisclosureIndicator'
import RowWithSwitch from '../../common/components/rows/RowWithSwitch'
import RowWithDetail from '../../common/components/rows/RowWithDetail'
import RowWithTextInput from '../../common/components/rows/RowWithTextInput'
import Screen from '../../routing/Screen'
import ReactNative, {
  View,
  StyleSheet,
  Alert,
  PickerIOS,
  TouchableHighlight,
  LayoutAnimation,
  Image,
  NativeModules,
} from 'react-native'

const { NativeAccessibility } = NativeModules

var PickerItemIOS = PickerIOS.Item

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

export class AssignmentDetailsEdit extends Component<any, AssignmentDetailsProps, any> {
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
        testID={testID}/>
    )
  }

  _scrollToInput = (event: any) => {
    const input = ReactNative.findNodeHandle(event.target)
    this.refs.scrollView.scrollToFocusedInput(input)
  }

  renderDataMapPicker = () => {
    if (!this.state.showPicker) return <View/>

    return <View>
      <PickerIOS
        selectedValue={this.state.pickerSelectedValue}
        onValueChange={this.pickerValueDidChange.bind(this)}
        testID='assignmentPicker'>
        {this.currentPickerMap && Array.from(this.currentPickerMap.keys()).map((key) => (
          <PickerItemIOS
            key={key}
            value={key}
            label={this.currentPickerMap ? this.currentPickerMap.get(key) : ''}
          />
        ))}
      </PickerIOS>
    </View>
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
        navBarStyle='light'
        navBarTitleColor={color.darkText}
        navBarButtonColor={color.link}
        rightBarButtons={[
          {
            title: i18n('Done'),
            style: 'done',
            testID: 'edit-assignment.dismiss-btn',
            action: this.actionDonePressed.bind(this),
          },
        ]}
        leftBarButtons={[
          {
            title: i18n('Cancel'),
            testID: 'edit-assignment.cancel-btn',
            action: this.actionCancelPressed.bind(this),
          },
        ]}
      >
        <View style={{ flex: 1 }}>
          <ModalActivityIndicator text={savingText} visible={this.state.pending}/>
          <UnmetRequirementBanner text={this.state.validation.invalid} visible={this.state.validation.invalid} testID={'assignmentDetailsEdit.unmet-requirement-banner'}/>
          <KeyboardAwareScrollView
            style={style.container}
            ref='scrollView'
            keyboardShouldPersistTaps='handled'
            enableAutoAutomaticScroll={false}
          >
            {/* Title */}
            <EditSectionHeader title={sectionTitle} />
            <View style={[style.row, style.topRow, style.bottomRow]}>
              { this.renderTextInput('name', titlePlaceHolder, 'titleInput', style.title) }
            </View>
            <RequiredFieldSubscript title={this.state.validation.title} visible={this.state.validation.title} />

            {/* Description */}
            <EditSectionHeader title={sectionDescription} style={{ marginTop: 0 }}/>
            <TouchableHighlight
              testID='edit-description'
              onPress={this._editDescription}
            >
              <View style={[style.row, style.topRow, style.twoColumnRow]}>
                <View style={style.buttonInnerContainer}>
                  <Image source={images.edit} style={[style.buttonImage, { tintColor: color.primaryButtonColor }]} />
                  <Text style={[style.buttonText, { color: color.primaryButtonColor }]}>{i18n('Edit Description')}</Text>
                </View>
                <DisclosureIndicator />
              </View>
            </TouchableHighlight>

            {/* Points */}
            <EditSectionHeader title={sectionDetails} />
            <RowWithTextInput
              title={pointsLabel}
              border='bottom'
              placeholder='--'
              inputWidth={200}
              onChangeText={detail => this.updateFromInput('points_possible', detail)}
              keyboardType='number-pad'
              defaultValue={this.defaultValueForInput('points_possible')}
              onFocus={this._scrollToInput}
              identifier='assignmentDetails.edit.points_possible.input'
            />

            {/* Display Grade As */}
            <RowWithDetail title={displayGradeAs}
              detailSelected={this.state.showPicker}
              detail={i18n(gradeDisplayOptions().get(this.state.assignment.grading_type))}
              onPress={this.toggleDisplayGradeAsPicker}
              border={'bottom'}
              testID="assignment-details.toggle-display-grade-as-picker" />
            {this.renderDataMapPicker()}

            {/* Publish */}
            <RowWithSwitch
              title={publish}
              border={'bottom'}
              value={this.defaultValueForBooleanInput('published')}
              identifier='published'
              onValueChange={this._updateToggleValue} />

            <RequiredFieldSubscript title={this.state.validation.points} visible={this.state.validation.points} />

            {/* Due Dates */}
            <AssignmentDatesEditor
              assignment={this.props.assignmentDetails}
              ref={c => { this.datesEditor = c }}
              canEditAssignees={Boolean(this.state.assignment)}
              navigator={this.props.navigator} />

          </KeyboardAwareScrollView>
        </View>
      </Screen>
    )
  }

  _updateToggleValue = (value: boolean, key: string) => {
    this.updateFromInput(key, value)
  }

  _editDescription = () => {
    this.props.navigator.show('/rich-text-editor', { modal: false }, {
      onChangeValue: (value) => { this.updateFromInput('description', value) },
      defaultValue: this.state.assignment.description,
      placeholder: i18n('Description'),
      showToolbar: 'always',
    })
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
    const assignment = this.state.assignment
    assignment[key] = value
    this.setState({ assignment })
  }

  defaultValueForInput (key: string): string {
    const value = this.state.assignment[key]
    if (!value && key !== 'points_possible') { return '' }
    return value.toString()
  }

  defaultValueForBooleanInput (key: string): boolean {
    let assignment = this.state.assignment
    return assignment[key]
  }

  validateChanges (): Validation {
    const assignment = this.state.assignment
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

  actionDonePressed () {
    const validator = this.validateChanges()

    if (validator.invalid !== '') {
      this.setState({ validation: validator })
      setTimeout(function () { NativeAccessibility.focusElement('assignmentDetailsEdit.unmet-requirement-banner') }, 500)
      return
    }

    const updatedAssignment = this.datesEditor.updateAssignment(this.state.assignment)
    this.setState({
      pending: true,
      assignment: updatedAssignment,
      validation: validator,
    })

    this.props.updateAssignment(this.props.courseID, updatedAssignment, this.props.assignmentDetails)
  }

  actionCancelPressed () {
    this.props.cancelAssignmentUpdate(this.props.assignmentDetails)
    this.props.navigator.dismiss()
  }

  componentDidUpdate () {
    if (this.state.error) {
      this.handleError()
    }
  }

  handleError () {
    setTimeout(() => { Alert.alert(ERROR_TITLE, this.state.error); delete this.state.error }, 1000)
  }

  componentWillReceiveProps (nextProps: AssignmentDetailsProps) {
    if (!nextProps.pending) {
      if (nextProps.error) {
        let error = parseErrorMessage(nextProps.error.response)
        this.setState({ pending: false, error: error, assignment: Object.assign({}, this.state.assignment) })
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

const style = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5F5F5',
  },
  row: {
    paddingTop: global.style.defaultPadding / 2,
    paddingBottom: global.style.defaultPadding / 2,
    paddingLeft: global.style.defaultPadding,
    paddingRight: global.style.defaultPadding,
    backgroundColor: 'white',
  },
  twoColumnRow: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    height: 54,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: color.grey2,
  },
  topRow: {
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: color.seperatorColor,
  },
  bottomRow: {
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: color.seperatorColor,
  },
  twoColumnRowLeftText: {
    flex: 1,
    fontWeight: '600',
  },
  title: {
    height: 45,
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
    backgroundColor: 'white',
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
    tintColor: color.primaryButton,
    marginRight: 8,
    height: 18,
    width: 18,
  },
})

let Connected = connect(updateMapStateToProps, AssignmentActions)(AssignmentDetailsEdit)
export default (Connected: Component<any, AssignmentDetailsProps, any>)
