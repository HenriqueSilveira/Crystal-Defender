--Inicializa a storyboard
local storyboard = require ("storyboard")
local scene = storyboard.newScene ()

function scene:createScene( event )
	-- Inicia Fisica
	local physics = require ("physics")
	physics.start()
	physics.setGravity (0,0)

	--Inicializa e posiciona as imagens
	local fundo = display.newImage ("Background.png")
	fundo.x = display.contentWidth/2
	fundo.y = display.contentHeight/2

	local setaCima = display.newImage ("setas.png")
	setaCima.x = 105
	setaCima.y = 1050

	local setaBaixo = display.newImage ("setas.png")
	setaBaixo.x = 615
	setaBaixo.y = 1050

	local btnAtirar = display.newImage ("setas.png")
	btnAtirar.x = 620
	btnAtirar.y = 120

	local objTeste = display.newImage ("obj.png")
	objTeste.x = 365
	objTeste.y = 1019

	local monstro = display.newImage ("monstro.png")
	monstro.x = 365
	monstro.y = 540
	physics.addBody (monstro, static, {bounce = 0, density = 1, friction = 0})
	monstro.name = "monstro"

	--Cria o evento de apertar a seta para cima e move o personagem
	function setaCima:tap (event)
		if (objTeste.x < display.contentWidth -550) then
			objTeste.x = 150
		else	
			objTeste.x = objTeste.x - 215
		end	
	end
	

	--Cria o evento de apertar a seta para baixo e move o personagem
	function setaBaixo:tap (event)
		if (objTeste.x > display.contentWidth -200) then
			objTeste.x = 580
		else	
			objTeste.x = objTeste.x + 215
		end	
	end	

	--Cria o evento de disparar a arma
	function atirar (event)
		local bala = display.newImage ("bala.png")
		physics.addBody (bala, static, {density = 0.5, friction = 0, bounce = 0} )
		bala.x = objTeste.x - 70
		bala.y = objTeste.y - 25
		bala.name = "bala"

		--Recebe o objeto bala apos concluir a transição e a apaga
		local apagarBala = function ( obj )
			display.remove (obj)
		end
		
		--Move a bala pela tela
		transition.to (bala, {time = 1000, x = objTeste.x - 70, y = -100, onComplete = apagarBala})

	end
	
	--Cria o evento de detecção de colisão
	function onCollision (event)
		if ((event.object1.name == "bala" and event.object2.name == "monstro") or (event.object1.name == "monstro" and event.object2.name == "bala")) then
			display.remove (event.object1)
			display.remove (event.object2)
		end
	end		

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