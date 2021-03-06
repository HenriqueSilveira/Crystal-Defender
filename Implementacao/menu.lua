local storyboard = require ("storyboard")
local scene = storyboard.newScene()
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

	local background = display.newImage ("Imagens/Menu.png")
	background.x = centerX
	background.y = centerY
	group:insert (background)
	--Cria, posiciona e define o destino de cada botão do menu. Insere-os no grupo de visão.
	local playBtn = display.newImage("Imagens/botao.png")
	playBtn.x = centerX
	playBtn.y = centerY - 50
	playBtn.destination = "levels"
	playBtn:addEventListener ("tap", apertarBotao)
	group:insert(playBtn)

	local optionsBtn = display.newImage("Imagens/botao.png")
	optionsBtn.x = centerX
	optionsBtn.y = centerY + 50
	optionsBtn.destination = "options"
	optionsBtn:addEventListener("tap", apertarBotao)
	group:insert(optionsBtn)

	local creditsBtn = display.newImage("Imagens/botao.png")
	creditsBtn.x = centerX
	creditsBtn.y = centerY + 150
	creditsBtn.destination = "gamecredits"
	creditsBtn:addEventListener("tap", apertarBotao)
	group:insert(creditsBtn)

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