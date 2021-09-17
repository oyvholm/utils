% STDfilenameDTS
% File ID: STDuuidDTS
% Author: Øyvind A. Holm <sunny@sunbase.org>

\include "defs.ily"

\include "chords.ily"
\include "click.ily"
\include "drums.ily"

\score {
  \new StaffGroup <<
    \chords {
      \set chordChanges = ##t
      \theChords
    }
    \new DrumStaff \with {
      instrumentName = "Drums"
      shortInstrumentName = "Drm"
    } {
      \clef percussion
      \theDrums
      % \bar "|."
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
    \new DrumStaff \with {
      instrumentName = "Drums"
      shortInstrumentName = "Drm"
      % midiMaximumVolume = #1.00
    } {
      \initTempo
      \countOff
      \unfoldRepeats \theDrums
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
