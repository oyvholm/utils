% STDfilenameDTS.ly
% File ID: STDuuidDTS
% Author: Øyvind A. Holm <sunny@sunbase.org>

\version "2.18.2"

\header {
  title = ""
  composer = ""
}

\include "guitar1.lyi"
\include "guitar2.lyi"
\include "piano-lower.lyi"
\include "piano-upper.lyi"

\score {
  \new StaffGroup <<
    \new Staff \with {
      instrumentName = "Guitar 1"
      shortInstrumentName = "Gt1"
      \omit StringNumber
    } {
      \clef "treble_8"
      \guitarOne
      % \bar "|."
    }
    %{
    \new TabStaff \with {
      instrumentName = "Guitar 1"
      shortInstrumentName = "Gt1"
    } {
      \guitarOne
      % \bar "|."
    }
    %}
    \new Staff \with {
      instrumentName = "Guitar 2"
      shortInstrumentName = "Gt2"
      \omit StringNumber
    } {
      \clef "treble_8"
      \guitarTwo
      % \bar "|."
    }
    %{
    \new TabStaff \with {
      instrumentName = "Guitar 2"
      shortInstrumentName = "Gt2"
    } {
      \guitarTwo
      % \bar "|."
    }
    %}
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
}

\score {
  \new StaffGroup <<
    \new Staff = "Guitar 1" \with {
      instrumentName = "Guitar 1"
      shortInstrumentName = "Gt1"
      midiInstrument = "overdriven guitar"
      % midiMaximumVolume = #1.00
      % midiPanPosition = 0
    } {
      \unfoldRepeats \guitarOne
    }
    \new Staff = "Guitar 2" \with {
      instrumentName = "Guitar 2"
      shortInstrumentName = "Gt2"
      midiInstrument = "electric guitar (clean)"
      % midiMaximumVolume = #1.00
      % midiPanPosition = 0
    } {
      \unfoldRepeats \guitarTwo
    }
    \new Staff = "Piano" \with {
      instrumentName = "Piano"
      shortInstrumentName = "Pn."
      midiInstrument = "acoustic grand"
      % midiMaximumVolume = #1.00
      % midiPanPosition = 0
    } {
      <<
        \pianoUpper
        \pianoLower
      >>
    }
  >>
  \midi { }
}

% vim: set tw=0 :
