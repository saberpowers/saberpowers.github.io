
# Before publishing course...
# 1. Manually publish the quiz

COURSE_ID = 92902
DAY_FIRST = '2026-08-24'    # the Monday of Week 1
DAY_MIDDLE = '2026-10-12'   # the Monday of Week 8
DAY_LAST = '2026-12-04'     # the Friday of Week 15

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

canvas.set_course_nickname(COURSE_ID, 'Sport Analytics Internship')

course.update(
    course = {
        'default_view': 'syllabus',
        'syllabus_body': '<p><a href="https://saberpowers.com/teaching/smgt373/syllabus.pdf" target="_blank" rel="noopener">Syllabus</a></p>',
    }
)

tabs_to_keep = ['Announcements', 'Syllabus', 'Assignments', 'Grades', 'Quizzes']
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


# Flush existing assignments ----

for assignment in course.get_assignments():
    assignment.delete()

for assignment_group in course.get_assignment_groups():
    assignment_group.delete()


# Create hour log assignments ----

group_hour_log = course.create_assignment_group(name = 'Hour Logs')
hour_log_assignments = []

for i in range(5):
    hour_log_end = day_last - timedelta(weeks=3*(4-i))
    hour_log_start = max(hour_log_end - timedelta(weeks=3) + timedelta(days=1), day_first)
    hour_log_dates = pd.date_range(hour_log_start, hour_log_end)
    template = ''.join([d.strftime('%Y-%m-%d: XX hours<br>') for d in hour_log_dates])
    assignment = course.create_assignment({
        'name': f'Hour Log #{i+1}',
        'submission_types': ['online_text_entry'],
        'points_possible': 10,
        'grading_type': 'points',
        'unlock_at': hour_log_end - timedelta(days=7),
        'due_at': hour_log_end + timedelta(days=3),         # hour log is due Monday after end date
        'lock_at': hour_log_end + timedelta(days=13),
        'assignment_group_id': group_hour_log.id,
        'description': f'Please copy and paste the template below and then edit it to report your hours between {hour_log_start:%A, %B %-d}, and {hour_log_end:%A, %B %-d}. Please delete any lines corresponding to dates on which you did not work.<br><br>Credit Hours: X              = how many credit hours you enrolled<br>Hours This Log: XX<br>Hours to Date: XX<br>Remaining Hours: XX    = (50 * Credit Hours) minus Hours to Date<br><br>Score: XX                        = Hours This Log divided by Credit Hours, rounded to nearest 0.01<br><br>You may not earn credit for more than 10 hours in one day.<br><br>{template}',
        'published': True,
    })
    hour_log_assignments.append(assignment)


# Create performance evaluation assignments ----

group_perf_eval = course.create_assignment_group(name = 'Performance Evaluations')

due_at = day_middle
deadline = due_at + timedelta(weeks=1)      # supervisor deadline is one week after due date
midterm = course.create_assignment({
    'name': 'Midterm Performance Evaluation',
    'submission_types': ['none'],
    'points_possible': 25,
    'grading_type': 'percent',
    'due_at': due_at,
    'assignment_group_id': group_perf_eval.id,
    'description': f"<p>Send an email to your internship supervisor with the course instructor CC'd. In the email, please link to <a href='https://saberpowers.com/teaching/smgt373' target='_blank' rel='noopener'>saberpowers.com/teaching/smgt373</a> and ask your supervisor to find the Supervisor Evaluation Form available on that page and complete it by {deadline:%A, %B %-d}. In the email, please attach your job description to remind your supervisor of the responsibilities on which they are to evaluate you.</p><p>To be clear, {due_at:%B %-d} is your deadline for sending this email to your supervisor, and {deadline:%B %-d} is the date by which we want your supervisor to complete the evaluation.</p>",
    'published': True,
})

# Set a reminder
course.create_discussion_topic(
    title = 'Reminder: Midterm Performance Evaluation',
    message = f'As a reminder, your deadline is {due_at:%A, %B %-d}, to email your internship supervisor requesting that they complete the Midterm Performance Evaluation for your internship. For details, see the <a href="/courses/{COURSE_ID}/assignments/{midterm.id}" data-course-type="assignments" data-published="true">Midterm Performance Evaluation</a> assignment.',
    is_announcement = True,
    delayed_post_at = due_at - timedelta(days=3) + timedelta(hours=9),  # 3 days before due @ 9am
    published = True,
)


