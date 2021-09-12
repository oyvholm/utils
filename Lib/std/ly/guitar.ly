% STDfilenameDTS
% File ID: STDuuidDTS
% Author: Øyvind A. Holm <sunny@sunbase.org>

\include "defs.ily"

\include "guitar.ily"

\score {
  \new StaffGroup <<
    \new Staff \with {
      instrumentName = "Guitar"
      shortInstrumentName = "Gt."
      \omit StringNumber
    } {
      \clef "treble_8"
      \guitar
      % \bar "|."
    }
    %{
    \new TabStaff \with {
      instrumentName = "Guitar"
      shortInstrumentName = "Gt."
    } {
      \guitar
      % \bar "|."
    }
    %}

    %{
    \new DrumStaff \with {
      instrumentName = "Metronome"
      shortInstrumentName = "Mt."
    } {
      \initTempo
      \clef percussion
      \metronome
      % \bar "|."
    }
    %}
  >>

  \layout { }
}

\score {
  \new StaffGroup <<
    \new Staff = "Guitar" \with {
      instrumentName = "Guitar"
      shortInstrumentName = "Gt."
      midiInstrument = "acoustic guitar (steel)"
      % midiMaximumVolume = #1.00
      % midiPanPosition = 0
    } {
      \initTempo
      \countOff
      \unfoldRepeats \guitar
    }

    %{
    \new DrumStaff \with {
      instrumentName = "Metronome"
      shortInstrumentName = "Mt."
      midiReverbLevel = #0
      % midiMaximumVolume = #1.00
    } {
      \initTempo
      \countOff
      \unfoldRepeats \metronome
    }
    %}
  >>

  \midi { }
}

% vim: set tw=0 :
