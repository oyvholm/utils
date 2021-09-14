% STDfilenameDTS
% File ID: STDuuidDTS
% Author: Øyvind A. Holm <sunny@sunbase.org>

\include "defs.ily"

\include "click.ily"
\include "vocal1.ily"

\score {
  \new StaffGroup <<
    \new Staff \with {
      instrumentName = "Vocal 1"
      shortInstrumentName = "Vc1"
    } {
      \clef treble
      \vocalOne
      % \bar "|."
    }

    \addlyrics {
    }

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
    \new Staff = "Vocal 1" \with {
      instrumentName = "Vocal 1"
      shortInstrumentName = "Vc1"
      midiInstrument = "voice oohs"
      % midiMaximumVolume = #1.00
      % midiPanPosition = 0
    } {
      \initTempo
      \countOff
      \unfoldRepeats \vocalOne
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
