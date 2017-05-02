/* @flow */

import React, { Component } from 'react'
import { RichTextEditor, RichTextToolbar } from '../../common/components/rich-text-editor/'
import { connect } from 'react-redux'
import KeyboardSpacer from 'react-native-keyboard-spacer'
import * as Actions from './actions'
import {
  StyleSheet,
  View,
  NativeModules,
} from 'react-native'

type OwnProps = {
  assignmentID: string,
}

type State = {
  id: string,
  description: ?string,
}

type Props = State & typeof Actions & {
  navigator: ReactNavigator,
  onChange: (input: string) => void,
  onFocus?: () => void,
  onBlur?: () => void,
  editorItemsChanged?: (items: [string]) => void,
}

export class AssignmentDescription extends Component<any, Props, any> {
  editor: RichTextEditor

  constructor (props: Props) {
    super(props)

    this.state = {
      description: props.description,
      activeEditorItems: [],
      editorFocused: false,
    }
  }

  componentWillUnmount () {
    this.props.updateAssignmentDescription(this.props.assignmentID, this.state.description)
  }

  render (): React.Element<*> {
    return (
      <View style={styles.container}>
        <RichTextEditor
          ref={(editor) => { this.editor = editor }}
          html={this.props.description}
          onLoad={this._onLoad}
          onFocus={this._onFocus}
          onBlur={this._onBlur}
          editorItemsChanged={this._onEditorItemsChanged}
          onInputChange={this._onInputChange}
        />
        { this.state.editorFocused &&
          <RichTextToolbar
            setBold={this._setBold}
            setItalic={this._setItalic}
            setUnorderedList={this._setUnorderedList}
            setOrderedList={this._setOrderedList}
            insertLink={this._insertLink}
            setTextColor={this._setTextColor}
            active={this.state.activeEditorItems}
            undo={this._undo}
            redo={this._redo}
          />
        }
        <KeyboardSpacer />
      </View>
    )
  }

  // EDITOR EVENTS

  _onLoad = () => {
    NativeModules.WebViewHacker.removeInputAccessoryView()
    NativeModules.WebViewHacker.setKeyboardDisplayRequiresUserAction(false)
  }

  _onInputChange = (description: string) => {
    this.setState({ description })
  }

  _onEditorItemsChanged = (activeEditorItems: string[]) => {
    this.setState({ activeEditorItems })
  }

  _onFocus = () => {
    this.setState({ editorFocused: true })
  }

  _onBlur = () => {
    this.setState({ editorFocused: false })
  }

  // TOOLBAR EVENTS

  _setBold = () => {
    this.editor.setBold()
  }
  _setItalic = () => { this.editor.setItalic() }
  _setUnorderedList = () => { this.editor.setUnorderedList() }
  _setOrderedList = () => { this.editor.setOrderedList() }
  _insertLink = () => { this.editor.insertLink() }
  _setTextColor = (color: string) => { this.editor.setTextColor(color) }
  _blurEditor = () => { this.editor.blurEditor() }
  _undo = () => { this.editor.undo() }
  _redo = () => { this.editor.redo() }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column',
  },
})

export function mapStateToProps (state: AppState, ownProps: OwnProps): State {
  if (state.entities &&
    state.entities.assignments &&
    state.entities.assignments[ownProps.assignmentID] &&
    state.entities.assignments[ownProps.assignmentID].data) {
    const assignment = state.entities.assignments[ownProps.assignmentID].data
    return {
      id: ownProps.assignmentID,
      description: assignment.description,
    }
  }

  return {
    id: ownProps.assignmentID,
    description: null,
  }
}

let Connected = connect(mapStateToProps, Actions, null, { withRef: true })(AssignmentDescription)
export default (Connected: any)
