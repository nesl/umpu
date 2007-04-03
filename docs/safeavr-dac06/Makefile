all:
	latex safeavr-dac06.tex
	bibtex -min-crossrefs=100 safeavr-dac06
	latex safeavr-dac06.tex
	latex safeavr-dac06.tex
	dvips -Ppdf safeavr-dac06.dvi
	dvipdf safeavr-dac06.dvi safeavr-dac06.pdf
	open safeavr-dac06.pdf

afterbib:
	latex safeavr-dac06.tex
	latex safeavr-dac06.tex
	dvips -Ppdf safeavr-dac06.dvi
	dvipdf safeavr-dac06.dvi safeavr-dac06.pdf
	open safeavr-dac06.pdf

clean:
	rm -fr safeavr-dac06.pdf safeavr-dac06.toc safeavr-dac06.lof safeavr-dac06.log \
safeavr-dac06.lot safeavr-dac06.aux safeavr-dac06.bbl safeavr-dac06.ps

