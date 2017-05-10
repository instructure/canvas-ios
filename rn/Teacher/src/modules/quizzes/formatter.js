/* @flow */

import i18n from 'format-message'
import { formattedDueDate } from '../../common/formatters'
import { extractDateFromString } from '../../utils/dateUtils'

type HumanReadableQuiz = {
  quizType: string,
  shuffleAnswers: string,
  timeLimit: string,
  allowedAttempts: string | number,
  viewResponses: string,
  showCorrectAnswers: ?string,
  oneQuestionAtATime: string,
  scoringPolicy: string,
}

export default function formatter (quiz: Quiz): HumanReadableQuiz {
  return {
    quizType: {
      practice_quiz: i18n('Practice Quiz'),
      assignment: i18n('Graded Quiz'),
      graded_survey: i18n('Graded Survey'),
      survey: i18n('Ungraded Survey'),
    }[quiz.quiz_type],
    shuffleAnswers: quiz.shuffle_answers ? i18n('Yes') : i18n('No'),
    timeLimit: quiz.time_limit
      ? i18n(`{
        number, plural,
        one {# Minute}
        other {# Minutes}
      }`, { number: quiz.time_limit })
      : i18n('No Time Limit'),
    allowedAttempts: quiz.allowed_attempts === -1 ? i18n('Unlimited') : quiz.allowed_attempts,
    viewResponses: quiz.hide_results ? {
      'always': i18n('No'),
      'until_after_last_attempt': i18n('After Last Attempt'),
    // $FlowFixMe
    }[quiz.hide_results] : 'Always',
    showCorrectAnswers: (() => {
      if (quiz.show_correct_answers) {
        if (quiz.show_correct_answers_at && !quiz.hide_correct_answers_at) {
          return i18n('After {date}', { date: formattedDueDate(extractDateFromString(quiz.show_correct_answers_at)) })
        }
        if (quiz.hide_correct_answers_at && !quiz.show_correct_answers_at) {
          return i18n('Until {date}', { date: formattedDueDate(extractDateFromString(quiz.hide_correct_answers_at)) })
        }
        if (quiz.show_correct_answers_at && quiz.hide_correct_answers_at) {
          return i18n('{show} to {hide}', {
            show: formattedDueDate(extractDateFromString(quiz.show_correct_answers_at)),
            hide: formattedDueDate(extractDateFromString(quiz.hide_correct_answers_at)),
          })
        }
        if (quiz.show_correct_answers_last_attempt && quiz.allowed_attempts > 0) {
          return i18n('After Last Attempt')
        }

        return quiz.hide_results ? null : i18n('Always')
      }

      return quiz.hide_results ? null : i18n('No')
    })(),
    oneQuestionAtATime: quiz.one_question_at_a_time ? i18n('Yes') : i18n('No'),
    scoringPolicy: {
      keep_average: i18n('Average'),
      keep_latest: i18n('Latest'),
      keep_highest: i18n('Highest'),
    }[quiz.scoring_policy],
  }
}
