Word-Scramble-iOS-Swift-UI

![Simulator Screen Shot - iPhone 13 Pro Max - 2022-03-03 at 07 27 25](https://user-images.githubusercontent.com/63089587/156468281-4029bda2-87ec-4f92-8f98-227e8a17e985.png)
![Simulator Screen Shot - iPhone 13 Pro Max - 2022-03-03 at 07 28 59](https://user-images.githubusercontent.com/63089587/156468280-fb712679-6653-4fdb-a7bd-dd8b58fb95b3.png)

![Simulator Screen Shot - iPhone 13 Pro Max - 2022-03-03 at 07 29 59](https://user-images.githubusercontent.com/63089587/156468267-294d3cd9-5510-40dc-abf3-1eb4ed46dc49.png)
![Simulator Screen Shot - iPhone 13 Pro Max - 2022-03-03 at 07 29 46](https://user-images.githubusercontent.com/63089587/156468274-fc7b19ad-078c-4135-a7df-c5acf1e40901.png)
![Simulator Screen Shot - iPhone 13 Pro Max - 2022-03-03 at 07 29 21](https://user-images.githubusercontent.com/63089587/156468276-9d84aafd-a7cf-4a70-a23e-ec506303c7b1.png)
![Simulator Screen Shot - iPhone 13 Pro Max - 2022-03-03 at 07 29 12](https://user-images.githubusercontent.com/63089587/156468278-4d4b6946-e570-4632-b8b8-b634e2767508.png)

Word Scramble is an iOS, Swift UI project with these implementaions:

- Loading assets into a project
- Parsing data from a text file/list into an array
- Keyboard input
- Removing AutoCapitalisation
- Removing AutoCorrect
- Autofocusing the input field
- Implementing game logic and rules
- Handling errors and communicating back to the user
- Building a List View from user generated words
- UI Toolbar Group
- Custom alerts to alert rule breaking

The aim of the game is to build as many of your own words as possible using the letters from a root word.

The rules are:
- You can only use the letters that are in the root word.
- You can only use each letter once.
- You cannot use more letters than there are.
- Your words need to be real English words, spelled correctly.
- Your words needs a minimum length of 3 characters.
- You cannot enter the same word twice.
- You cannot enter the root challenge word itself.

I created my own extension to this project that implements additional features:

- Calculate all possible words from all possible permutations of the root letters.
- Communicate to the user the total "word space" of how many new words are possible to create.
- Update how many have been discovered out of the total word space.
- Additional scrabble dictionary list asset for checking all possible words.
- An improved scoring system that scales rewards based on word length.

I also learned:

- The advantages of using Set<> over Array<> for it's Big O(1) access speed.
