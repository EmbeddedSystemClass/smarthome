#!/usr/bin/python
# -*- coding: utf-8 -*-

from gtts import gTTS
import os

pasha = gTTS(text='Здравствуй, Паша', lang='ru')
alina = gTTS(text='Здравствуй, Алина', lang='ru')
weather = gTTS(text='Сегодня пасмурно, дождь, температура +18, ветер 5 м/с. Возьмите зонтик!', lang='ru')

weather.save("weather.mp3")
pasha.save("pasha.mp3")
alina.save("alina.mp3")
#os.system("mpg321 weather.mp3")
os.system("mpg321 pasha.mp3")
os.system("mpg321 alina.mp3")
