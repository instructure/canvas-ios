// @flow
import React, { Component } from 'react'
import {
  StyleSheet,
} from 'react-native'

import { connect } from 'react-redux'
import i18n from 'format-message'
import Screen from '../../../routing/Screen'
import AuthenticatedWebView from '../../../common/components/AuthenticatedWebView'

type Props = {
  quizID: string,
}

type LocalProps = Props & {
  quiz: Quiz,
  navigator: Navigator,
}

export class QuizPreview extends Component<any, LocalProps, any> {

  render () {
    const javascript = "document.getElementById('preview_quiz_button').click();"
    const uri = `${this.props.quiz.html_url}/take?preview=1&persist_headless=1&force_user=1`
    return (
      <Screen
        title={i18n('Quiz Preview')}
        leftBarButtons={[
          {
            title: i18n('Done'),
            style: 'done',
            testID: 'quiz-preview.dismiss-btn',
            action: this.props.navigator.dismiss.bind(this),
          },
        ]}
      >
        <AuthenticatedWebView style={style.webView}
                              source={{ uri }}
                              injectedJavaScript={javascript}
                              automaticallyAdjustContentInsets={false} />
      </Screen>
    )
  }
}

const style = StyleSheet.create({
  webView: {
    flex: 1,
  },
})

export function mapStateToProps ({ entities }: AppState, { courseID, quizID }: Props): any {
  // I'm confidant that we don't need full routing to this, that's why it's making the assuption that the quiz is already there
  return {
    quiz: entities.quizzes[quizID].data,
  }
}

let Connected = connect(mapStateToProps, {})(QuizPreview)
export default (Connected: Component<any, Props, any>)
