
# Before publishing course...
# 1. update grade posting policy to manual (under "Grades" -> {gear icon})
# 2. change course color

COURSE_ID = 83831
DAY_FIRST = '2026-01-12'
DAY_LAST = '2026-04-24'
DAYS_OFF = [
    '2026-01-19',
    '2026-03-05',
    '2026-03-17',
    '2026-03-19',
]

COURSE_EVAL_DATE = ['2026-02-10', '2026-03-12', '2026-04-16']
PRACTICE_DUE = ['2026-01-28', '2026-02-17']
ASSIGNMENT_DUE = ['2026-02-03', '2026-03-10', '2026-04-14']
PROJECT_DUE = ['2026-03-03', '2026-03-24', '2026-04-07', '2026-04-21', '2026-05-05']

from canvasapi import Canvas
from datetime import datetime, timedelta
from dotenv import load_dotenv  # for saving variables from .env file as environment variables
import os                       # for getting envinronment variables
import random                   # for randomizing exit ticket access codes


# Load environment variables from .env file
load_dotenv(override=True)

# Initialize a new Canvas object
canvas = Canvas(os.getenv('API_URL'), os.getenv('API_KEY'))
course = canvas.get_course(COURSE_ID)

day_first = datetime.strptime(DAY_FIRST, '%Y-%m-%d')
day_last = datetime.strptime(DAY_LAST, '%Y-%m-%d')
days_off = [datetime.strptime(x, '%Y-%m-%d') for x in DAYS_OFF]
course_eval_date = [datetime.strptime(x, '%Y-%m-%d') for x in COURSE_EVAL_DATE]
practice_due = [datetime.strptime(x, '%Y-%m-%d') for x in PRACTICE_DUE]
assignment_due = [datetime.strptime(x, '%Y-%m-%d') for x in ASSIGNMENT_DUE]
project_due = [datetime.strptime(x, '%Y-%m-%d') for x in PROJECT_DUE]


# Re-organize home page and tabs ----

canvas.set_course_nickname(COURSE_ID, 'Introduction to Sport Analytics')

course.update(
    course = {
        'image_url': 'https://github.com/saberpowers/saberpowers.github.io/blob/main/teaching/smgt430/image.jpg?raw=true',
        'default_view': 'modules',
        'syllabus_body': '<a href="https://saberpowers.github.io/teaching/smgt430/syllabus/latest.pdf" target="_blank" rel="noopener">Syllabus</a>',
    }
)

tabs_to_keep = ['Announcements', 'Syllabus', 'Modules', 'Quizzes', 'Assignments', 'Grades', 'Files', 'People']
all_tabs = course.get_tabs()

for tab in all_tabs:
    if tab.label in ['Home', 'Settings']:
        continue                    # these tabes are not manageable
    if tab.label in tabs_to_keep:
        tab.update(hidden=False, position=tabs_to_keep.index(tab.label)+2)
    else:
        tab.update(hidden=True)

for module in course.get_modules():
    module.delete()
module_1 = course.create_module({'name': 'Unit #1: Measuring Team Strength'})
module_1.edit(module={'published': True})
module_2 = course.create_module({'name': 'Unit #2: Estimating Player Talent'})
module_2.edit(module={'published': True})
module_3 = course.create_module({'name': 'Unit #3: Valuing Event Outcomes'})
module_3.edit(module={'published': True})
module_4 = course.create_module({'name': 'Project'})
module_4.edit(module={'published': True})


# Create quizzes ----

for assignment in course.get_assignments():
    assignment.delete()

group_practice = course.create_assignment_group(name='Practice')

for index, date in enumerate(practice_due):
    assignment = course.create_assignment({
        'name': f'Practice #{index+1}',
        'submission_types': ['online_upload'],
        'allowed_extensions': ['pdf'],
        'peer_reviews': True,
        'automatic_peer_reviews': True,
        'peer_review_count': 2,
        'points_possible': 5,
        'grading_type': 'pass_fail',
        'due_at': date,
        'assignment_group_id': group_practice.id,
        'published': True,
        'peer_review': {
            'grading_type': 'pass_fail',
            'due_at': date + timedelta(days=2),
        },
    })
    module_1.create_module_item(module_item = {'type': 'Assignment', 'content_id': assignment.id})


