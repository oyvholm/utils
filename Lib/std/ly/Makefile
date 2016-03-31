# STDprojnameDTS/Makefile
# File ID: STDuuidDTS

NAME = STDprojnameDTS
AFVLOCKDIR = $(HOME)/.$(NAME)-afv.lock
FRESCOLOCKDIR = $(HOME)/.$(NAME)-fresco.lock
MTDIR = $(HOME)/src/git/lyrics/sunny/$(NAME)

default:
	make $(NAME).midi $(NAME).pdf

$(NAME).midi: $(NAME).ly *.lyi
	lilypond $(NAME).ly

$(NAME).pdf: $(NAME).ly *.lyi
	lilypond $(NAME).ly

$(NAME).wav: $(NAME).ly *.lyi
	make
	timidity --output-24bit -Ow $(NAME).midi

afv:
	mkdir $(AFVLOCKDIR)
	(sess -- afv -l5 $(NAME).ly '*.lyi' $(NAME).midi; rmdir $(AFVLOCKDIR)) &

clean:
	rm -fv $(NAME).pdf $(NAME).wav

diff:
	git diff *.ly *.lyi

dist:
	lilypond -dno-point-and-click $(NAME).ly

dw:
	git dw *.ly *.lyi

dww:
	git dww *.ly *.lyi

edit:
	v $(NAME).ly *.lyi

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
	for f in .*.swp; do git add $$(echo $$f | cut -c 2-); vim -r $$f; rm -iv $$f; done

touch:
	touch $(NAME).ly

view:
	make $(NAME).pdf
	sess evince $(NAME).pdf &>/dev/null &

wav: $(NAME).ly *.lyi
	make $(NAME).wav
	p $(NAME).wav
