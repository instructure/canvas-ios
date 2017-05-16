// @flow

class PropRegistry {
  registry: Object

  constructor () {
    this.registry = {}
  }

  save (screenInstanceID: string = '', passProps: Object = {}) {
    this.registry[screenInstanceID] = passProps
  }

  load (screenInstanceID: string = '') {
    return this.registry[screenInstanceID] || {}
  }
}

module.exports = new PropRegistry()
