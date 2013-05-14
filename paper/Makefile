all: paper.pdf

paper.pdf: paper.tex paper.bib
	pdflatex paper
	bibtex paper
	pdflatex paper
	pdflatex paper

clean:
	rm -f paper.aux paper.log paper.bbl paper.blg

distclean: clean
	rm -f paper.pdf