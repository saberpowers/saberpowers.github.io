
from canvasapi import Canvas
from datetime import datetime, timedelta
from dotenv import load_dotenv  # for saving variables from .env file as environment variables
import os                       # for getting envinronment variables
import random                   # for randomizing exit ticket access codes


# Load environment variables from .env file
load_dotenv()

# Initialize a new Canvas object
canvas = Canvas(os.getenv('API_URL'), os.getenv('API_KEY'))
course = canvas.get_course(os.getenv('SMGT_430'))
semester_start = datetime.strptime(os.getenv('SEMESTER_START'), '%Y-%m-%d')
semester_end = datetime.strptime(os.getenv('SEMESTER_END'), '%Y-%m-%d')
days_off = [datetime.strptime(x, '%Y-%m-%d') for x in os.getenv('DAYS_OFF').split(',')]


# Get class days ----

class_days = []
current_date = semester_start
while current_date <= semester_end:
    if current_date.weekday() == 1 or current_date.weekday() == 3:
        class_days.append(current_date)
    current_date += timedelta(days=1)

class_days = [date for date in class_days if date not in days_off]


# Create exit tickets ----

group_exit_ticket = course.create_assignment_group(name='Exit Tickets')

for date in class_days:
    exit_ticket = course.create_quiz({
        'title': 'Exit Ticket ' + date.strftime(format='%Y-%m-%d'),
        'quiz_type': 'graded_survey',
        'assignment_group_id': group_exit_ticket.id,
        'points_possible': 0.5,
        'anonymous_submissions': True,
        'hide_results': 'always',
        'access_code': random.randint(1000, 9999),
        'unlock_at': date.replace(hour=14, minute=0),
        'due_at': date.replace(hour=14, minute=15),
        'lock_at': date.replace(hour=14, minute=30)
    })
    exit_ticket.create_question(question = {
        'question_text': 'On a scale from 1 (very uninteresting) to 5 (very interesting), how interesting did you find the material today?',
        'question_type': 'multiple_choice_question',
        'answers': [{'answer_text': 1}, {'answer_text': 2}, {'answer_text': 3}, {'answer_text': 4}, {'answer_text': 5}]
    })
    exit_ticket.create_question(question = {
        'question_text': 'On a scale from 1 (very unclear) to 5 (very clear), how well do you feel you understood the material today?',
        'question_type': 'multiple_choice_question',
        'answers': [{'answer_text': 1}, {'answer_text': 2}, {'answer_text': 3}, {'answer_text': 4}, {'answer_text': 5}]
    })
    exit_ticket.create_question(question = {
        'question_text': 'What remaining questions or confusions do you have about the material today?',
        'question_type': 'essay_question'
    })


# Create modules ----

course.create_module({'name': 'Unit #1: Estimating Team and Player Strength'})
course.create_module({'name': 'Unit #2: Reducing Noise in Player Evaluation'})
course.create_module({'name': 'Unit #3: Applications of Markov Chains in Sports'})
course.create_module({'name': 'Unit #4: Practicum'})


# Create assignments ----

course.create_assignment({
    'name': 'Assignment #1: Bradley-Terry Model',
    'description': '<a href="https://saberpowers.github.io/teaching/smgt430/assignment/bradley_terry.pdf" target="_blank" rel="noopener">Prompt</a>',
    'due_at': datetime(2025, 9, 25, 12, 00),
    'submission_types': ['online_upload'],
    'allowed_extensions': ['pdf', 'r'],
    'points_possible': 15,
    'anonymous_grading': True,
})

course.create_assignment({
    'name': 'Assignment #2: Regression to the Mean',
    'description': '<a href="https://saberpowers.github.io/teaching/smgt430/assignment/regression_to_the_mean.pdf" target="_blank" rel="noopener">Prompt</a>',
    'due_at': datetime(2025, 10, 21, 12, 00),
    'submission_types': ['online_upload'],
    'allowed_extensions': ['pdf', 'r'],
    'points_possible': 15,
    'anonymous_grading': True,
})

course.create_assignment({
    'name': 'Assignment #3: Win Probability Model',
    'description': '<a href="https://saberpowers.github.io/teaching/smgt430/assignment/win_probability.pdf" target="_blank" rel="noopener">Prompt</a>',
    'due_at': datetime(2025, 11, 11, 12, 00),
    'submission_types': ['online_upload'],
    'allowed_extensions': ['pdf', 'r'],
    'points_possible': 15,
    'anonymous_grading': True,
})