due_at = day_last - timedelta(days=4)           # email is due Monday of Week 15
deadline = due_at + timedelta(weeks=1)          # supervisor deadline is one week after due date
final = course.create_assignment({
    'name': 'Final Performance Evaluation',
    'submission_types': ['none'],
    'points_possible': 25,
    'grading_type': 'percent',
    'due_at': due_at,
    'assignment_group_id': group_perf_eval.id,
    'description': f"<p>Send an email to your internship supervisor with the course instructor CC'd. In the email, please link to <a href='https://saberpowers.com/teaching/smgt373' target='_blank' rel='noopener'>saberpowers.com/teaching/smgt373</a> and ask your supervisor to find the Supervisor Evaluation Form available on that page and complete it by {deadline:%A, %B %-d}. In the email, please attach your job description to remind your supervisor of the responsibilities on which they are to evaluate you.</p><p>To be clear, {due_at:%B %-d} is your deadline for sending this email to your supervisor, and {deadline:%B %-d} is the date by which we want your supervisor to complete the evaluation.</p>",
    'published': True,
})

# Set a reminder
course.create_discussion_topic(
    title = 'Reminder: Final Performance Evaluation',
    message = f'As a reminder, your deadline is {due_at:%A, %B %-d}, to email your internship supervisor requesting that they complete the Final Performance Evaluation for your internship. For details, see the <a href="/courses/{COURSE_ID}/assignments/{final.id}" data-course-type="assignments" data-published="true">Final Performance Evaluation</a> assignment.',
    is_announcement = True,
    delayed_post_at = due_at - timedelta(days=3) + timedelta(hours=9),  # 3 days before due @ 9am
    published = True,
)


# Create Experience Picture & Caption assignment ----

group_picture_caption = course.create_assignment_group(name = 'Experience Picture & Caption')

course.create_assignment({
    'name': 'Experience Picture & Caption',
    'submission_types': ['online_text_entry', 'online_upload'],
    'allowed_extensions': ['jpg', 'png'],
    'points_possible': 5,
    'grading_type': 'pass_fail',
    'due_at': midterm.due_at,   # make this due alongside the midterm performance evaluation email
    'assignment_group_id': group_picture_caption.id,
    'description': f"<p>First, upload a vertical picture (jpg or png) of yourself with the internship organization logo somewhere in the picture. We will not accept selfies.</p><p>Second, submit at least two on-the-job/action pictures (jpg or png) depicting you doing the work. In the text entry box, include a brief captions describing the what you're doing in the pictures.</p><p>Third, write a blurb in the text entry box about your internship experience. Include your full name, graduation year, internship organization, and internship job title. Share a brief overview of your internship role or a key project on which you&rsquo;ve worked, and address the following questions:</p><p>What has been the most memorable or enjoyable part of your internship experience? What is the most valuable lesson or takeaway you&rsquo;ve gained during this internship? In what ways has this internship helped you move closer to your career goals? How did the Department support you in preparing for or securing this internship?</p><p>Include relevant hashtags to the organization and social media handles (personal &amp; organization) if you wish to be tagged.</p><p>The goal of this assignment is to showcase our students and the incredible industry experiences in which they are engaged. By completing it, you will be featured on our social media platforms and website. If you do not want your pictures uploaded on Rice Sport Management social media accounts, please indicate this in assignment submission with a brief explanation. In that case, the pictures will not be featured on our social media, but you still need to complete the assignment.</p><p>If you have an event after the assignment deadline or have questions on the assignment, please email Kerri Barber.</p><p>Examples: <a href='https://www.instagram.com/p/DNEQX-Gvau3/' target='_blank' rel='noopener'>Andersen Pickard '27</a></p>",
    'published': True
})


# Create survey to collect basic internship information ----

for quiz in course.get_quizzes():
    quiz.delete()

registration = course.create_quiz({
    'title': 'Registration',
    'description': 'Please complete this survey so we can add you to <a href="http://sport.rice.edu/internships" target="_blank" rel="noopener">sport.rice.edu/internships</a>.',
    'quiz_type': 'survey',
    'due_at': hour_log_assignments[0].due_at,
    'published': False,
})
registration.create_question(question = {
    'question_text': "What is your name and graduation year (e.g. Scott Powers '11)?",
    'question_type': 'short_answer_question',
})
registration.create_question(question = {
    'question_text': 'What is your internship organization?',
    'question_type': 'short_answer_question',
})
registration.create_question(question = {
    'question_text': 'What is your internship job title?',
    'question_type': 'short_answer_question',
})
registration.create_question(question = {
    'question_text': 'Please upload your Job Description as a PDF file.',
    'question_type': 'file_upload_question',
})


# Delete the original Assignment group ----

for group in course.get_assignment_groups():
    if group.name == 'Assignments':
        group.delete()

