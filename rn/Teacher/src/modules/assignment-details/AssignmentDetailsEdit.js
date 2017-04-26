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
import AssignmentDescription from '../assignment-description/AssignmentDescription'
import { RichTextToolbar, ColorPicker } from '../../common/components/rich-text-editor/'
import ReactNative, {
  View,
  StyleSheet,
  Alert,
  PickerIOS,
  TouchableHighlight,
  LayoutAnimation,
  Switch,
  Keyboard,
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
  currentPickerMap: ?Map<*, *> = null
  keyboardWillShowListener: *
  keyboardWillHideListener: *

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
      keyboardHeight: 0,
    }
  }

  componentWillMount () {
    this.keyboardWillShowListener = Keyboard.addListener('keyboardWillShow', this.keyboardWillShow)
    this.keyboardWillHideListener = Keyboard.addListener('keyboardWillHide', this.keyboardWillHide)
  }

  componentWillUnmount () {
    this.props.refreshAssignment(this.props.courseID, this.props.assignmentID)
    this.keyboardWillShowListener.remove()
    this.keyboardWillHideListener.remove()
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
                 onFocus={(event) => this._scrollToInput(ReactNative.findNodeHandle(event.target))}
                 testID={testID}/>
    )
  }

  _scrollToInput = (input: any) => {
    this.refs.scrollView.scrollToFocusedInput(input)
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

  renderDataMapPicker = (): React.Element<View> => {
    if (!this.state.showPicker) return <View/>

    return <View style={style.dateEditorContainer}>
      <PickerIOS
        style={style.picker}
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

  render (): React.Element<View> {
    let sectionTitle = i18n({
      default: 'Title',
      description: 'Assignment details edit title header',
    })
    let sectionDescription = i18n({
      default: 'Description',
      description: 'Assignment details edit description header',
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
        <KeyboardAwareScrollView
          style={style.container}
          ref='scrollView'
          contentInset={{ bottom: this.state.editingDescription ? this.state.keyboardHeight + (this.state.colorPickerVisible ? 100 : 50) : 0 }}
          keyboardShouldPersistTaps='handled'
          keyboardDismissMode={this.state.editingDescription ? 'none' : 'interactive'}
          enableAutoAutomaticScroll={false}
        >
          {/* Title */}
          <EditSectionHeader title={sectionTitle} />
          <View style={[style.row, style.topRow, style.bottomRow]}>
            { this.renderTextInput('name', titlePlaceHolder, 'titleInput', style.title, true) }
          </View>

          {/* Description */}
          <EditSectionHeader title={sectionDescription} style={[style.sectionHeader, { marginTop: 0 }]}/>
          <AssignmentDescription
            ref='description'
            assignmentID={this.props.assignmentDetails.id}
            onFocus={() => this.setState({ editingDescription: true })}
            onBlur={() => this.setState({ editingDescription: false })}
            editorItemsChanged={(descriptionEditorItems) => this.setState({ descriptionEditorItems })}
            onChange={(description) => this.updateFromInput('description', description)}
          />

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
          {this.renderDataMapPicker()}

          {/* Publish */}
          <View style={[style.row, style.twoColumnRow, style.bottomRow]}>
            { this.renderLeftColumnLabel(publish) }
            { this.renderToggle('published', 'published') }
          </View>

          {/* Due Dates */}
          <AssignmentDatesEditor assignment={this.props.assignmentDetails} ref={c => { this.datesEditor = c }} navigator={this.props.navigator} />

        </KeyboardAwareScrollView>

        { this.state.editingDescription &&
          <View>
            <View style={[style.toolbar, { bottom: this.state.keyboardHeight + (this.state.colorPickerVisible ? 55 : 0) }]}>
              <ColorPicker
                pickedColor={this._pickColor}
                style={{
                  position: 'absolute',
                  bottom: 0,
                  left: 0,
                }}
              />
            </View>
            <View style={[style.toolbar, { bottom: this.state.keyboardHeight }]}>
              <RichTextToolbar
                setBold={() => this._descriptionInstance().setBold()}
                setItalic={() => this._descriptionInstance().setItalic()}
                setUnorderedList={() => this._descriptionInstance().setUnorderedList()}
                setOrderedList={() => this._descriptionInstance().setOrderedList()}
                insertLink={() => this._descriptionInstance().insertLink()}
                setTextColor={this._toggleColorPicker}
                active={this.state.descriptionEditorItems}
                onTappedDone={() => this._descriptionInstance().blurEditor()}
                undo={() => this._descriptionInstance().undo()}
                redo={() => this._descriptionInstance().redo()}
              />
            </View>
          </View>
        }

      </View>
    )
  }

  _toggleColorPicker = () => {
    LayoutAnimation.configureNext(LayoutAnimation.Presets.spring)
    this.setState({ colorPickerVisible: !this.state.colorPickerVisible })
  }

  _pickColor = (color: string) => {
    this._descriptionInstance().setTextColor(color)
    LayoutAnimation.configureNext(LayoutAnimation.Presets.spring)
    this.setState({ colorPickerVisible: false })
  }

  _descriptionInstance = () => this.refs.description.getWrappedInstance()

  keyboardWillShow = (event: KeyboardEventData) => {
    this.setState({ keyboardHeight: event.endCoordinates.height })
  }

  keyboardWillHide = (event: KeyboardEventData) => {
    this.setState({ keyboardHeight: 0 })
  }

  pickerValueDidChange (value: any) {
    if (this.state.currentAssignmentKey) {
      this.state.assignment[this.state.currentAssignmentKey] = value
      this.setState({ pickerSelectedValue: value, assignment: this.state.assignment })
    }
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
      this.refs.scrollView.scrollToPosition(invalidDatesPosition.x, invalidDatesPosition.y, true)
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
    this.props.cancelAssignmentUpdate(this.props.assignmentDetails)
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
})

let Connected = connect(updateMapStateToProps, AssignmentActions)(AssignmentDetailsEdit)
export default (Connected: Component<any, AssignmentDetailsProps, any>)