group_assignment = course.create_assignment_group(name='Assignment')
assignment_module = [module_1, module_2, module_3]

for index, date in enumerate(assignment_due):
    assignment = course.create_assignment({
        'name': f'Assignment #{index+1}',
        'submission_types': ['online_upload'],
        'allowed_extensions': ['pdf'],
        'points_possible': 10,
        'grading_type': 'percent',
        'due_at': date,
        'assignment_group_id': group_assignment.id,
        'published': True,
        'anonymous_grading': True,
    })
    assignment_module[index].create_module_item(module_item = {'type': 'Assignment', 'content_id': assignment.id})


group_project = course.create_assignment_group(name='Project')
project_points_possible = [0, 5, 10, 5, 20]
project_module = [module_2, module_3, module_3, module_4, module_4]

for index, date in enumerate(project_due):
    assignment = course.create_assignment({
        'name': f'Project #{index}',
        'submission_types': ['online_upload'],
        'allowed_extensions': ['pdf'],
        'points_possible': project_points_possible[index],
        'grading_type': 'percent',
        'due_at': date,
        'assignment_group_id': group_project.id,
        'published': True,
    })
    project_module[index].create_module_item(module_item = {'type': 'Assignment', 'content_id': assignment.id})


# Create exit tickets ----

for quiz in course.get_quizzes():
    quiz.delete()

class_days = []
current_date = day_first
while current_date <= day_last:
    if current_date.weekday() == 1 or current_date.weekday() == 3:  # Tuesday or Thursday
        class_days.append(current_date)
    current_date += timedelta(days=1)


get_to_know_you = course.create_quiz({
    'title': 'Help Me Get to Know You!',
    'description': 'The sole purpose of this ungraded quiz is to get to know you!',
    'quiz_type': 'survey',
    'unlock_at': class_days[0].replace(hour=15, minute=30),
    'due_at': class_days[0].replace(hour=16, minute=0),
    'lock_at': class_days[0].replace(hour=16, minute=0),
    'published': True,
})
get_to_know_you.create_question(question = {
    'question_text': 'What are your favorite sports and teams?',
    'question_type': 'essay_question',
})
get_to_know_you.create_question(question = {
    'question_text': "What are your current plans for after Rice? It's okay if you don't know!",
    'question_type': 'essay_question',
})
get_to_know_you.create_question(question = {
    'question_text': 'How much experience do you have using R?',
    'question_type': 'essay_question',
})
get_to_know_you.create_question(question = {
    'question_text': 'Would you like to share with me any challenges you anticipate for yourself that could make it harder for you to successfully complete this course?',
    'question_type': 'essay_question',
})
get_to_know_you.create_question(question = {
    'question_text': 'Is there anything else you would like me to know about you?',
    'question_type': 'essay_question',
})


