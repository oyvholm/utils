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

\include "guitar1.lyi"

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
      \unfoldRepeats \guitarOne
    }
  >>
  \midi { }
}

% vim: set tw=0 :
