# Podgraph

Post to Blogger or Wordpress via email; inline local images.

Creates a special 'Multipart/Related' email from an html input.

## Installation

Ruby 2.3+

    $ gem install podgraph

## Usage

Blogger:

    $ pandoc post.md | podgraph | sendmail -i XXX@blogger.com

Wordpress:

    $ pandoc post.md | podgraph XXX@post.wordpress.com | sendmail -it

## Bugs

* WP strips out inlined svgs

## History

Once upon a time there was a blogging platform called Posterous. Its
main selling point was a 'post by email' feature. You could even email
images & they would appear neatly inlined within paragraphs (if your
email client supported composing such an email; many did).

Podgraph was initially written as a 'client' for Posterous: you wrote
your blog post in reStructuredText, converted it to html, piped the
result to 'podgraph' cmd, which grabbed all local images mentioned in
the html, made a 'Multipart/Related' email from them & delivered it to
sendmail.

Posterous has long been dead & gone. The 'post by email' feature was
copied by Blogger & Wordpress.

Recently I've tried to reuse podgraph for Blogger, but that endeavour
miscarried, for the script appeared to be hopelessly broken. Version
1.0.0 is a total rewrite.

## License

MIT
