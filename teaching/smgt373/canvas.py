
# Before publishing course...
# 1. import "Experience Picture & Caption" assignment from last semester

COURSE_ID = 85376
DAY_FIRST = '2026-01-12'
DAY_MIDDLE = '2026-02-27'
DAY_LAST = '2026-04-24'

from canvasapi import Canvas
from datetime import datetime, timedelta
from dotenv import load_dotenv  # for saving variables from .env file as environment variables
import os                       # for getting envinronment variables
import pandas as pd             # for date_range


# Load environment variables from .env file
load_dotenv()

# Initialize a new Canvas object
canvas = Canvas(os.getenv('API_URL'), os.getenv('API_KEY'))
course = canvas.get_course(COURSE_ID)
day_first = datetime.strptime(DAY_FIRST, '%Y-%m-%d')
day_middle = datetime.strptime(DAY_MIDDLE, '%Y-%m-%d')
day_last = datetime.strptime(DAY_LAST, '%Y-%m-%d')


# Re-organize home page and tabs ----

course.update(
    course = {
        'default_view': 'syllabus',
        'syllabus_body': '<p><a href="https://saberpowers.github.io/teaching/smgt373/syllabus.pdf" target="_blank" rel="noopener">Syllabus</a></p>',
    }
)

tabs_to_keep = ['Announcements', 'Syllabus', 'Assignments', 'Grades']
all_tabs = course.get_tabs()

for tab in all_tabs:
    if tab.label in ['Home', 'Settings']:
        continue                    # these tabes are not manageable
    if tab.label in tabs_to_keep:
        tab.update(hidden=False, position=tabs_to_keep.index(tab.label)+2)
    else:
        tab.update(hidden=True)


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


# Create hour log assignments ----

group_hour_log = course.create_assignment_group(name = 'Hour Logs')

for i in range(5):
    hour_log_end = day_last - timedelta(weeks=3*(4-i))
    hour_log_start = max(hour_log_end - timedelta(weeks=3) + timedelta(days=1), day_first)
    hour_log_dates = pd.date_range(hour_log_start, hour_log_end)
    template = "".join([d.strftime("%Y-%m-%d: XX hours<br>") for d in hour_log_dates])
    course.create_assignment({
        'name': f'Hour Log #{i+1}',
        'submission_types': ['online_text_entry'],
        'points_possible': 30,
        'grading_type': 'points',
        'unlock_at': hour_log_end - timedelta(days=10),
        'due_at': hour_log_end,
        'lock_at': hour_log_end + timedelta(days=10),
        'assignment_group_id': group_hour_log.id,
        'description': f'Please copy and paste the template below and then edit it to report your hours between {hour_log_start:%A, %B %-d}, and {hour_log_end:%A, %B %-d}. Please delete any lines corresponding to dates on which you did not work.<br><br>Total: XX hours<br>Credit Hours: X    (how many credit hours did you enroll?)<br>Score: XX              (Total divided by Credit Hours)<br><br>{template}',
        'published': True,
    })


# Create performance evaluation assignments ----

group_perf_eval = course.create_assignment_group(name = 'Performance Evaluations')

due_at = day_middle - timedelta(weeks=1)
deadline = day_middle + timedelta(weeks=1)
course.create_assignment({
    'name': 'Midterm Performance Evaluation',
    'submission_types': ['none'],
    'points_possible': 75,
    'grading_type': 'percent',
    'due_at': due_at,
    'assignment_group_id': group_perf_eval.id,
    'description': f"Send an email to your internship supervisor with the course instructor CC'd. In the email, please link to <a href='https://saberpowers.github.io/teaching/smgt373' target='_blank' rel='noopener'>https://saberpowers.github.io/teaching/smgt373</a> and ask your supervisor to find the Supervisor Evaluation Form available on that page and complete it by {deadline:%A, %B %-d}.",
    'published': True,
})

due_at = day_last - timedelta(weeks=1)
deadline = day_last + timedelta(weeks=1)
course.create_assignment({
    'name': 'Final Performance Evaluation',
    'submission_types': ['none'],
    'points_possible': 75,
    'grading_type': 'percent',
    'due_at': due_at,
    'assignment_group_id': group_perf_eval.id,
    'description': f"Send an email to your internship supervisor with the course instructor CC'd. In the email, please link to <a href='https://saberpowers.github.io/teaching/smgt373' target='_blank' rel='noopener'>https://saberpowers.github.io/teaching/smgt373</a> and ask your supervisor to find the Supervisor Evaluation Form available on that page and complete it by {deadline:%A, %B %-d}.",
    'published': True,
})


# Delete the original Assignment group ----

for group in course.get_assignment_groups():
    if group.name == 'Assignments':
        group.delete()

