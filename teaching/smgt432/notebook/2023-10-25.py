# -*- coding: utf-8 -*-
"""pyday_2023-10-25.ipynb

Automatically generated by Colaboratory.

Original file is located at
    https://colab.research.google.com/drive/1dpA3Gt8eYvXnK0Rc8jxLWUgWMsqSHrR1

Today we're taclking the first half of the Tracking Data section from Devin Pleuler's [Soccer Analytics Handbook](https://github.com/devinpleuler/analytics-handbook/blob/master/soccer_analytics_handbook.ipynb).
"""

!pip install mplsoccer
!pip install kloppy

import numpy as np
import matplotlib.pyplot as plt
import mplsoccer as mpl
from kloppy import metrica

from kloppy import metrica

data = metrica.load_open_data(
    match_id=1,
    coordinates="metrica"
)

df = data.to_df()

df.head(5)

blue, red = (44,123,182), (215,25,28)
blue = [x/256 for x in blue]
red = [x/256 for x in red]

frame_rate = 25
length, width = 105, 68
adjust = np.array([length, width])

hj = list(set([x.split("_")[1] for x in df.columns if "home" in x]))

metrica_attrs = {
    "pitch_type": "metricasports",
    "pitch_length": 105,
    "pitch_width": 68,
    "line_color": "black",
    "linewidth": 1,
    "goal_type": "circle"
 }

start, stop = 2143, 2310 # Frame Range
pitch = mpl.Pitch(**metrica_attrs)
fig, ax = pitch.draw(figsize=(9,6))

for j in hj:
    path = df[['home_{}_x'.format(j), 'home_{}_y'.format(j)]].values[start:stop]
    pitch.plot(*path.T, lw=2, alpha=0.8, ax=ax)

path = df[['ball_x', 'ball_y']].values[start:stop]
pitch.plot(*path.T, lw=2, color='black', ax=ax)

# EXERCISE #1: Plot the player path for the home goal for the full game
# EXERCISE #2: Add the path of the ball to this visualization
# EXERCISE #3: Plot player paths for frames leading up to first goal of match