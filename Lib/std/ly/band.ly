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

\include "bass.lyi"
\include "drums.lyi"
\include "guitar1.lyi"
\include "guitar2.lyi"
\include "piano-lower.lyi"
\include "piano-upper.lyi"
\include "vocal1.lyi"

\score {
  \new StaffGroup <<
    \new Staff \with {
      instrumentName = "Vocal 1"
      shortInstrumentName = "Vc1"
    } {
      \clef treble
      \vocalOne
    }
    \addlyrics {
    }
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
    \new Staff \with {
      instrumentName = "Bass"
      shortInstrumentName = "Bs."
      \omit StringNumber
    } {
      \clef "bass_8"
      \bassGuitar
      % \bar "|."
    }
    %{
    \new TabStaff \with {
      instrumentName = "Bass"
      stringTunings = #bass-tuning
    } {
      \bassGuitar
      % \bar "|."
    }
    %}
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
    \new DrumStaff \with {
      instrumentName = "Drums"
      shortInstrumentName = "Drm"
    } {
      \clef percussion
      \theDrums
      % \bar "|."
    }
  >>
  \layout { }
}

\score {
  \new StaffGroup <<
    \new Staff = "Vocal 1" \with {
      instrumentName = "Vocal 1"
      shortInstrumentName = "Vc1"
      midiInstrument = "voice oohs"
      % midiMaximumVolume = #1.00
      % midiPanPosition = 0
    } {
      \unfoldRepeats \vocalOne
    }
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
    \new Staff \with {
      instrumentName = "Bass"
      shortInstrumentName = "Bs."
      midiInstrument = "electric bass (finger)"
      % midiMaximumVolume = #1.60
      % midiPanPosition = 0
    } {
      \unfoldRepeats \bassGuitar
    }
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
    \new DrumStaff \with {
      instrumentName = "Drums"
      shortInstrumentName = "Drm"
      % midiMaximumVolume = #1.00
    } {
      \unfoldRepeats \theDrums
    }
  >>
  \midi { }
}

% vim: set tw=0 :
