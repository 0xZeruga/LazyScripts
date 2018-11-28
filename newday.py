import webbrowser
from subprocess import call

print("Open lazy stuff...")
webbrowser.open('http://greatday.com/nmot/random_message.html')
webbrowser.open('http://taiga.io')
webbrowser.open('http://slack.com')
webbrowser.open('http://github.com')
print("Done open lazy stuff")

print("Rebasing...")
call(["git","pull","--rebase"])
print("Rebase complete!")

raw_input()
