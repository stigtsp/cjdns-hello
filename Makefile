build: deps
	fatpack file cjdns-hello.pl > cjdns-hello
	chmod +x cjdns-hello
	echo "=== run ./cjdns-hello daemon to start ==="

deps:
	cpanm --installdeps .

run:
	morbo -w . -l http://\*:8080 cjdns-hello.pl
