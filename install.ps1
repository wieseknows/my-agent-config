$g = "$env:USERPROFILE\.gemini"
New-Item -ItemType Directory -Force "$g\config\skills","$g\config\agents" | Out-Null
Copy-Item .\GEMINI.md "$g\GEMINI.md" -Force
Copy-Item .\skills\*  "$g\config\skills\" -Recurse -Force
Copy-Item .\agents\*  "$g\config\agents\" -Force
# rules/ и workflows/ копируй в <проект>\.agents\ (или положи в репозиторий проекта)