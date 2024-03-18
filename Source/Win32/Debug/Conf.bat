@echo off
"E:\Git\bin\sh.exe" --login -i -c "find . -name '.git' -type d | sed 's/\/.git//' | xargs -P10 -I{} git -C {} checkout --no-track tags/teste"
"E:\Git\bin\sh.exe" --login -i -c "find . -name '.git' -type d | sed 's/\/.git//' | xargs -P10 -I{} git -C {} checkout -b Branch_teste"