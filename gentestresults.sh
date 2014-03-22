#!/bin/bash

mkdir -p Myoutput

for file in `ls resources/LexerTestcases/FullTests/*.java | /c/cygwin/bin/grep -o -P 'testcase[^\.]+'`; do ruby ./bin/lexer.rb resources/LexerTestcases/FullTests/${file}.java > Myoutput/${file}.output; done

mkdir -p Results

for file in `ls resources/LexerTestcases/FullTests/*.java | /c/cygwin/bin/grep -o -P 'testcase[^\.]+'`; do diff Myoutput/${file}.output resources/LexerTestcases/ExpectedOutput/${file}.out > Results/${file}.diff ; done