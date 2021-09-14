% STDfilenameDTS
% File ID: STDuuidDTS
% Author: Øyvind A. Holm <sunny@sunbase.org>

\include "defs.ily"

\include "click.ily"
\include "guitar2.ily"

\score {
  \new StaffGroup <<
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
    \new Staff = "Guitar 2" \with {
      instrumentName = "Guitar 2"
      shortInstrumentName = "Gt2"
      midiInstrument = "electric guitar (clean)"
      % midiMaximumVolume = #1.00
      % midiPanPosition = 0
    } {
      \initTempo
      \countOff
      \unfoldRepeats \guitarTwo
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
