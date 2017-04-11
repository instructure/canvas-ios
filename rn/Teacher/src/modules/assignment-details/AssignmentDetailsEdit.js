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
    return (<Text style={style.twoColumnRowLeftText} fontWeight={'semibold'}>{text}</Text>)
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

  render (): React.Element<View> {
    let sectionTitle = i18n({
      default: 'Title',
      description: 'Assignment details edit title header',
    })
    let sectionDetails = i18n({
      default: 'Details',
      description: 'Assignment details edit details header',
    })

    let dueDatesTitle = i18n({
      default: 'Due Dates',
      description: 'Assignment details due dates header',
    })

    let savingText = i18n({
      default: 'Saving',
      description: 'Text when a request to update an assignment is made and user is waiting',
    })

    let titlePlaceHolder = i18n({ default: 'Title', description: 'Assignemnt details title placeholder' })
    let pointsPlaceHolder = i18n({ default: 'Points', description: 'Assignemnt details points placeholder' })
    let displayGradeAs = i18n({ default: 'Display Grade As', description: 'Assignemnt details display grade as' })

    return (
      <View style={{ flex: 1 }}>
        <ModalActivityIndicator text={savingText} visible={this.state.pending}/>
        <KeyboardAwareScrollView style={style.container} ref='scrollView'>

          {/* Title */}
          <EditSectionHeader title={sectionTitle} style={[style.sectionHeader, { marginTop: 0 }]}/>
          <View style={style.row}>
            { this.renderTextInput('name', titlePlaceHolder, 'titleInput', style.title, true) }
          </View>

          {/* Points */}
          <EditSectionHeader title={sectionDetails} style={style.sectionHeader}/>
          <View style={[style.row, style.twoColumnRow]}>
            { this.renderLeftColumnLabel(pointsPlaceHolder) }
            { this.renderTextInput('points_possible', pointsPlaceHolder, 'pointsInput', style.points) }
          </View>

          {/* Display Grade As */}
          <TouchableHighlight underlayColor={color.cellUnderlayColor} onPress={() => { this.togglePicker('grading_type', GRADE_DISPLAY_OPTIONS) }} testID='assignment-details.toggle-display-grade-as-picker'>
            <View style={[style.row, style.twoColumnRow, { borderBottomWidth: 0 }]}>
              { this.renderLeftColumnLabel(displayGradeAs) }
              <Text>{GRADE_DISPLAY_OPTIONS.get(this.state.assignment.grading_type)}</Text>
            </View>
          </TouchableHighlight>

          {/* Due Dates */}
          <EditSectionHeader title={dueDatesTitle} style={style.sectionHeader}/>
          <AssignmentDatesEditor assignment={this.props.assignmentDetails} />

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

  updateFromInput (key: string, value: string) {
    const assignment = this.state.assignment
    assignment[key] = value
    this.setState({ assignment })
  }

  defaultValueForInput (key: string): string {
    let assignment = this.state.assignment
    return assignment[key].toString()
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
    this.setState({ pending: true })
    this.props.updateAssignment(this.props.courseID, this.state.assignment, this.props.assignmentDetails)
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
  },
  sectionHeader: {
    marginTop: global.style.defaultPadding / 2,
  },
  row: {
    paddingTop: global.style.defaultPadding / 2,
    paddingBottom: global.style.defaultPadding / 2,
    paddingLeft: global.style.defaultPadding,
    paddingRight: global.style.defaultPadding,
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
  twoColumnRowLeftText: {
    flex: 1,
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
