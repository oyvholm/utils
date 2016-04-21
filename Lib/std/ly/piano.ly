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

% showFirstLength = R1*1
% showLastLength = R1*1

\include ".version.ily"
tagline = \versioninfo

\include "piano-lower.ily"
\include "piano-upper.ily"

metronome = \repeat unfold 4 \drummode { ss4 }

\score {
  \new StaffGroup <<
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
      instrumentName = "Metronome"
      shortInstrumentName = "Mt."
    } {
      \clef percussion
      \metronome
      % \bar "|."
    }
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
      <<
        \unfoldRepeats \pianoUpper
        \unfoldRepeats \pianoLower
      >>
    }
    \new DrumStaff \with {
      instrumentName = "Metronome"
      shortInstrumentName = "Mt."
      % midiMaximumVolume = #1.00
    } {
      \unfoldRepeats \metronome
    }
  >>
  \midi { }
}

% vim: set tw=0 :
