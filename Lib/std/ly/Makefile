# STDprojnameDTS/Makefile
# File ID: STDuuidDTS

NAME = STDprojnameDTS

AFVLOCKDIR = $(HOME)/.$(NAME)-afv.lock
FRESCOLOCKDIR = $(HOME)/.$(NAME)-fresco.lock
IGNFILES  =
IGNFILES += -e '\.midi$$'
IGNFILES += -e '\.mp3$$'
IGNFILES += -e '\.opus$$'
IGNFILES += -e '\.pdf$$'
IGNFILES += -e '\.wav$$'
LILYPOND = lilypond
MTDIR = $(HOME)/src/git/lyrics/sunny/$(NAME)

.PHONY: all
all: midi pdf

%.midi: .version.ily
	$(LILYPOND) $*.ly

%.pdf: .version.ily
	$(LILYPOND) $*.ly

%.wav:
	$(MAKE) $*.midi
	timidity --output-24bit -Ow $*.midi

%.mp3:
	$(MAKE) $*.wav
	rm -f $*.mp3
	wav_to_mp3 $*.wav

%.opus:
	$(MAKE) $*.wav
	rm -f $*.opus
	wav_to_opus $*.wav

.version.ily: $(NAME).ly *.ily Makefile
	git log -1 --date=format:%Y-%m-%d \
		--format="versioninfo = #(string-append \"%cd, commit %h — Engraved with LilyPond v\" (lilypond-version) \" ❤\")" \
		. >.version.ily

.PHONY: afv
afv:
	mkdir $(AFVLOCKDIR)
	(sess -- afv -l5 $(NAME).ly '*.ily' $(NAME).midi; \
		rmdir $(AFVLOCKDIR)) &

.PHONY: clean
clean:
	rm -f $(NAME).mp3 $(NAME).opus $(NAME).pdf $(NAME).wav .version.ily

.PHONY: diff
diff:
	git diff *.ly *.ily

.PHONY: dist
dist:
	$(MAKE) .version.ily
	$(LILYPOND) -dno-point-and-click $(NAME).ly

.PHONY: dw
dw:
	git diff --word-diff *.ly *.ily

.PHONY: dww
dww:
	git diff --word-diff --word-diff-regex=. *.ly *.ily

.PHONY: edit
edit:
	$(EDITOR) $$(git ls-files | grep -v $(IGNFILES))

.PHONY: fresco
fresco:
	mkdir $(FRESCOLOCKDIR)
	(cd $(HOME)/src/other/frescobaldi; \
		sess ./frescobaldi $(MTDIR)/$(NAME).ly; \
		rmdir $(FRESCOLOCKDIR)) &

.PHONY: midi
midi: $(NAME).midi

.PHONY: mp3
mp3: $(NAME).mp3

.PHONY: opus
opus: $(NAME).opus

.PHONY: pdf
pdf: $(NAME).pdf

.PHONY: play
play: $(NAME).midi
	timidity --output-24bit $(NAME).midi

.PHONY: slow
slow: $(NAME).midi
	timidity --output-24bit -T 50 $(NAME).midi

.PHONY: swp
swp:
	for f in .*.swp; do \
		git add $$(basename $$(echo $$f | cut -c 2-) .swp); \
		vim -r $$f; rm -i $$f; \
	done

.PHONY: touch
touch:
	touch $(NAME).ly

.PHONY: view
view: $(NAME).pdf
	sess evince $(NAME).pdf &>/dev/null &

.PHONY: wav
wav: $(NAME).wav
	p $(NAME).wav
