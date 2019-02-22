#!/usr/bin/env node
/*
Ensures proper license header comments are added to .h, .m, .swift and .js files.

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
  /^scripts\//i,
  /\.framework\/Headers\//i,
  /\.framework\/Versions\//i,
  /CanvasKit1\/External Sources\//i,
  /node_modules/i,
  /jquery/i,
]

// Used to make sure there is the work "copyright" somewhere in the Header
// Doing this to be safe, so we don't replace other comments
const copyrightExp = /(^|\r\n|\n|\r)[\/*#|\s]*Copyright\s+[^\s\r\n]+/i

// This regex is used to find and/or replace the first block comment in a file
const bannerExp = /(^|\r\n|\n|\r)(?:\/\/[^\n\r]*(?:\r\n|\n|\r))*\/\/[^\n\r]*($|\r\n|\n|\r)/i

// Used to test whether the Instructure appears in a file
const instructureExp = /(^|\r\n|\n|\r)*Instructure/i

/*
 Returns the correct banner based on the file
 Tests and Frameworks are Apache;
 App code and everything else is GPL.
*/
function appropriateBanner (file, text) {
  // Find the existing copyright date
  const year = (text.match(/\/\/.*copyright.*(\d{4})/i) || [])[1] || thisYear
  const useApache = (
    file.startsWith('Frameworks') ||
    file.includes('Tests') ||
    file.includes('test')
  )

  if (useApache) {
    return `//
// Copyright (C) ${year}-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
`
  }

  return `//
// Copyright (C) ${year}-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
`
}

exports.check = check
function check(files, skipWrite = true) {
  const replaced = []
  const skipped = []
  const incompatible = []

  for (const file of files) {
    if (
      !/\.(swift|h|m|js)$/i.test(file) ||
      ignoreExps.some(exp => exp.test(file)) ||
      !existsSync(file)
    ) { continue }
    let text = readFileSync(file, 'utf8')
    const hasCopyright = copyrightExp.test(text)
    const hasBanner = text.match(bannerExp)
    const hasInstructure = instructureExp.test(text)
    const banner = appropriateBanner(file, text)

    if (!hasCopyright) {
      text = `${banner}\n${text}`
      if (!skipWrite) {
        writeFileSync(file, text, 'utf8')
      }
      replaced.push(file)
      continue
    }

    if (!hasBanner) {
      skipped.push(file)
      continue
    }

    if (!hasInstructure) {
      if (hasBanner[0].includes('GPL')) {
        incompatible.push(file)
      } else {
        skipped.push(file)
      }
      continue
    }

    const updated = text.replace(bannerExp, banner)
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
  console.log(`\nFiles with incompatible liceneses: ${incompatible.length}`)
  console.log(incompatible.sort().join('\n'))
}
