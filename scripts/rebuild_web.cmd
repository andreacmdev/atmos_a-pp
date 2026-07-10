@echo off
if exist build\web rmdir /s /q build\web
flutter build web --web-renderer canvaskit
