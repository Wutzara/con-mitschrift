
all: content.tex mitschrift.pdf

mitschrift.pdf: mitschrift.tex content.tex
	pdflatex -shell-escape mitschrift.tex

content.tex: content.markdown
	pandoc --filter minted.py -f markdown -t latex -o $@ content.markdown

clean:
	rm *.aux *.log *.out *.pdf *.bbl *.blg
