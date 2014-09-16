local storyboard = require ("storyboard")
local scene = storyboard.newScene()

local function apertarBotao( event )
	storyboard.gotoScene (event.target.destination, {effect = "fade"})
	return true
end

function scene:createScene( event )
	local group = self.view

	local titulo = display.newText("Crystal Defender", 0, 0, nil, 38)
	titulo.x = centerX
	titulo.y = display.screenOriginY+40
	group:insert(titulo)

	local playBtn = display.newText("Jogar", 0, 0, nil, 25)
	playBtn.x = centerX
	playBtn.y = centerY
	playBtn.destination = "levels"
	playBtn:addEventListener ("tap", apertarBotao)
	group:insert(playBtn)

	local optionsBtn = display.newText("Opções", 0, 0, nil, 25)
	optionsBtn.x = centerX
	optionsBtn.y = centerY + 80
	optionsBtn.destination = "options"
	optionsBtn:addEventListener("tap", apertarBotao)
	group:insert(optionsBtn)

	local creditsBtn = display.newText("Créditos", 0, 0, nil, 25)
	creditsBtn.x = centerX
	creditsBtn.y = centerY + 160
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