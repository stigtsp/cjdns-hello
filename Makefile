build: deps
	fatpack file hyp-welcome.pl > hyp-welcome
	chmod +x hyp-welcome
	echo "=== run ./hyp-welcome daemon to start ==="

deps:
	cpanm --installdeps .

run:
	morbo -w . -l http://\*:14220 hyp-welcome.pl
