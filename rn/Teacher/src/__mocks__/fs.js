/* @flow */

const path = require('path')

const fs = jest.genMockFromModule('fs')

let mockFiles = Object.create(null)
function __setMockFiles (newMockFiles) {
  mockFiles = Object.create(null)
  for (const file in newMockFiles) {
    const dir = path.dirname(file)

    if (!mockFiles[dir]) {
      mockFiles[dir] = {}
    }
    mockFiles[dir][path.basename(file)] = newMockFiles[file]
  }
}

function readFileSync (file) {
  const dir = path.dirname(file)
  const name = path.basename(file)
  return mockFiles[dir][name]
}

fs.__setMockFiles = __setMockFiles
fs.readFileSync = readFileSync

module.exports = fs
