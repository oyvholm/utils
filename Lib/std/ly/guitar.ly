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

\include ".version.lyi"
tagline = \versioninfo

\include "guitar.lyi"

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
      \unfoldRepeats \guitar
    }
  >>
  \midi { }
}

% vim: set tw=0 :
