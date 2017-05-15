// @flow
import React, { Component } from 'react'
import {
  StyleSheet,
  WebView,
} from 'react-native'

import { connect } from 'react-redux'
import i18n from 'format-message'

type Props = {
  quizID: string,
}

type LocalProps = Props & {
  quiz: Quiz,
  navigator: ReactNavigator,
}

export class QuizPreview extends Component<any, LocalProps, any> {
  constructor (props: LocalProps) {
    super(props)

    props.navigator.setTitle({
      title: i18n('Quiz Preview'),
    })

    props.navigator.setOnNavigatorEvent(this.onNavigatorEvent)
  }

  static navigatorButtons = {
    leftButtons: [
      {
        title: i18n('Done'),
        id: 'dismiss',
        testID: 'quiz-preview.dismiss-btn',
      },
    ],
  }

  onNavigatorEvent = (event: NavigatorEvent) => {
    switch (event.type) {
      case 'NavBarButtonPress':
        switch (event.id) {
          case 'dismiss':
            this.props.navigator.dismissModal()
            break
        }
        break
    }
  }

  render () {
    const javascript = "document.getElementById('preview_quiz_button').click();"
    const uri = `${this.props.quiz.html_url}/take?preview=1&persist_headless=1&force_user=1`
    return (<WebView style={style.webView}
                     source={{ uri }}
                     injectedJavaScript={javascript}
                     automaticallyAdjustContentInsets={false} />)
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
