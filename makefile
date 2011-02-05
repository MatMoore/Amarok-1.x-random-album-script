all:
	tar -cf randomAlbum.tar COPYING RandomAlbum.rb RandomAlbum.spec  README
	gzip randomAlbum.tar
	mv randomAlbum.tar.gz randomAlbum.amarokscript.tar.gz
