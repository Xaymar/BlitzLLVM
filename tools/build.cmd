@echo off
rem Builds BlitzLLVM the way CI does: tools\build.cmd [options], see tools\build.cmake (or tools\build.cmd --help).
cmake -P "%~dp0build.cmake" -- %*
