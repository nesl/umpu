all:
	latex harbor-tecs.tex
	bibtex -min-crossrefs=100 harbor-tecs
	latex harbor-tecs.tex
	latex harbor-tecs.tex
	dvips -Ppdf harbor-tecs.dvi
	dvipdf harbor-tecs.dvi harbor-tecs.pdf
	open harbor-tecs.pdf



clean:
	rm -fr harbor-tecs.pdf harbor-tecs.toc harbor-tecs.lof harbor-tecs.log \
harbor-tecs.lot harbor-tecs.aux harbor-tecs.bbl harbor-tecs.ps harbor-tecs.dvi harbor-tecs.blg


