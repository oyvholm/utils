% STDfilenameDTS
% File ID: STDuuidDTS
% Author: Øyvind A. Holm <sunny@sunbase.org>

\version "2.18.2"

\header {
  copyright = ""
  title = ""
  subtitle = ""
  composer = ""
  poet = ""
}

% showFirstLength = R1*1
% showLastLength = R1*1

\include ".version.ily"

\paper {
  oddFooterMarkup = \markup {
    \fill-line {
      \center-column { \versioninfo }
    }
  }
}

initTempo = { \tempo 4 = 120 }
countOff = \repeat unfold 4 \drummode { ss4 }
metronome = \repeat unfold 4 \drummode { ss4 }
