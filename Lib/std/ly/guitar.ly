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

initTempo = { \tempo 4 = 120 }

\include "guitar.ily"

metronome = \repeat unfold 4 \drummode { ss4 }

\score {
  \new StaffGroup <<
    \new Staff \with {
      instrumentName = "Guitar"
      \omit StringNumber
    } {
      \clef "treble_8"
      \guitar
      % \bar "|."
    }
    %{
    \new TabStaff \with {
      instrumentName = "Guitar"
    } {
      \guitar
      % \bar "|."
    }
    %}
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
    \new Staff = "Guitar" \with {
      instrumentName = "Guitar"
      midiInstrument = "acoustic guitar (steel)"
      % midiMaximumVolume = #1.00
      % midiPanPosition = 0
    } {
      \initTempo
      \unfoldRepeats \guitar
    }
    \new DrumStaff \with {
      instrumentName = "Metronome"
      shortInstrumentName = "Mt."
      % midiMaximumVolume = #1.00
    } {
      \initTempo
      \unfoldRepeats \metronome
    }
  >>
  \midi { }
}

% vim: set tw=0 :
