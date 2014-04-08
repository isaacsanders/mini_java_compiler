#!/bin/bash

mkdir -p ParserOutput

for file in `ls resources/ParserTestcases/FullTests/*.java | /c/cygwin/bin/grep -o -P 'testcase[^\.]+'`; do ruby ./bin/lexer.rb resources/ParserTestcases/FullTests/${file}.java > ParserOutput/${file}.output; done

mkdir -p ParserResults

for file in `ls resources/ParserTestcases/FullTests/*.java | /c/cygwin/bin/grep -o -P 'testcase[^\.]+'`; do diff ParserOutput/${file}.output resources/ParserTestcases/ExpectedOutput/${file}.out > ParserResults/${file}.diff ; done