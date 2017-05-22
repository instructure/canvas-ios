// @flow

const RealComponent = require.requireActual('../ZSSRichTextEditor')
const React = require('React')

export default class ZSSRichTextEditor extends React.Component {
  render () {
    const props = { ...this.props, _setMock: this._setMock }
    return React.createElement('ZSSRichTextEditor', props, this.props.children)
  }

  _setMock = (ref: string, mock: any) => {
    this[ref] = mock
  }
}
ZSSRichTextEditor.propTypes = RealComponent.propTypes
