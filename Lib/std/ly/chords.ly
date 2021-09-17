% STDfilenameDTS
% File ID: STDuuidDTS
% Author: Øyvind A. Holm <sunny@sunbase.org>

\include "defs.ily"

\include "chords.ily"
\include "click.ily"

\score {
  \new StaffGroup <<
    \chords {
      \set chordChanges = ##t
      \theChords
    }

    \new DrumStaff \with {
      instrumentName = "Metronome"
      shortInstrumentName = "Mt."
    } {
      \initTempo
      \clef percussion
      \metronome
      % \bar "|."
    }
  >>

  \layout { }
}

\score {
  \new StaffGroup <<
    \new Staff = "Chords" \with {
      instrumentName = "Chords"
      shortInstrumentName = "Ch."
      midiInstrument = "acoustic grand"
      % midiMaximumVolume = #1.00
      % midiPanPosition = 0
    } {
      \initTempo
      \countOff
      \unfoldRepeats \theChords
    }

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
  >>

  \midi { }
}

% vim: set tw=0 :
