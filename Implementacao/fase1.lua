--Inicializa a storyboard
local storyboard = require ("storyboard")
local scene = storyboard.newScene ()

--Cria a função global de apertar o botão, que redireciona o fluxo da storyboard para o destino do botão apertado.
local function apertarBotao( event )
	display.remove (fimdejogotxt)
	storyboard.gotoScene (event.target.destination, {effect = "fade"})
	return true
end

function scene:createScene( event )
	--Cria e inicializa o grupo de "visão" do jogo
	local group = self.view
	-- Inicia Fisica
	local physics = require ("physics")
	physics.start()
	physics.setGravity (0,0)

	--Cria um array com as posições que os monstros podem nascer e um array com todos os inimigos criados
	local posY = {122, 366, 580}
	local inimigosArray = {}

	--Cria uma variável global com o número de inimigos criados e uma variável para recer o timer dos inimigos
	local numInimigos = 0
	local tm
	

	--Inicializa e posiciona as imagens
	local fundo = display.newImage ("Background.png")
	fundo.x = display.contentWidth/2
	fundo.y = display.contentHeight/2
	group:insert (fundo)

	local cristais = display.newImage ("cristais.png")
	cristais.x = 80
	cristais.y = display.contentHeight/2
	physics.addBody (cristais, "static", {bounce = 0, density = 1, friction = 0})
	cristais.name = "cristal"
	group:insert (cristais)

	local setaCima = display.newImage ("setas.png")
	setaCima.x = 235
	setaCima.y = 100
	group:insert (setaCima)

	local setaBaixo = display.newImage ("setas.png")
	setaBaixo.x = 235
	setaBaixo.y = 620
	group:insert (setaBaixo)

	local btnAtirar = display.newImage ("setas.png")
	btnAtirar.x = 1200
	btnAtirar.y = 625
	group:insert (btnAtirar)

	local objTeste = display.newImage ("obj.png")
	objTeste.x = 255
	objTeste.y = 360
	physics.addBody (objTeste, "static", {bounce = 0, density = 1, friction = 0})
	objTeste.name = "personagem"
	group:insert (objTeste)

	--Cria o evento de apertar a seta para cima e move o personagem
	function setaCima:tap (event)
		if (objTeste.y < display.contentHeight -480) then
			objTeste.y = 140
		else	
			objTeste.y = objTeste.y - 220
		end	
	end
	

	--Cria o evento de apertar a seta para baixo e move o personagem
	function setaBaixo:tap (event)
		if (objTeste.y > display.contentHeight -240) then
			objTeste.y = 580
		else	
			objTeste.y = objTeste.y + 220
		end	
	end	

	--Cria o evento de disparar a arma
	function atirar (event)
		local bala = display.newImage ("bala.png")
		physics.addBody (bala, static, {density = 0.5, friction = 0, bounce = 0} )
		bala.x = objTeste.x + 30
		bala.y = objTeste.y - 70
		bala.name = "bala"
		group:insert (bala)

		--Recebe o objeto bala apos concluir a transição e a apaga
		local apagarBala = function ( obj )
			display.remove (obj)
		end
		
		--Move a bala pela tela
		transition.to (bala, {time = 1000, x = 1290, y = objTeste.y -70, onComplete = apagarBala})

	end

	-- Função para criar e movimentar os monstros aleatoriamente. Chamada com looping infinito para criar os monstros
	function criarMonstro()
		numInimigos = numInimigos + 1
		inimigosArray [numInimigos] = display.newImage ("monstro.png")
		physics.addBody (inimigosArray [numInimigos], {bounce = 0, density = 1, friction = 0})
		group:insert (inimigosArray [numInimigos])

		inimigosArray [numInimigos].name = "monstro"
		inimigosArray [numInimigos].x = display.contentWidth + 30
		inimigosArray [numInimigos].y = posY [math.floor (math.random()*3) + 1]

		-- Movimenta os inimigos em linha reta até o cristal
		transition.to (inimigosArray [numInimigos], {time = math.random(10000, 15000), x = cristais.x, y = inimigosArray [numInimigos].y})
	
	end
	tm = timer.performWithDelay (5000, criarMonstro, 0)

	--Cria o evento de detecção de colisão
	function onCollision (event)

		-- Detecta colisão entre a bala e o monstro. Remove ambos
		if ((event.object1.name == "bala" and event.object2.name == "monstro") or (event.object1.name == "monstro" and event.object2.name == "bala")) then
			display.remove (event.object1)
			display.remove (event.object2)
		end

		--Detecta colisão entre o monstro e o cristal/personagem. Encerra o jogo
		if ((event.object1.name == "cristal" and event.object2.name == "monstro") or (event.object1.name == "personagem" and event.object2.name == "monstro")) then

			local function fimDeJogo ()
				timer.cancel (tm)
				apagarFuncoes ()
				local fimdejogotxt = display.newText ("Fim de Jogo", centerX, centerY, nil, 50)
				fimdejogotxt.destination = "levels"
				fimdejogotxt:addEventListener ("tap", apertarBotao)
				group:insert (fimdejogotxt)
			end	
			apagarInimigos ()
			transition.to (objTeste, {time=1000, alpha = 0, onComplete = fimDeJogo})
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
		display.remove (objTeste)
		display.remove (btnAtirar)
		display.remove (setaCima)
		display.remove (setaBaixo)
	end
	-- Listeners dos botões e da detecção de colisão
	setaCima:addEventListener ("tap", setaCima)
	setaBaixo:addEventListener ("tap", setaBaixo)
	btnAtirar:addEventListener ("tap", atirar)	
	Runtime:addEventListener ("collision", onCollision)

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