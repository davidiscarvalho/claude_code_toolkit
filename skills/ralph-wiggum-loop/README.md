# Ralph Wiggum Loop

From https://www.youtube.com/@Chase-H-AI video https://www.youtube.com/watch?v=yAE3ONleUas:

"In this video, I break down what a Ralph Loop is, why the Claude Code Ralph Loop plugin misses the mark, and how to create your own Ralph loops inside of Claude Code.
Attached is the ralph.ps1 (for windows powershell), ralph.sh (for everyone else), and the PRD skill file (give it to claude code and tell it to make a PRD skill for you)"


In this folder, there is the Ralph Wiggum loop script, which does not block the Claude code session exit (using the stop hook), but it starts a new session with a blank context
