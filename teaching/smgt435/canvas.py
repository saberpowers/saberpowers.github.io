
# Before publishing course...
# 1. update grade posting policy to manual (under "Grades" -> {gear icon})
# 2. publish all quizzes

COURSE_ID = 92941
DAY_FIRST = '2026-08-24'    # first Monday of classes
DAY_LAST = '2026-12-04'     # final Friday of classes
DAYS_OFF = [
    '2026-09-24',
    '2026-10-13',
    '2026-10-15',
    '2026-11-25',
]

COURSE_EVAL_DATE = ['2026-09-10', '2026-10-08', '2026-11-05']
ASSIGNMENT_DUE = ['2026-09-17', '2026-10-15', '2026-11-12']
PROJECT_DUE = ['2026-10-08', '2026-11-05', '2026-11-19', '2026-12-01', '2026-12-14']

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
assignment_due = [datetime.strptime(x, '%Y-%m-%d') for x in ASSIGNMENT_DUE]
project_due = [datetime.strptime(x, '%Y-%m-%d') for x in PROJECT_DUE]


# Re-organize home page and tabs ----

canvas.set_course_nickname(COURSE_ID, 'Baseball Analytics')

course.update(
    course = {
        'image_url': 'https://github.com/saberpowers/saberpowers.github.io/blob/main/teaching/smgt435/image.jpg?raw=true',
        'default_view': 'modules',
        'syllabus_body': '<a href="https://saberpowers.com/teaching/smgt435/syllabus/latest.pdf" target="_blank" rel="noopener">Syllabus</a>',
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
module_1 = course.create_module({'name': 'Unit #1: Measuring Batting Performance'})
module_1.edit(module={'published': True})
module_2 = course.create_module({'name': 'Unit #2: Measuring Pitching Performance'})
module_2.edit(module={'published': True})
module_3 = course.create_module({'name': 'Unit #3: Advanced Topics'})
module_3.edit(module={'published': True})
module_4 = course.create_module({'name': 'Project'})
module_4.edit(module={'published': True})


# Create quizzes ----

for assignment in course.get_assignments():
    assignment.delete()

for assignment_group in course.get_assignment_groups():
    assignment_group.delete()

group_assignment = course.create_assignment_group(name='Assignment')
assignment_module = [module_1, module_2, module_3]
assignment_file = [
    'batter_outcomes',
    'pitch_outcome_model',
    'projections',
]
assignment_name = [
    'Signal v. Noise in Batter Outcomes',
    'Pitch Outcome Model',
    'Projections',
]

for index, date in enumerate(assignment_due):
    assignment = course.create_assignment({
        'name': f'Assignment #{index+1}: {assignment_name[index]}',
        'submission_types': ['online_upload'],
        'allowed_extensions': ['pdf'],
        'points_possible': 15,
        'grading_type': 'percent',
        'due_at': date,
        'description': f'<a href="https://saberpowers.com/teaching/smgt435/assignment/{assignment_file[index]}.pdf" target="_blank">Prompt</a>',
        'assignment_group_id': group_assignment.id,
        'published': True,
        'anonymous_grading': True,
    })
    assignment_module[index].create_module_item(module_item = {'type': 'Assignment', 'content_id': assignment.id})

group_project = course.create_assignment_group(name='Project')
project_points_possible = [0, 5, 10, 10, 20]
project_name = ['Registration', 'Proposal', 'Abstract', 'Presentation', 'Paper']
project_module = [module_2, module_3, module_4, module_4, module_4]

for index, date in enumerate(project_due):
    assignment = course.create_assignment({
        'name': f'Project #{index}: {project_name[index]}',
        'submission_types': ['online_upload'],
        'allowed_extensions': ['pdf'],
        'points_possible': project_points_possible[index],
        'grading_type': 'percent',
        'due_at': date,
        'description': f'<a href="https://saberpowers.com/teaching/smgt435/assignment/project.pdf" target="_blank">Prompt</a>',
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

for index, date in enumerate(course_eval_date):
    course_eval = course.create_quiz({
        'title': f'Early Course Eval #{index + 1}',
        'description': 'This is an anonymous survey. You responses will be used to improve the quality of instruction for the remainder of the course. Please provide your honest feedback.',
        'quiz_type': 'survey',
        'hide_results': 'always',                       # there are no correct answers
        'unlock_at': date.replace(hour=14, minute=0),
        'due_at': date.replace(hour=14, minute=30),
        'lock_at': date.replace(hour=14, minute=30),
        'published': False,
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

remaining_days = [date for date in class_days if date not in days_off + course_eval_date]

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
        'published': False,
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


# Add content to modules ----

for page in course.get_pages():
    page.delete()

topic_name = [
    'Pythagorean Formula',
    'Base-Out Run Expectancy and Linear Weights',
    'Batted Ball Outcome Model',
    'BABIP, FIP and DIPS',
    'Introduction to Pitch-Level Analysis',
    'Pitch Outcome Modeling',
    '"Stuff"',
    'Fielding and Baserunning',
    'Projections'
]
topic_lecture = [
    'pythagorean_formula',
    'run_expectancy',
    'batted_ball_outcome_model',
    '',
    'pitch_level_analysis',
    'pitch_outcome_modeling',
    'stuff',
    'fielding_baserunning',
    'projections'
]
topic_tutorial = [
    '1iBKnJEVVIAOls98L7O2gDlZJyTD2GLDF',
    '1ssbGKZM41kLR76-iLukm64DaSRpzrkwD',
    '1DdBF-D_Pl3fzg0xgsEGtKBTPVj-9pV9g',
    '1cd-KnI2VcNlG6fgDPQQi41Id_ZxCVyRT',
    '1oR82uQxRAETizWOkJJFkt2M2EUyr2nH-',
    '1zcZqQ1Vc-ilIieTaNdHFMV0njffBRzBm',
    '1X67kiqAVAFImx3VIxFH-1MvJ6TSQ83KC',
    '1tyAWCmhTgQi7AC8hIXYF7NOsoqxTKoTY',
    '1xQSwzqo8McwjJDa1VBdV7Ri8GjrFAGtA'
]
topic_solution = [
    '1AIaBKoAca8ei0-SMtdeKSr-Na1qLGdpZ',
    '1T5ozdYnGBnOtXRFJX-wS9DWDWlPAEAHf',
    '1yK_JIl_YHb-KryhqdsdVhFldxGUu4E-0',
    '1iVvxNqVuVCfMM8ZRBy5OE1ubc4TmYyZn',
    '1_I-K5JI9ky1Z7qQ0E0DBVPe1jMH3Did_',
    '1RrjCp52lkAl-4bmZ1gV09I9WWoUPNml1',
    '1leCmnIxwGnWInmy4ZwA6tcF3QVD6AVRB',
    '15RLvIXi9tEC8SAboPWpaOcoBFVF7R-li',
    '1kpMxDnAS_gJBXxX1BcVBq_-lC29V9GST'
]
topic_module = [0, 0, 0, 1, 1, 1, 2, 2, 2]

prefix_lecture = 'https://saberpowers.com/teaching/smgt435/lecture/'
prefix_notebook = 'https://colab.research.google.com/drive/'

for i in range(len(topic_name)):
    page = course.create_page(
        {
            'title': topic_name[i],
            'body': f"""
                <p><a href="{prefix_lecture}{topic_lecture[i]}.pdf" target="_blank">Lecture Notes</a></p>
                <p><a href="{prefix_notebook}{topic_tutorial[i]}" target="_blank">R Tutorial</a></p>
                <p><a href="{prefix_notebook}{topic_solution[i]}" target="_blank">R Tutorial Solutions</a></p>
            """,
            'published': True
        }
    )
    course.get_modules()[topic_module[i]].create_module_item(
        module_item = {'type': 'Page', 'page_url': page.url}
    )


module_1.create_module_item(
    module_item={
        'title': 'Pythagorean Formula Lecture Notes',
        'type': 'ExternalUrl',
        'external_url': 'https://saberpowers.com/teaching/smgt435/lecture/pythagorean_formula.pdf',
        'new_tab': True,
        'published': True
    }
)
