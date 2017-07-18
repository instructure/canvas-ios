// @flow
import React, { Component } from 'react'
import {
  StyleSheet,
  View,
} from 'react-native'

import { connect } from 'react-redux'
import i18n from 'format-message'
import Screen from '../../../routing/Screen'
import { Text } from '../../../common/text'
import ActivityIndicatorView from '../../../common/components/ActivityIndicatorView'
import AuthenticatedWebView from '../../../common/components/AuthenticatedWebView'

type Props = {
  quizID: string,
}

type LocalProps = Props & {
  quiz: Quiz,
  navigator: Navigator,
}

export class QuizPreview extends Component<any, LocalProps, any> {

  webView: AuthenticatedWebView

  constructor (props: any) {
    super(props)
    this.state = {
      waiting: true,
      error: false,
    }

    setTimeout(this.onTimeout, 30000)
  }

  captureRef = (c: AuthenticatedWebView) => {
    this.webView = c
  }

  onMessage = (event: any) => {
    const message = event.nativeEvent.data
    if (!message) return
    switch (message) {
      case 'done':
      case 'login':
        this.setState({ waiting: false })
        break
      case 'error':
        this.setState({ waiting: false, error: true })
        break
    }
  }

  onLoadEnd = (event: any) => {
    const js = `
      var button = document.getElementById('preview_quiz_button')
      var instructions = document.getElementById('quiz-instructions')
      var login = document.getElementById('login_form')
      if (button) {
        button.click()
      } else if (login) {
        window.postMessage('login')
      } else if (instructions) {
        window.postMessage('done')
      } else {
        window.postMessage('error')
      }
    `
    this.webView.injectJavaScript(js)
  }

  onError = (event: any) => {
    this.setState({ error: true, waiting: false })
  }

  onTimeout = () => {
    if (this.state.waiting) {
      this.setState({
        error: true,
        waiting: false,
      })
    }
  }

  render () {
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
        <View style={style.container}>
          { this.state.error && <View style={style.errorContainer}>
                                  <Text>{i18n('There was an error loading the quiz preview.')}</Text>
                                </View> }
          { this.state.waiting && <ActivityIndicatorView style={{ flex: 1 }} /> }
          { !this.state.error && <View style={ this.state.waiting ? style.waitingWebView : style.webView }>
                                   <AuthenticatedWebView style={ this.state.waiting ? style.waitingWebView : style.webView }
                                                         source={{ uri }}
                                                         automaticallyAdjustContentInsets={false}
                                                         onMessage={this.onMessage}
                                                         ref={this.captureRef}
                                                         onLoadEnd={this.onLoadEnd}
                                                         onError={this.onError} />
                                  </View>}
        </View>
      </Screen>
    )
  }
}

const style = StyleSheet.create({
  container: {
    flex: 1,
  },
  waitingWebView: {
    flex: 0,
    height: 1,
    position: 'absolute',
    bottom: -1,
  },
  webView: {
    flex: 1,
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
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
