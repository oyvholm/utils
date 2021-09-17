# STDprojnameDTS/Makefile
# File ID: STDuuidDTS

NAME = STDprojnameDTS

AFVLOCKDIR = $(HOME)/.$(NAME)-afv.lock
DEPS = .version.ily *.ily *.ly Makefile
ENGR = \"Engraved with LilyPond v\" (lilypond-version) \" ❤\"
FRESCOLOCKDIR = $(HOME)/.$(NAME)-fresco.lock
IGNFILES  =
IGNFILES += -e '\.midi$$'
IGNFILES += -e '\.mp3$$'
IGNFILES += -e '\.opus$$'
IGNFILES += -e '\.pdf$$'
IGNFILES += -e '\.wav$$'
LILYPOND = lilypond
PLAYER = mpv
SA_GIT = \#(string-append \"%cd, commit %h — \" $(ENGR))
SA_NOGIT = \#(string-append \"Compiled $$(date +%Y-%m-%d) — \" $(ENGR))

.PHONY: all
all: midi pdf

.version.ily: *.ily *.ly Makefile
	if [ -z "$$(git log -1 --format=%h . 2>/dev/null)" ]; then \
		echo "versioninfo = $(SA_NOGIT)"; \
	else \
		git log -1 --date=format:%Y-%m-%d \
		        --format="versioninfo = $(SA_GIT)" \
		        .; \
	fi >.version.ily

%.midi: $(DEPS)
	$(LILYPOND) $*.ly

%.pdf: $(DEPS)
	$(LILYPOND) $*.ly

%.wav: $(DEPS)
	$(MAKE) $*.midi
	timidity --output-24bit -Ow $*.midi

%.mp3: $(DEPS)
	$(MAKE) $*.wav
	rm -f $*.mp3
	wav_to_mp3 $*.wav

%.opus: $(DEPS)
	$(MAKE) $*.wav
	rm -f $*.opus
	wav_to_opus $*.wav

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
	(sess frescobaldi $(NAME).ly; rmdir $(FRESCOLOCKDIR)) &

.PHONY: midi
midi: $(NAME).midi

.PHONY: mp3
mp3: $(NAME).mp3

.PHONY: opus
opus: $(NAME).opus

.PHONY: pdf
pdf: $(NAME).pdf

.PHONY: play
play: $(NAME).wav
	$(PLAYER) $(NAME).wav

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
	sess okular $(NAME).pdf &>/dev/null &

.PHONY: wav
wav: $(NAME).wav
