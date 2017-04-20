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
import { Navigation } from 'react-native-navigation'
import { ERROR_TITLE, parseErrorMessage } from '../../redux/middleware/error-handler'
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view'
import color from './../../common/colors'
import {
  View,
  StyleSheet,
  Alert,
  PickerIOS,
  TouchableHighlight,
  LayoutAnimation,
  Switch,
} from 'react-native'

var PickerItemIOS = PickerIOS.Item

const GRADE_DISPLAY_OPTIONS = new Map([
  ['percent', i18n({
    default: 'Percentage',
    description: 'display grade as percentage',
  })],
  ['pass_fail', i18n({
    default: 'Complete/Incomplete',
    description: 'display grade as Complete/Incomplete',
  })],
  ['points', i18n({
    default: 'Points',
    description: 'display grade as points',
  })],
  ['letter_grade', i18n({
    default: 'Letter Grade',
    description: 'display grade as letter grade',
  })],
  ['gpa_scale', i18n({
    default: 'GPA Scale',
    description: 'display grade as GPA scale',
  })],
  ['not_graded', i18n({
    default: 'Not Graded',
    description: 'display grade as not graded',
  })],
])

export class AssignmentDetailsEdit extends Component<any, AssignmentDetailsProps, any> {
  props: AssignmentDetailsProps
  state: any = {}
  datesEditor: AssignmentDatesEditor
  scrollView: KeyboardAwareScrollView
  currentPickerMap: ?Map<*, *> = null

  static navigatorButtons = {
    rightButtons: [
      {
        title: i18n({
          default: 'Done',
          description: 'Button to close modal',
          id: 'done_edit_assignment',
        }),
        id: 'dismiss',
        testID: 'edit-assignment.dismiss-btn',
      },
    ],
    leftButtons: [
      {
        title: i18n('Cancel'),
        id: 'cancel',
        testID: 'edit-assignment.cancel-btn',
      },
    ],
  }

  constructor (props: AssignmentDetailsProps) {
    super(props)
    props.navigator.setOnNavigatorEvent(this.onNavigatorEvent)
    this.state = {
      assignment: Object.assign({}, props.assignmentDetails),
      showPicker: false,
      pickerSelectedValue: 'initial value set in constructor',
      currentAssignmentKey: null,
    }
  }

  componentDidMount () {
    this.props.navigator.setTitle({
      title: i18n({
        default: 'Edit Assignment Details',
        description: 'Title of Assignment details EDIT screen',
      }),
    })
  }

  renderLeftColumnLabel (text: string): React.Element<*> {
    return (<Text style={style.twoColumnRowLeftText}>{text}</Text>)
  }

  renderTextInput (fieldName: string, placeholder: string, testID: string, styleParam: Object = {}, multiline: boolean = false): React.Element<*> {
    return (
      <TextInput style={styleParam}
                 value={ this.defaultValueForInput(fieldName) }
                 multiline={ multiline }
                 placeholder={ placeholder }
                 onChangeText={ value => this.updateFromInput(fieldName, value) }
                 testID={testID}/>
    )
  }

  renderToggle (fieldName: string, testID: string, styleParam: Object = {}): React.Element<*> {
    return (
      <Switch style={styleParam}
              value={ this.defaultValueForBooleanInput(fieldName) }
              onValueChange={ value => this.updateFromInput(fieldName, value) }
              testID={testID}
              tintColor={ color.primaryBrandColor }
              onTintColor={ color.primaryBrandColor }
      />
    )
  }