for index, date in enumerate(course_eval_date):
    course_eval = course.create_quiz({
        'title': f'Early Course Eval #{index + 1}',
        'description': 'This is an anonymous survey. You responses will be used to improve the quality of instruction for the remainder of the course. Please provide your honest feedback.',
        'quiz_type': 'survey',
        'hide_results': 'always',                       # there are no correct answers
        'unlock_at': date.replace(hour=15, minute=30),
        'due_at': date.replace(hour=16, minute=0),
        'lock_at': date.replace(hour=16, minute=0),
        'published': True,
    })
    course_eval.create_question(question = {
        'question_text': '<p>To what extent do you agree with the following statement:</p><p>The <strong>lectures</strong> in this class have been valuable for my learning.</p>',
        'question_type': 'multiple_choice_question',
        'answers': [{'answer_text': 'Strongly disagree'}, {'answer_text': 'Disagree'}, {'answer_text': 'Neither agree nor disagree'}, {'answer_text': 'Agree'}, {'answer_text': 'Strongly agree'}],
    })
    course_eval.create_question(question = {
        'question_text': '<p>To what extent do you agree with the following statement:</p><p>The <strong>workshops</strong> in this class have been valuable for my learning.</p>',
        'question_type': 'multiple_choice_question',
        'answers': [{'answer_text': 'Strongly disagree'}, {'answer_text': 'Disagree'}, {'answer_text': 'Neither agree nor disagree'}, {'answer_text': 'Agree'}, {'answer_text': 'Strongly agree'}],
    })
    course_eval.create_question(question = {
        'question_text': '<p>To what extent do you agree with the following statement:</p><p>The <strong>review days</strong> in this class have been valuable for my learning.</p>',
        'question_type': 'multiple_choice_question',
        'answers': [{'answer_text': 'Strongly disagree'}, {'answer_text': 'Disagree'}, {'answer_text': 'Neither agree nor disagree'}, {'answer_text': 'Agree'}, {'answer_text': 'Strongly agree'}],
    })
    course_eval.create_question(question = {
        'question_text': '<p>To what extent do you agree with the following statement:</p><p>The <strong>quest speakers</strong> in this class have been valuable for my learning.</p>',
        'question_type': 'multiple_choice_question',
        'answers': [{'answer_text': 'Strongly disagree'}, {'answer_text': 'Disagree'}, {'answer_text': 'Neither agree nor disagree'}, {'answer_text': 'Agree'}, {'answer_text': 'Strongly agree'}],
    })
    course_eval.create_question(question = {
        'question_text': f'<p>To what extent do you agree with the following statement:</p><p><strong>Assignment #{index+1}</strong> was valuable for my learning.</p>',
        'question_type': 'multiple_choice_question',
        'answers': [{'answer_text': 'Strongly disagree'}, {'answer_text': 'Disagree'}, {'answer_text': 'Neither agree nor disagree'}, {'answer_text': 'Agree'}, {'answer_text': 'Strongly agree'}],
    })
    course_eval.create_question(question = {
        'question_text': f'<p>Approximately how many hours did you spend on <strong>Assignment #{index+1}</strong>?</p>',
        'question_type': 'numerical_question',
    })
    course_eval.create_question(question = {
        'question_text': 'What do you like about this class?',
        'question_type': 'essay_question',
    })
    course_eval.create_question(question = {
        'question_text': 'What do you dislike about this class? Or what could be improved?',
        'question_type': 'essay_question',
    })


group_exit_ticket = course.create_assignment_group(name='Exit Tickets')

remaining_days = [date for date in class_days if date not in days_off + [class_days[0]] + course_eval_date]

for date in remaining_days:
    exit_ticket = course.create_quiz({
        'title': 'Exit Ticket ' + date.strftime(format='%Y-%m-%d'),
        'quiz_type': 'graded_survey',
        'assignment_group_id': group_exit_ticket.id,
        'points_possible': 0.5,
        'anonymous_submissions': True,
        'hide_results': 'always',                       # there are no correct answers
        'access_code': random.randint(1000, 9999),
        'unlock_at': date.replace(hour=15, minute=30),
        'due_at': date.replace(hour=16, minute=0),
        'lock_at': date.replace(hour=16, minute=0),
        'published': True,
    })
    exit_ticket.create_question(question = {
        'question_text': 'On a scale from 1 (too confusing, slow down!) to 3 (just right) to 5 (too boring, speed up!), how was the pace of class today?',
        'question_type': 'multiple_choice_question',
        'answers': [{'answer_text': 1}, {'answer_text': 2}, {'answer_text': 3}, {'answer_text': 4}, {'answer_text': 5}]
    })
    exit_ticket.create_question(question = {
        'question_text': 'What remaining questions or confusions do you have about the material today?',
        'question_type': 'essay_question'
    })

# Set late policy ----

try:    # if the late policy has already been set, this will throw an exception
    course.create_late_policy(
        late_policy = {
            'missing_submission_deduction_enabled': True,
            'missing_submission_deduction': 100,
            'late_submission_deduction_enabled': True,
            'late_submission_deduction': 10,
            'late_submission_interval': 'day',
            'late_submission_minimum_percent_enabled': True,
            'late_submission_minimum_percent': 0,
        }
    )
except:
    print('the course already has a late policy')
