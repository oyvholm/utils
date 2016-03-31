% STDfilenameDTS.ly
% File ID: STDuuidDTS
% Author: Øyvind A. Holm <sunny@sunbase.org>

\version "2.18.2"

\header {
  title = ""
  composer = ""
}

\include "piano-lower.lyi"
\include "piano-upper.lyi"

\score {
  \new StaffGroup <<
    \new PianoStaff <<
      \set PianoStaff.instrumentName = #"Piano"
      \new Staff = "upper" {
        \clef treble
        \pianoUpper
      }
      \new Staff = "lower" {
        \clef bass
        \pianoLower
      }
    >>
  >>
  \layout { }
  \midi { }
}

% vim: set tw=0 :
