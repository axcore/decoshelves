===========
decoshelves
===========

This is a mod for `Minetest <https://www.minetest.net/>`__, providing an expanded selection of bookshelves.

.. image:: screenshots/decoshelves.png
  :alt: A selection of bookshelves

Have YOU ever wanted to make a bookshelf out of leaves, coral, lava or any other completely unsuitable material? Well, now you can!

`minetest-game <https://github.com/minetest/minetest_game/>`__ provides a single bookshelf made out of default wood.

This mod provides (as standard) bookshelves made out of about forty different materials. A few of them use animated textures.

Each bookshelf come in two varities: the ordinary version, and a lockable version (with glass doors). Skeleton keys from default can be used with the lockable version.

The craft recipe for the ordinary version is:

        MATERIAL MATERIAL MATERIAL

        BOOK     BOOK     BOOK

        MATERIAL MATERIAL MATERIAL

The locked version uses a steel ingot in its craft recipe:

        MATERIAL MATERIAL MATERIAL

        BOOK     INGOT    BOOK

        MATERIAL MATERIAL MATERIAL

You can easily add or remove new types of bookshelf; just open the init.lua file in a text editor, and add or remove lines from the list. You can add a bookshelf type out of (almost) any material: as long as minetest can retrieve the texture, then decoshelves can use that texture.

License (code): GNU Lesser General Public License, version 2.1
License (media): Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)

Credits: The code and textures are adapted from `minetest-game <https://github.com/minetest/minetest_game/>`__.

Dependencies: default

Optional dependencies: bones and bucket
