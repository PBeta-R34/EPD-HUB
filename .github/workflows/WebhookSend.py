import requests
import json
import time
from os import environ

def main():
  if environ.get("GITHUB_ENV", None):
    Data = {
      "username": "EPD Documentation Update",
      "content": environ.get("PingTag"),
      "embeds": [
        {
          "title": "EPD Docs Was Deployed",
          "url": "https://pbeta-r34.github.io/EPD-Documentation/",
          "description": "Docs Site Deployed At " + time.strftime("%a, %d %b %Y %H:%M:%S", time.gmtime()),
          "color": 12912,
          "fields": [
            {
              "name": "Documentation Version:",
              "value": "V" + str(environ.get("GITHUB_RUN_NUMBER")),
            },
            {
              "name": "Commit Reason:",
              "value": environ.get("CommitMessage"),
            },
          ],

        }
      ]
    }
    Result = requests.post(environ.get("DiscordWebhookToken"), headers={"Content-Type":"application/json"}, data=json.dumps(Data))

main()