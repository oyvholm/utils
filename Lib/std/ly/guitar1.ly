% STDfilenameDTS
% File ID: STDuuidDTS
% Author: Øyvind A. Holm <sunny@sunbase.org>

\include "defs.ily"

\include "click.ily"
\include "guitar1.ily"

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
    \new Staff = "Guitar 1" \with {
      instrumentName = "Guitar 1"
      shortInstrumentName = "Gt1"
      midiInstrument = "overdriven guitar"
      % midiMaximumVolume = #1.00
      % midiPanPosition = 0
    } {
      \initTempo
      \countOff
      \unfoldRepeats \guitarOne
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
