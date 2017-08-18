library(RCurl)
setwd('D:/DOPA')
for (j in c(115:122, 124:135, 137:148, 150:161, 163:174, 176:187, 1011:1022)) {
	pag <- readLines(sprintf('http://www2.portoalegre.rs.gov.br/dopa/default.php?p_secao=%d', j))
	pag <- paste(pag, collapse = '')
	pos_links <- gregexpr('<a[^<]*?executivo.*?</a>', pag)[[1]]
	DOPAS <- unlist(mapply(substr, pag, pos_links, attr(pos_links, "match.length") + pos_links - 1, SIMPLIFY = FALSE))
	names(DOPAS) <- NULL

	for (i in DOPAS) {
	    pos_dopa <- gregexpr('http.*?pdf', i)[[1]]
		url_dopa <- substr(i, pos_dopa, attr(pos_dopa, "match.length") + pos_dopa - 1)
		dopa <- basename(url_dopa)

		nome_dopa <- gsub('<.*?>', '', i)
		
		if (file.exists(dopa)) { file.remove(dopa) }
		while(!is.null(try({bin <- getBinaryURL(url_dopa)
		con <- file(dopa, open = "wb")
		writeBin(bin, con)
		close(con)}))) { cat('Erro!\n') }
			
		data_dopa <- format(as.Date(strsplit(nome_dopa, ' - ')[[1]][1], '%d/%m/%Y'), '%Y%m%d')
		cod_dopa <- strsplit(dopa, '_')[[1]][1]

		nome <- sprintf('%s - %s%s', data_dopa, cod_dopa, paste(c('', tail(strsplit(nome_dopa, ' - ')[[1]], -1)), collapse = ' - '))
		file.rename(dopa, sprintf('%s.pdf', nome))
	}
}
