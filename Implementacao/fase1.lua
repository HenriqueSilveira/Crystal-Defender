--Inicializa a storyboard
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

	--Desativa o som de fundo e carrega a variável com o som de tiro. Inicializa os sons de arma recarregada e arma sem balas.
	audio.fade ({channel = 1, time = 5000, volume = 0})
	local tiro = audio.loadSound ("Sons/tiro.wav")
	local recarregado = audio.loadSound ("Sons/recarregado.mp3")
	local semBala = audio.loadSound ("Sons/vazio.wav")

	-- Inicia Fisica
	local physics = require ("physics")
	physics.start()
	physics.setGravity (0,0)

	--Faz a requisição do banco de dados.
	require "sqlite3"

	--Cria um array com as posições que os monstros podem nascer e um array com todos os inimigos criados
	local posY = {430, 650, 550}
	local inimigosArray = {}

	--Cria uma variável global com o número de inimigos criados, uma variável para receber o timer dos inimigos, uma variável para a velocidade dos inimigos e uma variável com o número de inimigos que a fase possui.
	local numInimigos = 0
	local tm
	local tmrecarga
	local contInimigos = 3
	local intervaloMonstros = 4000
	local numBalas = 6
	local danoBala = 1

	--Opções dos cortes da sprite do contador de balas.
	local optionsBalas ={
		width = 128,
		height = 67,
		numFrames = 7
	}

	--Importa a folha de sprite do contador de balas e aplica os cortes do options.
	local folhaBalas = graphics.newImageSheet ("Imagens/spriteBalas.png", optionsBalas)

	--Define a sequência de frames do contador de balas. Todos so possuem um frame.
	local sequenceDataBalas = {
		{name = "bala6", start = 1, count = 1},
		{name = "bala5", start = 2, count = 1},
		{name = "bala4", start = 3, count = 1},
		{name = "bala3", start = 4, count = 1},
		{name = "bala2", start = 5, count = 1},
		{name = "bala1", start = 6, count = 1},
		{name = "bala0", start = 7, count = 1}
	}

	--Cria uma tabela com os tipos de monstros e suas características.
	local tiposMonstros = {
		{vida = 3, velocidade = 5000},
		{vida = 6, velocidade = 10000}
	}

	--Faz a requisição das medidas dos cortes, importa a folha para aplicar os cortes e define as sequencias da sprite do personagem.
	local optionsPersonagem = require ("spriteBoneco")
	local folhaPersonagem = graphics.newImageSheet ("Imagens/spriteBoneco.png", optionsPersonagem.sheetData)
	local sequenceDataPersonagem = {
		{name="parado", start=4, count = 1},
		{name="atirando", frames = {7, 8, 1, 3, 4}, time = 500, loopCount = 1},
		{name="andarCima", frames = {5, 6, 4}, time = 1000, loopCount = 1},
		{name="andarBaixo", frames = {9, 10, 4}, time = 1000, loopCount = 1},
		{name="dano", frames = {4, 11}, time = 400, loopCount = 1, loopDirection = "bounce"},
		{name="morto", start = 2, count = 1}
	}

	--Faz a requisição das medidas dos cortes, importa a folha para aplicar os cortes e define as sequencias da sprite do monstro.
	local optionsMonstro = require ("spriteMonstro")
	local folhaMonstro = graphics.newImageSheet ("Imagens/spriteMonstro.png", optionsMonstro.sheetData)
	local sequenceDataMonstro = {
		{name = "vida3", start = 4, count = 1},
		{name = "vida2", start = 1, count = 1},
		{name = "vida1", start = 2, count = 1},
		{name = "vida0", start = 3, count = 1}
	}

	--Inicializa e posiciona a sprite do contador de balas. Inicia no sprite com o cartucho cheio.
	local contBalas = display.newSprite (folhaBalas, sequenceDataBalas)
	contBalas.x = widthScn - 80
	contBalas.y = topScn + 100
	group:insert (contBalas)
	contBalas:setSequence ("bala6")
	contBalas:play()

	--Cria e posiciona o objeto personagem com sprite.
	local personagem = display.newSprite (folhaPersonagem, sequenceDataPersonagem)
	personagem.x = 210
	personagem.y = 550
	physics.addBody (personagem, "static", {bounce = 0, density = 1, friction = 0})
	personagem.vida = 6
	personagem.name = "personagem"
	personagem:setSequence ("parado")
	personagem:play()
	group:insert (personagem)

	--Inicializa e posiciona as imagens
	local fundo = display.newImage ("Imagens/BackgroundNovo.png")
	fundo.x = display.contentWidth/2
	fundo.y = display.contentHeight/2
	group:insert (fundo)
	fundo:toBack ()

	--Insere um background invisível para quando a fase acabar.
	local fundo2 = display.newImage ("Imagens/BackgroundNovoEmbacado.png")
	fundo2.x = centerX
	fundo2.y = centerY
	fundo2.alpha = 0
	group:insert (fundo2)

	local cristais = display.newImage ("Imagens/cristaisNovo.png")
	cristais.x = 80
	cristais.y = 560
	physics.addBody (cristais, "static", {bounce = 0, density = 1, friction = 0})
	cristais.name = "cristal"
	cristais.vida = 6
	cristais.alpha = 1
	group:insert (cristais)

	local setaCima = display.newImage ("Imagens/setas.png")
	setaCima.x = 235
	setaCima.y = 430
	group:insert (setaCima)

	local setaBaixo = display.newImage ("Imagens/setas.png")
	setaBaixo.x = 235
	setaBaixo.y = 650
	group:insert (setaBaixo)

	local btnAtirar = display.newImage ("Imagens/setas.png")
	btnAtirar.x = 1225
	btnAtirar.y = 625
	btnAtirar.name = "btnAtirar"
	group:insert (btnAtirar)

	local instrucoes = display.newImage ("Imagens/InstrucoesNovas.png")
	instrucoes.x = centerX
	instrucoes.y = centerY
	group:insert (instrucoes)

	-- Cria o contador com o número de inimigos restantes na fase.
	local contador = display.newText ("Inimigos restantes: "..contInimigos, widthScn - 200, topScn + 30, nil, 35)
	group:insert (contador)

	--Cria o texto de recarregando em modo invisível.
	local reloading = display.newText ("Recarregando...", centerX, centerY, nil, 50)
	reloading.alpha = 0
	group:insert (reloading)

	--Cria o texto para indicar a quantidade de balas restante no cartucho.
	local contBalasTxt = display.newText ("Cartucho: ", widthScn - 240, topScn + 100, nil, 35)
	group:insert(contBalasTxt)

	local vidaPersonagem = display.newText ("Vida Personagem: "..personagem.vida, centerX - 450, topScn + 30, nil, 35)
	group:insert(vidaPersonagem)

	local vidaCristal = display.newText ("Vida Cristal: "..cristais.vida, centerX - 500, topScn + 80, nil, 35)
	group:insert (vidaCristal)

	--Cria o evento de apertar a seta para cima e move o personagem
	function setaCima:tap (event)
		local moveCima = function ()
			personagem:setSequence ("andarCima")
			personagem:play()
		end
		local ficaParado = function ()
			personagem:setSequence ("parado")
		end
		if personagem.sequence == "parado" then
			if personagem.y > 440 then
				transition.to (personagem, {time = 800, x = personagem.x, y = personagem.y - 110, onStart = moveCima, onComplete = ficaParado})
			end
		end		
	end
	

	--Cria o evento de apertar a seta para baixo e move o personagem
	function setaBaixo:tap (event)
		local moveBaixo = function ()
			personagem:setSequence ("andarBaixo")
			personagem:play()
		end
		local ficaParado = function ()
			personagem:setSequence ("parado")
		end		
		if personagem.sequence == "parado" then
			if personagem.y < 660 then
				transition.to (personagem, {time = 800, x = personagem.x, y = personagem.y + 110, onStart = moveBaixo, onComplete = ficaParado})	
			end
		end	
	end

	function instrucoes:tap(event)
		transition.fadeOut (instrucoes, {time = 1000})
	end

	--Função para recarregar o cartucho.
	function recarrega()
		transition.cancel (reloading)
		contBalas:setSequence ("bala6")
		reloading.alpha = 0
		numBalas = 6
		audio.play(recarregado)
	end

	--Função que decrementa o número de balas no cartucho e aplica o delay na recarga do mesmo.
	function atualizaCartucho()
		numBalas = numBalas - 1
		contBalas:setSequence ("bala"..numBalas)
		contBalas:play ()
		if numBalas == 0 then
			reloading.alpha = 1
			transition.blink (reloading, {time = 3000})
			tmrecarga = timer.performWithDelay (5000, recarrega, 1)
		end	
	end

	--Cria o evento de disparar a arma
	function btnAtirar:tap (event)
		--Checa se o cartucho não está vazio. Caso não esteja, efetua o disparo e atualiza o cartucho.
		if numBalas ~= 0 then
			atualizaCartucho ()
			local bala = display.newImage ("Imagens/balaNova.png")
			physics.addBody (bala, "static", {density = 0.5, friction = 0, bounce = 0} )
			bala.x = personagem.x + 30
			bala.y = personagem.y - 20
			bala.alpha = 0
			bala.name = "bala"
			bala.dano = danoBala
			bala.collision = onBalaCollision
			bala:addEventListener ("collision", bala)
			group:insert (bala)
		
			personagem:setSequence ("atirando")
			personagem:play()
			local criaBala = function ()
				bala.alpha = 1
				audio.play (tiro)
			end
			--Recebe o objeto bala apos concluir a transição e a apaga
			local apagarBala = function ( obj )
				display.remove (obj)
			end
			--Move a bala pela tela e muda sprite do personagem para atirando. Ativa também o delay entre disparos.
			transition.to (bala, {delay = 300, time = 800, x = 1290, y = bala.y, onStart = criaBala, onComplete = apagarBala})
		--Insere o som de arma descarregada caso o contador de balas esteja vazio.	
		elseif numBalas == 0 then
			audio.play(semBala)
		end	
	end

	-- Função para criar e movimentar os monstros aleatoriamente. Chamada com o numero de monstros que o level exige.
	function criarMonstro()
		numInimigos = numInimigos + 1
		local selecionaMonstro = 1
		inimigosArray [numInimigos] = display.newSprite (folhaMonstro, sequenceDataMonstro)
		physics.addBody (inimigosArray [numInimigos],  {bounce = 0, density = 1, friction = 0})
		group:insert (inimigosArray [numInimigos])

		inimigosArray [numInimigos].name = "monstro"
		inimigosArray [numInimigos].vida = tiposMonstros [selecionaMonstro].vida
		inimigosArray [numInimigos].velocidade = tiposMonstros [selecionaMonstro].velocidade
		inimigosArray [numInimigos].isFixedRotation = true
		inimigosArray [numInimigos].x = display.contentWidth + 30
		inimigosArray [numInimigos].y = posY [math.floor (math.random()*3) + 1]
		inimigosArray [numInimigos].collision = onMonstroCollision
		inimigosArray [numInimigos]:addEventListener ("collision", inimigosArray [numInimigos])

		-- Movimenta os inimigos em linha reta até o cristal
		transition.to (inimigosArray [numInimigos], {time = inimigosArray[numInimigos].velocidade, x = cristais.x, y = inimigosArray [numInimigos].y})
	end
	tm = timer.performWithDelay (intervaloMonstros, criarMonstro, contInimigos)

	--Função que encerra o jogo com a derrota do jogador e cria o botao para voltar a seleção de leveis. 
	function derrota ()
		if personagem.vida <= 0 then
			personagem:setSequence ("morto")
			personagem:play()
		end	
		timer.cancel (tm)
		encerra ()
		local derrotatxt = display.newText ("Fim de Jogo", centerX, centerY, nil, 50)
		derrotatxt.destination = "levels"
		derrotatxt:addEventListener ("tap", apertarBotao)
		group:insert (derrotatxt)
	end

	-- Função que encerra a fase com o jogador sendo vitorioso, checando se o personagem/cristal possui vida. Altera o valor da variável progresso através do BD e chama a função para atualizar a variável para liberar a próxima fase.
	function vitoria()
		if contInimigos == 0 and personagem.vida > 0 and cristais.vida > 0 then
			encerra ()
			if progresso < 1 then
				local atualizaProgresso = [[UPDATE tabelaProgresso SET valor=1 WHERE id=1;]]
				db:exec(atualizaProgresso)
			end	
			local concluido = display.newText ("Você venceu!", centerX, centerY, nil, 50)
			concluido.destination = "levels"
			concluido:addEventListener ("tap", apertarBotao)
			group:insert (concluido)
		end	 
	end	

	--Função que trata a colisão da bala.
	function onBalaCollision (self, event)
		if event.phase == "began" then
			event.other.vida = event.other.vida - self.dano
			event.other:setSequence ("vida"..event.other.vida)
			event.other:play()
			display.remove (self)
			if event.other.vida == 0 then
				display.remove (self)
				display.remove (event.other)
				contInimigos = contInimigos - 1
				contador.text = "Inimigos restantes: "..contInimigos
				vitoria ()
			end
		end		
	end

	--Função que trata a colisão dos monstros.
	function onMonstroCollision(self, event)
		if event.phase == "began" then
			if event.other.name == "personagem" or event.other.name == "cristal" then
				if event.other.name == "personagem" then
					personagem:setSequence ("dano")
					personagem:play()
				end	
				event.other.vida = event.other.vida - self.vida
				print (event.other.vida)
				display.remove(self)
				contInimigos = contInimigos - 1
				contador.text = "Inimigos restantes: "..contInimigos
				vidaPersonagem.text = "Vida Personagem: "..personagem.vida
				vidaCristal.text = "Vida Cristal: "..cristais.vida
				vitoria ()
				if event.other.vida <= 0 then
					derrota ()
				end
			end
		end			
	end

	--Função que detecta a movimentação do dispositivo e recarrega o cartucho.
	function trataAcelerometro(event)
		if event.isShake then
			if tmrecarga ~= nil then
				timer.cancel (tmrecarga)
			end
			recarrega ()
		end	
	end

	function trataSprite(event)
		if ((event.target.sequence == "atirando" or event.target.sequence == "dano") and (event.phase == "ended")) then
			personagem:setSequence ("parado")
		end	
	end

	-- Função para apagar da tela e da memória o array com todos os inimigos
	function apagarInimigos( )
		for i=1, #inimigosArray do
			if (inimigosArray [i].name ~= nil) then
				display.remove (inimigosArray [i])
				inimigosArray [i].name = nil		
			end
		end	
	end	
	
	--Função para apagar os botões e personagem após fim de jogo
	function apagarFuncoes( )
		if tmrecarga ~= nil then
			timer.cancel (tmrecarga)
		end
		display.remove (btnAtirar)
		display.remove (setaCima)
		display.remove (setaBaixo)
		display.remove (contador)
		display.remove (reloading)
		display.remove (contBalas)
		display.remove (contBalasTxt)
		display.remove (vidaPersonagem)
		display.remove (vidaCristal)
		display.remove (instrucoes)
	end

	--Função que limpa os inimigos, funções e troca o background. Faz Fade Out no personagem e cristal.
	function encerra()
		apagarInimigos ()
		apagarFuncoes ()
		if personagem.vida > 0 then
			transition.fadeOut(personagem, {time=1000})
			transition.fadeIn (fundo2, {time = 1000})
		end	
		transition.fadeOut (cristais, {time=1000})

	end

	-- Listeners dos botões e da detecção de colisão
	setaCima:addEventListener ("tap", setaCima)
	setaBaixo:addEventListener ("tap", setaBaixo)
	btnAtirar:addEventListener ("tap", btnAtirar)
	instrucoes:addEventListener ("tap", instrucoes)	
	personagem:addEventListener ("sprite", trataSprite)
	Runtime:addEventListener ("accelerometer", trataAcelerometro)

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

--Gatilhos das funções
scene:addEventListener ("createScene", scene)
scene:addEventListener ("enterScene", scene)
scene:addEventListener ("exitScene", scene)
scene:addEventListener ("destroyScene", scene)

return scene