  render (): React.Element<View> {
    let sectionTitle = i18n({
      default: 'Title',
      description: 'Assignment details edit title header',
    })
    let sectionDetails = i18n({
      default: 'Details',
      description: 'Assignment details edit details header',
    })

    let savingText = i18n({
      default: 'Saving',
      description: 'Text when a request to update an assignment is made and user is waiting',
    })

    let titlePlaceHolder = i18n({ default: 'Title', description: 'Assignment details title placeholder' })
    let pointsPlaceHolder = i18n({ default: 'Points', description: 'Assignment details points placeholder' })
    let displayGradeAs = i18n({ default: 'Display Grade As', description: 'Assignment details display grade as' })
    let publish = i18n({ default: 'Publish', description: 'Assignment details publish toggle' })

    return (
      <View style={{ flex: 1 }}>
        <ModalActivityIndicator text={savingText} visible={this.state.pending}/>
        <KeyboardAwareScrollView style={style.container} ref={ (c) => { this.scrollView = c } } >

          {/* Title */}
          <EditSectionHeader title={sectionTitle} />
          <View style={[style.row, style.topRow, style.bottomRow]}>
            { this.renderTextInput('name', titlePlaceHolder, 'titleInput', style.title, true) }
          </View>

          {/* Points */}
          <EditSectionHeader title={sectionDetails} />
          <View style={[style.row, style.twoColumnRow, style.topRow]}>
            { this.renderLeftColumnLabel(pointsPlaceHolder) }
            { this.renderTextInput('points_possible', pointsPlaceHolder, 'pointsInput', style.points) }
          </View>

          {/* Display Grade As */}
          <TouchableHighlight underlayColor={color.cellUnderlayColor} onPress={() => { this.togglePicker('grading_type', GRADE_DISPLAY_OPTIONS) }} testID='assignment-details.toggle-display-grade-as-picker'>
            <View style={[style.row, style.twoColumnRow]}>
              { this.renderLeftColumnLabel(displayGradeAs) }
              <Text>{GRADE_DISPLAY_OPTIONS.get(this.state.assignment.grading_type)}</Text>
            </View>
          </TouchableHighlight>

          {/* Publish */}
          <View style={[style.row, style.twoColumnRow, style.bottomRow]}>
            { this.renderLeftColumnLabel(publish) }
            { this.renderToggle('published', 'published') }
          </View>

          {/* Due Dates */}
          <AssignmentDatesEditor assignment={this.props.assignmentDetails} ref={c => { this.datesEditor = c }} navigator={this.props.navigator} />

        </KeyboardAwareScrollView>

        { this.state.showPicker && this.currentPickerMap &&
        <PickerIOS
          style={style.picker}
          selectedValue={this.state.pickerSelectedValue}
          onValueChange={this.pickerValueDidChange.bind(this)}
          testID='assignmentPicker'>
          {Array.from(this.currentPickerMap.keys()).map((key) => (
            <PickerItemIOS
              key={key}
              value={key}
              label={this.currentPickerMap ? this.currentPickerMap.get(key) : ''}
            />
          ))}
        </PickerIOS>
        }

      </View>
    )
  }

  pickerValueDidChange (value: any) {
    if (this.state.currentAssignmentKey) {
      this.state.assignment[this.state.currentAssignmentKey] = value
      this.setState({ pickerSelectedValue: value, assignment: this.state.assignment })
    }
  }

  togglePicker = (selectedField: string, map: ?Map<*, *>) => {
    let animation = LayoutAnimation.create(250, LayoutAnimation.Types.linear, LayoutAnimation.Properties.opacity)
    LayoutAnimation.configureNext(animation)
    this.currentPickerMap = map
    this.setState({ showPicker: !this.state.showPicker, currentAssignmentKey: selectedField })
  }

  updateFromInput (key: string, value: any) {
    const assignment = this.state.assignment
    assignment[key] = value
    this.setState({ assignment })
  }

  defaultValueForInput (key: string): string {
    let assignment = this.state.assignment
    return assignment[key].toString()
  }

  defaultValueForBooleanInput (key: string): boolean {
    let assignment = this.state.assignment
    return assignment[key]
  }

  onNavigatorEvent = (event: NavigatorEvent) => {
    switch (event.type) {
      case 'NavBarButtonPress':
        switch (event.id) {
          case 'dismiss':
            this.actionDonePressed()
            break
          case 'cancel':
            this.actionCancelPressed()
            break
        }
        break
    }
  }

  actionDonePressed () {
    const invalidDatesPosition = this.datesEditor.validate()
    if (invalidDatesPosition) {
      this.scrollView.scrollToPosition(invalidDatesPosition.x, invalidDatesPosition.y, true)
      return
    }

    const updatedAssignment = this.datesEditor.updateAssignment(this.state.assignment)
    this.setState({
      pending: true,
      assignment: updatedAssignment,
    })

    this.props.updateAssignment(this.props.courseID, updatedAssignment, this.props.assignmentDetails)
  }

  actionCancelPressed () {
    Navigation.dismissAllModals()
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
    if (!nextProps.pending && nextProps.error) {
      let error = parseErrorMessage(nextProps.error.response)
      this.setState({ pending: false, error: error, assignment: Object.assign({}, this.state.assignment) })
      return
    }

    if (this.state.pending && (nextProps.assignmentDetails && !nextProps.pending)) {
      this.setState({ error: undefined })
      Navigation.dismissAllModals()
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
  picker: {
    flex: 1,
  },
})

let Connected = connect(updateMapStateToProps, AssignmentActions)(AssignmentDetailsEdit)
export default (Connected: Component<any, AssignmentDetailsProps, any>)
