--Váriaveis pra uso rápido e fácil
centerX = display.contentWidth/2
centerY = display.contentHeight/2
widthScn = display.contentWidth
heightScn = display.contentHeight
topScn = display.screenOriginY
leftScn = display.screenOriginX

--Faz a requisição do banco de dados, define o caminho e o arquivo do banco. Abre o banco de dados.
require ("sqlite3")
local path = system.pathForFile( "data.db", system.DocumentsDirectory )
local db = sqlite3.open( path )

--Cria a tabelaProgresso caso já não exista no arquivo. Possui duas colunas (id[auto-incrementável] e valor).
tabelaProgresso = [[CREATE TABLE IF NOT EXISTS tabelaProgresso (id INTEGER PRIMARY KEY autoincrement, valor INTEGER);]]
db:exec(tabelaProgresso)

-- Insere a primeira linha da tabela com valor 0.
--local insereProgresso = [[INSERT INTO tabelaProgresso VALUES (NULL, 0);]]
--db:exec (insereProgresso)
-- Deleta todas as linhas da tabela.
--local d = [[DELETE FROM tabelaProgresso;]]
--db:exec(d)

--Função que atualiza a variável global progresso através de um select no banco de dados. Limita a pesquisa somente a primeira linha.
function atualizaProgressoF()
	for row in db:nrows ("SELECT * FROM tabelaProgresso LIMIT 1") do
		progresso = row.valor
		print (progresso)
	end
end
--Chamada da função para poder inicializar a variável progresso na primeira abertura do programa.
atualizaProgressoF ()

--Função para fechar o banco de dados assim que o aplicativo for fechado.
function trataSistema(event)
	if event.type == "applicationExit" then
		if db and db:isopen() then
			db:close()
		end
	end
end

Runtime:addEventListener ("system", trataSistema)

--Carrega a musica de fundo e toca em loop infinito.
musicaBg = audio.loadStream ("Sons/BgMusic.mp3")
audio.play (musicaBg, {loops = -1, channel = 1})

--Efetua a chamada da storyboard
local storyboard = require ("storyboard")

--Limpa as cenas e as remove nas transições.
storyboard.purgeOnSceneChange = true

--Faz a troca de cena utilizando um efeito de fade
storyboard.gotoScene ("menu", {effect = "fade"})