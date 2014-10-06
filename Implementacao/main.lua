--Váriaveis pra uso rápido e fácil
centerX = display.contentWidth/2
centerY = display.contentHeight/2
widthScn = display.contentWidth
heightScn = display.contentHeight
topScn = display.screenOriginY
leftScn = display.screenOriginX
progresso = 0

--Carrega a musica de fundo e toca em loop infinito.
musicaBg = audio.loadStream ("Sons/BgMusic.mp3")
audio.play (musicaBg, {loops = -1, channel = 1})

--Efetua a chamada da storyboard
local storyboard = require ("storyboard")
--Limpa as cenas e as remove nas transições.
storyboard.purgeOnSceneChange = true

--Faz a troca de cena utilizando um efeito de fade
storyboard.gotoScene ("menu", {effect = "fade"})