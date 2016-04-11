# STDprojnameDTS/Makefile
# File ID: STDuuidDTS

NAME = STDprojnameDTS
AFVLOCKDIR = $(HOME)/.$(NAME)-afv.lock
FRESCOLOCKDIR = $(HOME)/.$(NAME)-fresco.lock
MTDIR = $(HOME)/src/git/lyrics/sunny/$(NAME)

.PHONY: default
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
	git log -1 --date=format:%Y-%m-%d --format="versioninfo = #(string-append \"%cd, commit %h — Engraved with LilyPond v\" (lilypond-version) \" ❤\")" . >.version.ily

.PHONY: afv
afv:
	mkdir $(AFVLOCKDIR)
	(sess -- afv -l5 $(NAME).ly '*.ily' $(NAME).midi; rmdir $(AFVLOCKDIR)) &

.PHONY: clean
clean:
	rm -fv $(NAME).pdf $(NAME).wav .version.ily

.PHONY: diff
diff:
	git diff *.ly *.ily

.PHONY: dist
dist:
	make .version.ily
	lilypond -dno-point-and-click $(NAME).ly

.PHONY: dw
dw:
	git dw *.ly *.ily

.PHONY: dww
dww:
	git dww *.ly *.ily

.PHONY: edit
edit:
	v $(NAME).ly *.ily

.PHONY: fresco
fresco:
	mkdir $(FRESCOLOCKDIR)
	(cd $(HOME)/src/other/frescobaldi; sess ./frescobaldi $(MTDIR)/$(NAME).ly; rmdir $(FRESCOLOCKDIR)) &

.PHONY: play
play:
	make
	timidity --output-24bit $(NAME).midi

.PHONY: slow
slow:
	make $(NAME).midi
	timidity --output-24bit -T 50 $(NAME).midi

.PHONY: swp
swp:
	for f in .*.swp; do git add $$(basename $$(echo $$f | cut -c 2-) .swp); vim -r $$f; rm -iv $$f; done

.PHONY: touch
touch:
	touch $(NAME).ly

.PHONY: view
view:
	make $(NAME).pdf
	sess evince $(NAME).pdf &>/dev/null &

.PHONY: wav
wav:
	make $(NAME).wav
	p $(NAME).wav
