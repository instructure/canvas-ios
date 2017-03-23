/* @flow */

/*
 * A function that takes a set of answers and returns a uri for the
 * google form with the entry answers in the uri.
 *
 * Example:
 *   const entries = { favoriteColor: '1' }
 *   const form: GoogleForm = googleForm('https://docs.google.com/a', entries)
 *   const uri = form({ favoriteColor: 'blue' })
 *   => 'https://docs.google.com/a?entry.1=blue'
 */
type GoogleForm = (answers: { [string]: string }) => string

/*
 * Returns a GoogleForm configured with the given uri and entries
 */
export default function googleForm (uri: string, entries: { [string]: string }): GoogleForm {
  return (answers) => {
    const params = Object.keys(answers)
      .filter(key => answers[key])
      .map((key) => `entry.${entries[key]}=${answers[key]}`)
    return [uri, params.join('&')]
      .filter((s) => s.trim() !== '')
      .join('?')
      .replace(' ', '+')
  }
}
