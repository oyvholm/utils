# STDprojnameDTS/Makefile
# File ID: STDuuidDTS

NAME = STDprojnameDTS
AFVLOCKDIR = $(HOME)/.$(NAME)-afv.lock
FRESCOLOCKDIR = $(HOME)/.$(NAME)-fresco.lock
MTDIR = $(HOME)/src/git/lyrics/sunny/$(NAME)

default:
	make .version.ily $(NAME).midi $(NAME).pdf

$(NAME).midi: $(NAME).ly *.ily Makefile
	make .version.ily
	lilypond $(NAME).ly

$(NAME).pdf: $(NAME).ly *.ily Makefile
	make .version.ily
	lilypond $(NAME).ly

$(NAME).wav: $(NAME).ly *.ily Makefile
	make
	timidity --output-24bit -Ow $(NAME).midi

.version.ily: $(NAME).ly *.ily Makefile
	git log -1 --date=format:%Y-%m-%d --format="versioninfo = \"%cd, commit %h — Engraved with LilyPond ❤\"" . >.version.ily

afv:
	mkdir $(AFVLOCKDIR)
	(sess -- afv -l5 $(NAME).ly '*.ily' $(NAME).midi; rmdir $(AFVLOCKDIR)) &

clean:
	rm -fv $(NAME).pdf $(NAME).wav .version.ily

diff:
	git diff *.ly *.ily

dist:
	make .version.ily
	lilypond -dno-point-and-click $(NAME).ly

dw:
	git dw *.ly *.ily

dww:
	git dww *.ly *.ily

edit:
	v $(NAME).ly *.ily

fresco:
	mkdir $(FRESCOLOCKDIR)
	(cd $(HOME)/src/other/frescobaldi; sess ./frescobaldi $(MTDIR)/$(NAME).ly; rmdir $(FRESCOLOCKDIR)) &

play:
	make
	timidity --output-24bit $(NAME).midi

slow:
	make $(NAME).midi
	timidity --output-24bit -T 50 $(NAME).midi

swp:
	for f in .*.swp; do git add $$(basename $$(echo $$f | cut -c 2-) .swp); vim -r $$f; rm -iv $$f; done

touch:
	touch $(NAME).ly

view:
	make $(NAME).pdf
	sess evince $(NAME).pdf &>/dev/null &

wav:
	make $(NAME).wav
	p $(NAME).wav
