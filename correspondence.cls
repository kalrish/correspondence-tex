\ProvidesClass{correspondence}

\LoadClass[oneside]{memoir}


\pageaiv
\setstocksize{297mm}{210mm}
%\stockaiv
\settrimmedsize{\stockheight}{\stockwidth}{*}
\settypeblocksize{591.5302pt}{418.25368pt}{*}
\setlrmargins{*}{*}{1}
\setheaderspaces{*}{18.06749pt}{*}
\setlength{\footskip}{40.29494pt}
\checkandfixthelayout[fixed]

\newsavebox\correspondence@headl
\newsavebox\correspondence@headr
\newcount\correspondence@perletterpage
\newluafunction\correspondence@updateheaderheight
%\newluafunction\correspondence@outputimage
\newluafunction\correspondence@beforeamendment
\newluafunction\correspondence@afteramendment


\makepagestyle{fancy}
\makeoddhead{fancy}{\usebox{\correspondence@headl}}{}{\usebox{\correspondence@headr}}
\makeheadrule{fancy}{\textwidth}{\normalrulethickness}
\makeoddfoot{fancy}{}{}{\footpagenumberfont\correspondence@theperletterpage}

\pagestyle{fancy}


%\let\letterheaderfont\empty
%\let\letterreceivedfont\empty
%\let\amendmentfont\empty
%\let\footpagenumberfont\empty

\def\outputcorrespondence{%
	\begin{document}%
		\directlua{require('correspondence.outputcorrespondence')()}%
	\end{document}%
}


\ifnum\outputmode=1
	\pdfextension catalog{/ViewerPreferences<</PageMode /UseOutlines /PrintScaling /None /Duplex /Simplex>>}
\fi