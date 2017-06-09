// @flow

import React, { Component, PropTypes } from 'react'
import { requireNativeComponent } from 'react-native'

type Props = {
  config: { documentURL: string },
  style?: Object,
}

export default class PDFView extends Component<any, Props, any> {
  render () {
    return <PSPDFView style={this.props.style} {...this.props} />
  }
}

PDFView.propTypes = {
  config: PropTypes.shape({ documentURL: PropTypes.string }).isRequired,
}

const PSPDFView = requireNativeComponent('PSPDFView', PDFView)
