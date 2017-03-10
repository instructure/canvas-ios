// @flow
import { NativeModules } from 'react-native'

declare var Intl: any

// apple gives us the locale/region using an underscore as delimiter
// for some reason Intl wants it as a hyphen
// also account for tests where NativeModules.SettingsManager is not
// defined
const defaultLocale = NativeModules.SettingsManager ? NativeModules.SettingsManager.settings.AppleLocale.replace('_', '-') : 'en'

export default function localeSort (first: any, second: any, locale?: string = defaultLocale): number {
  let collator = new Intl.Collator(locale)
  return collator.compare(first, second)
}

/*
 This can't be tested in our test environment right now.
 Node does not includee all of the language data needed
 to do proper sorting. There is a module `full-icu` that
 you can use to give node access to all the language
 data but it will not install with yarn as per this issue
 https://github.com/unicode-org/full-icu-npm/issues/9
 Another alternative would be to use the Intl polyfill
 but that does not include support for Collators. Thus
 there is no way to test this yet
*/
