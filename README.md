# Sudoku Engine

Algorithm to solve & generate sudoku puzzles, with equivalent implementations in Crystal, C++, and TypeScript.  
_(or at least as similar as I could make them)_

## Background

I started this in early 2019 as a pet project for me to learn the [Crystal Language](https://crystal-lang.org/).  

Soon after getting an initial version working in Crystal, I wanted to test Crystal's claim: "As fast as C; as slick as Ruby", so I began implementing the same algorithm in C++ to test the performance of the equivalent engines built in C++ vs in Crystal.  So far, the one I built in C++ is actually _slower_. . .  Go Crystal!

I also wanted to spread the word about Crystal since I enjoyed working with the language so much, so I also wrote an equivalent implementation in TypeScript so that anyone who feels most comfortable in the world of JavaScript would be able to use this a fun way to get introduced to Crystal.  I chose TypeScript over JavaScript for the sake of similarity to Crystal, since Crystal is a statically typed language and its type annotations are often similar to those of TypeScript.

My C++ was pretty rusty when I got started with this and there are likely some best practices for good performance which I'm missing in the present C++ implementation, so maybe it would be able to match the timing of the Crystal implementation given all best practices.  But even if that's the case, it renewed my appreciation for the considerations that we do **not** have to worry about when writing in a language like Crystal rather than C/C++ (e.g. memory leaks).  My guess is that even the most experienced C++ developer could not make an implementation which is _significantly_ more performant than the equivalent implementation in Crystal.

