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
	local background = display.newImage ("Imagens/TelaOpcoes.png")
	background.x = centerX
	background.y = centerY
	group:insert(background)

	local resetaJogo = display.newText ("Reset", 0, 0, nil, 50)
	resetaJogo.x = centerX
	resetaJogo.y = centerY
	group:insert (resetaJogo)

	local backBtn = display.newImage ("Imagens/botaoVoltar.png")
	backBtn.x = 120
	backBtn.y = heightScn - 50
	backBtn.destination = "menu"
	backBtn:addEventListener ("tap", apertarBotao)
	group:insert (backBtn)

	--Função que reseta o jogo para o início e apaga todo o avanço de fases.
	function resetaJogo:tap(event)
		local reset = [[UPDATE tabelaProgresso SET valor=0 WHERE id=1;]]
		db:exec(reset)
	end

	resetaJogo:addEventListener ("tap", resetaJogo)
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