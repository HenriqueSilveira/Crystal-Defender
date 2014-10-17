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
	local posY = {122, 366, 580}
	local inimigosArray = {}

	--Cria uma variável global com o número de inimigos criados, uma variável para receber o timer dos inimigos, uma variável para a velocidade dos inimigos e uma variável com o número de inimigos que a fase possui.
	local numInimigos = 0
	local tm
	local tmrecarga
	local contInimigos = 3
	local velocidadeIni = 5000
	local numBalas = 6

	--Opções dos cortes do sprite de atirar. Possui dois frames de tamanhos diferentes.
	local options ={
		frames = {
		-- Frame 1, sem atirar
			{
				x = 0,
				y = 0,
				width = 129,
				height = 163,
				--Valores para ajustar o posicionamento partindo de uma imagem "sem bordas".
				sourceX = 0,
				sourceY = 0,
				sourceWidth = 171,
				sourceHeight = 166
			},
		-- Frame 2, atirando
			{
				x = 135,
				y = 0,
				width = 172,
				height = 163,
				--Valores para ajustar o posicionamento partindo de uma imagem "sem bordas".
				sourceX = 6,
				sourceY = 0,
				sourceWidth = 171,
				sourceHeight = 166
			}
		}
	}

	--Opções dos cortes da sprite do contador de balas.
	local optionsBalas ={
		width = 128,
		height = 67,
		numFrames = 7
	}

	--Importa a folha de sprite do contador de balas e aplica os cortes do options.
	local folhaBalas = graphics.newImageSheet ("Imagens/spriteBalas.png", optionsBalas)

	--Importa a folha de sprite e aplica os cortes do options.
	local folha = graphics.newImageSheet ("Imagens/SpriteTiro.png", options)

	--Define a sequências de frames para a animação baseada na folha de sprites.
	local sequenceData = {
		{
			name = "atirando",
			start = 1,
			count = 2,
			time = 200,
			loopCount = 1,
			loopDirection = "bounce"
		}
	}

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

	--Inicializa e posiciona a sprite do contador de balas. Inicia no sprite com o cartucho cheio.
	local contBalas = display.newSprite (folhaBalas, sequenceDataBalas)
	contBalas.x = widthScn - 80
	contBalas.y = topScn + 100
	group:insert (contBalas)
	contBalas:setSequence ("bala6")
	contBalas:play()

	--Cria e posiciona o objeto personagem com sprite.
	local personagem = display.newSprite (folha, sequenceData)
	personagem.x = 255
	personagem.y = 360
	physics.addBody (personagem, "static", {bounce = 0, density = 1, friction = 0})
	personagem.name = "personagem"
	--personagem.vida = 10
	--print (personagem.vida)
	group:insert (personagem)

	--Inicializa e posiciona as imagens
	local fundo = display.newImage ("Imagens/Background.png")
	fundo.x = display.contentWidth/2
	fundo.y = display.contentHeight/2
	group:insert (fundo)
	fundo:toBack ()

	--Insere um background invisível para quando a fase acabar.
	local fundo2 = display.newImage ("Imagens/BackgroundEmbaçado.png")
	fundo2.x = centerX
	fundo2.y = centerY
	fundo2.alpha = 0
	group:insert (fundo2)

	local cristais = display.newImage ("Imagens/cristais.png")
	cristais.x = 80
	cristais.y = display.contentHeight/2
	physics.addBody (cristais, "static", {bounce = 0, density = 1, friction = 0})
	cristais.name = "cristal"
	group:insert (cristais)

	local setaCima = display.newImage ("Imagens/setas.png")
	setaCima.x = 235
	setaCima.y = 100
	group:insert (setaCima)

	local setaBaixo = display.newImage ("Imagens/setas.png")
	setaBaixo.x = 235
	setaBaixo.y = 620
	group:insert (setaBaixo)

	local btnAtirar = display.newImage ("Imagens/setas.png")
	btnAtirar.x = 1200
	btnAtirar.y = 625
	btnAtirar.name = "btnAtirar"
	group:insert (btnAtirar)

	local instrucoes = display.newImage ("Imagens/Instrucoes.png")
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

	--Cria o evento de apertar a seta para cima e move o personagem
	function setaCima:tap (event)
		if (personagem.y < display.contentHeight -480) then
			personagem.y = 140
		else	
			personagem.y = personagem.y - 220
		end	
	end
	

	--Cria o evento de apertar a seta para baixo e move o personagem
	function setaBaixo:tap (event)
		if (personagem.y > display.contentHeight -240) then
			personagem.y = 580
		else	
			personagem.y = personagem.y + 220
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
			local bala = display.newImage ("Imagens/Bala.png")
			physics.addBody (bala, "static", {density = 0.5, friction = 0, bounce = 0} )
			bala.x = personagem.x + 30
			bala.y = personagem.y - 70
			bala.name = "bala"
			group:insert (bala)

			--Recebe o objeto bala apos concluir a transição e a apaga
			local apagarBala = function ( obj )
					--if personagem.vida == 0 then
					--	derrota()
					--end	
					--personagem.vida = personagem.vida - 1
					display.remove (obj)
			end
			--Move a bala pela tela e muda sprite do personagem para atirando. Ativa também o delay entre disparos.
			audio.play (tiro)
			transition.to (bala, {time = 800, x = 1290, y = personagem.y -70, onStart = personagem:play(), onComplete = apagarBala})
		--Insere o som de arma descarregada caso o contador de balas esteja vazio.	
		elseif numBalas == 0 then
			audio.play(semBala)
		end	
	end

	-- Função para criar e movimentar os monstros aleatoriamente. Chamada com o numero de monstros que o level exige.
	function criarMonstro()
		numInimigos = numInimigos + 1
		inimigosArray [numInimigos] = display.newImage ("Imagens/monstro.png")
		physics.addBody (inimigosArray [numInimigos],  {bounce = 0, density = 1, friction = 0})
		group:insert (inimigosArray [numInimigos])

		inimigosArray [numInimigos].name = "monstro"
		inimigosArray [numInimigos].x = display.contentWidth + 30
		inimigosArray [numInimigos].y = posY [math.floor (math.random()*3) + 1]

		-- Movimenta os inimigos em linha reta até o cristal
		transition.to (inimigosArray [numInimigos], {time = math.random(velocidadeIni, velocidadeIni*2), x = cristais.x, y = inimigosArray [numInimigos].y})
	end
	tm = timer.performWithDelay (5000, criarMonstro, contInimigos)

	--Função que encerra o jogo com a derrota do jogador e cria o botao para voltar a seleção de leveis. 
	function derrota ()
		timer.cancel (tm)
		encerra ()
		local derrotatxt = display.newText ("Fim de Jogo", centerX, centerY, nil, 50)
		derrotatxt.destination = "levels"
		derrotatxt:addEventListener ("tap", apertarBotao)
		group:insert (derrotatxt)
	end

	-- Função que encerra a fase com o jogador sendo vitorioso. Altera o valor da variável progresso através do BD e chama a função para atualizar a variável para liberar a próxima fase.
	function vitoria()
		if contInimigos == 0 then
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


	--Cria o evento de detecção de colisão
	function onCollision (event)

		-- Detecta colisão entre a bala e o monstro. Remove ambos
		if ((event.object1.name == "bala" and event.object2.name == "monstro") or (event.object1.name == "monstro" and event.object2.name == "bala")) then
				display.remove (event.object1)
				display.remove (event.object2)
				contInimigos = contInimigos - 1
				contador.text = "Inimigos restantes: "..contInimigos
				vitoria ()
		end

		--Detecta colisão entre o monstro e o cristal/personagem. Encerra o jogo
		if ((event.object1.name == "cristal" and event.object2.name == "monstro") or (event.object1.name == "personagem" and event.object2.name == "monstro")) then
			derrota ()
		end	
	end

	--Função que detecta a movimentação do dispositivo e recarrega o cartucho.
	function trataAcelerometro(event)
		if event.isShake then
			recarrega ()
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
		display.remove (instrucoes)
	end

	--Função que limpa os inimigos, funções e troca o background. Faz Fade Out no personagem e cristal.
	function encerra()
		apagarInimigos ()
		apagarFuncoes ()
		transition.fadeOut(personagem, {time=1000})
		transition.fadeOut (cristais, {time=1000})
		transition.fadeIn (fundo2, {time = 1000})
	end

	-- Listeners dos botões e da detecção de colisão
	setaCima:addEventListener ("tap", setaCima)
	setaBaixo:addEventListener ("tap", setaBaixo)
	btnAtirar:addEventListener ("tap", btnAtirar)
	instrucoes:addEventListener ("tap", instrucoes)	
	Runtime:addEventListener ("collision", onCollision)
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