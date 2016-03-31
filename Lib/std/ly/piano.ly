% STDfilenameDTS.ly
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

\include "piano-lower.lyi"
\include "piano-upper.lyi"

\score {
  \new PianoStaff <<
    \set PianoStaff.instrumentName = #"Piano"
    \new Staff = "upper" {
      \clef treble
      \pianoUpper
      % \bar "|."
    }
    \new Staff = "lower" {
      \clef bass
      \pianoLower
      % \bar "|."
    }
  >>
  \layout { }
  \midi { }
}

% vim: set tw=0 :
