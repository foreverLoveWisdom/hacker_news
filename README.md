* Ruby version: 2.5.3
* Rails version: 5.2.4.4
* External API: 
  *  [URL Meta](https://urlmeta.org/): Faster response time comparing with queries directly to original links for getting images and excerpts(**4x faster**: *13* seconds vs *61* seconds)

* Implemented features:
  - [x] Parse https://news.ycombinator.com/best to pull down the latest best news.
  - [x] Display the items in a custom layout that is more visual but still readable:
    * [Image]
    * [Title]
    * [article excerpt...]
  - [x] Clicking on an article will show a page with the simplified, readability version of the article:
    * Just the text, images
    * The content should be formatted for ease of reading, clean and nice
  - [x] Deploy to Heroku or make it publically accessible for review purposes
    * [Heroku Link](https://hackernews-custom.herokuapp.com/) 
  - [x] Code to check to Github

* Requirements:
  - [x] All pages should be responsive
  - [ ] Focus on design and typography
  - [ ] Full test suite
    - [x] Unit testings
    - [ ] Integration testings
  - [x] No DB needed, but you'll need to think about performance, caching, etc.

* Gems to use:
  - [x] Nokogiri
  - [x] Readability

* Bonus:
  - [x] Fully responsive for mobile view
  - [ ] Use ajax to pull the content of the page
  - [ ] Use HTML5 pushstate to manage the history
  - [ ] Implement CI integration
  - [ ] Impress us with your front-end skills and your attention to design and user experience
