% STDfilenameDTS
% File ID: STDuuidDTS
% Author: Øyvind A. Holm <sunny@sunbase.org>

\include "defs.ily"

\include "bass.ily"
\include "click.ily"

\score {
  \new StaffGroup <<
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
    \new Staff \with {
      instrumentName = "Bass"
      shortInstrumentName = "Bs."
      midiInstrument = "electric bass (finger)"
      % midiMaximumVolume = #1.60
      % midiPanPosition = 0
    } {
      \initTempo
      \countOff
      \unfoldRepeats \bassGuitar
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
