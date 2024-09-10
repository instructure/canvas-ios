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

const program = require('commander')
const { spawn } = require('child_process')
const { createReadStream, readFileSync, writeFileSync } = require('fs')
const S3 = require('aws-sdk/clients/s3')
const localizables = require('./localizables.json')

program
  .version(require('../../package.json').version)
  .option('-s, --skipPush', 'Skip pushing to S3')
  .option('-v, --verbose', 'Print all outputs to console')

program.on('--help', () => {
  console.log(`
  Environment Variables:

    AWS_ACCESS_KEY_ID      AWS key, required to sync to instructure-translations S3 bucket
    AWS_SECRET_ACCESS_KEY  AWS secret, required to sync to instructure-translations S3 bucket
  \n`)
})
program.parse(process.argv)

if (
  !program.skipPush &&
  (!process.env.AWS_ACCESS_KEY_ID || !process.env.AWS_SECRET_ACCESS_KEY)
) {
  program.outputHelp()
  process.exit(1)
}

exportTranslations().catch(err => {
  console.error('Export translations failed: ', err)
  process.exit(2)
})

function run(cmd, args, opts) {
  return new Promise((resolve, reject) => {
    const command = spawn(cmd, args, opts)
    // If we don't read these xcodebuild just hangs
    command.stdout.on('data', (data) => {
      if (program.verbose) {
	    console.log(`${data}`)
      }
	})
    command.stderr.on('data', (data) => {
      if (program.verbose) {
	    console.log(`${data}`)
      }
	})
    command.on('error', reject)
    command.on('exit', code => {
      if (code === 0) return resolve()
      reject(`${cmd} failed with code ${code}.`)
    })
  })
}

async function exportTranslations() {
  const toUpload = []
  await processNativeLocalizations(toUpload)
  await pushToS3(toUpload)
  console.log('Finished!')
}

async function processNativeLocalizations(toUpload) {
  const outputPath = 'scripts/translations/source/all/'
  await exportLocalizations(outputPath)
  
  const outputFile = `${outputPath}en.xcloc/Localized Contents/en.xliff`
  let xml = readFileSync(outputFile, 'utf8')
  xml = removeNonLocalizedFiles(xml)
  xml = removeNonLocalizedKeys(xml)
  writeFileSync(outputFile, xml, 'utf8')
  toUpload.push({ from: outputFile, to: `all.xliff` })
}

async function pushToS3(toUpload) {
  if (program.skipPush) {
    console.log(`Skipping S3 push of these entries:`)
    for (const entry of toUpload) {
	  console.log(`${entry.from} -> ${entry.to}`)
    }
    return
  }
  
  const Bucket = 'instructure-translations'
  const s3 = new S3({ region: 'us-east-1' })
  await Promise.all(toUpload.map(({ from, to }) => {
    console.log(`Uploading ${from} to s3://instructure-translations/sources/canvas-ios/en/${to}`)
    return s3.putObject({ Bucket, Key: `sources/canvas-ios/en/${to}`, Body: createReadStream(from) })
      .promise()
  }))
}

async function exportLocalizations(outputPath) {
  await run('xcodebuild', [
  	'-exportLocalizations',
	'-workspace',
  	'Canvas.xcworkspace',
  	'-localizationPath',
  	outputPath,
  	'-n'
  ])
}

function removeNonLocalizedFiles(xml) {
  // Matches file tags with original attribute
  const pattern = new RegExp(`<file\\s+original="([^"]+)"[^>]*>[\\s\\S]*?<\\/file>`, 'g')

  // Replace non-matching files with an empty string
  let result = xml.replace(pattern, (match, p1) => {
    return localizables.includes(p1) ? match : ''
  })
  
  // Remove empty lines
  result = result.replace(/^(?:[\t ]*(?:\r?\n|\r))+/gm, '');

  return result
}

function removeNonLocalizedKeys(xml) {
  const keysToSkip = ['CFBundleName']
  let result = xml
  keysToSkip.forEach((key) => {
    const regex = new RegExp(`<trans-unit id=\"${key}\"[\\\s\\\S]*?<\/trans-unit>\\s`, 'g')
    result = result.replace(regex, '')
  })
  return result
}
