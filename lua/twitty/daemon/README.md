twitty service
==============

Python service for twitty module: gets HTTP requests and publishes it to the specified MQTT topic.
Additionaly profanity filter with custom dictionary performed.

Dictionary
----------

How to prepare base64 encoded custom dictionary file:
```bash
base64 -d stopwords_en_base64.txt > stopwords_en.txt
base64 stopwords_en.txt > stopwords_en_base64.txt
```