local storyboard = require ("storyboard")
local scene = storyboard.newScene ()
local cliqueSom = audio.loadSound ("Sons/click.mp3")

--Cria a função global de apertar o botão, que redireciona o fluxo da storyboard para o destino do botão apertado.Toca o som de clique.
local function apertarBotao( event )
	audio.play (cliqueSom)
	storyboard.gotoScene (event.target.destination, {effect = "fade"})
	return true
end

function scene:createScene( event )
	--Cria e inicializa o grupo de "visão" do jogo
	local group = self.view

	--Faz a requisição do banco de dados.
	require ("sqlite3")

	--Cria, posiciona e define o destino de cada botão do menu. Insere-os no grupo de visão.
	local background = display.newImage ("Imagens/TelaConfirmacaoReset.png")
	background.x = centerX
	background.y = centerY
	group:insert(background)

	local sim = display.newImage ("Imagens/botaoVoltar.png")
	sim.x = centerX - 200
	sim.y = centerY + 230
	sim.destination = "menu"
	group:insert(sim)

	local nao = display.newImage ("Imagens/botaoVoltar.png")
	nao.x = centerX + 200
	nao.y = centerY + 230
	nao.destination = "options"
	nao:addEventListener ("tap", apertarBotao)
	group:insert(nao)

	--Função que reseta o jogo para o início e apaga todo o avanço de fases.
	function sim:tap(event)
		audio.play (cliqueSom)
		local reset = [[UPDATE tabelaProgresso SET valor=0 WHERE id=1;]]
		db:exec(reset)
	end
	sim:addEventListener ("tap", sim)
	sim:addEventListener ("tap", apertarBotao)
end

function scene:enterScene( event )
	local group = self.view
	-- Usado pra inicializar contadores, musicas, afins logo ao entrar na cena.
end

function scene:exitScene( event )
	local group = self.view
	-- Usado pra remover músicas, contadores e afins logo ao sair da cena.
end

function scene:destroyScene( event )
	local group = self.view
	-- Usado para remover do grupo "view" os audios, contadores e afins para liberarem memoria.
end

scene:addEventListener ("createScene", scene)
scene:addEventListener ("enterScene", scene)
scene:addEventListener ("exitScene", scene)
scene:addEventListener ("destroyScene", scene)


return scene