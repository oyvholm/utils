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
}

\score {
  \new Staff = "Piano" \with {
    instrumentName = "Piano"
    shortInstrumentName = "Pn."
    midiInstrument = "acoustic grand"
    % midiMaximumVolume = #1.00
    % midiPanPosition = 0
  } {
    <<
      \unfoldRepeats \pianoUpper
      \unfoldRepeats \pianoLower
    >>
  }
  \midi { }
}

% vim: set tw=0 :
