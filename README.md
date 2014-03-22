mini_java_compiler
==================

Our MiniJava Compiler for CSSE404 Spring 2014

`ruby -r ./lib/lexer.rb -e "p Lexer.new(File.new('./resources/lexer_test_cases/reserved_words.input')).get_tokens"`

run in zsh:
```zsh
for file in `ls resources/LexerTestcases/FullTests/*.java | grep -o 'testcase[^\.]\+'`
ruby ./bin/lexer.rb resources/LexerTestcases/FullTests/$file.java
```
