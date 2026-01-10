
COURSE_ID = 87603
DAY_FIRST = '2026-01-12'
DAY_LAST = '2026-04-24'
DAYS_OFF = [
    '2026-01-19',
    '2026-02-16'
]

from canvasapi import Canvas
from datetime import datetime, timedelta
from dotenv import load_dotenv  # for saving variables from .env file as environment variables
import os                       # for getting envinronment variables
import pandas as pd             # for date_range
import random                   # for randomizing exit ticket access codes

# Load environment variables from .env file
load_dotenv()

# Initialize a new Canvas object
canvas = Canvas(os.getenv('API_URL'), os.getenv('API_KEY'))
course = canvas.get_course(COURSE_ID)
day_first = datetime.strptime(DAY_FIRST, '%Y-%m-%d')
day_last = datetime.strptime(DAY_LAST, '%Y-%m-%d')
days_off = [datetime.strptime(day, '%Y-%m-%d') for day in DAYS_OFF]


# Re-organize home page and tabs ----

canvas.set_course_nickname(COURSE_ID, 'Sport Analytics Reading Group')

course.update(
    course = {
        'friendly_name': 'Sport Analytics Reading Group',
        'image_url': 'https://github.com/saberpowers/saberpowers.github.io/blob/main/teaching/stat699/image.jpg?raw=true',
        'default_view': 'syllabus',
        'syllabus_body': '<p><a href="https://saberpowers.github.io/teaching/stat699/syllabus/latest.pdf" target="_blank" rel="noopener">Syllabus</a></p><p><a href="https://docs.google.com/spreadsheets/d/1oeNds81sxkB3HfrLI6KXsO1SHMR2t04G5peNt4luvTU" target="_blank" rel="noopener">Schedule</a></p><p><a href="https://docs.google.com/spreadsheets/d/1ZhIMaT7YYFcWenDv8ocXihceKlIbCIU7jEX_h9aLWyo" target="_blank" rel="noopener">Candidate Papers</a></p>',
    }
)

tabs_to_keep = ['Announcements', 'Syllabus', 'Assignments', 'Quizzes', 'Grades']
all_tabs = course.get_tabs()

for tab in all_tabs:
    if tab.label in ['Home', 'Settings']:
        continue                    # these tabes are not manageable
    if tab.label in tabs_to_keep:
        tab.update(hidden=False, position=tabs_to_keep.index(tab.label)+2)
    else:
        tab.update(hidden=True)


# Create assignments ----

with open('teaching/stat699/assignments/select_your_paper.html', 'r', encoding='utf-8') as file:
    description = file.read()
course.create_assignment({
    'name': 'Select Your Paper',
    'submission_types': ['online_url'],
    'points_possible': 0,
    'grading_type': 'pass_fail',
    'description': description,
    'published': True,
})

with open('teaching/stat699/assignments/present_your_paper.html', 'r', encoding='utf-8') as file:
    description = file.read()
course.create_assignment({
    'name': 'Present Your Paper',
    'submission_types': ['online_upload'],
    'allowed_extensions': ['jpg'],
    'points_possible': 10,
    'grading_type': 'pass_fail',
    'description': description,
    'published': True,
})


# Get class days ----

class_days = []
current_date = day_first
while current_date <= day_last:
    class_days.append(current_date)
    current_date += timedelta(weeks=1)

class_days = [date for date in class_days if date not in days_off]


# Create exit tickets ----

group_exit_ticket = course.create_assignment_group(name='Exit Tickets')

for date in [d for d in class_days if d != day_first]:      # no exit ticket on first day of class
    exit_ticket = course.create_quiz({
        'title': 'Exit Ticket ' + date.strftime(format='%Y-%m-%d'),
        'quiz_type': 'graded_survey',
        'assignment_group_id': group_exit_ticket.id,
        'points_possible': 1,
        'anonymous_submissions': True,
        'hide_results': 'always',                       # there are no correct answers
        'access_code': random.randint(1000, 9999),
        'unlock_at': date.replace(hour=15, minute=40),
        'due_at': date.replace(hour=15, minute=50),
        'lock_at': date.replace(hour=16, minute=00),
        'published': True,
    })
    exit_ticket.create_question(question = {
        'question_text': 'Please rate the paper presented today on a scale from 1 star to 5 stars.<br><br><em>Note: This rating is intended to reflect the paper, NOT the presentation.</em><br><br><strong>5 stars:</strong> This was a brilliant paper that inspired me or taught me something valuable.<br><strong>4 stars</strong>: This was an impressive paper with a good research question and solid methods.<br><strong>3 stars</strong>: This paper was okay but not high impact.<br><strong>2 stars:</strong> This was an unimpressive paper with methods insufficient for impactful research.<br><strong>1 star:</strong> This paper was terrible, with glaring mistakes made by the author(s).',
        'question_type': 'multiple_choice_question',
        'answers': [{'answer_text': 5}, {'answer_text': 4}, {'answer_text': 3}, {'answer_text': 2}, {'answer_text': 1}]
    })
    exit_ticket.create_question(question = {
        'question_text': 'Please explain the reasoning for your rating.',
        'question_type': 'essay_question'
    })

