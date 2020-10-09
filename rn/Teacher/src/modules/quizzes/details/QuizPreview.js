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

export class QuizPreview extends Component<LocalProps, any> {
  webView: ?AuthenticatedWebView

  state = {
    waiting: true,
    error: false,
  }

  componentWillUnmount () {
    clearTimeout(this.timer)
  }

  captureRef = (c: ?AuthenticatedWebView) => {
    this.webView = c
  }

  onMessage = (event) => {
    const message = event.nativeEvent.body
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
      var results = document.querySelector('.quiz-submission')
      var button = document.getElementById('preview_quiz_button')
      var instructions = document.getElementById('quiz-instructions')
      var login = document.getElementById('login_form')
      if (results) {
        results.scrollIntoView(true)
      } else if (button) {
        button.click()
        var dialogue = document.getElementById('js-sequential-warning-dialogue')
        if (dialogue) {
          var accept = dialogue.querySelector('button')
          if (accept) {
            accept.click()
          }
        }
      } else if (login) {
        window.webkit.messageHandlers.canvas.postMessage('login')
      } else if (instructions) {
        window.webkit.messageHandlers.canvas.postMessage('done')
      } else {
        window.webkit.messageHandlers.canvas.postMessage('error')
      }
    `
    this.webView && this.webView.evaluateJavaScript(js)
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
  timer = setTimeout(this.onTimeout, 30000)

  render () {
    const uri = `${this.props.quiz.html_url}/take?preview=1&persist_headless=1&force_user=1`
    return (
      <Screen
        title={i18n('Quiz Preview')}
      >
        <View style={style.container}>
          { this.state.error &&
            <View style={style.errorContainer}>
              <Text>{i18n('There was an error loading the quiz preview.')}</Text>
            </View>
          }
          { this.state.waiting &&
            <ActivityIndicatorView style={{ flex: 1 }} />
          }
          { !this.state.error &&
            <View style={ this.state.waiting ? style.waitingWebView : style.webView }>
              <AuthenticatedWebView
                navigator={this.props.navigator}
                onError={this.onError}
                onFinishedLoading={this.onLoadEnd}
                onMessage={this.onMessage}
                ref={this.captureRef}
                source={{ uri }}
                style={ this.state.waiting ? style.waitingWebView : style.webView }
              />
            </View>
          }
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
export default (Connected: Component<Props, any>)
