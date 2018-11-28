from subprocess import call

call(["git","add","-A"])
text = raw_input("Insert your commit message & press enter\n")
print("Committing " + str(text) + " ...")
call(["git","commit","-m",str(text)])
print("Checkout dev...")
call(["git","checkout","master"])
print("Branch checked out")
print("Rebasing...")
call(["git","pull","--rebase"])
print("Rebase complete!")
print("Pushing...")
call(["git","push", "origin", "master"])
print("Push complete!")

raw_input()
