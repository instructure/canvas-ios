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
const { execSync, spawn } = require('child_process')
const { createReadStream, readFileSync, writeFileSync, readdir } = require('fs')
const mkdirp = require('mkdirp')
const path = require('path')
const S3 = require('aws-sdk/clients/s3')
const localizables = require('./localizables.json')

program
  .version(require('../../package.json').version)
  .option('-s, --skip-pull', 'Skip pulling from S3')
  .option('-n, --no-import', 'Skip importing downloaded files')
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
  !program.skipPull &&
  (!process.env.AWS_ACCESS_KEY_ID || !process.env.AWS_SECRET_ACCESS_KEY)
) {
  program.outputHelp()
  process.exit(1)
}

importTranslations().catch(err => {
  console.error(err)
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

async function importTranslations() {
  if (!program.skipPull) {
    await pullTranslationsFromS3()
  }

  if (program.import) {
    await importXcodeTranslations()
  }
  
  discardNonTranslatableFileChanges()
}

async function pullTranslationsFromS3() {
  const Bucket = 'instructure-translations'
  const s3 = new S3({ region: 'us-east-1' })
  const listObjects = await s3.listObjectsV2({ Bucket, Prefix: `translations/canvas-ios/` }).promise()
  const keys = listObjects.Contents.map(({ Key }) => Key)

  for (const key of keys) {
    let [ , , locale, basename ] = key.split('/')
    if (!locale || !basename) continue // skip folders
    locale = normalizeLocale(locale)
    const [ projectName, ext ] = basename.split('.')
    const filename = `scripts/translations/imports/${projectName}/${locale}.${ext}`
    console.log(`Pulling s3://instructure-translations/${key} to ${filename}`)

    const { Body } = await s3.getObject({ Bucket, Key: key }).promise()
    let content = Body.toString().replace(/^\uFEFF/, '') // Strip BOM
    if (key.endsWith('.json')) {
      content = content.replace(/"message": "(.*)"$/gm, (_, message) => (
        `"message": "${
          message.replace(/\\"/g, '"').replace(/"/g, '\\"')
        }"`
      ))
      content = JSON.stringify(JSON.parse(content), null, '  ')
    } else {
      content = content.replace(/target-language="[^"]*"/g, `target-language="${locale}"`)
    }

    mkdirp.sync(path.dirname(filename))
    writeFileSync(filename, content, 'utf8')
  }
}

// make it more difficult for translators to accidentally break stuff
function normalizeLocale(locale) {
  return locale.replace(/_/g, '-')
    .replace(/-x-/, '-inst')
    .replace(/-inst(\w{5,})/, '-$1')
    .replace(/-k12/, '-instk12')
    .replace(/-ukhe/, '-instukhe')
}

async function importXcodeTranslations() {
  const folder = 'scripts/translations/imports/all'
  const files = await new Promise(resolve =>
    readdir(folder, (err, files) => resolve(files || []))
  )
  for (const file of files) {
    if (file.startsWith('.')) continue
    console.log(`Importing ${file} into workspace.`)

      await run('xcodebuild', [
        '-importLocalizations',
        '-localizationPath',
        `${folder}/${file}`,
        '-workspace',
        'Canvas.xcworkspace',
      ])
  }
}

async function discardNonTranslatableFileChanges() {
  console.log('Discarding all non translation file changes.')
  const modifiedFiles = execSync('git diff --name-only', { encoding: 'utf-8' })
    .trim()
    .split('\n')
  const filesToDiscard = modifiedFiles.filter(filePath => !localizables.includes(filePath))

  for (const filePath of filesToDiscard) {
    execSync(`git checkout -- "${filePath}"`)
  } 
}
