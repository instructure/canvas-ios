#!/usr/bin/env node
//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

/*
Ensures proper license header comments are added to .sh, .h, .m, .swift, and .js files.

Depends on node
 brew install node

Run this script from the repo root directory
 yarn update-headers
*/
const { execSync } = require('child_process')
const program = require('commander')
const { existsSync, readdirSync, readFileSync, writeFileSync } = require('fs')

program
  .version(require('../package.json').version)
  .option('-s --skip-write', 'Skips actually writing the files to disk')
  .option('-p --print', 'Print all of the files that will be modified')

const thisYear = new Date().getFullYear()
const ignoreExps = [
  /\.framework\/Headers\//i,
  /\.framework\/Versions\//i,
  /node_modules/i,
  /jquery/i,
  /preact/i,
]

//                   optional header                                space    star block        hash or slash block       space
const headerExp = /^((#!|\/\/ swift-tools-version:).*(?:\r?\n|\r))?[\s\r\n]*(\/\*.*?\*\/|(?:(?:#|\/\/).*(?:\r?\n|\r))+)?[\s\r\n]*/

/*
 Returns the correct AGPL banner based on the file.
*/
function newBanner (file, banner) {
  // Find the existing copyright date
  const year = (banner.match(/\d{4}/) || [])[0] || thisYear
  const license = `
This file is part of Canvas.
Copyright (C) ${year}-present  Instructure, Inc.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
`
    const comment = file.endsWith('.sh') ? '#' : '//'
    return license
        .split(/\n/)
        .map(line => line ? `${comment} ${line}` : comment)
        .join('\n')
        + '\n\n'
}

exports.check = check
function check(files, skipWrite = true) {
  const replaced = []
  const skipped = []
  const incompatible = []

  for (const file of files) {
    if (
      !/\.(swift|h|m|js|sh)$/i.test(file) ||
      ignoreExps.some(exp => exp.test(file)) ||
      !existsSync(file)
    ) { continue }
    const text = readFileSync(file, 'utf8')
    const [ , header = '', , banner = '' ] = text.match(headerExp) || []
    const hasCopyright = /copyright/i.test(banner)
    const hasInstructure = /instructure/i.test(banner)

    if (!hasCopyright) {
      const noHeader = text.replace(/^((#!|\/\/ swift-tools-version:).*(?:\r?\n|\r)+)/, '')
      const updated = `${header}${newBanner(file, banner)}${noHeader}`
      if (!skipWrite) {
        writeFileSync(file, updated, 'utf8')
      }
      replaced.push(file)
      continue
    }

    if (!hasInstructure) {
      if (banner.includes('GPL')) {
        incompatible.push(file)
      } else {
        skipped.push(file)
      }
      continue
    }

    const updated = text.replace(headerExp, `$1${newBanner(file, banner)}`)
    if (updated === text) {
      skipped.push(file)
      continue
    }
    if (!skipWrite) {
      writeFileSync(file, updated, 'utf8')
    }
    replaced.push(file)
  }

  return { replaced, skipped, incompatible }
}

if (require.main === module) {
  program.parse(process.argv)
  const { skipWrite = false, print = false } = program
  const files = execSync('git ls-files -z', { encoding: 'utf8' }).split('\0')
  console.log(`Checking ${files.length} files...`)
  const { replaced, skipped, incompatible } = check(files, skipWrite)
  console.log(`Files ${skipWrite ? 'to be ' : ''}modified: ${replaced.length}`)
  if (print) {
    console.log(replaced.sort().join('\n'))
  }
  console.log(`Files ${skipWrite ? 'to be ' : ''}skipped: ${skipped.length}`)
  if (print) {
    console.log(skipped.sort().join('\n'))
  }
  console.log(`\nFiles with incompatible licences: ${incompatible.length}`)
  console.log(incompatible.sort().join('\n'))
}
