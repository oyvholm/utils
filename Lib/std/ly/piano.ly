% STDfilenameDTS
% File ID: STDuuidDTS
% Author: Øyvind A. Holm <sunny@sunbase.org>

\include "defs.ily"

\include "chords.ily"
\include "click.ily"
\include "piano-lower.ily"
\include "piano-upper.ily"

\score {
  \new StaffGroup <<
    \chords {
      \set chordChanges = ##t
      \theChords
    }
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
    \new Staff = "Piano" \with {
      instrumentName = "Piano"
      shortInstrumentName = "Pn."
      midiInstrument = "acoustic grand"
      % midiMaximumVolume = #1.00
      % midiPanPosition = 0
    } {
      \initTempo
      \countOff
      <<
        \unfoldRepeats \pianoUpper
        \unfoldRepeats \pianoLower
      >>
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
