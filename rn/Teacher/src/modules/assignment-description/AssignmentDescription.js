/* @flow */

import React, { Component } from 'react'
import RichTextEditor from '../../common/components/rich-text-editor/RichTextEditor'
import { connect } from 'react-redux'
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

type Props = State & {
  navigator: ReactNavigator,
  onChange: (input: string) => void,
  onFocus?: () => void,
  editorItemsChanged?: (items: [string]) => void,
}

export class AssignmentDescription extends Component<any, Props, any> {
  editor: RichTextEditor

  render (): React.Element<*> {
    return (
      <View style={styles.container}>
        <RichTextEditor
          ref='editor'
          html={this.props.description}
          style={styles.editor}
          onLoad={this._onEditorLoaded}
          onFocus={this.props.onFocus}
          editorItemsChanged={this.props.editorItemsChanged}
          onInputChange={this.props.onChange}
        />
      </View>
    )
  }

  _onEditorLoaded = () => {
    NativeModules.WebViewHacker.removeInputAccessoryView()
    NativeModules.WebViewHacker.setKeyboardDisplayRequiresUserAction(false)
  }

  setBold () { this.refs.editor.setBold() }
  setItalic () { this.refs.editor.setItalic() }
  setUnorderedList () { this.refs.editor.setUnorderedList() }
  setOrderedList () { this.refs.editor.setOrderedList() }
  insertLink () { this.refs.editor.insertLink() }
  setTextColor (color: string) { this.refs.editor.setTextColor(color) }
  blurEditor () { this.refs.editor.blurEditor() }
  undo () { this.refs.editor.undo() }
  redo () { this.refs.editor.redo() }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column',
  },
  editor: {
    alignItems: 'center',
    justifyContent: 'center',
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

let Connected = connect(mapStateToProps, {}, null, { withRef: true })(AssignmentDescription)
export default (Connected: any)
