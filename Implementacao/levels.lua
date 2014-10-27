local storyboard = require ("storyboard")
local scene = storyboard.newScene ()
--Cria a variável que recebe o som de clique.
local cliqueSom = audio.loadSound ("Sons/click.mp3")

--Cria a função global de apertar o botão, que redireciona o fluxo da storyboard para o destino do botão apertado. Toca o som de clique.
local function apertarBotao( event )
	audio.play (cliqueSom)
	storyboard.gotoScene (event.target.destination, {effect = "fade"})
	return true
end

function scene:createScene( event )
	--Cria e inicializa o grupo de "visão" do jogo
	local group = self.view

	--Função para checar se o som de background está tocando, caso não, toca. Faz a chamada da função em seguida.
	function checaSomBg()
		local checaVolume = audio.getVolume ({channel = 1})
		if checaVolume < 1 then
			audio.rewind ({channel = 1})
			audio.fade ({channel = 1, time = 5000, volume = 1})
		end	
	end
	checaSomBg ()

	--Função para checar o progresso do jogo e liberar novas fases. Chama a função logo após.
	function checaProgresso()
		atualizaProgressoF()
		if progresso >= 1 then
			local fase2 = display.newImage ("Imagens/fase2DesbloqueadaNova.png")
			fase2.x = centerX + 60 
			fase2.y = centerY - 83
			fase2.destination = "fase2"
			fase2:addEventListener ("tap", apertarBotao)
			group:insert(fase2)
		end
		-- if progresso >= 2 then
		-- 	local fase3 = display.newImage ("Imagens/monstro.png")
		-- 	fase3.x = centerX + 130 
		-- 	fase3.y = centerY - 83
		-- 	fase3.destination = "menu"
		-- 	fase3:addEventListener ("tap", apertarBotao)
		-- 	group:insert(fase3)
		-- end	
	end
	checaProgresso ()	

	--Cria, posiciona e define o destino de cada botão do menu. Insere-os no grupo de visão. Manda o BG para o fundo do grupo de visão.
	local background = display.newImage ("Imagens/TelaNiveis.png")
	background.x = centerX
	background.y = centerY
	group:insert(background)
	background:toBack()

	local fase1 = display.newImage ("Imagens/botaoNiveis.png")
	fase1.x = centerX - 357
	fase1.y = centerY - 83
	fase1.destination = "fase1"
	fase1:addEventListener ("tap", apertarBotao)
	group:insert(fase1)

	local backBtn = display.newImage ("Imagens/botaoVoltar.png")
	backBtn.x = 120
	backBtn.y = heightScn - 50
	backBtn.destination = "menu"
	backBtn:addEventListener ("tap", apertarBotao)
	group:insert(backBtn)
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